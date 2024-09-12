SRC_DIR=reth-clone
REF=v$(VERSION)
BIN=$(SRC_DIR)/target/$(CARGO_TARGET)/release/reth

reth-$(VERSION): $(BIN)
	mv $< $@
	rm -rf $(SRC_DIR)

$(BIN): $(SRC_DIR)
	cargo build --manifest-path $(SRC_DIR)/Cargo.toml --target $(CARGO_TARGET) --release --bin reth

$(SRC_DIR):
	git clone -b $(REF) https://github.com/paradigmxyz/reth $@
