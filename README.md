# Personal Docker Compose Collection

A curated collection of Docker Compose configurations for commonly used services, optimized for development and personal use with NVIDIA GPU support.

## Services Included

### 🤖 AI/LLM Services
- **Ollama** - Local LLM server (official image)
- **Ollama37** - Custom Ollama build with additional features
- **Open WebUI** - Web interface for interacting with LLMs

### 🖥️ Desktop Environments
- **Webtop** - Browser-accessible Linux desktops
  - Firefox on Ubuntu KDE
  - Chrome on Debian XFCE

### 📝 Web Applications
- **WordPress** - Complete WordPress stack with MySQL database

## Quick Start

1. **Prerequisites**
   - Docker and Docker Compose installed
   - NVIDIA Container Runtime (for GPU-accelerated services)

2. **Running a Service**
   ```bash
   cd <service-directory>
   docker-compose up -d
   ```

3. **Access Services**
   - Ollama: `http://localhost:11434`
   - Open WebUI: `http://localhost:8080`
   - Webtop Firefox: `http://localhost:3000`
   - Webtop Chrome: `http://localhost:3001`
   - WordPress: `http://localhost:80`

## Service Details

| Service | Port | GPU Support | Description |
|---------|------|-------------|-------------|
| Ollama | 11434 | ✅ | Official Ollama LLM server |
| Ollama37 | 11434 | ✅ | Custom Ollama build |
| Open WebUI | 8080 | ✅ | LLM web interface |
| Webtop Firefox | 3000 | ✅ | Ubuntu KDE desktop |
| Webtop Chrome | 3001 | ✅ | Debian XFCE desktop |
| WordPress | 80 | ❌ | WordPress + MySQL |

## Configuration

All services are configured with:
- **Timezone**: Asia/Taipei
- **Restart Policy**: unless-stopped (except WordPress: always)
- **Persistent Storage**: Local volumes in each service directory
- **NVIDIA Runtime**: Enabled for GPU acceleration where applicable

## Common Commands

```bash
# Start service in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop service
docker-compose down

# Rebuild and restart
docker-compose up -d --build

# Remove volumes (careful!)
docker-compose down -v
```

## Storage

Each service uses local volumes that persist data:
- Configuration files
- User data
- Application state

Volume directories are automatically created and are excluded from version control.

## Notes

- Services are designed to run independently
- GPU services require NVIDIA drivers and Container Runtime
- Default credentials for WordPress MySQL are included in the compose file
- All services are configured for local development/personal use