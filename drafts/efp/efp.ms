.\" -*- nroff -*-
.\" ################################################################
.\" COPYRIGHT_BEGIN
.\"
.\" Copyright (C) 2000-2007 Elvin.Org
.\" All rights reserved.
.\"
.\" Redistribution and use in source and binary forms, with or without
.\" modification, are permitted provided that the following conditions
.\" are met:
.\"
.\" * Redistributions of source code must retain the above
.\"   copyright notice, this list of conditions and the following
.\"   disclaimer.
.\"
.\" * Redistributions in binary form must reproduce the above
.\"   copyright notice, this list of conditions and the following
.\"   disclaimer in the documentation and/or other materials
.\"   provided with the distribution.
.\"
.\" * Neither the name of the Elvin.Org nor the names
.\"   of its contributors may be used to endorse or promote
.\"   products derived from this software without specific prior
.\"   written permission. 
.\"
.\" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
.\" "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
.\" LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
.\" FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
.\" REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
.\" INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
.\" BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
.\" LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
.\" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
.\" LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
.\" ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
.\" POSSIBILITY OF SUCH DAMAGE.
.\"
.\" COPYRIGHT_END
.\" ################################################################
m4_define(__title,`Elvin Federation Protocol 1.0')m4_dnl
m4_include(macros.m4)m4_dnl
.pl 11.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.nr PI 3n
.ds LF Arnold and Lister
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH __date
.ds CH __title
.hy 0
.ad l
Elvin.Org                                                      D. Arnold
Preliminary INTERNET-DRAFT                                     I. Lister
                                                            Mantara, Inc
Expires: aa bbb cccc                                         _d __m __yr

.DS C
__title
__file
.DE
m4_dnl Header macros end an indent, so start one here
.RS
m4_dnl
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
between Elvin routers.  It provides administrative filtering of both
incoming and outgoing traffic.

It has no effect on the protocol used for Elvin client to router
communications, or between router nodes in an Elvin cluster.

m4_heading(1, Introduction)

The Elvin protocol provides undirected, content-routed messaging
between any number of clients connected to a single cluster of
routers. The Elvin cluster protocol allows these clients to be
connected to any of a group of cooperating, typically co-located
routers, by tightly joining these routers into a single logical
entity.

The purpose of this document is to define a protocol in the Elvin
suite that allows loose joining of routers, each potentially located
anywhere on the Internet, into a federated Elvin service.

This protocol allows for administrative control over each autonomous
system and its connections to other parts of the Elvin federation,
including control over what notifications are permitted to travel in
and out of each router.

m4_heading(1, Terminology)

This document discusses Elvin clients, client libraries and routers.

An Elvin router is a server process that runs on a single machine.  It
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

Elvin routers, in addition to whatever client connection protocols
they support, use a separate router federation protocol.  This
protocol has several purposes:
.IP 1. 3
management of the router(s)
.IP 3. 3
clustering of local routers for scaling or reliability
.IP 3. 3
linking routers to form wide-area routing networks

m4_heading(2, Wide-area Federation)

Wide-area federation (in future referred to simply as federation) is
used to link islands of Elvin address spaces together into a single
routing network.  

m4_heading(1, Abstract Protocol)

m4_heading(2, Protocol Overview)

An Elvin router may be statically configured with an initial state.
This state may include directions to initiate federation relationships
with other routers or to accept federation relationships with other
routers.

Federation relationships consist of a reliable one-to-one connection
between two routers and may optionally include administrative filters
at each end.  Two federated routers share information about their own
registered subscriptions in order to forward matching Elvin
notification traffic to each other.  The subscription information is
shared in the form of an abstract syntax tree of a single aggregate
Elvin subscription expression representing the union of all
subscriptions registered at a router (excluding that registered by the
other router in the federation relationship).

Incoming notifications are evaluated for forwarding to connected
routers in addition to any connected clients.  Handling of a
notification received from a federated router is largely the same as
handling a notification received from a client, with the exception
that the notification is not sent back to the router from which it was
received.

.KS
.nf
                                  +--------------+ Elvin
   +----------+                   | +----------+ | Federation
   | Producer | ---NotifyEmit------>| Router 1 | |
   +----------+                   | +----------+ |
                                  |      |       |
                                  |      |       |
                                  |      V       |
   +----------+                   | +----------+ |
   | Consumer | <--NotifyDeliver--- | Router 2 | |
   +----------+                   | +----------+ |
                                  +--------------+
                                                   NOTIFICATION PATH
.fi
.KE

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
  Federation Subscription Replace FedSubReplace           194
  Federation Notify               FedNotify               195

  Disconnect                      Disconn                  53
  Acknowledge                     Ack                      65
  Negative Acknowledge            Nack                     48
  Drop Warn                       DropWarn                 62
  Test Connection                 TestConn                 63
  Confirm Connection              ConfConn                 64

  ----------------------------------------------------------------
.fi
.KE


m4_heading(3, Federation Connection Request)

A router, configured with filters and addressing information for a
remote router, initiates a connection using this request.

m4_pre(
struct FedConnRqst {
  id32 xid;  
  uint32 major_version;
  uint32 minor_version;
  string router_domain;
};)m4_dnl

The xid field is a number identifying this request.  It must be unique
among all outstanding requests on any one connection at any one time.
Successive requests SHOULD use an xid that increments by one for each
request.

The router_domain parameter is a unique UTF-8 string identifying the
local router or cluster.  It is used to prevent importation of traffic
which has previously been exported from the local domain.  This means
that it MUST be globally unique for each single router or cluster, and
it MUST be identical for each router within a single cluster.  It is
RECOMMENDED that this name be based on the DNS domain name or IP
address of the router's host machine(s).

A router receiving a FedConnRqst MUST check that it is compatible with
the protocol version specified in the packet. To be compatible, the
router must be able to use a version of the protocol with the major
component being equal to the version requested, and the minor
component being greater than or equal to the version requested. If a
router cannot meet this requirement it MUST immediately close the
connection, as for a protocol violation.

The version of the protocol specified in this document has a major
component of one (1) and a minor component of zero (0).  This can be
represented in text form as 1.0.

m4_heading(3, Federation Connection Reply)

A router, having received a FedConnRqst, responds with either a Nack
(if the request was unsuccessful) or a FedConnRply (if the request was
successful).  If the router_domain in the received FedConnRqst is the
same as the router_domain of any other known directly connected router
or the same as the receiving router's own router_domain, the router
MUST respond with a Nack.

m4_pre(
struct FedConnRply {
  id32 xid;
  string router_domain;
};)m4_dnl

The xid field MUST be set to the same value as that in the FedConnRqst
being responded to.  A FedConnRply MUST NOT be sent other than in
response to a FedConnRqst.

The router_domain field contains a unique identifier for the sending
router or cluster, in the same way as the router_domain sent in a
FedConnRqst.

m4_heading(3, Federation Subscription Replace)

Each of the linked routers may optionally provide a compiled Elvin
subscription expression, known as the pull_filter, describing the
traffic requested by clients of the local router. Either of the linked
routers may request a replacement of their registered pull_filter at
any time during the life of the connection, by sending a FedSubReplace.

m4_pre(
struct FedSubReplace {
  id32 xid;
  SubAST pull_filter;
};)m4_dnl

The pull_filter MAY be different from the subscription database of the
sender; for example it MAY be made more general to minimise updates caused
by minor changes to the local subscription database, and/or it MAY be made
more specific to prevent importation of notifications known to be unwanted
(despite matching local subscriptions).

The receiving router MUST process the request, and return either an
Ack or a Nack, depending on the validity of the SubAST.


m4_heading(3, Federation Notify)

Notification traffic is sent between the routers using the FedNotify
packet.  

m4_pre(
struct FedNotify {
  NameValue attributes[];
  boolean deliver_insecure;
  Keys keys;
  string routing[];
};)m4_dnl

The routing list consists of the unique signatures of domains
that have previously seen this packet.  For those routers with
multiple federation links, packets MUST NOT be forwarded through links whose
registered signature is already present in the routing list.

Before forwarding a FedNotify, a router MUST insert its own signature
into the routing list to prevent it being delivered again.  However,
if a notification is received where the routing list contains the
signature of the receiving router, it MUST be silently dropped.

A router SHOULD NOT forward a FedNotify to a router that has not
requested it i.e. a notification that does not match the router's most
recently positively acknowledged pull_filter.

A router MAY choose to not forward a FedNotify to a router that has
requested it (i.e. a notification that matches the router's most
recently positively acknowledged pull_filter). Some cases in which a
router might choose to do this are if the router or its network
connections are overloaded, or if it has been configured not to send
this type of notification.

m4_heading(2, Configuration)

It is beyond the scope of this document to describe how implementations
may be configured to control the flow of notifications between routers,
but there are some important points for implementers and administrators
to consider.

The Elvin federation protocol assumes a that federation links are
configured to form a spanning tree. This means that for any given pair
of routers there is only one possible route for any given notification
to travel from one router to the other.

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

Email: specs@elvin.org
.fi
.KE
.bp
m4_heading(1, `Full Copyright Statement')

Copyright (C) 2000-__yr Elvin.Org
All Rights Reserved.

This specification may be reproduced or transmitted in any form or by
any means, electronic or mechanical, including photocopying,
recording, or by any information storage or retrieval system,
providing that the content remains unaltered, and that such
distribution is under the terms of this licence.

While every precaution has been taken in the preparation of this
specification, Mantara Software assumes no responsibility for errors
or omissions, or for damages resulting from the use of the information
herein.

Elvin.Org welcomes comments on this specification.  Please address any
queries, comments or fixes (please include the name and version of the
specification) to the address below:

.nf
    Email: specs@elvin.org
.fi

All trademarks and registered marks belong to their respective owners.
