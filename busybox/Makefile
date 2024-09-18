SRC_TAR=busybox-$(VERSION).tar.bz2
DEST_DIR=build
SRC_DIR=$(DEST_DIR)/busybox-$(VERSION)
BIN=$(SRC_DIR)/busybox

CFLAGS=-O1 -ftrivial-auto-var-init=pattern -D_FORTIFY_SOURCE=2 -fexceptions -fPIE -fstack-clash-protection -fstack-protector-strong -ffunction-sections -fdata-sections
LDFLAGS=-pie -Wl,-z,now,-z,relro,--gc-sections -s

busybox-$(VERSION): $(BIN)
	mv $< $@
	rm -rf $(DEST_DIR) $(SRC_TAR)

$(BIN): $(SRC_DIR) $(SRC_DIR)/.config $(SRC_DIR)/filter_exit.patch
	cd $(SRC_DIR) && patch -Np1 < filter_exit.patch
	make -j $(shell nproc) -C $< ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- "CFLAGS=$(CFLAGS)" "LDFLAGS=$(LDFLAGS)" busybox

$(SRC_DIR)/.config: config
	cp $< $@

$(SRC_DIR)/%.patch: %.patch
	cp $< $@

$(SRC_DIR): $(SRC_TAR)
	mkdir -p $(DEST_DIR)
	tar xf $< -C $(DEST_DIR)

$(SRC_TAR):
	curl -fsSL -O https://busybox.net/downloads/$(SRC_TAR)
