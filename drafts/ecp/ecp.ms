m4_include(macros.m4)
.pl 10.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Arnold & Boot
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH _date_
.ds CH ESCP
.hy 0
.ad l
.in 0
XXX Working Group                                              D. Arnold
Internet Draft                                                   J. Boot
Category: Standards Track                                   dd mmmm _yr_

.ce
Elvin Server Clustering Protocol

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
servers.  It enables exchange of message traffic and load-balancing
across local clusters.

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
subscription space.

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

m4_heading(1, ABSTRACT PROTOCOL)

m4_heading(2, Protocol Overview)

An Elvin server is statically configured with an initial state.  This
state may include a direction to participate in a server cluster.
Servers in a cluster communicate using a reliable multicast protocol
over an IP network.

To implement a common subscription space, all clustered servers
maintain awareness of the traffic required by each server's clients.
Arriving notifications are forwarded to servers in the cluster as
required.  

The awareness of other server's subscriptions is currently limited to
the set of notification element names for which each server has
subscriptions.  Further knowledge that will enable the ingress server
to discard more traffic will be shared in a later protocol revision.

Incoming notifications are evaluated for forwarding to all servers
requiring traffic containing those element names.  On receiving a
forwarded notification, a server performs further evaluation,
delivering the notification to the subscriptions it matches.

In addition to this basic data traffic, the clustered servers are able
to be managed from any inidividual server in the cluster.  This
management includes both reporting and control functions.  Individual
servers accept management requests, and where required, forward these
across the cluster.  Statistical and other reporting information is
emitted by each server, and a cluster-wide summary is collated for
presentation to a remote management client by each server.

m4_heading(2, Packet Types)

The protocol is defined in terms of individual packet specifications.
Each packet has two unique identifiers: a string name and a number.
In a concrete protocol implementation, if packets are identified using
a number or string, these numeric values SHOULD be used.

The numeric identifiers have been chosen such that they do not overlap
with the identifiers used for the Elvin client protocol, and both sets
of identifiers can be encoded using a single byte.

.KS
.nf 
  ----------------------------------------------------------------
  Packet Type                   Abbreviation         Identifier
  ----------------------------------------------------------------
  Activate                      Activate                128
  Standby                       Standby                 129
  Restart                       Restart                 130
  Shutdown                      Shutdown                131
  Server Config Notify          ServerConfigNotify      132
  Negative Acknowledge          ServerNack              133

  Cluster Join Request          ClstJoinRqst            160
  Clister Join Reply            ClstJoinRply            161

  Cluster Term Add              ClstTermAdd             162
  Cluster Term Delete           ClstTermDel             163

  Cluster Notify                ClstNotify              164

  Cluster Redirect              ClstRedir               165
  Cluster Leave                 ClstLeave               167

  
  ----------------------------------------------------------------
.fi
.KE

m4_heading(2, Management Packets)

Management of an Elvin server is implemented using a secure connection
either directly to the server in question, or to any server in the
cluster of which it is a member.

All management operations are considered privileged, and MUST require
that the identity of the requestor be authenticated prior to
authorisation of the request.

When invoked from a server, a management operation may refer either to
that server alone, to another single server, or to multiple servers.
When the operation applies to any server other than that initiating
the operation, the request MUST be multicast.

Regardless of whether the operation was requested directly, or via
multicast from another server in the cluster, the affected server(s)
MUST multicast a ServerConfigNotify packet describing their new state.

.nf
*** additional operations here could include: changing the log level,
*** enabling/disabling protocols (and thus offers), interface usage,
*** QoS value changes, etc.

*** once we have a large cluster, these notifications will be
*** problematic.  maybe it is better to always multicast the request,
*** and then rely on the NACK if things don't go as planned?

*** having done that, what if we were expecting a NACK (like, an
*** active server been told to go active) but don't see one?  do we
*** need a ConfigQuery?  or should we abort?  eek ...
.fi

m4_heading(3, Server Config Notify)

Describe the status of a server.  Sent in response to a (successful)
request to change a server's status.

m4_pre(
struct ServerConfigNotify {
  id32 xid;
  id16 server_id;
  id8  mode;
};)m4_dnl

m4_heading(3, Management Nack)

Return an error result to a requested operation.

m4_pre(
struct ServerNack {
  id32 xid;
  id32 error_code;
  string default_template;
  Value args[]
};)m4_dnl

m4_heading(3, Activate)

A server process operates in two modes: active, or standby.  A server
in standby state remains an active process, and continues to process management
requests, but it suspends any activity via the Elvin client protocol.
This is used to provision servers for periods of greater activity, in
a hot-standby role for reliability, etc.

A standby server process may be made active by sending this message.

m4_pre(
struct Activate {
  id32 xid;
  id16 server_ids[];
};)m4_dnl

m4_heading(3, Standby)

The Standby message forces a server from active into standby mode.
The server MUST withdraw any currently offered protocols, and stop
accepting client connections.

Any clients connected to the specified server(s) MUST be disconnected
(without redirection).  It is RECOMMENDED that explicit redirection be
performed prior to a Standby.

m4_pre(
struct Standby {
  id32 xid;
  id16 server_ids[];
};)m4_dnl

m4_heading(3, Restart)

Restart the server with the current configuration.  Used to reclaim
virtual memory space used by a previously busy server process.

If the server is not currently in standby mode, a ServerActive error
MUST be returned.

m4_pre(
struct Restart {
  id32 xid;
  id16 server_ids[];
};)m4_dnl

m4_heading(3, Shutdown)

Shut down the server.  Once a server has been shut down, it cannot be
restarted via the Elvin protocols.

If the server is not currently in standby mode, a ServerActive error
MUST be returned.

m4_pre(
struct Shutdown {
  id32 xid;
  id16 server_ids[];
};)m4_dnl

m4_heading(3, Cluster Join Request)

Multicast request to the cluster to join its managed cluster.
The server and urls fields match the information sent in SvrAdvt
packets by the server, and are used to allow the cluster to take over
the role of advertising server endpoints to client programs.

m4_pre(
struct ClstJoinRqst {
  id32 xid; 
  string server;        /* unique name for server */
  string urls[];        /* set of URLs for server */
};)m4_dnl

If a node gets no response after a reasonable timeout (?) then it
should assume that it is the first node in the cluster and assume
the role of "leader".  The leader is responsible for responding to
further ClstJoinRqst's and also to client discovery requests on
behalf of the cluster.

.nf
*** dealing with changes in the set of protocols or their options
*** offered by a server during its membership of the cluster is an
*** open issue.  do we forbid this?  is it controlled by the cluster
*** mgmt and so we know anyway?  or do we introduce an update packet?
*** or something else entirely?
.fi

m4_heading(3, Cluster Join Reply)

Multicast reply from the leader node in a cluster.  Includes the
server's newly allocated unique identifier and the current
subscription database of the cluster.

m4_pre(
struct ClstJoinRply {
  id32 xid;
  id16 server_id;
  id16 servers[];
  struct {
    string attr_name;
    SubAST sub_expr;      /* not used at present - set to (int32)0 */
    id16 server_ids[];
  }  subscriptions[];
};)m4_dnl

m4_heading(3, Cluster Leave)

Multicast when a server wishes to leave the cluster.  After receiving
a Leave, servers should wait for a ServerConfigNotify of mode Shutdown
before freeing state associated with that server.

m4_pre(
struct ClstLeave {
  id16 server_id;
};)m4_dnl

m4_heading(3, Cluster Redirect)

Multicast to all servers, the Cluster Redirect packet specifies a set
of clients to be disconnected from their current server and
(optionally) redirected elsewhere.

m4_pre(
struct ClstRedir {
  id64 client_ids[];
  string address[];
};)m4_dnl

The client identifiers are full, 64bit identifiers, containing both a
server identifier and per-server client identifier.  Multiple clients
connected to multiple servers can be redirected with a single packet.

The string address list MAY be zero length, in which case the clients
are disconnected without redirection (using the client Disconn
packet).  If multiple address values are provided, a server SHOULD
share the redirection specification across the provided addresses
approximately evenly using a pseudo-random selection method.


m4_heading(3, Cluster Notify)

m4_pre(
struct ClstNotify {
  id16 server_id;
  id16 server_ids[];
  NameValue attributes[];
  boolean deliver_insecure;
  Keys conn_keys;
  Keys nfn_keys;
};)m4_dnl

.nf
*** what's the first server_id for ?
.fi

m4_heading(3, Cluster Term Add)

m4_pre(
struct ClstTermAdd {
  id16 server_id;
  string names[];
};)m4_dnl
  
m4_heading(3, Cluster Term Delete)

m4_pre(
struct ClstSubDel {
  id16 server_id;
  string names[];
};)m4_dnl

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

Copyright (C) The Internet Society (_yr_).  All Rights Reserved.

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

