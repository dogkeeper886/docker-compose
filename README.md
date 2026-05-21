# Personal Docker Compose Collection

A set of self-contained Docker Compose stacks I run for personal and development use — LLM serving, browser-based desktops, a monitoring stack, and a couple of dev tools. Services that can use a GPU are wired for NVIDIA acceleration.

## Services Included

### 🤖 AI / LLM

- **Ollama** — local LLM server (official image)
- **Ollama37** — a custom Ollama build with extra features
- **Open WebUI** — browser front-end for chatting with your models

### 🖥️ Desktops

- **Webtop** — full Linux desktops you reach from a browser
  - Firefox on Ubuntu KDE
  - Chrome on Debian XFCE

### 📊 Monitoring

- **Monitoring** — Prometheus + Grafana, with Node Exporter, cAdvisor and a Libvirt exporter bundled in
- **Host Exporters** — Node Exporter + cAdvisor on their own, for a host scraped by a Prometheus running elsewhere
- **GPU Exporter** — NVIDIA GPU metrics
- **Ollama Exporter** — VRAM used by each loaded Ollama model

### 🛠️ Developer Tools

- **GitLab** — self-hosted GitLab CE (web + SSH)
- **MCP Atlassian** — MCP server bridging Jira and Confluence

## Quick Start

Every service lives in its own directory and starts the same way:

```bash
cd <service-directory>
docker-compose up -d
```

You'll need Docker and Docker Compose installed. GPU-accelerated services also need the NVIDIA Container Runtime. Once a service is up, reach it at `http://localhost:<port>` using the ports below.

## Services & Ports

| Service | Port | GPU | Description |
|---------|------|-----|-------------|
| Ollama | 11434 | ✅ | Official Ollama LLM server |
| Ollama37 | 11434 | ✅ | Custom Ollama build |
| Open WebUI | 8080 | ✅ | LLM web interface |
| Webtop Firefox | 3000 | ✅ | Ubuntu KDE desktop |
| Webtop Chrome | 3001 | ✅ | Debian XFCE desktop |
| Grafana | 13000 | ❌ | Monitoring dashboard UI |
| Prometheus | 19090 | ❌ | Time-series database |
| GPU Exporter | 9835 | ❌ | NVIDIA GPU metrics exporter |
| Ollama Exporter | 9836 | ❌ | Ollama loaded-model metrics |
| Host Exporters | 9100 / 8081 | ❌ | Standalone Node Exporter + cAdvisor |
| GitLab | 8929 / 2222 | ❌ | Self-hosted GitLab CE (web / SSH) |
| MCP Atlassian | 9000 | ❌ | Atlassian MCP server |

## Common Commands

```bash
# Start a service in the background
docker-compose up -d

# Follow the logs
docker-compose logs -f

# Stop it
docker-compose down

# Rebuild and restart
docker-compose up -d --build

# Stop and wipe its volumes (careful!)
docker-compose down -v
```

## Conventions

Every stack follows the same handful of conventions:

- **Timezone** — `Asia/Taipei` on all containers
- **Restart policy** — `unless-stopped`
- **Storage** — each service keeps its data in local `./volume` directories, created automatically and excluded from git
- **GPU** — the NVIDIA runtime is enabled wherever a service can use it (needs host drivers and the Container Runtime)

The stacks are independent, so run only the ones you need.
