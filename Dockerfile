FROM cryptobughunters/rust:main AS rust-builder

FROM rust-builder AS reth-builder
ARG RETH_VERSION=v1.0.5
WORKDIR /opt/build
RUN <<EOF
set -eu
git clone -b ${RETH_VERSION} https://github.com/paradigmxyz/reth
cd reth
cargo build --target ${CARGO_TARGET} --release --bin reth
mv target/${CARGO_TARGET}/release/reth /root/reth
cd ..
rm -rf reth
EOF

FROM ubuntu:noble-20240801 AS bundler
WORKDIR /opt/bundle
COPY --from=reth-builder --chmod=755 /root/reth .
RUN tar --sort=name \
    --mtime=@0 \
    --owner=0 --group=0 --numeric-owner \
    --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
    -czf builtins.tar.gz *
