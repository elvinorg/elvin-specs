m4_define(__title, `Elvin Client Protocol')
m4_include(macros.m4)m4_dnl
m4_include(head.m4)m4_dnl

.ce
__title
.ce
__file

m4_heading(1, Status of this Memo)

This document specifies an Internet standards track protocol for the
Internet community, and requests discussion and suggestions for
improvements.  Please refer to the current edition of the "Internet
Official Protocol Standards" (STD 1) for the standardization state and
status of this protocol.  Distribution of this memo is unlimited.

Internet-Drafts are working documents of the Internet Engineering Task
Force (IETF), its areas, and its working groups.  Note that other
groups may also distribute working documents as Internet-Drafts.

Internet-Drafts are draft documents valid for a maximum of six months
and may be updated, replaced, or obsoleted by other documents at any
time.  It is inappropriate to use Internet- Drafts as reference
material or to cite them other than as "work in progress."

The list of current Internet-Drafts can be accessed at
http://www.ietf.org/1id-abstracts.html

The list of Internet-Draft Shadow Directories can be accessed at
http://www.ietf.org/shadow.html

m4_heading(1, ABSTRACT)

This document describes the Elvin notification service: its
architecture, protocols, packet formats, operational semantics,
programming interfaces and management.

m4_dnl .ti 0
m4_dnl TABLE OF CONTENTS
m4_dnl (tdb) (probably last ;-)
.bp

m4_include(introduction.m4)
m4_include(terminology.m4)
m4_include(architecture.m4)
m4_include(basic-impl.m4)
m4_include(abstract-protocol.m4)
m4_include(protocol-impl.m4)
m4_include(security-issues.m4)
m4_include(sub-syntax.m4)
m4_include(bib.m4)
m4_include(contact.m4)
m4_include(copyright.m4)
