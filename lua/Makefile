SRC_TAR=lua-$(VERSION).tar.gz
DEST_DIR=build
SRC_DIR=$(DEST_DIR)/lua-$(VERSION)
BIN=$(SRC_DIR)/src/lua

CC=riscv64-linux-gnu-gcc
AR=riscv64-linux-gnu-ar rc
RANLIB=riscv64-linux-gnu-ranlib
MYCFLAGS=-O1 -ftrivial-auto-var-init=pattern -D_FORTIFY_SOURCE=2 -fexceptions -fPIE -fstack-clash-protection -fstack-protector-strong -ffunction-sections -fdata-sections
MYLDFLAGS=-pie -Wl,-z,now,-z,relro,--gc-sections -s

lua-$(VERSION): $(BIN)
	mv $< $@
	rm -rf $(DEST_DIR) $(SRC_TAR)
	touch --date=@0 $@

$(BIN): $(SRC_DIR)
	make -j $(shell nproc) -C $< "CC=$(CC)" "AR=$(AR)" "RANLIB=$(RANLIB)" "MYCFLAGS=$(MYCFLAGS)" "MYLDFLAGS=$(MYLDFLAGS)" linux

$(SRC_DIR): $(SRC_TAR)
	mkdir -p $(DEST_DIR)
	tar xf $< -C $(DEST_DIR)

$(SRC_TAR):
	curl -fsSL -O https://www.lua.org/ftp/$@
