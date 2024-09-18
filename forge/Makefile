SRC_DIR=foundry-clone
TAG=nightly-$(COMMIT_SHA)
COMMIT_SHA_SHORT=$(shell echo $(COMMIT_SHA) | head -c7)
BIN=$(SRC_DIR)/target/$(CARGO_TARGET)/release/forge

forge-$(COMMIT_SHA_SHORT)-linux-riscv64: $(BIN)
	mv $< $@
	rm -rf $(SRC_DIR)
	touch --date=@0 $@

$(BIN): $(SRC_DIR)
	cargo build --manifest-path $(SRC_DIR)/Cargo.toml --target $(CARGO_TARGET) --release --bin forge

$(SRC_DIR):
	git clone -b $(TAG) https://github.com/foundry-rs/foundry $@
