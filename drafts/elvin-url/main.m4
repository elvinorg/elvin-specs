m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_include(macros.m4)m4_dnl

.\" page length 10 inches
.pl 10.0i
.\" page offset 0 lines
.po 0
.\" line length (inches)
.ll 7.2i
.\" title length (inches)
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Arnold, et al
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH dd mmm yyyy
.ds CH Elvin URL
.\" hyphenation mode 0
.hy 0
.\" adjust left
.ad l
.\" indent 0
.in 0
Elvin Project                                                  D. Arnold
Internet Draft                                                      DSTC
Expires:  aa bbb cccc                                        dd mmm yyyy
                     

.ce
Elvin URL Scheme
.ce
draft-arnold-elvin-url-00pre.txt

m4_heading(1, Status of this Memo)

.in 3
This document is an Internet-Draft and is subject to all provisions of
Section 10 of RFC2026 except that the right to produce derivative
works is not granted.

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

m4_heading(1, Abstract)


m4_heading(1, Introduction)

Undirected communication, where the sender is unaware of the identity,
location or even existence of the receiver, is not currently provided
by the Internet protocol suite.  This style of messaging, also called
"publish/subscribe", is typically implemented using a notification
service.

Notification service clients can be characterised as producers, which
detect conditions, and emit notifications; and consumers, which
request delivery of notifications from the service.  Consumers
normally subscribe to receive notifications matching some supplied
criteria.

While directed communication is well serviced by the Internet protocol
suite, undirected communications is limited to IP multicast.  While IP
multicast is appropriate for many applications, it is inherently
channel-based: a particular address and port must be shared by the
communicating applications.

Elvin is a notification service which provides fast, simple,
undirected messaging, using content-based selection of delivered
messages.  It has been show to work on a wide-area scale and is
designed to complement the existing Internet protocols.

The Elvin protocol is designed to provide undirected, content-routed
messaging.  The raw protocol is expected to be accessed via an
interface library, not unlike the Berkeley sockets interface.  Unlike
sockets, however, the use of message content for routing requires that
the message body be structured.

The messages are routed from their source to required destinations by
Elvin router(s).  Delivery has best-effort, at-most-once semantics.
Under no circumstances will an Elvin client receive duplicate
messages.  Messages from a single source must be delivered in order,
but interleaving of messages from different sources is allowed in any
order.

Inter-router routing is not specified by this document.  It is noted,
however, that messages are forwarded between routers, and that such
journeys are subject to filtering and greater latency than messages
between clients of a single router process.

m4_heading(1, Terminology)

This document discusses clients, client libraries, routers, producers,
consumers, quenchers, messages, and subscriptions.

An Elvin router is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin message. A client is a
program that uses the Elvin router, via a client library for a
particular programming language.  A client library implements the
Elvin protocol and manages clients' connections to an Elvin router.

Clients can have three roles: producer, consumer or quencher.
Producer clients create structured messages and send them, using a
client library, to an Elvin router.  Consumer clients establish a
session with an Elvin router and register a request for delivery of
messages matching a subscription expression.  Quenching clients also
establish a session with a router, and register a request for
notification of changes to the router's subscription database that
match criteria supplied by the quencher.

Clients MAY take any number of the producer, consumer and quencher
roles concurrently.
m4_dnl
m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.


m4_heading(1, `URL Scheme Name')

The scheme name is: elvin

m4_heading(1, Syntax)

elvin:<version>/<protocol>/<endpoint>;<option>;<option=value>

m4_heading(2, `TCP Endpoint Syntax')

<hostname|IPv4-addr|IPv6-addr>[:port]

m4_heading(2, `UDP Endpoint Syntax')

<hostname|IPv4-addr|IPv6-addr>[:port]

m4_heading(2, `HTTP Endpoint Syntax')

[username[:password]@]<hostname|IPv4-addr|IPv6-addr>[:port]

m4_heading(2, `Unix Endpoint Syntax')

<hostname|IPv4-addr|IPv6-addr>/path[/path]*

m4_heading(1, `Character Encoding Considerations')

Elvin URLs normally contain only those characters present in the DNS
names of the hosting servers.  However, it is possible that the URL
options, or a yet to be defined endpoint syntax, could require
non-ASCII characters.  In such cases, characters should be encoded as
UTF-8, and represented using the normal URL encoding %xx.

m4_heading(1, `Intended Usage')

Elvin URLs are normally used in two ways: for specification of an
Elvin server in a client application by a human user, and, in
advertisements of server endpoints emitted by an Elvin server.

m4_heading(1, `Applications and/or Protocols Using the Scheme')

The scheme is used by the Elvin access protocol.

m4_heading(1, `Interoperability Considerations')

hmmmm.

m4_heading(1, `Security Considerations')

????

m4_heading(1, `IANA Considerations')

Are discussed in the Elvin Client Protocol.

m4_heading(1, `Relevant Publications')

m4_heading(1, `Contact for further information')

m4_heading(1, `Author/Change controller')

m4_dnl  bibliography
m4_dnl
m4_dnl  -*-nroff-mode-*-
m4_dnl
.bp
m4_heading(1, REFERENCES)

.IP [RFC1832] 12
Srinivasan, R.,
"XDR: External Data Representation Standard",
RFC 1832, August 1995.

.IP [RFC2234] 12
Crocker, D., Overell, P., 
"Augmented BNF for Syntax Specifications: ABNF", 
RFC 2234, November 1997.

.IP [RFC2279] 12
Yergeau, F.,
"UTF-8, a transformation format of ISO 10646",
RFC 2279, January 1998.

.IP [UNICODE] 12
Unicode Consortium, The,
"The Unicode Standard, Version 2.0",
Addison-Wesley, February 1997.

.IP [POSIX.1] 12
IEEE,
"POSIX.1-1990",
1990.

.IP [RFC2119] 12
Bradner, S.,
"Key words for use in RFCs to Indicate Requirement Levels"
RFC2119, March 1997

.IP [RFC2717] 12
Rich Petke and Ian King,
"Registration Procedures for URL Scheme Names"
RFC2717, November 1999

.IP [RFC2718] 12
L. Masinter, H. Alvestrand, D. Zigmond, R. Petke,
"Guidelines for new URL Schemes"
RFC2718, November 1999


RFC2396


.KS
m4_heading(1, Contact)

Author's Address

.nf
David Arnold

Distributed Systems Technology Centre
Level7, General Purpose South
Staff House Road
University of Queensland
St Lucia QLD 4072
Australia

Phone:  +617 3365 4310
Fax:    +617 3365 4311
Email:  elvin@dstc.edu.au
.fi
.KE


.KS
m4_heading(1, Full Copyright Statement)

Copyright (C) The Internet Society (yyyy).  All Rights Reserved.

This document and translations of it may be copied and furnished to
others, and derivative works that comment on or otherwise explain it
or assist in its implmentation may be prepared, copied, published and
distributed, in whole or in part, without restriction of any kind,
provided that the above copyright notice and this paragraph are
included on all such copies and derivative works.  However, this
document itself may not be modified in any way, such as by removing
the copyright notice or references to the Internet Society or other
Internet organizations, except as needed for the purpose of
developing Internet standards in which case the procedures for
copyrights defined in the Internet Standards process must be
followed, or as required to translate it into languages other than
English.

The limited permissions granted above are perpetual and will not be
revoked by the Internet Society or its successors or assigns.

This document and the information contained herein is provided on an
"AS IS" basis and THE INTERNET SOCIETY AND THE INTERNET ENGINEERING
TASK FORCE DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO ANY WARRANTY THAT THE USE OF THE INFORMATION
HEREIN WILL NOT INFRINGE ANY RIGHTS OR ANY IMPLIED WARRANTIES OF
MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE."
.KE
