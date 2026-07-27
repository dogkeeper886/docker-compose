#!/usr/bin/env bash
#
# Import community dashboards from grafana.com into a *running* Grafana.
#
# Why post-boot import instead of file provisioning: a dashboard owned by the
# file provider is read-only in the UI (Grafana refuses "Save" while
# allowUiUpdates is false). Importing over the HTTP API stores the dashboard in
# Grafana's own database, so it behaves like one you created by hand — fully
# editable, and it survives restarts via ./volume/grafana.
#
# WARNING: re-running OVERWRITES. Each import posts overwrite=true against a
# fixed uid, so any change you made to an imported dashboard in the UI is
# replaced by the pristine copy from grafana.com. Re-run to pick up a new
# dashboard ID or a newer upstream revision — not as a routine step. To keep a
# customised dashboard, save it under a new name (Dashboard settings -> Save As)
# so it no longer shares a uid with the imported original.
#
# Usage: ./import-dashboards.sh        (or: make import-dashboards)

set -euo pipefail

cd "$(dirname "$0")"

GRAFANA_URL="${GRAFANA_URL:-http://localhost:13000}"
GRAFANA_USER="${GRAFANA_USER:-admin}"
DATASOURCE_UID="${DATASOURCE_UID:-prometheus}"

# grafana.com dashboard IDs to import. See README.md for what each one covers.
DASHBOARDS=(
  1860   # Node Exporter Full  — host CPU / memory / disk / network
  14282  # Cadvisor exporter   — per-container CPU / memory / network
)

if [[ ! -f .env ]]; then
  echo "error: .env not found. Run: cp .env.example .env" >&2
  exit 1
fi

# Read the password without sourcing .env — base64 passwords may contain '='.
GRAFANA_PASSWORD="$(grep -E '^GF_SECURITY_ADMIN_PASSWORD=' .env | head -1 | cut -d= -f2-)"
# Strip CR, surrounding whitespace, and matching quotes. Compose unquotes .env
# values when it interpolates them, so leaving the quotes on here would send a
# different password than Grafana was started with — a silent 401.
GRAFANA_PASSWORD="${GRAFANA_PASSWORD%$'\r'}"
GRAFANA_PASSWORD="$(printf '%s' "${GRAFANA_PASSWORD}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
if [[ "${GRAFANA_PASSWORD}" == \"*\" || "${GRAFANA_PASSWORD}" == \'*\' ]]; then
  GRAFANA_PASSWORD="${GRAFANA_PASSWORD:1:${#GRAFANA_PASSWORD}-2}"
fi
if [[ -z "${GRAFANA_PASSWORD}" ]]; then
  echo "error: GF_SECURITY_ADMIN_PASSWORD is empty in .env" >&2
  exit 1
fi

# /api/health goes green before Grafana can actually service database writes:
# on a cold start it is still running migrations and provisioning dashboards,
# and its SQLite store returns SQLITE_BUSY under that load. Gate on an
# authenticated read instead, which exercises the same path an import needs.
READY_ATTEMPTS=90
READY_SLEEP=2
echo "Waiting for Grafana at ${GRAFANA_URL} ..."
for i in $(seq 1 ${READY_ATTEMPTS}); do
  code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 \
    -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" "${GRAFANA_URL}/api/org" || true)"

  case "${code}" in
    200)
      break
      ;;
    401|403)
      # Grafana is answering, so it is up — the credentials are simply wrong.
      # Retrying for three minutes would report this as a readiness timeout.
      echo "error: Grafana rejected the admin credentials (HTTP ${code})." >&2
      echo "GF_SECURITY_ADMIN_PASSWORD in .env must match the password Grafana" >&2
      echo "started with. Note that Grafana only applies that variable on FIRST" >&2
      echo "start; if the volume already existed, the old password still applies." >&2
      exit 1
      ;;
  esac

  if [[ $i -eq ${READY_ATTEMPTS} ]]; then
    echo "error: Grafana did not become ready for writes within $((READY_ATTEMPTS * READY_SLEEP))s" >&2
    echo "hint: check 'docker compose logs grafana'" >&2
    exit 1
  fi
  sleep ${READY_SLEEP}
done
echo "Grafana is ready."

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

for id in "${DASHBOARDS[@]}"; do
  echo ""
  echo "--- dashboard ${id} ---"

  if ! curl -sf --max-time 60 -o "${tmpdir}/${id}.json" \
      "https://grafana.com/api/dashboards/${id}/revisions/latest/download"; then
    echo "error: failed to download dashboard ${id} from grafana.com" >&2
    exit 1
  fi

  # Build the /api/dashboards/import payload. Community dashboards declare
  # their datasource either as an __inputs entry (must be answered at import
  # time) or as a datasource template variable (resolves to the default), so
  # fill in every __inputs entry and leave the rest alone.
  python3 - "${tmpdir}/${id}.json" "${DATASOURCE_UID}" "${tmpdir}/${id}.payload.json" <<'PY'
import json, sys

src, ds_uid, dst = sys.argv[1], sys.argv[2], sys.argv[3]
dash = json.load(open(src))

inputs = []
for item in dash.get("__inputs", []):
    if item.get("type") == "datasource":
        inputs.append({
            "name": item["name"],
            "type": "datasource",
            "pluginId": item.get("pluginId", "prometheus"),
            "value": ds_uid,
        })

# Grafana rejects an import that carries an id from another instance.
dash.pop("id", None)

json.dump({
    "dashboard": dash,
    "inputs": inputs,
    "overwrite": True,
    "folderId": 0,
}, open(dst, "w"))

print(f"  title: {dash.get('title')}")
print(f"  inputs answered: {[i['name'] for i in inputs] or 'none (uses default datasource)'}")
PY

  # Grafana's SQLite store returns SQLITE_BUSY while the dashboard provisioner
  # is writing, so a single POST can lose the race even once Grafana is ready.
  imported=""
  for attempt in 1 2 3 4 5; do
    # `|| true` is required: under `set -e` a bare assignment inherits curl's
    # exit status, so a connection reset or --max-time expiry would abort the
    # script here instead of falling through to the retry.
    response="$(curl -sS --max-time 60 -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
      -H "Content-Type: application/json" \
      -X POST "${GRAFANA_URL}/api/dashboards/import" \
      -d "@${tmpdir}/${id}.payload.json" 2>&1 || true)"

    if echo "${response}" | grep -q '"imported":true'; then
      imported="${response}"
      break
    fi

    echo "  attempt ${attempt}/5 failed: ${response}"
    sleep $((attempt * 5))
  done

  if [[ -z "${imported}" ]]; then
    echo "error: import of dashboard ${id} failed after 5 attempts" >&2
    exit 1
  fi

  url_path="$(echo "${imported}" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("importedUrl",""))')"
  echo "  imported: ${GRAFANA_URL}${url_path}"
done

echo ""
echo "Done. Imported dashboards are editable in the Grafana UI."
