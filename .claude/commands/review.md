You are reviewing a Grafana dashboard JSON or Docker Compose configuration in this repository.

## Input

$ARGUMENTS

If no specific file is given, review all changed files in the current branch compared to main.

## Review Checklist

### Docker Compose
- [ ] Image tags: pinned version or `latest` with justification
- [ ] `restart: unless-stopped` set
- [ ] `TZ=Asia/Taipei` in environment
- [ ] Volumes use `./volume/` pattern and are in `.gitignore`
- [ ] No hardcoded IPs or secrets in committed files — use `.env` or target files
- [ ] `.example` file provided for any gitignored config
- [ ] Port mappings do not conflict with other services in the repo
- [ ] NVIDIA runtime configured where GPU is needed
- [ ] Health checks defined where applicable
- [ ] Healthcheck endpoint matches the service's real port **and** network mode — e.g. cAdvisor's `CADVISOR_HEALTHCHECK_URL` must use the `--port` value under `network_mode: host`, or the *container-internal* port (not the host-mapped port) under bridge networking; a mismatch flags the container `unhealthy` while `/metrics` still works
- [ ] `depends_on` set for service dependencies

### Grafana Dashboard JSON
- [ ] **Layout hierarchy**: stat panels at top, time series in middle, static/reference info at bottom (collapsed)
- [ ] **Template variables**: datasource variable (`DS_PROMETHEUS`) and instance/filter variables defined
- [ ] **Units**: every panel has an appropriate unit (percent, bytes, celsius, watt, MHz, etc.)
- [ ] **Thresholds**: stat and gauge panels have green/yellow/red thresholds
- [ ] **Legend format**: `{{label}}` used for readable series names
- [ ] **Grid positions**: no overlapping panels, logical row grouping
- [ ] **UID**: stable and descriptive (e.g., `nvidia-gpu-metrics`)
- [ ] **Tags**: relevant tags for dashboard search
- [ ] **Refresh interval**: appropriate for the use case (30s for operational)
- [ ] **No hardcoded datasource UIDs**: uses `${DS_PROMETHEUS}` variable

### Prometheus Config
- [ ] `file_sd_configs` used instead of hardcoded `static_configs` for external targets
- [ ] Target files are gitignored with `.example` committed
- [ ] Target files mounted into Prometheus container as read-only
- [ ] Scrape interval appropriate for the exporter
- [ ] Job name is descriptive and consistent with existing jobs

### Security
- [ ] No credentials, tokens, or IPs in committed files
- [ ] `.gitignore` updated for any new secret/config files
- [ ] Container privileges minimized (no unnecessary `privileged: true`)

## Output Format

```
## Summary
[What was reviewed]

## Findings
### ✅ Pass
- [Items that look good]

### ⚠️ Warnings
- [Non-blocking concerns]

### ❌ Issues
- [Must-fix items]

## Recommendation
[PASS / NEEDS CHANGES]
```
