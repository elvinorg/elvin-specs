################################################################
# COPYRIGHT_BEGIN
# Copyright (C) 2001-2004, David Arnold.
#
# This specification may be reproduced or transmitted in any form or
# by any means, electronic or mechanical, including photocopying,
# recording, or by any information storage or retrieval system,
# providing that the content remains unaltered, and that such
# distribution is under the terms of this licence.
# 
# While every precaution has been taken in the preparation of this
# specification, the authors assume no responsibility for errors or
# omissions, or for damages resulting from the use of the information
# herein.
# 
# We welcome comments on this specification.  Please address any
# queries, comments or fixes (please include the name and version of
# the specification) to the address below:
# 
#     ticker-dev@tickertape.org
# 
# Elvin is a trademark of Mantara Software.  All other trademarks and
# registered marks belong to their respective owners.
# COPYRIGHT_END
#
# $Id: Makefile,v 1.6 2004/03/19 07:55:59 d Exp $
#
################################################################

.PHONY: all macros outline

#  create date string
dd=$(shell date +%d)
mmm=$(shell date +%b)
yyyy=$(shell date +%Y)
exp=$(shell date -d "6 months" "+%d %b %Y")

FILENAME := draft-arnold-ticker-chat-v3
VERSION := 00
PUBLISHED := $(FILENAME)-$(VERSION).txt



all: main.txt

outline: outline.txt

outline.txt: main.ms
	awk '/.NH/ {for(i=0;i<$$2;i++)printf("%s","  ");getline;print}' < $< > $@

main.txt: main.ms

main.ms: *.m4 ../macros.m4 Makefile
	m4 -I.. -DPUBLISHED=$(PUBLISHED) -P main.m4 > $@

clean:
	rm -f main.txt main.ms


publish: $(PUBLISHED)

$(PUBLISHED): main.txt
	sed -e 's/aa bbb cccc/${exp}/g' $^ > $@

################################################################

%.txt : %.ms
	gtbl $< | groff -Tascii -P-c -P-b -P-u -ms | ../fix.pl | sed -e 's/dd mmm/${dd} ${mmm}/g' -e 's/yyyy/${yyyy}/g' -e 's/aa bbb cccc/${exp}/g'  | tail +4  > $@

%.ms : %.m4
	m4 -P $< > $@

################################################################
