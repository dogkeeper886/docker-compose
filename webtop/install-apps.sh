#!/bin/bash
set -e

CONTAINER=${CONTAINER:-webtop-webtop-1}

echo "==> Ensuring /config/.local/bin is in PATH..."
docker exec -u abc "$CONTAINER" bash -c '
  mkdir -p /config/.local/bin
  if ! grep -q "/config/.local/bin" /config/.bashrc 2>/dev/null; then
    echo "export PATH=\"/config/.local/bin:\$PATH\"" >> /config/.bashrc
  fi
'

echo "==> Installing Cursor IDE..."
docker exec -u abc "$CONTAINER" bash -c '
  if [ -f /config/.local/bin/cursor ]; then
    echo "Cursor already installed, skipping."
    exit 0
  fi
  echo "Downloading Cursor AppImage..."
  curl -L "https://download.todesktop.com/230313mzl4w4u92/cursor-0.44.11-build-250103fqxdt5u9z-x86_64.AppImage" -o /tmp/cursor.AppImage
  chmod +x /tmp/cursor.AppImage
  echo "Extracting Cursor..."
  cd /tmp && /tmp/cursor.AppImage --appimage-extract
  mkdir -p /config/.local/cursor
  mv /tmp/squashfs-root/* /config/.local/cursor/
  rm -rf /tmp/squashfs-root /tmp/cursor.AppImage
  mkdir -p /config/.local/bin /config/.cache/dconf /config/.pki/nssdb
  printf "#!/bin/bash\nexec /config/.local/cursor/cursor --no-sandbox \"\$@\"\n" > /config/.local/bin/cursor
  chmod +x /config/.local/bin/cursor
  mkdir -p /config/.local/share/applications
  cat > /config/.local/share/applications/cursor.desktop << DESKTOP
[Desktop Entry]
Name=Cursor
Comment=Cursor IDE
Exec=/config/.local/cursor/cursor --no-sandbox %F
Icon=/config/.local/cursor/cursor.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=Cursor
DESKTOP
  chmod +x /config/.local/share/applications/cursor.desktop
  echo "Cursor installed successfully."
'

echo "==> Installing Zed editor..."
docker exec -u abc "$CONTAINER" bash -c '
  if [ -f /config/.local/bin/zed ]; then
    echo "Zed already installed, skipping."
    exit 0
  fi
  curl -f https://zed.dev/install.sh | sh
  echo "Zed installed successfully."
'

echo "==> Installing Claude Code CLI..."
docker exec -u abc "$CONTAINER" bash -c '
  if [ -f /config/.local/bin/claude ]; then
    echo "Claude Code already installed, skipping."
    exit 0
  fi
  curl -fsSL https://claude.ai/install.sh | bash
  echo "Claude Code installed successfully."
'

echo "==> All apps installed."
