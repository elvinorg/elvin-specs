m4_include(macros.m4)
.pl 10.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Arnold, Boot & Segall
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH dd mmmm 1999
.ds CH Elvin
.hy 0
.ad l
.in 0
Network Working Group                                          D. Arnold
Internet Draft                                                   J. Boot
Category: Standards Track                                      T. Maslen
                                                               B. Segall
                                                                    DSTC
                                                            dd mmmm 1999


.ce
Elvin \- An Internet Notification System

.ti 0
Status of this Memo

.in 3
This document specifies an Internet standards track protocol for the
Internet community, and requests discussion and suggestions for
improvements.  Please refer to the current edition of the "Internet
Official Protocol Standards" (STD 1) for the standardization state and
status of this protocol.  Distribution of this memo is unlimited.

.ti 0
Copyright Notice

.in 3
Copyright (C) The Internet Society (1999).  All Rights Reserved.


.ti 0
ABSTRACT

.in 3
This document describes the Elvin notification service: its
architecture, protocols, packet formats, operational semantics,
programming interfaces and management.

.ti 0
TABLE OF CONTENTS

(tdb) (probably last ;-)

.bp
m4_heading(1, INTRODUCTION)

Undirected communication, where the sender is unaware of the identity,
location or even existence of the receiver, is not currently provided
by the Internet protocol suite.  This style of messaging, also called
"publish/subscribe", is typically implemented using a notification
service.

Notification service clients can be characterised as producers, which
detect conditions, and emit notifications; and consumers, which
request delivery of notifications from the service.  Comsumers
normally subscribe to receive notifications matching some supplied
criteria.

While directed communication is well serviced by the Internet protocol
suite, undirected communications is limited to UDP multicast.  While
UDP multicast is appropriate for many applications, it is inherently
channel-based: a particular address and port must be shared by the
communicating applications.

Elvin is a notification service which provides fast, simple,
undirected messaging, using content-based selection of delivered
messages.  It has been show to work on a wide-area scale and is
designed to complement the existing Internet protocols.


m4_heading(1, TERMINOLOGY)

This document discusses clients, client libraries, servers, producers,
consumers, subscription, notification, events and federation.  

The Elvin server is a background process that runs on a single server.
It acts as a distribution mechanism for event notifications. A client
is a program which uses the Elvin server, via the client library for a
particular programming language.  The client library implements the
Elvin protocol and manages that client's connection to the server.

Clients can have two roles: producer or consumer.  Producer clients
detect events of interest, and send a notification describing that
event to the server using the client library.  Consumer clients
subscribe to the server, requesting delivery of notifications matching
a subscription language query.  Some clients can be both producers and
consumers of notifications.

Elvin servers can also act as clients, enabling groups of servers to
exchange notifications.  This grouping, called federation, allows the
system to scale beyond a single company or network.

.nf
   int32    Signed 32-bit integer

   int64    Signed 64-bit integer

   real64   Double precision float using IEEE standard encoding 

   string   Variable length string, UTF8 encoded and are NOT null
            terminated.  
  
   opaque   Variable length byte array

   server   the process and/or host computer distributing 
            notifications to and from connected clients.

   client   A process that interacts with an Elvin server as a
            producer or consumer of notifications.
.fi

m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.


m4_include(architecture.m4)
m4_include(basic-impl.m4)
m4_include(slp.m4)

m4_include(abstract-protocol.m4)



m4_heading(2, Protocols)
m4_heading(3, Marshalling)
m4_heading(3, Security)
m4_heading(3, Transport)

m4_heading(2, Interoperability)
m4_heading(3, Server Features)
m4_heading(3, Protocols)
m4_heading(3, Standard Protocol)

overview: TCP/SSL, XDR

Elvin4 supports a 3-layer protocol stack, providing separate
marshalling, security and transport options.  While the content of the
resulting data packets composed by each of these layers is specified
by this document, the programming interfaces are internal to an
implementation.

An Elvin4 implementation MAY support any number of distinct
combinations of protocols.  An Elvin4 implementation MUST support the
standard protocol stack comprised of XDR marshalling, SSL-3 security
and TCP/IP transport.  This combination is known as the Elvin4
standard protocol.

Additional protocol layers must be proposed and registered via the
IETF RFC series, either as a revision to this document, or as a
separate specification.

m4_heading(4, Marshalling)

m4_include(xdr-encoding.m4)

m4_heading(4, Security)

null

m4_heading(4, Transport)

tcp

TCP/IP is the standard transport protocol for Elvin4 Standard
Protocol.  Each client maintains a TCP connection to the server
daemon.  Either side (client or server) may close this connection at
any time, triggering reconnection handling by the client library.

The connection is established to a port advertised by the server.
Once the connection is open, the server must determine the security
protocol required for the connection.  how?

m4_heading(2, Federation)
m4_heading(3, Objectives)
m4_heading(3, Local Area)
m4_heading(3, Wide Area)
m4_heading(4, Network Issues)
m4_heading(4, Security)


m4_heading(2, Quality of Service)
m4_heading(3, Fairness)
m4_heading(3, Policies)


m4_heading(2, Environment)

.nf
ports
location
service names
environment variables
file usage
- /etc/elvind.conf
- /etc/slp.conf
registry
.fi


m4_heading(1, SECURITY CONSIDERATIONS)

m4_include(sub-syntax.m4)
m4_include(c-api.m4)
m4_include(java-api.m4)
m4_include(python-api.m4)
m4_include(slp-template.m4)
m4_include(bib.m4)

.KS
m4_heading(1, CONTACT)

Author's Address

.nf
David Arnold
Julian Boot
Thomas Maslen
Bill Segall

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
m4_heading(1, FULL COPYRIGHT STATEMENT)

Copyright (C) The Internet Society (1999).  All Rights Reserved.

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
