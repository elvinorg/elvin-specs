m4_include(macros.m4)m4_dnl
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
                                                               T. Phelps 
                                                               B. Segall
                                                                    DSTC
                                                            dd mmmm 2000


.ce
Elvin \- Content-Addressed Messaging Protocol

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
Copyright (C) The Internet Society (2000).  All Rights Reserved.


.ti 0
ABSTRACT

.in 3
This document describes the Elvin notification service: its
architecture, protocols, packet formats, operational semantics,
programming interfaces and management.

.ti 0
TABLE OF CONTENTS

(tdb) (probably last ;-)

m4_include(introduction.m4)
m4_include(terminology.m4)

m4_include(architecture.m4)
m4_include(basic-impl.m4)
m4_include(abstract-protocol.m4)


m4_heading(1, PROTOCOL IMPLEMENTATION)
m4_heading(2, Layering and Modules)
m4_heading(3, Marshalling)
m4_heading(3, Security)
m4_heading(3, Transport)

m4_heading(2, Interoperability)
m4_heading(3, Server Discovery)
m4_heading(3, Protocol Selection)
m4_heading(3, Server Features)
m4_heading(2, Standard Protocol)

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

m4_heading(3, Marshalling)

m4_include(xdr-encoding.m4)

m4_heading(3, Security)

null

m4_heading(3, Transport)

tcp

TCP/IP is the standard transport protocol for Elvin4 Standard
Protocol.  Each client maintains a TCP connection to the server
daemon.  Either side (client or server) may close this connection at
any time, triggering reconnection handling by the client library.

The connection is established to a port advertised by the server.
Once the connection is open, the server must determine the security
protocol required for the connection.  how?


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
m4_include(contact.m4)
m4_include(copyright.m4)
