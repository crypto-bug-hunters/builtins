BOOST_VERSION=1.74.0
BOOST_SRC_DIR=boost_$(subst .,_,$(BOOST_VERSION))
BOOST_SRC_TAR=$(BOOST_SRC_DIR).tar.gz
BOOST_INSTALLATION_DIR=/opt/boost
BOOST_USER_CONFIG_FILE=$(HOME)/user-config.jam
BOOST_FLAGS=link=static variant=release runtime-link=static
BOOST_LIBNAMES=system filesystem test program_options

SOLC_SRC_DIR=solidity_$(VERSION)
SOLC_SRC_TAR=$(SOLC_SRC_DIR).tar.gz
SOLC_BUILD_DIR=$(SOLC_SRC_DIR)/build
BIN=$(SOLC_BUILD_DIR)/solc/solc

CC=riscv64-linux-gnu-gcc
CXX=riscv64-linux-gnu-g++

CFLAGS=-O1 -ftrivial-auto-var-init=pattern -D_FORTIFY_SOURCE=2 -fPIE -fstack-clash-protection -fstack-protector-strong -ffunction-sections -fdata-sections -Wno-unused-result
CXXFLAGS=$(CFLAGS)
LDFLAGS=-pie -Wl,-z,now,-z,relro,--gc-sections

solc-$(VERSION): $(BIN)
	mv $< $@
	rm -rf $(BOOST_SRC_TAR) $(BOOST_SRC_DIR) $(BOOST_INSTALLATION_DIR) $(BOOST_USER_CONFIG_FILE) $(SOLC_SRC_TAR) $(SOLC_SRC_DIR)

$(BIN): $(SOLC_BUILD_DIR)
	make -C $< solc -j $(shell nproc)

$(SOLC_BUILD_DIR): $(SOLC_SRC_DIR) $(BOOST_INSTALLATION_DIR)
	cmake \
		-S $< \
		-B $@ \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_C_COMPILER=$(CC) \
		-DCMAKE_CXX_COMPILER=$(CXX) \
		-DBoost_INCLUDE_DIR=$(BOOST_INSTALLATION_DIR) \
		-DBoost_USE_STATIC_RUNTIME=ON \
		-DUSE_Z3=OFF \
		-DTESTS=OFF

$(SOLC_SRC_DIR): $(SOLC_SRC_TAR)
	tar xf $<

$(SOLC_SRC_TAR):
	wget -O $@ https://github.com/ethereum/solidity/releases/download/v$(VERSION)/$@

$(BOOST_INSTALLATION_DIR): $(BOOST_SRC_DIR) $(BOOST_USER_CONFIG_FILE)
	mkdir -p $@
	cd $< && ./bootstrap.sh --prefix=$@
	cd $< && ./b2 toolset=gcc-riscv64 headers
	cd $< && ./b2 toolset=gcc-riscv64 $(BOOST_FLAGS) $(patsubst %,--with-%,$(BOOST_LIBNAMES)) install -j $(shell nproc)

$(BOOST_USER_CONFIG_FILE):
	echo "using gcc : riscv64 : $(CXX) ;" > $@

$(BOOST_SRC_DIR): $(BOOST_SRC_TAR)
	tar xf $<

$(BOOST_SRC_TAR):
	wget https://boostorg.jfrog.io/artifactory/main/release/$(BOOST_VERSION)/source/$@
