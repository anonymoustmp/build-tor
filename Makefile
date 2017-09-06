# -*-coding:utf-8-unix;-*-
#
all: build_deps
#
getsrc: zlib libevent openssl tor
#
zlib:
	git clone --depth=1 --branch=v1.2.11 https://github.com/madler/zlib zlib
#
libevent:
	git clone --depth=1 --branch=release-2.1.8-stable \
	https://github.com/libevent/libevent libevent
#
openssl:
	git clone --depth=1 --branch=OpenSSL_1_1_0f \
	https://github.com/openssl/openssl openssl
#
tor:
	git clone --depth=1 --branch=tor-0.3.0.10 \
	https://github.com/torproject/tor tor
#
deps:
	mkdir -p deps
#
build_deps:	build_zlib build_libevent build_openssl
#
build_zlib: deps zlib
	cd zlib && CFLAGS="-fPIC" ./configure --prefix=$(CURDIR)/deps \
	--static --64 --const && make -j4 && make install
#
build_libevent: deps libevent
	cd libevent && ./autogen.sh && ./configure --prefix=$(CURDIR)/deps \
	--enable-gcc-hardening --disable-thread-support --with-pic \
	--disable-malloc-replacement --disable-openssl --disable-debug-mode \
	--disable-libevent-regress --disable-samples --enable-function-sections \
	--disable-largefile --disable-shared && make -j4 && make install
#
build_openssl: deps openssl
	cd openssl && ./config --prefix=$(CURDIR)/deps \
	no-ui no-dgram no-shared && \
	make -j4 && make install_dev
#
out:
	mkdir -p out
#
build_tor: tor out
	cd tor && ./autogen.sh && ./configure --prefix=$(CURDIR)/out \
	--disable-unittests --disable-systemd \
	--disable-seccomp --disable-libscrypt --disable-largefile \
	--enable-static-openssl \
	--with-openssl-dir=$(CURDIR)/deps  \
	--enable-static-libevent \
	--with-libevent-dir=$(CURDIR)/deps \
	--enable-static-zlib  \
	--with-zlib-dir=$(CURDIR)/deps \
	&& make -j4 && make install

