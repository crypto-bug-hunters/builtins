SRC_TAR=sqlite-version-$(VERSION).tar.gz
SRC_DIR=sqlite-version-$(VERSION)
BIN=$(SRC_DIR)/sqlite3

HOST=riscv64-linux-gnu
CC=/usr/bin/$(HOST)-gcc

HARDEN_CFLAGS=-O1 -ftrivial-auto-var-init=pattern -D_FORTIFY_SOURCE=2 -fPIE -fstack-clash-protection -fstack-protector-strong -ffunction-sections -fdata-sections
HARDEN_LDFLAGS=-pie -Wl,-z,now,-z,relro,--gc-sections
SQLITE_CFLAGS=-DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION
SQLITE_LDFLAGS=-lm -s

sqlite-$(VERSION)-linux-riscv64: $(SRC_DIR)/sqlite3.c
	$(CC) -o $@ $(HARDEN_CFLAGS) $(SQLITE_CFLAGS) $(SRC_DIR)/shell.c $(SRC_DIR)/sqlite3.c $(HARDEN_LDFLAGS) $(SQLITE_LDFLAGS)
	rm -rf $(SRC_TAR) $(SRC_DIR)
	touch --date=@0 $@

$(SRC_DIR)/sqlite3.c: $(SRC_DIR)
	cd $< && ./configure --host=$(HOST)
	make -C $< sqlite3.c

$(SRC_DIR): $(SRC_TAR)
	tar xf $<

$(SRC_TAR):
	curl -fsSL -o $@ https://github.com/sqlite/sqlite/archive/refs/tags/version-$(VERSION).tar.gz
