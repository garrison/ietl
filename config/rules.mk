###########################################################################
# IETL library
#
# config/rules.mk
#
# $Id: rules.mk,v 1.2 2004/03/05 09:54:42 prakash Exp $
#
# Copyright (C) 1994-2003 by Matthias Troyer <troyer@comp-phys.org>,
#                            Synge Todo <wistaria@comp-phys.org>,
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
###########################################################################

.SUFFIXES:

# targets

default : Makefile libs programs
all : Makefile libs programs tests example
libs : Makefile $(LIB)
programs : Makefile libs $(PROGRAM)
example : Makefile libs programs $(EXAMPLE)
tests : Makefile libs programs $(TESTOK)
install : Makefile libs programs
uninstall clean distclean : Makefile
depend : Makefile

# object files

%.o : $(srcdir)/%.C
	$(CXX) -c $(cppflags) $(cxxflags) $< -o $@
%.o : $(srcdir)/%.cpp
	$(CXX) -c $(cppflags) $(cxxflags) $< -o $@

# programs & examples

$(PROGRAM) : $(LIB) $(OBJ_PROGRAM)
$(EXAMPLE) : $(LIB) $(OBJ_PROGRAM)

% : $(srcdir)/%.C
	$(CXX) $(cppflags) $(cxxflags) -o $@ $< $(OBJ_PROGRAM) $(ldflags) $(libs_program) $(libs)
% : $(srcdir)/%.cpp
	$(CXX) $(cppflags) $(cxxflags) -o $@ $< $(OBJ_PROGRAM) $(ldflags) $(libs_program) $(libs)

# tests

TESTOBJ = $(TESTOK:.ok=.o)
TEST = $(TESTOK:.ok=)

$(TEST) : $(LIB)

%.ok : %
	-@if test -f $(@:.ok=.input); then \
	  if test -f $(srcdir)/$(@:.ok=.output); then \
	    echo './$(@:.ok=) < $(@:.ok=.input) | diff $(srcdir)/$(@:.ok=.output) -'; \
	    ./$(@:.ok=) < $(@:.ok=.input) | diff $(srcdir)/$(@:.ok=.output) -; \
	  else \
	    echo './$(@:.ok=) < $(@:.ok=.input)'; \
	    ./$(@:.ok=) < $(@:.ok=.input); \
	  fi; \
	elif test -f $(srcdir)/$(@:.ok=.input); then \
	  if test -f $(srcdir)/$(@:.ok=.output); then \
	    echo './$(@:.ok=) < $(srcdir)/$(@:.ok=.input) | diff $(srcdir)/$(@:.ok=.output) -'; \
	    ./$(@:.ok=) < $(srcdir)/$(@:.ok=.input) | diff $(srcdir)/$(@:.ok=.output) -; \
	  else \
	    echo './$(@:.ok=) < $(srcdir)/$(@:.ok=.input)'; \
	    ./$(@:.ok=) < $(srcdir)/$(@:.ok=.input); \
	  fi; \
	else \
	  if test -f $(srcdir)/$(@:.ok=.output); then \
	    echo './$(@:.ok=) | diff $(srcdir)/$(@:.ok=.output) -'; \
	    ./$(@:.ok=) | diff $(srcdir)/$(@:.ok=.output) -; \
	  else \
	    echo './$(@:.ok=)'; \
	    ./$(@:.ok=); \
	  fi; \
	fi
	@touch $@

# install

install : $(LIB) $(PROGRAM)
	@list='$(HEADER_CONFIG) $(HEADER)'; for p in $$list; do \
          if test -d $(pkgincludedir); then :; else \
	    echo "$(mkinstalldirs) $(pkgincludedir)"; \
	    $(mkinstalldirs) $(pkgincludedir); \
	  fi; \
	  sd=`dirname $$p`; \
	  if test "$$sd" != "."; then \
	    if test -d "$(pkgincludedir)/$$sd"; then :; else \
	      echo "$(mkinstalldirs) $(pkgincludedir)/$$sd"; \
	      $(mkinstalldirs) $(pkgincludedir)/$$sd; \
	    fi; \
	  fi; \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$(INSTALL_HEADER) $$d$$p $(pkgincludedir)/$$p"; \
	  $(INSTALL_HEADER) $$d$$p $(pkgincludedir)/$$p; \
	done
	@list='$(LIB)'; for p in $$list; do \
          if test -d $(libdir); then :; else \
	    echo "$(mkinstalldirs) $(libdir)"; \
	    $(mkinstalldirs) $(libdir); \
	  fi; \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$(INSTALL_LIB) $$d$$p $(libdir)/$$p"; \
	  $(INSTALL_LIB) $$d$$p $(libdir)/$$p; \
	  echo "$(RANLIB) $(libdir)/$$p"; \
	  $(RANLIB) $(libdir)/$$p; \
	done
	@list='$(XMLLIB)'; for p in $$list; do \
          if test -d $(libdir)/xml ; then :; else \
	    echo "$(mkinstalldirs) $(libdir)/xml "; \
	    $(mkinstalldirs) $(libdir)/xml ; \
	  fi; \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$(INSTALL_LIB) $$d$$p $(libdir)/xml/$$p"; \
	  $(INSTALL_LIB) $$d$$p $(libdir)/xml/$$p; \
	done
	@list='$(PROGRAM)'; for p in $$list; do \
          if test -d $(bindir); then :; else \
	    echo "$(mkinstalldirs) $(bindir)"; \
	    $(mkinstalldirs) $(bindir); \
	  fi; \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$(INSTALL_PROGRAM) $$d$$p $(bindir)/$$p"; \
	  $(INSTALL_PROGRAM) $$d$$p $(bindir)/$$p; \
	done
	@list='$(SCRIPT_CONFIG) $(SCRIPT)'; for p in $$list; do \
          if test -d $(bindir); then :; else \
	    echo "$(mkinstalldirs) $(bindir)"; \
	    $(mkinstalldirs) $(bindir); \
	  fi; \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$(INSTALL_SCRIPT) $$d$$p $(bindir)/$$p"; \
	  $(INSTALL_SCRIPT) $$d$$p $(bindir)/$$p; \
	done
	@list='$(DATA_CONFIG) $(DATA)'; for p in $$list; do \
          if test -d $(datadir); then :; else \
	    echo "$(mkinstalldirs) $(datadir)"; \
	    $(mkinstalldirs) $(datadir); \
	  fi; \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$(INSTALL_DATA) $$d$$p $(datadir)/$$p"; \
	  $(INSTALL_DATA) $$d$$p $(datadir)/$$p; \
	done
	@list='$(PKGDATA_CONFIG) $(PKGDATA)'; for p in $$list; do \
          if test -d $(pkgdatadir); then :; else \
	    echo "$(mkinstalldirs) $(pkgdatadir)"; \
	    $(mkinstalldirs) $(pkgdatadir); \
	  fi; \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$(INSTALL_DATA) $$d$$p $(pkgdatadir)/$$p"; \
	  $(INSTALL_DATA) $$d$$p $(pkgdatadir)/$$p; \
	done
uninstall :
	@list='$(HEADER_CONFIG) $(HEADER)'; for p in $$list; do \
	  echo "rm -f $(pkgincludedir)/$$p"; \
	  rm -f $(pkgincludedir)/$$p; \
	done
	@list='$(LIB)'; for p in $$list; do \
	  echo "rm -f $(libdir)/$$p"; \
	  rm -f $(libdir)/$$p; \
	done
	@list='$(PROGRAM) $(SCRIPT_CONFIG) $(SCRIPT)'; for p in $$list; do \
	  echo "rm -f $(bindir)/$$p"; \
	  rm -f $(bindir)/$$p; \
	done
	@list='$(DATA_CONFIG) $(DATA)'; for p in $$list; do \
	  echo "rm -f $(datadir)/$$p"; \
	  rm -f $(datadir)/$$p; \
	done
	@list='$(PKGDATA_CONFIG) $(PKGDATA)'; for p in $$list; do \
	  echo "rm -f $(pkgdatadir)/$$p"; \
	  rm -f $(pkgdatadir)/$$p; \
	done

# clean & distclean

clean :
	-rm -f *.a *.ti */*.ti */*/*.ti *.ii */*.ii */*/*.ii *.o */*.o */*/*.o *~ */*~ icc??????gas $(PROGRAM) $(EXAMPLE) $(TEST) $(TESTOK) a.out core
	-rm -rf ti_files */ti_files */*/ti_files ii_files */ii_files */*/ii_files cxx_repository TemplateDir 
distclean : clean
	-rm -f Makefile config.log $(HEADER_CONFIG) $(SCRIPT_CONFIG) $(DATA_CONFIG) $(PKGDATA_CONFIG) $(LOCAL_CONFIG)

# Makefile & dependency

Makefile : $(srcdir)/Makefile.in
	(cd $(top_builddir) && ./config.status)
depend :
	@if test -f Makefile.dep; then \
	  echo "rm -f Makefile.dep && touch Makefile.dep"; \
	  rm -f Makefile.dep && touch Makefile.dep; \
	  echo "$(MAKEDEPEND) -f Makefile.dep -- -Y -I$(top_srcdir)/src -- \`find * -name '*.C' -o -name '*.cpp'\` > /dev/null 2>&1"; \
	  $(MAKEDEPEND) -f Makefile.dep -- -Y -I$(top_srcdir)/src -- `find * -name '*.C' -o -name '*.cpp'` > /dev/null 2>&1; \
	  echo "mv -f Makefile.dep makedepend.tmp"; \
	  mv -f Makefile.dep makedepend.tmp; \
	  echo "cat makedepend.tmp | $(MAKEDEPEND_PL) | sort > Makefile.dep"; \
	  cat makedepend.tmp | $(MAKEDEPEND_PL) | sort > Makefile.dep; \
	  echo "rm -f Makefile.dep.bak makedepend.tmp"; \
	  rm -f Makefile.dep.bak makedepend.tmp; \
	fi
