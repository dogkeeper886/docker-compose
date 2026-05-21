# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of Docker Compose configurations for various services, organized by service type in separate directories. Each directory is an independent stack with its own volumes and configuration — with one exception: the monitoring stack in `monitoring/` scrapes the standalone exporters (`host-exporters/`, `gpu-exporter/`, `ollama-exporter/`) rather than bundling them, so those pieces are designed to work together.

## Architecture

The repository follows a modular structure where each service is isolated in its own directory:

- `ollama/` - Ollama LLM service (official image) with NVIDIA runtime
- `ollama37/` - Ollama service using custom image (dogkeeper886/ollama37)
- `open-webui/` - Open WebUI interface for LLM interaction with CUDA support
- `webtop/` - Linux desktop environments (Firefox on KDE, Chrome on XFCE) accessible via web browser
- `monitoring/` - Prometheus + Grafana stack (node-exporter, cAdvisor, libvirt-exporter); `docker-compose-btrfs.yml` variant for btrfs hosts
- `host-exporters/` - Standalone node-exporter + cAdvisor for a host scraped by a remote Prometheus
- `gpu-exporter/` - NVIDIA GPU metrics exporter (nvidia_gpu_exporter), scraped by the monitoring stack
- `ollama-exporter/` - Custom exporter for Ollama loaded-model VRAM metrics
- `gitlab/` - Self-hosted GitLab CE
- `mcp-atlassian/` - MCP server for Atlassian (Jira/Confluence)

## Common Commands

### Starting Services
Navigate to the specific service directory and run:
```bash
cd <service-directory>
docker-compose up -d
```

### Stopping Services
```bash
cd <service-directory>
docker-compose down
```

### Viewing Logs
```bash
cd <service-directory>
docker-compose logs -f
```

### Rebuilding Services
```bash
cd <service-directory>
docker-compose up -d --build
```

### Makefile-Driven Stacks
`monitoring/` and `gpu-exporter/` ship Makefiles — prefer them over raw `docker compose`:
```bash
make setup    # one-time: create volumes with correct UID permissions (monitoring/)
make up       # start the stack
make down     # stop it
make logs     # follow logs
```

## Service-Specific Information

### Port Mappings
- Ollama (both variants): 11434
- Open WebUI: 8080
- Webtop Firefox: 3000
- Webtop Chrome: 3001
- Grafana: 13000
- Prometheus: 19090
- Monitoring node-exporter / cAdvisor / libvirt-exporter: 19100 / 18081 / 19177
- host-exporters node-exporter / cAdvisor: 9100 / 8081
- GPU Exporter: 9835
- Ollama Exporter: 9836
- GitLab web / SSH: 8929 / 2222
- MCP Atlassian: 9000

### Volume Management
Each service uses local volumes in its directory (e.g., `./volume`, `./volume-chrome`) which are excluded from git via `.gitignore`.

## Conventions for New or Edited Services

Follow the existing patterns — the `/design` and `/review` skills encode them:

- **Timezone** — set `TZ=Asia/Taipei` on every container.
- **Restart policy** — `restart: unless-stopped`.
- **Image tags** — pin a version, or use `latest` only with a reason.
- **Volumes** — persist data under `./volume/` in the service directory; keep it gitignored.
- **Secrets & IPs** — never commit them. Put them in `.env` or a target file (e.g. `exporter-targets.yml`), gitignore it, and commit a `.example` alongside.
- **Ports** — check the Port Mappings list above for conflicts before assigning a new one.
- **GPU** — add the NVIDIA runtime only where the service actually uses the GPU.

Run `/design` when creating a dashboard or service, and `/review` before committing compose, dashboard, or Prometheus changes.

## Gotchas

- **cAdvisor healthcheck URL must match the container's port _and_ network mode.** The image's healthcheck reads `$CADVISOR_HEALTHCHECK_URL`; if it's unset or points at the wrong port, the container is flagged `unhealthy` even though `/metrics` works. Under host networking use the `--port` value; under bridge networking use the *container-internal* port, not the host-mapped one. Per-file values are in `monitoring/README.md`.
- **Monitoring volume permissions.** Prometheus runs as UID `65534`, Grafana as UID `472`. The `volume/` directories must be owned accordingly or the containers fail to start — run `make setup` (or `make fix-permissions`) in `monitoring/` first.
- **External exporters use file-based discovery.** `prometheus.yml` finds GPU/Ollama targets in `exporter-targets.yml` (gitignored; copy `exporter-targets.example.yml`), filtered by an `exporter:` label via relabel keep/drop rules — don't convert these to hardcoded `static_configs`.
- **btrfs hosts.** Use `monitoring/docker-compose-btrfs.yml` if you hit `failed to identify the read-write layer ID` errors; it's the same cAdvisor image with different networking and metric flags.

## Project Skills

This project provides two slash commands in `.claude/commands/`:

- `/design` — Design a new Grafana dashboard or Docker Compose service. Applies the inverted pyramid layout for dashboards (stat panels at top, reference info collapsed at bottom) and repo conventions for services.
- `/review` — Review dashboard JSON, Docker Compose config, or Prometheus config against a checklist covering layout hierarchy, security (no hardcoded IPs/secrets), port conflicts, thresholds, template variables, and gitignore hygiene.

## Development Notes

- All services require Docker and Docker Compose
- NVIDIA services require NVIDIA Container Runtime
- Volume directories are automatically created by Docker Compose
- No build processes, linting, or testing - this is purely a Docker Compose orchestration repository