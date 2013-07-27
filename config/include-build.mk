###########################################################################
# IETL library
#
# config/include-build.mk
#
# $Id: include-build.mk,v 1.1 2003/09/01 10:17:43 troyer Exp $
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

# this is used only for building the IETL library

include $(top_builddir)config/include.mk

# overwrite variables in include.mk

install_sh = $(top_srcdir)/config/install-sh
mkinstalldirs = $(top_srcdir)/config/mkinstalldirs
ARXX = $(SHELL) $(top_builddir)config/arxx
MAKEDEPEND_PL = perl $(top_srcdir)/config/makedepend.pl

cppflags = -I$(top_builddir) -I$(top_srcdir) $(BASE_CPPFLAGS)
cxxflags = $(CXXFLAGS)
ldflags = -L$(builddir) -L$(top_builddir) $(BASE_LDFLAGS)
