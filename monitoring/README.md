# Monitoring Stack

A Prometheus and Grafana stack for monitoring KVM and Docker hosts.

## Services

| Service | Port | Description |
|---------|------|-------------|
| Grafana | 13000 | Dashboard UI |
| Prometheus | 19090 | Time-series database |
| Node Exporter | 19100 | Host system metrics |
| cAdvisor | 18081 | Docker container metrics |
| Libvirt Exporter | 19177 | KVM/QEMU VM metrics |

### External Exporters

These live in their own directories and are scraped by Prometheus through `exporter-targets.yml`:

| Exporter | Default Port | Description |
|----------|------|-------------|
| GPU Exporter (`gpu-exporter/`) | 9835 | NVIDIA GPU metrics (utilization, memory, temperature, power, clocks) |
| Ollama Exporter (`ollama-exporter/`) | 9836 | Ollama loaded model VRAM usage with model details |

## Quick Start

```bash
# Copy environment and target files
cp .env.example .env
cp exporter-targets.example.yml exporter-targets.yml

# Edit exporter-targets.yml with your actual exporter host IPs
# Edit .env with your Grafana admin password

# First-time setup (creates volumes with correct permissions)
make setup

# Start all services
make up

# Import the community dashboards (needs Grafana running)
make import-dashboards
```

Or manually:

```bash
# Create volume directories with correct permissions
mkdir -p volume/prometheus volume/grafana
sudo chown -R 65534:65534 volume/prometheus  # Prometheus runs as nobody (UID 65534)
sudo chown -R 472:472 volume/grafana          # Grafana runs as grafana (UID 472)

# Start services
docker compose up -d
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make setup` | Create volume directories with correct permissions |
| `make up` | Start all services |
| `make down` | Stop all services |
| `make restart` | Restart all services |
| `make logs` | Show logs (follow mode) |
| `make ps` | Show service status |
| `make fix-permissions` | Fix volume directory permissions |
| `make seed-dashboards` | Copy this repo's dashboards into the Grafana volume |
| `make import-dashboards` | Import community dashboards into a running Grafana |
| `make clean` | Stop services and remove volumes |

## Grafana Setup

Open Grafana at http://localhost:13000 and log in as `admin` (password from your `.env`). Prometheus lives at http://localhost:19090.

The Prometheus data source is **provisioned automatically** from `provisioning/datasources/prometheus.yml` (uid `prometheus`, `http://prometheus:9090`, set as default) — no manual step.

> **Upgrading an existing install?** Earlier versions of this README told you to add the data source by hand, which gave it a random uid. Provisioning matches by *name*, so a hand-made data source called `Prometheus` gets its uid rewritten to `prometheus` on the next `make up` — and any dashboard already stored in Grafana that references the old uid renders as *"Datasource &lt;uid&gt; was not found"*. Fix by re-selecting the data source on the affected panels, or by renaming your old one before starting. Fresh installs are unaffected.

### Two ways dashboards get in

Dashboards arrive by one of two paths, and the difference matters:

| Path | Command | Where it lives | Editable in the UI? |
|------|---------|----------------|---------------------|
| **Seeded** (file provider) | `make seed-dashboards` (runs in `make setup`) | `volume/grafana/dashboards/*.json` | **No** — `allowUiUpdates: false` in `provisioning/dashboards/dashboards.yml` makes Grafana refuse "Save". Edit the JSON file instead; the provider reloads it every ~30s. |
| **Imported** (HTTP API) | `make import-dashboards` | Grafana's own database, inside `volume/grafana` | **Yes** — behaves like a dashboard you built by hand. |

Import is the right path for community dashboards you expect to tweak. Seeding is the right path for dashboards this repo owns and versions in git.

### Dashboards

Imported from grafana.com by `make import-dashboards` (see the `DASHBOARDS` array in `import-dashboards.sh` to add more):

- **Node Exporter Full** — ID `1860`. Host CPU, memory, disk, filesystem, network, load.
- **Cadvisor exporter** — ID `14282`. Per-container CPU, memory, and network.

Seeded from `provisioning/dashboards/` by `make setup`:

- **NVIDIA GPU Metrics** — `nvidia-gpu.json`
- **OPNsense (FreeBSD)** — `opnsense.json` — a Node Exporter Full clone with memory widgets remapped to FreeBSD metrics (`node_memory_active/wired/size_bytes`); select the router via the `node` variable

Manual import, kept in this directory for reference:

- **Libvirt VMs** — import `libvirt-dashboard-v2.json` (recommended over `libvirt-dashboard.json`)

> Seeded dashboards are copied **into the Grafana volume**, not mounted read-only into the container — a per-file `:ro` mount makes them impossible to edit once the container is up. The source copies live in `provisioning/dashboards/`; re-run `make seed-dashboards` to refresh the volume from them.

### Libvirt Dashboard (v2)

The `libvirt-dashboard-v2.json` is a streamlined dashboard for KVM/libvirt monitoring:

| Row | Panels |
|-----|--------|
| Overview | VM Status Table, Running VMs, Total vCPUs, Total Memory, Avg Memory % |
| CPU | CPU Usage Rate, vCPU Time |
| Memory | Memory Usage %, Available vs Used, Balloon & Cache, Page Faults |
| Disk I/O | Throughput, IOPS, I/O Time, Capacity vs Used |
| Network | Throughput, Packets, Errors, Drops |

**Features:**
- 19 panels (simplified from 37 in v1)
- Hardcoded `Prometheus` datasource (no configuration needed)
- 2 template variables: `$instance` and `$domain`
- Uses all metrics from `alekseizakharov/libvirt-exporter`

> **Note**: The original `libvirt-dashboard.json` (based on Grafana ID 13633) is kept for reference but requires manual datasource configuration.

### NVIDIA GPU Dashboard

The `nvidia-gpu.json` is auto-provisioned and displays:

| Row | Panels |
|-----|--------|
| Stats | GPU Utilization %, Memory Used, Max Temperature, Total Power Draw |
| Timeseries | GPU Utilization, Memory Utilization, Temperature, Power Draw, GPU Clock, Memory Clock |
| Ollama | Loaded Models VRAM usage (stacked, with model/params/quantization in tooltip) |
| Reference | GPU Info table (collapsed) |

**Features:**
- Template variables: `$DS_PROMETHEUS` (datasource), `$uuid` (GPU filter)
- External targets configured via `exporter-targets.yml` (gitignored)
- Copy `exporter-targets.example.yml` and set your exporter host IPs

## Collected Metrics

### Host (Node Exporter)
- CPU, memory, disk, network
- Filesystem usage
- System load

### Docker (cAdvisor)
- Per-container CPU/memory
- Container network I/O
- Container disk I/O

### KVM (Libvirt Exporter)
- VM state (running/stopped)
- Per-VM CPU usage
- Per-VM memory allocation
- Per-VM disk/network I/O

### NVIDIA GPU (GPU Exporter)
- GPU utilization, memory utilization
- Temperature, power draw
- Graphics and memory clock speeds
- GPU info labels (name, driver version, etc.)

### Ollama (Ollama Exporter)
- `ollama_model_vram_bytes` — VRAM per loaded model
- Labels: model name, parameter size, quantization level, context length

## Technical Notes

### cAdvisor Configuration

This stack uses `ghcr.io/google/cadvisor:0.55.1` for container metrics collection.

> **Note for btrfs users**: If you encounter `failed to identify the read-write layer ID` errors with Docker's containerd-snapshotter, use `docker-compose-btrfs.yml`. It runs the same cAdvisor image with a configuration tuned for that setup (bridge networking and adjusted metric flags).

> **⚠️ cAdvisor healthcheck URL must match the container's port AND network mode.** The cAdvisor image's built-in healthcheck runs `wget --spider $CADVISOR_HEALTHCHECK_URL` *inside* the container. If `CADVISOR_HEALTHCHECK_URL` is unset or points at the wrong port, the container is flagged `unhealthy` even though `/metrics` works fine. The correct value depends on the setup — there is **no single global value**:
>
> | Setup | cAdvisor port | Correct `CADVISOR_HEALTHCHECK_URL` |
> |-------|---------------|------------------------------------|
> | `docker-compose.yml` (host networking) | `--port=18081` | `http://localhost:18081/healthz` |
> | `host-exporters/` (host networking) | `--port=8081` | `http://localhost:8081/healthz` |
> | `docker-compose-btrfs.yml` (bridge, `18081:8080`) | default `8080` | `http://localhost:8080/healthz` |
>
> Under **host networking**, use the `--port` value. Under **bridge networking**, the healthcheck runs in the container's own namespace, so it must use the *container-internal* port (`8080`) — **not** the host-mapped port (`18081`). The `docker-compose-btrfs.yml` variant currently omits this variable and is therefore flagged `unhealthy` (metrics still flow); set it to `http://localhost:8080/healthz` if you use that variant.

### Libvirt Exporter

Uses `alekseizakharov/libvirt-exporter` which requires:
- Privileged mode for libvirt socket access
- Read-only mount of `/var/run/libvirt`

## Troubleshooting

### Permission Denied Errors

If you see errors like:
- `open /prometheus/queries.active: permission denied`
- `GF_PATHS_DATA='/var/lib/grafana' is not writable`

Run:
```bash
make fix-permissions
make restart
```

### cAdvisor Errors

If you see `failed to identify the read-write layer ID` errors (common on btrfs with containerd-snapshotter), switch to the btrfs-optimized configuration:

```bash
docker compose -f docker-compose-btrfs.yml up -d
```

If you see `Cannot read smaps files` warnings, these are harmless with cgroups v2.
