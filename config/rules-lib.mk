###########################################################################
# IETL library
#
# config/rules-lib.mk
#
# $Id: rules-lib.mk,v 1.1 2003/09/01 10:17:43 troyer Exp $
#
# Copyright (C) 1994-2003 by Matthias Troyer <troyer@comp-phys.org>,
#                            Synge Todo <wistaria@comp-phys.org>,
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

# library

$(LIB) : $(OBJ)
	$(ARXX) $(cxxflags) $(ldflags) -o $@ $(OBJ) $(libs)
