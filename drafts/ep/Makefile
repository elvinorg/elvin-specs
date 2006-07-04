################################################################
# Copyright (C) DSTC Pty Ltd (ACN 052 372 577) 1998-1999.
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
#      Level 7, Gehrmann Labs
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
# File:     $Source: /Users/d/work/elvin/CVS/elvin-specs/drafts/ep/Makefile,v $
# Version:  $RCSfile: Makefile,v $ $Revision: 1.7 $
#
################################################################

.PHONY: all outline ps

FILENAME := draft-elvin-ecp-40
VERSION := 03
PUBLISHED := $(FILENAME)-$(VERSION).txt

# Get current date
DATE := $(shell date +"%B %Y")
YEAR := $(shell date +"%Y")
MTH := $(shell date +"%b")
DAY := $(shell date +"%e")

# Calulate expiry date 6 months in future
EXP=$(shell date -d "6 months" "+%d %b %Y")

# Set M4 macros for date substitution in the document
M4FLAGS := \
	-D__file="$(PUBLISHED)" \
	-D__yr="$(YEAR)" \
	-D__date="$(DATE)" \
	-D__m="$(MTH)" \
	-D_d="$(DAY)"

all: ps

outline: outline.txt

outline.txt: main.ms
	awk '/.NH/ {for(i=0;i<$$2;i++)printf("%s","  ");getline;print}' < $< > $@

main.txt: main.ms

main.ms: main.m4
	m4 -P -I ../ $(M4FLAGS) $< > $@

ps: main.txt
	a2ps -m main.txt --center-title="Elvin Client Protocol" -o main.ps

clean:
	rm -f main.txt main.ms main.ps

publish: $(PUBLISHED)

$(PUBLISHED): main.txt
	sed -e 's/aa bbb cccc/${EXP}/g' $^ > $@

################################################################

%.txt : %.ms
	nroff -c -ms $< | ./fix.pl | sed -e 's/_//g' -e 's/.//g'  > $@

%.ms : %.m4
	m4 -P $< > $@


################################################################
