CC?=gcc
CFLAGS?=-g -O2
CFLAGS+=-Wall -Wextra -Wno-unused-parameter
LIBS+=-lrt
SRCDIR=src
TESTDIR=tests
LIB_OBJS=bitstring.o encparams.o hash.o idxgen.o key.o mgf.o ntru.o poly.o rand.o sha1.o sha2.o
TEST_OBJS=test_bitstring.o test_hash.o test_idxgen.o test_key.o test_ntru.o test.o test_poly.o test_util.o
VERSION=0.2
INST_PFX=/usr
INST_LIBDIR=$(INST_PFX)/lib
INST_INCLUDE=$(INST_PFX)/include/libntru
INST_DOCDIR=$(INST_PFX)/share/doc/libntru
INST_HEADERS=ntru.h types.h key.h encparams.h hash.h rand.h err.h

LIB_OBJS_PATHS=$(patsubst %,$(SRCDIR)/%,$(LIB_OBJS))
TEST_OBJS_PATHS=$(patsubst %,$(TESTDIR)/%,$(TEST_OBJS))
DIST_NAME=libntru-$(VERSION)

.PHONY: all
all: lib

.PHONY: lib
lib: $(LIB_OBJS_PATHS)
	$(CC) $(CFLAGS) $(CPPFLAGS) -shared -Wl,-soname,libntru.so -o libntru.so $(LIB_OBJS_PATHS) $(LDFLAGS) $(LIBS)

.PHONY: install
install: lib
	test -d "$(DESTDIR)$(INST_PFX)" || mkdir -p "$(DESTDIR)$(INST_PFX)"
	test -d "$(DESTDIR)$(INST_LIBDIR)" || mkdir "$(DESTDIR)$(INST_LIBDIR)"
	test -d "$(DESTDIR)$(INST_INCLUDE)" || mkdir -p "$(DESTDIR)$(INST_INCLUDE)"
	test -d "$(DESTDIR)$(INST_DOCDIR)" || mkdir -p "$(DESTDIR)$(INST_DOCDIR)"
	install -m 0755 libntru.so "$(DESTDIR)$(INST_LIBDIR)/libntru.so"
	install -m 0644 README.md "$(DESTDIR)$(INST_DOCDIR)/README.md"
	for header in $(INST_HEADERS) ; do \
	    install -m 0644 "$(SRCDIR)/$$header" "$(DESTDIR)$(INST_INCLUDE)/" ; \
	done

.PHONY: uninstall
uninstall:
	rm -f "$(DESTDIR)$(INST_LIBDIR)/libntru.so"
	rm -f "$(DESTDIR)$(INST_DOCDIR)/README.md"
	rmdir "$(DESTDIR)$(INST_DOCDIR)/"
	for header in $(INST_HEADERS) ; do \
	    rm "$(DESTDIR)$(INST_INCLUDE)/$$header" ; \
	done
	rmdir "$(DESTDIR)$(INST_INCLUDE)/"

.PHONY: dist
dist:
	rm -rf $(DIST_NAME)
	mkdir $(DIST_NAME)
	mkdir $(DIST_NAME)/$(SRCDIR)
	mkdir $(DIST_NAME)/$(TESTDIR)
	cp Makefile Makefile.win Makefile.osx README.md LICENSE PATENTS $(DIST_NAME)
	cp $(SRCDIR)/*.c $(DIST_NAME)/$(SRCDIR)
	cp $(SRCDIR)/*.h $(DIST_NAME)/$(SRCDIR)
	cp $(TESTDIR)/*.c $(DIST_NAME)/$(TESTDIR)
	cp $(TESTDIR)/*.h $(DIST_NAME)/$(TESTDIR)
	tar cf $(DIST_NAME).tar.xz $(DIST_NAME) --lzma
	rm -rf $(DIST_NAME)

test: lib $(TEST_OBJS_PATHS)
	$(CC) $(CFLAGS) $(CPPFLAGS) -o test $(TEST_OBJS_PATHS) $(LDFLAGS) -L. -lntru -lm
	LD_LIBRARY_PATH=. ./test

bench: lib $(SRCDIR)/bench.o
	$(CC) $(CFLAGS) $(CPPFLAGS) -o bench $(SRCDIR)/bench.o $(LDFLAGS) -L. -lntru

$(SRCDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -fPIC $< -o $@

tests/%.o: tests/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -fPIC -I$(SRCDIR) -c $< -o $@

.PHONY: clean
clean:
	@# also clean files generated on other OSes
	rm -f $(SRCDIR)/*.o $(TESTDIR)/*.o libntru.so libntru.dylib libntru.dll test test.exe bench bench.exe

.PHONY: distclean
distclean: clean
	rm -rf $(DIST_NAME)
	rm -f $(DIST_NAME).tar.xz $(DIST_NAME).zip
