#!/usr/local/bin/perl
###########################################################################
# IETL library
#
# config/makedepend.pl : supplemental perl script processing output of
#                        makedepend
#
# $Id: makedepend.pl,v 1.1 2003/09/01 10:17:43 troyer Exp $
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

# usage:
#   rm -f Makefile.dep && touch Makefile.dep
#   makedepend -f Makefile.dep -- -Y -I../../src -- `find * -name '*.C' -o -name '*.cpp'` > /dev/null 2>&1
#   mv -f Makefile.dep makedepend.tmp
#   cat makedepend.tmp | perl makedepend.pl | sort > Makefile.dep
#   rm -f Makefile.dep.bak makedepend.tmp

$SRCDIR = '$(srcdir)';
$TOP_SRCDIR = '$(top_srcdir)';
$TOP_BUILDDIR = '$(top_builddir)';

while (<>) {
    chomp;
    @elems = split(' ');
    if (@elems[0] ne '#' && @elems[0] ne '') {
	$base = shift @elems;
	$base =~ s/\.o\://;
	foreach $header (@elems) {
	    # remove preceding '../'
	    $header =~ s/(\.\.\/)//g;
	    if ($header =~ /^ietl/ || $header =~ /^include/) {
		if ($header =~ /config\.h$/) {
		    $header = "$TOP_BUILDDIR/$header";
		} else {
		    $header = "$TOP_SRCDIR/$header";
		}
	    } else {
		$header = "$SRCDIR/$header";
	    }
	    $headers{$base} = "$headers{$base} $header";
	}
    }
}

foreach $base (keys(%headers)) {
    print "${base}.o ${base} ${base}_mpi ${base}_pvm:$headers{$base}\n";
}
