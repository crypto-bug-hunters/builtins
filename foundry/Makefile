SRC_DIR=foundry-clone
TAG=nightly-$(COMMIT_SHA)
COMMIT_SHA_SHORT=$(shell echo $(COMMIT_SHA) | head -c7)

.PHONY: all
all: cast-$(COMMIT_SHA_SHORT)-linux-riscv64
all: forge-$(COMMIT_SHA_SHORT)-linux-riscv64

.PHONY: clean
clean:
	rm -rf $(SRC_DIR)

%-$(COMMIT_SHA_SHORT)-linux-riscv64: $(SRC_DIR)/target/$(CARGO_TARGET)/release/%
	mv $< $@
	touch --date=@0 $@

$(SRC_DIR)/target/$(CARGO_TARGET)/release/%: $(SRC_DIR)
	cargo build --manifest-path $(SRC_DIR)/Cargo.toml --target $(CARGO_TARGET) --release --bin $(notdir $@)

$(SRC_DIR):
	git clone -b $(TAG) https://github.com/foundry-rs/foundry $@
