################################################################
# Copyright (C) DSTC Pty Ltd (ACN 052 372 577) 1998-2000.
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
# File:     $Source: /Users/d/work/elvin/CVS/elvin-specs/drafts/elvin-xml/Makefile,v $
# Version:  $RCSfile: Makefile,v $ $Revision: 1.1 $
#
################################################################

.PHONY: all macros outline

all: main.txt

outline: outline.txt

outline.txt: main.ms
	awk '/.NH/ {for(i=0;i<$$2;i++)printf("%s","  ");getline;print}' < $< > $@

main.txt: main.ms

main.ms: *.m4
	m4 -P main.m4 > $@

clean:
	rm -f main.txt main.ms

################################################################

%.txt : %.ms
	nroff -ms $< | ./fix.pl | sed 's/_//g'  > $@

%.ms : %.m4
	m4 -P $< > $@

################################################################

billstall: main.txt
	cp main.txt /home/bill/e4/web-public/download/id-elvin-xml.txt


