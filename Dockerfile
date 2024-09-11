FROM cryptobughunters/rust:2.1.0 AS reth-builder
WORKDIR /opt/reth
ARG RETH_VERSION=v1.0.5
RUN git clone -b ${RETH_VERSION} https://github.com/paradigmxyz/reth .
RUN cargo build --target ${CARGO_TARGET} --release --bin reth
RUN mv target/${CARGO_TARGET}/release/reth /root/reth

FROM ubuntu:noble-20240801 AS bundler
WORKDIR /opt/bundle
COPY --from=reth-builder --chmod=755 /root/reth .
RUN tar --sort=name \
    --mtime=@0 \
    --owner=0 --group=0 --numeric-owner \
    --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
    -czf builtins.tar.gz *
