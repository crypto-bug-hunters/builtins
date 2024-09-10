FROM cryptobughunters/rust:2.0.0
ARG VERSION

WORKDIR /opt/build
RUN git clone -b v${VERSION} https://github.com/paradigmxyz/reth

WORKDIR /opt/build/reth
RUN cargo build --target riscv64gc-unknown-linux-gnu --release --bin reth

WORKDIR /root
RUN mv /opt/build/reth/target/riscv64gc-unknown-linux-gnu/release/reth .
