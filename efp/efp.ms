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
.ds RH _date_
.ds CH Elvin
.hy 0
.ad l
.in 0
XXX Working Group                                              D. Arnold
Internet Draft                                                   J. Boot
Category: Standards Track                                   M. Henderson
                                                               T. Phelps
                                                               B. Segall
                                                                    DSTC
                                                            dd mmmm _yr_

.ce
Elvin Server Federation Protocol

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
This document describes a protocol for federation of Elvin []
servers.  It enables exchange of message traffic, load-balancing
across local clusters and wide-area links between administrative
domains.

It has no effect on the protocol used for Elvin client to server
communications.

.ti 0
TABLE OF CONTENTS

(tdb) (probably last ;-)

.bp
m4_heading(1, INTRODUCTION)
m4_heading(1, TERMINOLOGY)

Wide-area federation

Local-area federation

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


m4_heading(2, Server Management)


m4_heading(2, Clustering)

Clustering is used to link multiple local servers into a single
address space or subscription scope.

Where an address space has a large number of clients, it can be
necessary to share the evaluation of their subscriptions over multiple
host nodes to achieve adequate performance.  This is analagous to a
web server farm, for example.

Alternatively, where performance is not an issue, it can still be
desirable to have multiple local servers for an address space to
continue service in the face of a server (daemon, node, network)
failure.

At a logical level, the cluster of Elvin servers must appear to
implement a single address space; effectively a virtual server
providing the same service semantics as a single server daemon with
better performance or reliability.

m4_heading(2, Wide-area Federation)

Wide-area federation (in future referred to simply as federation) is
used to link islands of Elvin address spaces together into a single
routing network.  



m4_heading(1, ABSTRACT PROTOCOL)

m4_heading(2, Protocol Overview)

An Elvin server is statically configured with an initial state,
including one or more scope names which it is to provide.  The server
advertises these scope names (together with other information) via a
well-known multicast address as described in [ELVIN].

If other servers are found providing the same scopes, the server
contacts them to obtain the (dynamically allocated) multicast address
used for communication within that scope.

[[[
      this is bogus because we could get multiple copies of a
      message, and we could end up sending it out on multiple mcast
      channels.  if we have just one for the domain however, how do we
      figure what a domain is?  ie. all works fine until a server
      starts that has two configured scopes which join two previously
      independent domains.

      i *think* that i need to change scopes back to having less
      significance.  they are simply a way of controlling clients'
      connectivity to servers, including the ability to partition a
      cluster from a client's POV.

      the principle concept from a clustering POV is the address space
      or domain, which shares a multicast channel, and is orthogonal
      to scopes.  the important thing then is defining a domain.  how
      do we ensure that clients cannot find multiple domains unless we
      want them too.

      or maybe in other words, how do we make all the servers in a
      domain are equally visible to any client (esp wrt server
      discovery).
]]]




Clustered servers communicate using a reliable multicast protocol over
an IP network.  



m4_heading(2, Packet Types)


m4_heading(2, Management Packets)

Remote management of an Elvin server is implemented using a secure
connection to the server in question.  The management protocol
provides a number of operations.

m4_heading(3, Go Idle)

A server process operates in two modes: active, or idle.  An idle
server remains an active process, and continues to process management
requests, but it suspends any activity via the Elvin client protocol.
This is used to provision servers for periods of greater activity, in
a hot-standby role for reliability, etc.

The Go Idle message forces a server from active, into idle mode.  Any
clients currently connected to the server are disconnected and no
further connections are accepted.

The Go Idle packet MAY include a redirection specification, allowing
the server to direct connected clients to a specific alternative
server.  If the redirection string is zero-length, clients MUST NOT be
redirected

m4_pre(
struct GoIdle {
  int32  xid;
  string server;
  string redirection;
};)m4_dnl

m4_heading(3, Go Active)

An idle server process may be made active by sending this message.

m4_pre(
struct GoActive {
  int32 xid;
  string server;
};)m4_dnl


m4_heading(3, Restart)

Restart the server with the current configuration.  Used to reclaim
virtual memory space used by a previously busy server process.  This
spawns a new process from the current process before shutting down the
current process.

m4_pre(
struct Restart {
  int32 xid;
  string server;
};)m4_dnl


m4_heading(3, Shutdown)

Shut down the server.  Once a server has been shut down, it cannot be
restarted by the cluster controller.

m4_pre(
struct Shutdown {
  int32 xid;
  string server;
};)m4_dnl



m4_heading(3, Client Information Request)

Request of client information from the server uses the ClientInfoRqst
packet.  It includes a summary of all the server's current clients.

m4_pre(
struct ClientInfoRqst {
  int32 xid;
  string server;
  int64 clients[];
};)m4_dnl


m4_pre(
struct ClientInfoRply {
  int32 xid;
  struct {
    int64 client;
    string protocol;
    opaque peer_address;
    etc ...
  } clients[];
};)m4_dnl




m4_heading(3, Transfer Client)

m4_pre(
struct TransferClients {
  int32 xid;
  string server;
  string redirection;
  int64 clients[];
};)m4_dnl






m4_heading(3, Add Scope)

Instructs the server to add the specified scope name to the set it
offers.  A server may host any number of scopes; if configured with no
scopes, it is not visible for server discovery.

m4_pre(
struct AddScope {
  int32  xid;
  string name;
};)m4_dnl

If the specified scope is already offered by the server, a Nack reply
is generated.

Note that the addition of a scope will require the server to increment
the advertisement version number for SvrAdvt packets in the client
protocol.

FIXME: what implications on clustering ????

m4_heading(3, Remove Scope)

Instructs the server to stop offering the specified scope.

m4_pre(
struct RemoveScope {
  int32  xid;
  string name;
};)m4_dnl

If the specified name is not offered by the server, a Nack reply is
generated.

Similarly to Add Scope, the removal of a scope from a server requires
that the advertisement version be incremented.

FIXME: what implications on clustering ????


m4_heading(3, Add Protocol)
m4_heading(3, Remove Protocol)
m4_heading(3, Zero Stats)

per subscription:

- notifications/second, average and peak
- bytes/second, average and peak
- terms/subscription, average and peak
- percentage of terms that are exists()
- percentage of terms that are integer ops
- percentage of terms that are simple string ops
- percentage of terms that are regexps
- average length of string elements in notifications
- average length of element names in notifications

per server:

- number of producers, average and peak
- delta producer, average and peak (ie. producer-only
  connect/disconnects per second)
- number of consumers, average and peak
- delta consumer, average and peak (ie. consumer-only
  connect/disconnects per second)
- server load average
- network load ????


m4_heading(3, Get Stats)




.KS
.ti 0
.NH 1
CONTACT
.ft
.in 3

Author's Address

.nf
David Arnold
Julian Boot
Michael Henderson
Ted Phelps
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

