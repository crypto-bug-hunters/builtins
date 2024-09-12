SRC_TAR=sqlite-version-$(VERSION).tar.gz
SRC_DIR=sqlite-version-$(VERSION)
BIN=$(SRC_DIR)/sqlite3

HOST=riscv64-linux-gnu
CCLINK=/usr/bin/$(HOST)-gcc

HARDEN_CFLAGS=-O1 -ftrivial-auto-var-init=pattern -D_FORTIFY_SOURCE=2 -fPIE -fstack-clash-protection -fstack-protector-strong -ffunction-sections -fdata-sections
HARDEN_LDFLAGS=-pie -Wl,-z,now,-z,relro,--gc-sections
SQLITE_CFLAGS=-DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION
SQLITE_LDFLAGS=-lm -s

sqlite-$(VERSION): $(SRC_DIR)/sqlite3.c $(CCLINK)
	$(CCLINK) -o $@ $(HARDEN_CFLAGS) $(SQLITE_CFLAGS) $(SRC_DIR)/shell.c $(SRC_DIR)/sqlite3.c $(HARDEN_LDFLAGS) $(SQLITE_LDFLAGS)
	rm -rf $(SRC_TAR) $(SRC_DIR)

$(SRC_DIR)/sqlite3.c: $(SRC_DIR) 
	cd $< && ./configure --host=$(HOST)
	make -C $< sqlite3.c

$(CCLINK): $(CCLINK)-12
	ln -s $< $@

$(SRC_DIR): $(SRC_TAR)
	tar xf $<

$(SRC_TAR):
	wget -O $@ https://github.com/sqlite/sqlite/archive/refs/tags/version-$(VERSION).tar.gz
