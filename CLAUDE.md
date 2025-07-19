# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of Docker Compose configurations for various services, organized by service type in separate directories. Each directory contains a self-contained Docker Compose setup with its own volumes and configuration.

## Architecture

The repository follows a modular structure where each service is isolated in its own directory:

- `ollama/` - Ollama LLM service (official image) with NVIDIA runtime
- `ollama37/` - Ollama service using custom image (dogkeeper886/ollama37)
- `open-webui/` - Open WebUI interface for LLM interaction with CUDA support
- `webtop/` - Linux desktop environments (Firefox on KDE, Chrome on XFCE) accessible via web browser
- `wordpress/` - WordPress with MySQL database stack

All services are configured with:
- NVIDIA runtime for GPU acceleration where applicable
- Asia/Taipei timezone
- Persistent volumes for data storage
- Restart policies for reliability

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

## Service-Specific Information

### Port Mappings
- Ollama (both variants): 11434
- Open WebUI: 8080
- Webtop Firefox: 3000
- Webtop Chrome: 3001
- WordPress: 80

### Volume Management
Each service uses local volumes in its directory (e.g., `./volume`, `./volume-chrome`) which are excluded from git via `.gitignore`.

## Development Notes

- All services require Docker and Docker Compose
- NVIDIA services require NVIDIA Container Runtime
- Volume directories are automatically created by Docker Compose
- No build processes, linting, or testing - this is purely a Docker Compose orchestration repository