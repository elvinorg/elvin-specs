################################################################
# Copyright (C) 2006 elvin.org
# All Rights Reserved.
#
# $Id: Makefile,v 1.1 2006/10/12 10:16:44 d Exp $
#
################################################################

.PHONY: all macros outline

SOURCE_FILES:= $(wildcard *.ms)

FILENAME := draft-elvin-sha1-keys
VERSION := 00
PUBLISHED := $(FILENAME)-$(VERSION).txt

# Get current date
DATE := $(shell date +"%e %b %Y")

# Calulate expiry date 6 months in future
EXP=$(shell date -d "6 months" "+%d %b %Y")

# Set M4 macros for date substitution in the document
M4FLAGS := \
	-I .. \
	-D__cur_date_="$(DATE)"

all: main.txt

outline: outline.txt

outline.txt: main.tmp
	awk '/.NH/ {for(i=0;i<$$2;i++)printf("%s","  ");getline;print}' < $< > $@

main.txt: main.tmp

main.tmp: elvin-sha1-keys.ms
	m4 $(M4FLAGS) -P $< > $@

clean:
	rm -f main.txt main.tmp
	rm -f $(FILENAME)*.txt

publish: $(PUBLISHED)

$(PUBLISHED): main.txt
	sed -e 's/aa bbb cccc/${EXP}/g' $^ > $@

################################################################

%.txt : %.tmp
	nroff -ms $< | ../fix.pl | sed 's/_//g'  > $@

%.tmp : %.ms
	m4 -P $< > $@

################################################################



