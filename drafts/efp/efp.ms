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
Elvin Project                                                  D. Arnold
Preliminary INTERNET-DRAFT                                     I. Lister
                                                                    DSTC
Expires: aa bbb cccc                                         dd mmm yyyy

.ce
Elvin Router Federation Protocol
.ce
draft-arnold-elvin-federation-prelim-00.txt

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

m4_heading(1, Abstract)

This document describes a protocol for forwarding message traffic
between Elvin servers.  It provide administrative filtering of both
incoming and outgoing traffic.

It has no effect on the protocol used for Elvin client to server
communications, or between server nodes in an Elvin cluster.

m4_heading(1, Introduction)

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

m4_heading(1, Terminology)

This document discusses Elvin clients, client libraries and routers.

An Elvin router is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin messages. A client is a
program that uses an Elvin router, via a client library for a
particular programming language.  A client library implements the
Elvin protocols and manages clients' connections to an Elvin router.

Further details of the Elvin protocol, its entities and their roles is
available in [EP].

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

m4_heading(1, Abstract Protocol)

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
  Federation Connection Reply     FedConnRply             193
  Federation Subscription Modify  FedModify               194
  Federation Notify               FedNotify               195

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

The pull_filter MAY be different from the subscription database of the
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

A server SHOULD NOT forward a FedNotify to a server that has not
requested it i.e. a notification that does not match the server's most
recently positively acknowledged pull_filter.

A server MAY choose to not forward a FedNotify to a server that has
requested it (i.e. a notification that matches the server's most
recently positively acknowledged pull_filter). Some cases in which a
server might choose to do this are if the server or its network
connections are overloaded, or if it has been configured not to send
this type of notification.


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

m4_heading(1, `Security Considerations')

Multiple concrete implementations of the abstract protocol mean that
the federation links can have many different properties, depending
upon the protocol stack(s) used.

The Elvin federation protocol relies on any necessary authentication
being performed by the underlying transport protocols, for example by
verification of SSL certificates.

Administrators of Elvin routers should be careful to ensure that only
appropriate combinations of protocols are offered by their routers.

m4_heading(1, `IANA Considerations')

The TCP port 2916 has been reserved by the IANA for the Elvin
federation protocol using the concrete XDR marshalling protocol.

.KS
m4_heading(Contact)

Author's Address

.nf
David Arnold
Ian Lister

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
.bp
m4_heading(1, `Full Copyright Statement')

Copyright (C) 2000-__yr DSTC Pty Ltd, Brisbane, Australia.

All Rights Reserved.

This specification may be reproduced or transmitted in any form or by
any means, electronic or mechanical, including photocopying,
recording, or by any information storage or retrieval system,
providing that the content remains unaltered, and that such
distribution is under the terms of this licence.

While every precaution has been taken in the preparation of this
specification, DSTC Pty Ltd assumes no responsibility for errors or
omissions, or for damages resulting from the use of the information
herein.

DSTC Pty Ltd welcomes comments on this specification.  Please address
any queries, comments or fixes (please include the name and version of
the specification) to the address below:

.nf
    DSTC Pty Ltd
    Level 7, General Purpose South
    University of Queensland
    St Lucia, 4072
    Tel: +61 7 3365 4310
    Fax: +61 7 3365 4311
    Email: elvin@dstc.com
.fi

Elvin is a trademark of DSTC Pty Ltd.  All other trademarks and
registered marks belong to their respective owners.
