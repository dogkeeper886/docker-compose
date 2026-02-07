FROM linuxserver/webtop:fedora-mate

# Install glibc-langpack for UTF-8 locale support, then install desired packages
RUN dnf update -y && \
    dnf install -y \
        glibc-langpack-en \
        bash-completion \
        gnome-terminal \
        gnome-tweaks \
        firefox \
        git \
        fuse \
        fuse-libs && \
    dnf clean all

# Install Cursor IDE (pinned to v0.44.11 — update URL when upgrading)
RUN curl -L "https://download.todesktop.com/230313mzl4w4u92/cursor-0.44.11-build-250103fqxdt5u9z-x86_64.AppImage" -o /tmp/cursor.AppImage && \
    chmod +x /tmp/cursor.AppImage && \
    cd /opt && /tmp/cursor.AppImage --appimage-extract && \
    mv squashfs-root cursor && \
    ln -s /opt/cursor/cursor /usr/local/bin/cursor && \
    rm /tmp/cursor.AppImage

# Create desktop entry for Cursor
RUN mkdir -p /usr/share/applications && \
    printf '%s\n' \
        '[Desktop Entry]' \
        'Name=Cursor' \
        'Exec=/opt/cursor/cursor --no-sandbox %F' \
        'Terminal=false' \
        'Type=Application' \
        'Icon=/opt/cursor/usr/share/icons/hicolor/256x256/apps/cursor.png' \
        'Categories=Development;IDE;' \
        'MimeType=text/plain;inode/directory;' \
        'StartupNotify=true' \
        'StartupWMClass=Cursor' \
    > /usr/share/applications/cursor.desktop && \
    chmod +x /usr/share/applications/cursor.desktop

# Create desktop shortcut for Cursor (on user's desktop)
RUN mkdir -p /etc/skel/Desktop && \
    cp /usr/share/applications/cursor.desktop /etc/skel/Desktop/ && \
    chmod +x /etc/skel/Desktop/cursor.desktop

# Install Claude Code CLI and make it accessible to all users (webtop runs as abc user)
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    ln -s /root/.local/bin/claude /usr/local/bin/claude

# Clone and install San Francisco fonts
RUN git clone https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts.git /usr/share/fonts/San-Francisco-Pro-Fonts && \
    git clone https://github.com/supercomputra/SF-Mono-Font.git /usr/share/fonts/SF-Mono-Font && \
    fc-cache -fv

# Set UTF-8 locale environment variables
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
