# Monitoring Stack

Prometheus + Grafana monitoring stack for KVM/Docker hosts.

## Services

| Service | Port | Description |
|---------|------|-------------|
| Grafana | 13000 | Dashboard UI |
| Prometheus | 19090 | Time-series database |
| Node Exporter | 19100 | Host system metrics |
| cAdvisor | 18081 | Docker container metrics |
| Libvirt Exporter | 19177 | KVM/QEMU VM metrics |

## Quick Start

```bash
# First-time setup (creates volumes with correct permissions)
make setup

# Start all services
make up
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
| `make clean` | Stop services and remove volumes |

## Access

- **Grafana**: http://localhost:13000
  - Default login: `admin` / `admin`
- **Prometheus**: http://localhost:19090

## Grafana Setup

1. Add Prometheus data source:
   - URL: `http://prometheus:9090`

2. Import recommended dashboards:
   - **Node Exporter Full**: ID `1860`
   - **Docker/cAdvisor**: ID `14282`
   - **Libvirt VMs**: Import from `libvirt-dashboard-v2.json` (recommended)

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

## Technical Notes

### cAdvisor Configuration

This stack uses `gcr.io/cadvisor/cadvisor:v0.51.0` for container metrics collection.

> **Note for btrfs users**: If you encounter `failed to identify the read-write layer ID` errors with Docker's containerd-snapshotter, use `docker-compose-btrfs.yml` which includes cAdvisor v0.55.1 with containerd-snapshotter support and optimized metric collection.

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
