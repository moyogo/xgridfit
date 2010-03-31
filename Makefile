#!/usr/bin/make -f
#
#  Makefile by Kestutis Biliunas 2007
#  Revised by Peter Baker 2007-2009
#  Contributions by Nicolas Mailhot 2009
#

SHELL=/bin/bash

include version.mk

DESTDIR =
PREFIX = /usr/local

# %{_bindir} in rpm speak
BINDIR = $(PREFIX)/bin

# %{_datadir}/xml in rpm speak
XMLDIR = $(PREFIX)/share/xml

#%{_mandir} in rpm speak
MANDIR = $(PREFIX)/share/man

# Could be changed to $(XMLDIR)/$(PACKAGE)-$(VERSION)
MAINDIR = $(XMLDIR)/$(PACKAGE)

install:
	@install -d -m 0755 $(DESTDIR)$(BINDIR)
	@install -p -m 0755 bin/* $(DESTDIR)$(BINDIR)
	@which python > /dev/null ; \
	if [ $$? -eq 0 ] ; then \
	  PYTHONPROG=`which python` ; \
	  for file in $(DESTDIR)$(BINDIR)/{ttx2xgf,xgfconfig,xgfmerge,xgfupdate,xgridfit,getinstrs} ; do \
	  sed -i -e "s|@xgridfit_dir@|${MAINDIR}|g" -e "s|@version@|$(VERSION)|" -e \
	  "s|@python_prog@|$$PYTHONPROG|" $$file ; done ; \
	else \
	  echo "Python is required for xgridfit." ; \
	  rm -f $(DESTDIR)$(BINDIR)/{ttx2xgf,xgfconfig,xgfmerge,xgfupdate,xgridfit,getinstrs} ; \
	fi
	@install -d -m 0755  $(DESTDIR)$(MAINDIR)/{lib,schemas,utils}
	@for dir in lib schemas utils ; do \
	  install -p -m 0644 $$dir/* $(DESTDIR)$(MAINDIR)/$$dir ; \
	done
	@for file in $(DESTDIR)$(MAINDIR)/schemas/*.xml ; do \
	  sed -i "s|@xgridfit_dir@|${MAINDIR}|g" $$file ; \
	done
	@install -d -m 0755 $(DESTDIR)$(MANDIR)/man1
	@install -p -m 0644 man/*.1 $(DESTDIR)$(MANDIR)/man1
	@cd python ; python setup.py install --root=$(DESTDIR)/
	@echo "Xgridfit installed successfully."


install-mac:
	@install -d -m 0755 $(DESTDIR)$(BINDIR)
	@install -p -m 0755 bin/* $(DESTDIR)$(BINDIR)
	@which python > /dev/null ; \
	if [ $$? -eq 0 ] ; then \
	  PYTHONPROG=`which python` ; \
	  for file in $(DESTDIR)$(BINDIR)/{ttx2xgf,xgfconfig,xgfmerge,xgfupdate,xgridfit,getinstrs} ; do \
	  sed -i "" -e "s|@xgridfit_dir@|${MAINDIR}|g" -e "s|@version@|$(VERSION)|" -e \
	  "s|@python_prog@|$$PYTHONPROG|" $$file ; done ; \
	else \
	  echo "Python is required for xgridfit." ; \
	  rm -f $(DESTDIR)$(BINDIR)/{ttx2xgf,xgfconfig,xgfmerge,xgfupdate,xgridfit,getinstrs} ; \
	fi
	@install -d -m 0755  $(DESTDIR)$(MAINDIR)/{lib,schemas,utils}
	@for dir in lib schemas utils ; do \
	  install -p -m 0644 $$dir/* $(DESTDIR)$(MAINDIR)/$$dir ; \
	done
	@for file in $(DESTDIR)$(MAINDIR)/schemas/*.xml ; do \
	  sed -i "" "s|@xgridfit_dir@|${MAINDIR}|g" $$file ; \
	done
	@install -d -m 0755 $(DESTDIR)$(MANDIR)/man1
	@install -p -m 0644 man/*.1 $(DESTDIR)$(MANDIR)/man1
	@cd python ; python setup.py install --root=$(DESTDIR)/
	@echo "Xgridfit installed successfully."


install-docs:
	@mkdir -p $(DESTDIR)$(PREFIX)/share/doc/$(PACKAGE)/html
	@cp docs/* $(DESTDIR)$(PREFIX)/share/doc/$(PACKAGE)/html
	@echo "Xgridfit documentation installed in $(DESTDIR)$(PREFIX)/share/doc/"


install-all:
	$(MAKE) -f Makefile install
	$(MAKE) -f Makefile install-docs


install-all-mac:
	$(MAKE) -f Makefile install-mac
	$(MAKE) -f Makefile install-docs


uninstall:
	rm -f $(DESTDIR)$(MAINDIR)/lib/*
	rmdir $(DESTDIR)$(MAINDIR)/lib
	rm -f $(DESTDIR)$(MAINDIR)/schemas/*
	rmdir $(DESTDIR)$(MAINDIR)/schemas
	rm -f $(DESTDIR)$(MAINDIR)/utils/*
	rmdir $(DESTDIR)$(MAINDIR)/utils
	rmdir $(DESTDIR)$(MAINDIR)
	rm -f $(DESTDIR)$(MANDIR)/man1/$(PACKAGE).1*
	rm -f $(DESTDIR)$(MANDIR)/man1/xgfupdate.1*
	rm -f $(DESTDIR)$(MANDIR)/man1/ttx2xgf.1*
	rm -f $(DESTDIR)$(MANDIR)/man1/xgfconfig.1*
	rm -f $(DESTDIR)$(BINDIR)/$(PACKAGE)
	rm -f $(DESTDIR)$(BINDIR)/xgfupdate
	rm -f $(DESTDIR)$(BINDIR)/ttx2xgf
	rm -f $(DESTDIR)$(BINDIR)/xgfconfig
	rm -f $(DESTDIR)$(BINDIR)/xgfmerge
	rm -f $(DESTDIR)$(BINDIR)/getinstrs


uninstall-docs:
	rm -f $(DESTDIR)$(PREFIX)/share/doc/$(PACKAGE)/html/*
	rmdir $(DESTDIR)$(PREFIX)/share/doc/$(PACKAGE)/html
	rmdir $(DESTDIR)$(PREFIX)/share/doc/$(PACKAGE)


uninstall-all:
	$(MAKE) -f Makefile uninstall
	$(MAKE) -f Makefile uninstall-docs


dist:
	$(MAKE) -f Makefile clean
	tar -C .. -zcvf $(PACKAGE)-$(VERSION).tar.gz \
		--exclude=CVS --exclude=*.tar.bz2 --exclude=.*  --exclude=*.*~ \
		--exclude=*~ --exclude=*.tar.gz $(PACKAGE)

clean:
	rm -f *.tar.gz *.*~ *~
	rm -f bin/*~
	rm -f docs/*.*~
	rm -f lib/*.*~
	rm -f schemas/*.*~
	rm -f utils/*.*~
	rm -f man/*.*~


.PHONY:	install install-mac install-docs install-all install-all-mac \
	uninstall uninstall-docs uninstall-all dist clean

