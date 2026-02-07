# Webtop

MATE desktop environment accessible via web browser, based on linuxserver/webtop:fedora-mate.

## Features

- NVIDIA GPU support
- San Francisco Pro and SF Mono fonts
- gnome-terminal, gnome-tweaks, bash-completion, firefox
- UTF-8 locale support

## Usage

```bash
make help           # Show available commands
make build          # Build the Docker image
make up             # Start the container in detached mode
make down           # Stop the container
make logs           # Follow container logs
make setup          # Full setup: build, start, install apps
make install-apps   # Install custom apps (Cursor, Zed, Claude) into running container
```

## Access

Open https://localhost:3001 in your browser.

HTTP Basic auth is enabled by default. Configure credentials in `.env`:
- **Username:** `CUSTOM_USER` (default: `abc`)
- **Password:** `PASSWORD`

## Font Configuration

Use gnome-tweaks to configure fonts:
- Interface Text: SF Pro Display Medium
- Document Text: SF Pro Text Medium
- Monospace Text: SF Mono Medium
