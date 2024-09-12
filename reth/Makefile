CLONE_DIR=reth-clone
CLONE_REF=v$(VERSION)
BUILT_BIN=$(CLONE_DIR)/target/$(CARGO_TARGET)/release/reth

reth-$(VERSION): $(BUILT_BIN)
	mv $< $@
	rm -rf $(BUILD_DIR)

$(BUILT_BIN): $(CLONE_DIR)
	cargo build --manifest-path $(CLONE_DIR)/Cargo.toml --target $(CARGO_TARGET) --release --bin reth

$(CLONE_DIR):
	git clone -b $(CLONE_REF) https://github.com/paradigmxyz/reth $@
