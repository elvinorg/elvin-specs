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

The Elvin protocol provides undirected, content-routed messaging
between any number of clients connected to a single cluster of
servers. The Elvin cluster protocol allows these clients to be
connected to any of a group of cooperating, typically co-located
servers, by tightly joining these servers into a single logical
entity.

The purpose of this document is to define a new protocol in the Elvin
suite that allows loose joining of servers, each potentially located
anywhere on the Internet, into a federated Elvin service.

This protocol allows for administrative control over each autonomous
system and its connections to other parts of the Elvin federation,
including control over what notifications are permitted to travel in
and out of each server.

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

The numeric identifiers for new kinds of packets have been chosen such
that they do not overlap with the identifiers used for the Elvin
client protocol, and both sets of identifiers can be encoded using a
single byte. Some packets share the same semantics as in the Elvin
client protocol, so the same identifiers are used.

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
that it MUST be globally unique for each single server or cluster, but
it MUST be identical for each server within a single cluster.  It is
RECOMMENDED that this name be based on the DNS domain name or IP address
of the server's host machine(s).

A server receiving a FedConnRqst MUST check that it is compatible with
the protocol version specified in the packet. To be compatible, the
server must be able to use a version of the protocol with the major
component being equal to the version requested, and the minor
component being greater than or equal to the version requested. If a
server cannot meet this requirement it MUST immediately close the
connection, as for a protocol violation.

The version of the protocol specified in this document has a major
component of one (1) and a minor component of zero (0). This can be
represented in text form as 1.0.

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

The pull_filter MAY NOT exactly reflect the subscription database of the
sender; for example it MAY be made more general to minimise updates caused
by minor changes to the local subscription database, and/or it MAY be made
more specific to prevent importation of notifications known to be unwanted
(despite matching local subscriptions).

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

A server SHOULD NOT forwarding a FedNotify to a server that has not
requested it i.e. a notification that does not match the server's most
recently positively acknowledged outgoing_filter.

A server MAY NOT forward a FedNotify to a server that has requested it
(i.e. a notification that matches the server's most recently positively
acknowledged outgoing_filter).


m4_heading(2, Configuration)

It is beyond the scope of this document to describe how implementations
may be configured to control the flow of notifications between servers,
but there are some important points for implementers and administrators
to consider.

The Elvin federation protocol assumes a that federation links are
configured to form a spanning tree. This means that for any given pair
of servers there is only one possible route for any given notification
to travel from one server to the other.

Future revisions of the protocol may provide for automatic detection
or configuration.



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

