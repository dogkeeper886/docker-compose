# Webtop

MATE desktop environment accessible via web browser, based on linuxserver/webtop:fedora-mate.

## Features

- NVIDIA GPU support
- San Francisco Pro and SF Mono fonts
- gnome-terminal, gnome-tweaks, bash-completion, firefox
- UTF-8 locale support

## Usage

```bash
make build   # Build the Docker image
make up      # Start the container
make down    # Stop the container
make logs    # Follow container logs
make help    # Show available commands
```

## Access

Open http://localhost:3001 in your browser.

## Font Configuration

Use gnome-tweaks to configure fonts:
- Interface Text: SF Pro Display Medium
- Document Text: SF Pro Text Medium
- Monospace Text: SF Mono Medium
