m4_define(__title, `Elvin Client Access Protocol')
m4_include(macros.m4)m4_dnl
.pl 10.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Arnold, ed.
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH __date
.ds CH Elvin
.hy 0
.ad l
.in 0
Elvin.Org                                              D. Arnold, Editor
Preliminary INTERNET-DRAFT                              Mantara Software

Expires: aa bbb cccc                                         _d __m __yr

.ce
__title
.ce
__file

m4_heading(1, Status of this Memo)

This document is an Internet-Draft and is NOT offered in accordance
with Section 10 of RFC2026, and the author does not provide the IETF
with any rights other than to publish as an Internet-Draft.

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

This document describes a client access protocol for the Elvin
notification service.  It includes a general overview of the system
architecture, and defines an access protocol in terms of operational
semantics, an abstract protocol, and a default concrete implementation
of the abstract protocol.

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
