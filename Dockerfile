# ------------------------ Stage 1: Builder ------------------------
FROM iredmail/mariadb:stable AS builder

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      wget ca-certificates git curl \
      build-essential pkg-config \
      libssl-dev libbz2-dev zlib1g-dev libcurl4-openssl-dev libxml2-dev \
      libjson-c-dev libre2-dev libpcre2-dev \
      libncurses-dev; \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && wget https://github.com/Kitware/CMake/releases/download/v3.27.9/cmake-3.27.9-linux-x86_64.sh \
 && bash cmake-3.27.9-linux-x86_64.sh --skip-license --prefix=/usr/local \
 && rm -f /tmp/cmake-3.27.9-linux-x86_64.sh

ENV RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo PATH=/opt/cargo/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain 1.81.0 \
 && rustc --version && cargo --version

ARG CLAMAV_TAG=clamav-1.4.3
RUN git clone --depth=1 --branch "${CLAMAV_TAG}" https://github.com/Cisco-Talos/clamav.git /tmp/clamav && \
    cmake -B /tmp/clamav/build -S /tmp/clamav \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D CMAKE_INSTALL_SYSCONFDIR=/etc \
      -D ENABLE_TESTS=OFF \
      -D ENABLE_MILTER=OFF \
      -D CMAKE_DISABLE_FIND_PACKAGE_Curses=ON && \
    cmake --build /tmp/clamav/build -j"$(nproc)" && \
    cmake --install /tmp/clamav/build && \
    rm -rf /tmp/clamav && ldconfig


# ------------------------ Stage 2: Runtime ------------------------
FROM iredmail/mariadb:stable AS runtime

RUN set -eux; apt-get update && apt-get install -y --no-install-recommends socat && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /usr/local/sbin/ /usr/local/sbin/
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/local/include/ /usr/local/include/

RUN ln -sf /usr/local/sbin/clamd    /usr/sbin/clamd && \
    ln -sf /usr/local/bin/clamscan  /usr/bin/clamscan && \
    ln -sf /usr/local/bin/freshclam /usr/bin/freshclam && \
    echo /usr/local/lib >/etc/ld.so.conf.d/clamav-local.conf && ldconfig && \
    mkdir -p /usr/local/etc && \
    ln -sf /etc/clamav/freshclam.conf /usr/local/etc/freshclam.conf && \
    ln -sf /etc/clamav/clamd.conf      /usr/local/etc/clamd.conf
