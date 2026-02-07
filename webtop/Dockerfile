FROM linuxserver/webtop:fedora-mate

# Install system packages (requires root)
RUN dnf update -y && \
    dnf install -y \
        glibc-langpack-en \
        bash-completion \
        gnome-terminal \
        gnome-tweaks \
        firefox \
        git \
        fuse \
        fuse-libs \
        gh \
        glab && \
    dnf clean all

# Clone and install San Francisco fonts
RUN git clone https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts.git /usr/share/fonts/San-Francisco-Pro-Fonts && \
    git clone https://github.com/supercomputra/SF-Mono-Font.git /usr/share/fonts/SF-Mono-Font && \
    fc-cache -fv

# Set UTF-8 locale environment variables
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
