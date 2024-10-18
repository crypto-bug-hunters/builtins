SRC_DIR=reth-clone
REF=v$(VERSION)
BIN=$(SRC_DIR)/target/$(CARGO_TARGET)/release/reth

reth-$(VERSION)-linux-riscv64: $(BIN)
	mv $< $@
	rm -rf $(SRC_DIR)
	touch --date=@0 $@

$(BIN): $(SRC_DIR) $(SRC_DIR)/custom_mdbx_geometry.patch
	cd $(SRC_DIR) && patch -Np1 < custom_mdbx_geometry.patch
	cargo build --manifest-path $(SRC_DIR)/Cargo.toml --target $(CARGO_TARGET) --release --bin reth

$(SRC_DIR)/%.patch: %.patch
	cp $< $@

$(SRC_DIR):
	git clone -b $(REF) https://github.com/paradigmxyz/reth $@
