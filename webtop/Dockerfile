FROM linuxserver/webtop:el-mate

# System packages. Rocky/RHEL 9 base ships stable Mesa 25 — Fedora 44's
# Mesa 26 has an LLVM JIT bug that crashes Zed's shader compiler (no GPU passthrough).
RUN dnf install -y \
        bash-completion \
        curl \
        firefox \
        fuse \
        fuse-libs \
        gh \
        git \
        glibc-langpack-en \
        gnome-terminal \
        gnome-tweaks \
        tar \
        xdg-utils && \
    dnf clean all

# San Francisco fonts (pinned commits for reproducibility)
ARG SF_PRO_COMMIT=8bfea09aa6f1139479f80358b2e1e5c6dc991a58
ARG SF_MONO_COMMIT=1409ae79074d204c284507fef9e479248d5367c1
RUN git clone https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts.git /usr/share/fonts/San-Francisco-Pro-Fonts && \
    git -C /usr/share/fonts/San-Francisco-Pro-Fonts checkout "$SF_PRO_COMMIT" && \
    git clone https://github.com/supercomputra/SF-Mono-Font.git /usr/share/fonts/SF-Mono-Font && \
    git -C /usr/share/fonts/SF-Mono-Font checkout "$SF_MONO_COMMIT" && \
    fc-cache -fv

# Cursor IDE — extracted because AppImage needs FUSE+sandbox, which containers lack.
ARG CURSOR_VERSION=0.44.11
ARG CURSOR_BUILD=250103fqxdt5u9z
RUN curl -fL "https://download.todesktop.com/230313mzl4w4u92/cursor-${CURSOR_VERSION}-build-${CURSOR_BUILD}-x86_64.AppImage" -o /tmp/cursor.AppImage && \
    chmod +x /tmp/cursor.AppImage && \
    cd /tmp && /tmp/cursor.AppImage --appimage-extract && \
    mkdir -p /opt/cursor && \
    mv /tmp/squashfs-root/* /opt/cursor/ && \
    rm -rf /tmp/squashfs-root /tmp/cursor.AppImage && \
    chmod -R go+rX /opt/cursor && \
    printf '#!/bin/bash\nexec /opt/cursor/cursor --no-sandbox "$@"\n' > /usr/local/bin/cursor && \
    chmod +x /usr/local/bin/cursor

# MimeType=x-scheme-handler/cursor registers cursor:// for the sign-in OAuth callback.
RUN cat > /usr/share/applications/cursor.desktop <<'EOF'
[Desktop Entry]
Name=Cursor
Comment=Cursor IDE
Exec=/usr/local/bin/cursor %U
Icon=/opt/cursor/cursor.png
Terminal=false
Type=Application
Categories=Development;IDE;
MimeType=x-scheme-handler/cursor;
StartupWMClass=Cursor
EOF

# Zed editor
ARG ZED_VERSION=1.1.6
RUN curl -fL "https://github.com/zed-industries/zed/releases/download/v${ZED_VERSION}/zed-linux-x86_64.tar.gz" -o /tmp/zed.tar.gz && \
    tar -xzf /tmp/zed.tar.gz -C /opt && \
    rm /tmp/zed.tar.gz && \
    chown -R 911:911 /opt/zed.app && \
    ln -sf /opt/zed.app/bin/zed /usr/local/bin/zed && \
    ln -sf /opt/zed.app/share/applications/dev.zed.Zed.desktop /usr/share/applications/dev.zed.Zed.desktop

# Claude Code CLI — installer hardcodes $HOME/.local/{bin,share}, so install
# under /opt/claude and symlink the binary into /usr/local/bin.
RUN mkdir -p /opt/claude && \
    HOME=/opt/claude bash -c 'curl -fsSL https://claude.ai/install.sh | bash' && \
    ln -sf /opt/claude/.local/bin/claude /usr/local/bin/claude

# macOS-style font + rendering defaults. Family names without weight suffix
# because fontconfig parses "SF Pro Display Medium" as family rather than
# family+weight, which falls back to DejaVu.
RUN cat > /usr/share/glib-2.0/schemas/90-mac-fonts.gschema.override <<'EOF'
[org.mate.interface]
font-name='SF Pro Display 11'
monospace-font-name='SF Mono 11'
document-font-name='SF Pro Text 11'

[org.mate.Marco.general]
titlebar-font='SF Pro Display Bold 11'

[org.mate.font-rendering]
antialiasing='rgba'
hinting='slight'

[org.gnome.desktop.interface]
font-name='SF Pro Display 11'
monospace-font-name='SF Mono 11'
document-font-name='SF Pro Text 11'
font-antialiasing='rgba'
font-hinting='slight'

[org.gnome.desktop.wm.preferences]
titlebar-font='SF Pro Display Bold 11'
EOF
RUN glib-compile-schemas /usr/share/glib-2.0/schemas/

# Per-container init: fix /config/.cache/dconf ownership (linuxserver init creates
# it as root which prevents abc's dconf-service from compiling the cache, breaking
# settings reads) and seed Zed defaults so it doesn't nag about failed auto-updates.
RUN mkdir -p /custom-cont-init.d && \
    cat > /custom-cont-init.d/30-webtop-fixups <<'EOF'
#!/usr/bin/with-contenv bash
mkdir -p /config/.cache/dconf /config/.config/zed
chown -R abc:abc /config/.cache /config/.config/zed
if [ ! -f /config/.config/zed/settings.json ]; then
  cat > /config/.config/zed/settings.json <<'JSON'
{
  "auto_update": false
}
JSON
  chown abc:abc /config/.config/zed/settings.json
fi
EOF
RUN chmod +x /custom-cont-init.d/30-webtop-fixups

# Refresh desktop/MIME databases so the new entries (incl. cursor:// scheme) are picked up.
RUN update-desktop-database /usr/share/applications && \
    update-mime-database /usr/share/mime 2>/dev/null || true

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
