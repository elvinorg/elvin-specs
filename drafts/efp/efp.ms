m4_include(macros.m4)
.pl 10.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Arnold
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH _date_
.ds CH Elvin
.hy 0
.ad l
.in 0
XXX Working Group                                              D. Arnold
Internet Draft                                                      DSTC
Category: Standards Track                                   dd mmmm _yr_

.ce
Elvin Wide-area Federation Protocol

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
Copyright (C) The Internet Society (_yr_).  All Rights Reserved.


.ti 0
ABSTRACT

.in 3
This document describes a protocol for forwarding message traffic
between Elvin servers.  It provide administrative filtering of both
incoming and outgoing traffic.

It has no effect on the protocol used for Elvin client to server
communications, or between server nodes in an Elvin cluster.

.ti 0
TABLE OF CONTENTS

(tdb) (probably last ;-)

.bp
m4_heading(1, INTRODUCTION)
m4_heading(1, TERMINOLOGY)

Wide-area federation

Clustering

Scope

Subscription scope

Address space

Elvin domain

m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.


m4_heading(1, Basic Operation)

Elvin servers, in addition to whatever client/server protocols they
support, use a separate server federation protocol.  This protocol has
several purposes:
.IP 1. 3
management of the server(s)
.IP 3. 3
clustering of local servers for scaling or reliability
.IP 3. 3
linking servers to form wide-area routing networks


m4_heading(2, Wide-area Federation)

Wide-area federation (in future referred to simply as federation) is
used to link islands of Elvin address spaces together into a single
routing network.  

m4_heading(1, ABSTRACT PROTOCOL)

m4_heading(2, Protocol Overview)

An Elvin server may be statically configured 

m4_heading(2, Packet Types)

The protocol is defined in terms of individual packet specifications.
Each packet has two unique identifiers: a string name and a number.
In a concrete protocol implementation, if packets are identified using
a number or string, these values SHOULD be used.

The numeric identifiers have been chosen such that they do not overlap
with the identifiers used for the Elvin client protocol, and both sets
of identifiers can be encoded using a single byte.

.KS
.nf 
  ----------------------------------------------------------------
  Packet Type                     Abbreviation         Identifier
  ----------------------------------------------------------------
  Federation Connection Request   FedConnRqst             192
  Federation Connection Reply     FedConnRply             192
  Federation Subscription Modify  FedModify               193
  Federation Notify               FedNotify               194

  Disconnect                      Disconn                  53
  Acknowledge                     Ack                      65
  Negative Acknowledge            Nack                     48
  
  ----------------------------------------------------------------
.fi
.KE


m4_heading(3, Federation Connection Request)

A server, configured with filters and addressing information for a
remote server, initiates a connection using this request.

m4_pre(
struct FedConnRqst {
  id32 xid;  
  uint32 major_version;
  uint32 minor_version;
  string server_domain;
};)m4_dnl

The server_domain parameter is a unqiue UTF-8 string identifying the
local server or cluster.  It is used to prevent importation of traffic
which has previously been exported from the local domain.  This means
that it MUST be globally unique for a single server, or for all
servers in a cluster.  It is RECOMMENDED that this name be based on
the DNS domain name or IP address of the server's host machine(s).

m4_heading(3, Federation Connection Reply)

A server, having received a FedConnRqst, responds with either a Nack (if
the request was unsuccessful) or a FedConnRply (if the request was
successful).

m4_pre(
struct FedConnRply {
  id32 xid;
  string server_domain;
};)m4_dnl

m4_heading(3, Federation Subscription Modify)

Each of the linked servers may optionally provide a compiled Elvin
subscription expression, known as the pull_filter, describing the
traffic requested by clients of the local server. Either of the linked
servers may request a modification of their registered pull_filter at
any time during the life of the connection, by sending a FedModify.

m4_pre(
struct FedModify {
  id32 xid;
  SubAST pull_filter;
};)m4_dnl

The pull_filter MAY be simplified to minimise updates caused by minor
changes to the local subscription base.

The receiving server MUST process the request, and return either an
Ack or a Nack, depending on the validity of the SubAST.


m4_heading(3, Federation Notify)

Notification traffic is sent between the servers using the FedNotify
packet.  

m4_pre(
struct FedNotify {
  NameValue attributes[];
  boolean deliver_insecure;
  Keys keys;
  string routing[];
};)m4_dnl

The routing list consists of the unique signatures of domains
that have previously seen this packet.  For those servers with
multiple federation links, packets MUST NOT be forwarded through links whose
registered signature is already present in the routing hash.

Before forwarding a FedNotify, a server MUST insert its own signature
into the routing list to prevent it being delivered again.  However,
if a notification is received where the routing list contains the
signature of the receiving server, it MUST be silently dropped.



.KS
.ti 0
.NH 1
CONTACT
.ft
.in 3

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
.ti 0
.NH 1
FULL COPYRIGHT STATEMENT
.ft
.in 3

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

