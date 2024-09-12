FROM ubuntu:noble-20240801 AS base-builder
WORKDIR /opt/build
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt install -y --no-install-recommends ca-certificates
apt update --snapshot=20240801T030400Z
EOF

###############################################################################

FROM base-builder AS c-builder
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends \
    build-essential \
    gcc-12-riscv64-linux-gnu \
    libc6-dev-riscv64-cross \
    wget

###############################################################################

FROM c-builder AS lua-builder
COPY lua/Makefile .

FROM lua-builder AS lua-5.4.3-builder
RUN make VERSION=5.4.3

FROM lua-builder AS lua-5.4.7-builder
RUN make VERSION=5.4.7

###############################################################################

FROM c-builder AS busybox-builder
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends bzip2 patch
COPY busybox/* .

FROM busybox-builder AS busybox-1.36.1-builder
RUN make VERSION=1.36.1

###############################################################################

FROM c-builder AS sqlite-builder
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends tcl
COPY sqlite/* .

FROM sqlite-builder AS sqlite-3.32.2-builder
RUN make VERSION=3.32.2

FROM sqlite-builder AS sqlite-3.43.2-builder
RUN make VERSION=3.43.2

###############################################################################

FROM cryptobughunters/rust:main AS rust-builder
WORKDIR /opt/build

###############################################################################

FROM rust-builder AS reth-builder
COPY reth/Makefile .

FROM reth-builder AS reth-1.0.5-builder
RUN make VERSION=1.0.5

###############################################################################

FROM ubuntu:noble-20240801 AS bundler
WORKDIR /opt/bundle
COPY --from=lua-5.4.3-builder --chmod=755 /opt/build/lua-5.4.3 .
COPY --from=lua-5.4.7-builder --chmod=755 /opt/build/lua-5.4.7 .
COPY --from=busybox-1.36.1-builder --chmod=755 /opt/build/busybox-1.36.1 .
COPY --from=sqlite-3.32.2-builder --chmod=755 /opt/build/sqlite-3.32.2 .
COPY --from=sqlite-3.43.2-builder --chmod=755 /opt/build/sqlite-3.43.2 .
COPY --from=reth-1.0.5-builder --chmod=755 /opt/build/reth-1.0.5 .
RUN tar --sort=name \
    --mtime=@0 \
    --owner=0 --group=0 --numeric-owner \
    --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
    -czf builtins.tar.gz *
