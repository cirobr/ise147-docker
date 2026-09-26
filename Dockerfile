FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=America/Sao_Paulo

# universe is required for libncurses5 / libtinfo5 on Jammy
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates software-properties-common \
    && add-apt-repository universe \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libncurses5 \
        libncurses5:i386 \
        libncursesw5 \
        libncursesw5:i386 \
        libtinfo5 \
        libtinfo5:i386 \
        libstdc++5 \
        libstdc++6 \
        libstdc++6:i386 \
        libc6:i386 \
        zlib1g:i386 \
        libx11-6:i386 \
        libxext6:i386 \
        libxrender1:i386 \
        libxtst6:i386 \
        libxi6:i386 \
        libxft2:i386 \
        libsm6 libsm6:i386 \
        libice6 libice6:i386 \
        libgtk2.0-0 libgtk2.0-0:i386 \
        libmotif-dev \
        libpng16-16:i386 \
        libfreetype6:i386 \
        libfontconfig1:i386 \
        libglib2.0-0:i386 \
        xfonts-75dpi \
        xfonts-100dpi \
        fontconfig \
        xvfb \
        xauth \
        wget \
        ca-certificates \
        tar \
        gawk \
        make \
        gcc \
        locales \
        libusb-1.0-0 \
    && locale-gen en_US.UTF-8 \
    && ln -sf /usr/bin/make /usr/bin/gmake \
    && rm -rf /var/lib/apt/lists/*

# --- installer ---
# Option A: COPY the tarball (simple, large build context)
COPY Xilinx_ISE_DS_Lin_14.7_1015_1.tar /tmp/
COPY install_config.txt /tmp/install_config.txt

ENV TERM=xterm

RUN set -eux; \
    mkdir -p /tmp/ise-src; \
    tar -xf /tmp/Xilinx_ISE_DS_Lin_14.7_1015_1.tar -C /tmp/ise-src; \
    ISE_DIR="$(find /tmp/ise-src -maxdepth 2 -type d -name 'Xilinx_ISE_DS_Lin_14.7*' | head -1)"; \
    echo "ISE_DIR=$ISE_DIR"; \
    ls -la "$ISE_DIR/bin/lin64"; \
    cd "$ISE_DIR/bin/lin64"; \
    ./batchxsetup -batch /tmp/install_config.txt; \
    test -x /opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/ise; \
    rm -rf /tmp/Xilinx_ISE_DS_Lin_14.7_1015_1.tar /tmp/ise-src /tmp/install_config.txt

# ISE ships a stale libstdc++ that segfaults on modern glibc. Hide it.
RUN for d in \
        /opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64 \
        /opt/Xilinx/14.7/ISE_DS/common/lib/lin64; do \
      if [ -d "$d" ]; then \
        mkdir -p "$d/bak"; \
        mv "$d"/libstdc++.so* "$d/bak/" 2>/dev/null || true; \
      fi; \
    done

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
