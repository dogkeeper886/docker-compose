# Webtop

MATE desktop environment accessible via web browser, based on `linuxserver/webtop:el-mate`
(Enterprise Linux 9 / Rocky family).

## Features

- Cursor, Zed, and Claude Code CLI pre-installed system-wide
- gnome-terminal, gnome-tweaks, bash-completion, firefox, gh, git
- San Francisco Pro and SF Mono fonts, set as default with macOS-style rendering
- UTF-8 locale, optional NVIDIA GPU runtime

## Usage

```bash
make help    # Show available commands
make build   # Build the Docker image
make up      # Start the container in detached mode
make down    # Stop the container
make logs    # Follow container logs
```

## Access

Open https://localhost:3000 in your browser (or whichever port `WEBTOP_PORT` is set to in `.env`).

HTTP Basic auth is enabled by default. Configure credentials in `.env`:
- **Username:** `CUSTOM_USER` (default: `abc`)
- **Password:** `PASSWORD`

## Notes

The base image is `el-mate` rather than `fedora-mate` because Fedora 44 ships Mesa 26, which
has an LLVM JIT bug that crashes Zed's software shader compiler. EL 9 ships Mesa 25, which
is unaffected (no GPU passthrough required).
