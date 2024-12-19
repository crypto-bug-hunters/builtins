ARG UBUNTU_TAG=noble-20241015

FROM --platform=$BUILDPLATFORM ubuntu:${UBUNTU_TAG} AS base-builder
WORKDIR /opt/build
ENV SOURCE_DATE_EPOCH=0
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt install -y --no-install-recommends ca-certificates
apt update --snapshot=20241015T030400Z
apt install -y --no-install-recommends curl
EOF

###############################################################################

FROM base-builder AS c-builder
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends \
    build-essential \
    gcc-riscv64-linux-gnu \
    libc-dev-riscv64-cross

###############################################################################

FROM c-builder AS cpp-builder
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends \
    g++-riscv64-linux-gnu

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
COPY busybox/Makefile busybox/config busybox/filter_exit.patch ./

FROM busybox-builder AS busybox-1.36.1-builder
RUN make VERSION=1.36.1

###############################################################################

FROM c-builder AS sqlite-builder
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends tcl
COPY sqlite/Makefile .

FROM sqlite-builder AS sqlite-3.32.2-builder
RUN make VERSION=3.32.2

FROM sqlite-builder AS sqlite-3.43.2-builder
RUN make VERSION=3.43.2

###############################################################################

FROM cpp-builder AS solc-builder
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends cmake
COPY solc/Makefile .

FROM solc-builder AS solc-0.8.28-builder
RUN make -j $(nproc) VERSION=0.8.28

###############################################################################

FROM --platform=$BUILDPLATFORM cryptobughunters/rust:2.2.0 AS rust-builder
WORKDIR /opt/build

###############################################################################

FROM rust-builder AS foundry-builder
COPY foundry/Makefile .

FROM foundry-builder AS foundry-2cdbfac-builder
RUN make all clean COMMIT_SHA=2cdbfaca634b284084d0f86357623aef7a0d2ce3

###############################################################################

FROM rust-builder AS reth-builder
ENV MDBX_BUILD_TIMESTAMP=unknown
COPY reth/Makefile reth/custom_mdbx_geometry.patch .

FROM reth-builder AS reth-1.0.5-builder
RUN make VERSION=1.0.5

###############################################################################

FROM base-builder AS chiselled-builder
WORKDIR /rootfs

# Get chisel binary
ARG CHISEL_VERSION=1.0.0
ADD "https://github.com/canonical/chisel/releases/download/v${CHISEL_VERSION}/chisel_v${CHISEL_VERSION}_linux_riscv64.tar.gz" /tmp/chisel.tar.gz
RUN tar -xvf /tmp/chisel.tar.gz -C /usr/bin/

RUN chisel cut \
    --release ubuntu-24.04 \
    --root /rootfs \
    --arch=riscv64 \
    base-files_chisel \
    busybox_bins \
    libstdc++6_libs \
    libatomic1_libs

###############################################################################

FROM scratch
WORKDIR /opt/bundle
COPY --from=lua-5.4.3-builder --chmod=755 /opt/build/lua-5.4.3-linux-riscv64 .
COPY --from=lua-5.4.7-builder --chmod=755 /opt/build/lua-5.4.7-linux-riscv64 .
COPY --from=busybox-1.36.1-builder --chmod=755 /opt/build/busybox-1.36.1-linux-riscv64 .
COPY --from=sqlite-3.32.2-builder --chmod=755 /opt/build/sqlite-3.32.2-linux-riscv64 .
COPY --from=sqlite-3.43.2-builder --chmod=755 /opt/build/sqlite-3.43.2-linux-riscv64 .
COPY --from=solc-0.8.28-builder --chmod=755 /opt/build/solc-0.8.28-linux-riscv64 .
COPY --from=foundry-2cdbfac-builder --chmod=755 /opt/build/cast-2cdbfac-linux-riscv64 .
COPY --from=foundry-2cdbfac-builder --chmod=755 /opt/build/forge-2cdbfac-linux-riscv64 .
COPY --from=reth-1.0.5-builder --chmod=755 /opt/build/reth-1.0.5-linux-riscv64 .
COPY --from=chiselled-builder /rootfs /

ENTRYPOINT ["/usr/bin/busybox", "sh"]
