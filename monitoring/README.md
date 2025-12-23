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
docker-compose up -d
```

## Access

- **Grafana**: http://localhost:13000
  - Default login: `admin` / `admin`
- **Prometheus**: http://localhost:19090

## Grafana Setup

1. Add Prometheus data source:
   - URL: `http://prometheus:9090`

2. Import recommended dashboards:
   - Node Exporter Full: `1860`
   - Docker/cAdvisor: `14282`
   - Libvirt: `12177`

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
