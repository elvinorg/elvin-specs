################################################################
# Copyright (C) DSTC Pty Ltd (ACN 052 372 577) 1999
# All Rights Reserved.
#
# The software contained on this media is the property of the
# DSTC Pty Ltd.  Use of this software is strictly in accordance
# with the license agreement in the accompanying LICENSE.DOC file.
# If your distribution of this software does not contain a
# LICENSE.DOC file then you have no rights to use this software
# in any manner and should contact DSTC at the address below
# to determine an appropriate licensing arrangement.
# 
#      DSTC Pty Ltd
#      Level 7, General Purpose South
#      University of Queensland
#      St Lucia, 4072
#      Australia
#      Tel: +61 7 3365 4310
#      Fax: +61 7 3365 4311
#      Email: enquiries@dstc.edu.au
# 
# This software is being provided "AS IS" without warranty of
# any kind.  In no event shall DSTC Pty Ltd be liable for
# damage of any kind arising out of or in connection with
# the use or performance of this software.
#
# Project:  Elvin
# File:     $Source: /Users/d/work/elvin/CVS/elvin-specs/protocol-v3/Makefile,v $
#
################################################################

.PHONY: all html ps pdf

FIG_FILES  :=   $(wildcard *.fig)
EPS_FILES  :=   $(patsubst %.fig,%.eps,$(FIG_FILES))
GIF_FILES  :=   $(patsubst %.fig,%.gif,$(FIG_FILES))

INSTALLDIR=/www/public/htdocs/Elvin/doc/papers/es99


################################################################
#  some general rules

#  create an Encapsulated PostScript file from the FIG source
%.eps: %.fig
	fig2dev -L ps $< $@

#  create a "nice" GIF from the FIG source
#
#  to do this we first convert to PPM, scale it to 620 pixels wise, 
#  quantize to 16 colours, and then convert to an interlaces GIF.
%.gif: %.fig
	fig2dev -L ppm $< $(basename $@).ppm
	pnmscale -xsize 620 $(basename $@).ppm | ppmquant 16 | ppmtogif -interlace > $@
	rm -f $(basename $@).ppm

#  create HTML from TROFF source (using m2h and fig2gif)
#
#  sed hacks remove the <h1> file name header, and the .ip broken-ness
#  head/tail/cat hacks insert the generated bibliography
#  rm cleans up
%.html: %.tmp
	/home/arnold/tmp/m2h/m2h -t $@ -b '#ffffff' $<
	sed s:\<H1\>$@\</H1\>:\<br\>\<br\>\<br\>:g < $<.html | sed s/lt\;\-\ \./lt\;\-/g > $@
	head -`grep -n @BIB@ < $@ | cut -d : -f 1` $@ >$@.1
	tail +`grep -n @BIB@ < $@ | cut -d : -f 1` $@ >$@.2
	cat $@.1 $(basename $@).bib $@.2 > $@
	rm -f $<-fig??? $<.html $@.1 $@.2

################################################################

all: elvin-3.pdf elvin-3.ps elvin-3.html

html: elvin-3.html

ps: elvin-3.ps

pdf: elvin-3.pdf

elvin-3.tmp: elvin-3.troff elvin-3.ref Makefile
	grefer -e -p elvin-3.ref elvin-3.troff > $@

elvin-3.bib: elvin-3.troff elvin-3.ref Makefile
	grep '\[.+\]' < elvin-3.troff | cut -b 4- | sort | uniq | ref2html -p elvin-3.ref > $@

elvin-3.ps: elvin-3.tmp $(EPS_FILES)
	geqn elvin-3.tmp | groff -me  > $@

elvin-3.pdf: elvin-3.ps
	distill $< 

elvin-3.html: $(FIG_FILES) elvin-3.tmp elvin-3.bib

clean:
	rm -f elvin-3.html elvin-3.pdf elvin-3.ps elvin-3.tmp elvin-3.bib \
		$(EPS_FILES)

clobber: clean
	rm -rf elvin-3.html elvin-3.ps elvin-3.pdf *.tmp-f* 

install: elvin-3.html elvin-3.pdf
	cp elvin-3.tmp-fig???.gif $(INSTALLDIR)
	cp elvin-3.html $(INSTALLDIR)
	cp elvin-3.pdf $(INSTALLDIR)


################################################################
