################################################################
# COPYRIGHT_BEGIN
#
# Copyright (C) 2000-2007 Elvin.Org
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above
#   copyright notice, this list of conditions and the following
#   disclaimer.
#
# * Redistributions in binary form must reproduce the above
#   copyright notice, this list of conditions and the following
#   disclaimer in the documentation and/or other materials
#   provided with the distribution.
#
# * Neither the name of the Elvin.Org nor the names
#   of its contributors may be used to endorse or promote
#   products derived from this software without specific prior
#   written permission. 
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# COPYRIGHT_END
################################################################

.PHONY: all outline publish

FILENAME := draft-elvin-router-discovery
VERSION := 00
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

all: main.txt

outline: outline.txt

outline.txt: main.ms
	awk '/.NH/ {for(i=0;i<$$2;i++)printf("%s","  ");getline;print}' < $< > $@

main.txt: main.ms

main.ms: main.m4 Makefile
	m4 -P -I ../ $(M4FLAGS) $< > $@

ps: main.txt
	a2ps -m main.txt --center-title="Elvin Router Discovery Protocol" -o main.ps

clean:
	rm -f main.txt main.ms main.ps

publish: $(PUBLISHED)

$(PUBLISHED): main.txt
	sed -e 's/aa bbb cccc/${EXP}/g' $^ > $@

################################################################

%.txt : %.ms
#	nroff -ms $< | ./fix.pl | sed -e 's/_//g' -e 's/.//g' -e 's/dd mmm/${dd} ${mmm}/g' -e 's/yyyy/${yyyy}/g' -e 's/aa bbb cccc/${exp}/g' > $@
	nroff -c -ms $< | ./fix.pl | sed -e 's/_//g' -e 's/.//g'  > $@

%.ms : %.m4
	m4 -P $< > $@

################################################################
