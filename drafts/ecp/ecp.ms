m4_include(macros.m4)m4_dnl
m4_define(__title, `Elvin Server Clustering Protocol')m4_dnl
m4_define(__abbrev, `ESCP')m4_dnl
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
.ds RH __date
.ds CH __abbrev
.hy 0
.ad l
.in 0
XXX Working Group                                              D. Arnold
Internet Draft                                                   J. Boot
Category: Standards Track                                    _d __m __yr

.ce
__title

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
Copyright (C) The Internet Society (__yr).  All Rights Reserved.


.ti 0
ABSTRACT

.in 3
This document describes a protocol for federation of Elvin [ELVIN]
servers.  It enables exchange of message traffic and load-balancing
across local clusters.

It has no effect on the protocol used for Elvin client to server
communications.

.ti 0
TABLE OF CONTENTS

(tdb) (probably last ;-)

.bp
m4_heading(1, INTRODUCTION)

Elvin is a notification service which provides fast, simple,
undirected messaging, using content-based selection of delivered
messages.  It has been show to work on a wide-area scale and is
designed to complement the existing Internet protocols.

The __title describes the messages and interactions that allow
multiple Elvin servers to provide a single Elvin service.

m4_heading(1, TERMINOLOGY)

Wide-area federation

Local-area federation 

Clustering

Scope

Subscription scope

Address space

Elvin domain

Elvin cluster

Slave server

Master server

m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.


m4_heading(1, BASIC OPERATION)

Elvin servers, in addition to whatever client/server protocols they
support, use a separate server federation protocol.  This protocol has
two purposes:
.IP 1. 3
management of the server(s)
.IP 2. 3
clustering of local servers for scaling or reliability

m4_heading(2, Server Management)

m4_heading(2, Clustering)

Clustering is used to link multiple local servers into a single
subscription space.

Where an address space has a large number of clients, it can be
necessary to share the evaluation of their subscriptions over multiple
host nodes to achieve adequate performance.  This is analogous to a
web server farm, for example.

Alternatively, where performance is not an issue, it can still be
desirable to have multiple local servers for an address space to
continue service in the face of a server (daemon, node, network)
failure.

At a logical level, the cluster of Elvin servers must appear to
implement a single address space; effectively a virtual server
providing the same service semantics as a single server daemon with
better performance or reliability.

m4_heading(3, Subscription Sharing)

Muliple servers in a cluster 

term lists per server id

m4_heading(3, Notification Deleiver)

eval against term list.  emit with list of servers in the notification

m4_heading(3, Slave Role)

do the data thing 

everyone shares all state: server url lists, etc

ready to become master if master exits

m4_heading(3, Master Role)

server discovery

join replies

m4_heading(3, Master Failover)

hand off on exit

reelection on abort

m4_heading(3, Load Balancing)

redir clients when ew get unbalanced

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
to be managed from any individual server in the cluster.  This
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
  Server Report                 ServerReport            132
  Server Negative Acknowledge   ServerNack              133
  Server Statistics Report      ServerStatsReport	134

  Cluster Join Request          ClstJoinRqst            160
  Cluster Join Reply            ClstJoinRply            161
  Cluster Terms                 ClstTerms               162
  Cluster Notify                ClstNotify              163

  Cluster Redirect              ClstRedir               164
  Cluster Leave                 ClstLeave               165
  ----------------------------------------------------------------
.fi
.KE

m4_heading(2, Joining the Cluster)

Servers are staticly configured to use a specified RLM group number
for cluster management operations.  When configured to become part of
a cluster, a server must discover other servers already in the
cluster, and synchronise its state before accepting client
connections.

m4_heading(3, Cluster Join Request)

Multicast request to the cluster to join its managed cluster.
The server and URLs fields match the information sent in SvrAdvt
packets by the server, and are used to allow the cluster to take over
the role of advertising server endpoints to client programs.

m4_pre(
struct ClstJoinRqst {
  id32 xid; 
  uint8 version_major;
  uint8 version_minor;
  id16 server_id;
  string urls[];
  string mgmt_url;
};)m4_dnl

The xid field should contain a random number which used to identify
corresponding ClstJoinRply packets.  The major version should be set
to 4 and the minor version should be 0.

The server_id value is a unique identifier the server has selected
to use.  This MUST be set the the RLM member identifier generated
by the RLM protocol during its connection process.

The urls field contains the Elvin URLs the server is configured 
with and will offer to clients when the server is activated.

The mgmt_url field is the secure HTTP URL which can be accessed
using a standard web browser for administration of the server.

On initial startup, a server configured to join a cluster MUST join
the RLM group specified.  The server MUST then send its ClstJoinRqst.
When a server receives its own ClstJoinRqst, it SHOULD calculate how
long the packet took to arrive from the time it was sent, RTT. The
server should then start a new timer for 4*RTT waiting for a
ClstJoinRply response.

Once a server has seen its own ClstJoinRqst, it MUST record all
observed packets.

If a ClstJoinRply is received during the 4*RTT period, the timer is
cancelled, and the server initialises its internal state and enters
active operation.  The recorded ClstJoinRqst packets are discarded.

If no response is seen within the timeout period, and the server has
not seen any ClstJoinRply packets, the server declares itself the
master.  It multicasts its own ClstJoinRply to announce this decision.
When this ClstJoinRply is recived back, ther server then responds to
each of the recorded ClstJoinRqst packets that it has observed during
the timeout with a ClstJoinRply.

If the server has observed a ClstJoinRply for another server, this
indicates another server is acting as the master and this server MUST
NOT assume the master role.  The server SHOULD resend a ClstJoinRqst
and start the join process again.

Should a server see multiple ClstJoinRply's in response to its
request, it MUST ignore the second and subsequent packets.

The master is responsible for responding to further ClstJoinRqst's and
also to client server discovery requests on behalf of the cluster.

m4_remark(
*** dealing with changes in the set of protocols or their options
*** offered by a server during its membership of the cluster is an
*** open issue.  do we forbid this?  is it controlled by the cluster
*** mgmt and so we know anyway?  or do we introduce an update packet?
*** or something else entirely?

*** this is related to the elvind.conf issue of specifying protocol
*** options.  the current URL-based scheme is bogus, and should go
*** away ASAP.  at that time, we should revisit this packet format.)

m4_heading(3, Cluster Join Reply)

Multicast reply from the master node in a cluster.  Includes the
server's newly allocated unique identifier and the current
subscription database of the cluster.

m4_pre(
struct ClstJoinRply {
  id32 xid;
  id16 master_id;          /* id of master node */
  id16 server_id;          /* newly allocated id for the requestor */
  string scope;            /* the scope used for this cluster */
  struct {                
    id16 server_id;
    string mgmt_url;
    string offer_urls[];
  } servers[];
  struct {
    string attr_name;
    int32 reserved;
    id16 server_ids[];
  } subscriptions[];
};)m4_dnl

m4_remark(
*** all the bits exaplained
*** rant about shared initial state 
)

m4_heading(2, Leaving the Cluster)

Servers leave a cluster in several different circumstances.

Uncontrolled loss of a server is detected by the underlying reliable
multicast protocol, and reported to all (remaining) nodes.  Such a
loss can occur through exit of the server process either through a
failure or an uncontrolled termination (ie. kill -9), a crash of the
machine hosting the server process, or a loss of network connectivity.

Upon receiving such a report for the multicast layer, the server
should purge all state information held for those nodes no longer
active.  

Should a network partition heal, the multicast protocol will reject
those packets from previous members of the cluster.  A server
receiving notification of such a rejected packet MUST restart (see
below), but MUST NOT send the restart notification.

Leaving the cluster under control is initiated either by an interrupt
from the host operating system (ie. SIGINT), a request from the local
management API (via HTTP) or a remote request from another management
API within the cluster.

A locally initiated leave MUST multicast a Shutdown or Restart,
specifying the local server's identifier.

m4_heading(3, Restart)

m4_pre(
struct Restart {
  id32 xid;
  id16 server_ids[];
};)m4_dnl

Request that the specified server or servers restart. 

m4_heading(3, Shutdown)

m4_pre(
struct Shutdown {
  id32 xid;
  id16 server_ids[];
};)m4_dnl

Request that the specified server or servers shutdown.

On receiving a Shutdown or Restart request, the server MUST withdraw
all client protocol offers, send a Disconn (with no redirect) to all
remaining clients, multicast a ServerReport for the final state
(either Shutdown or Restart), and exit or restart the process as
required.

m4_heading(3, Server Report)

m4_pre(
struct ServerReport {
  id32 xid;
  id16 server_id;
  id8  mode;
};)m4_dnl

Report a change of operating mode for a server.  The new mode is
specified.

Upon receiving a ServerReport for Shutdown or Restart, a server SHOULD
remove all state associated with that server.

m4_remark(
when a master node leaves, it picks a new master and sends a server
report, mode set to master, and the server id set to the newly
choosen server.  the server_ids list SHOULD be empty.
)

m4_heading(2, Additional Management Packets)

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
MUST multicast a Server Report packet describing their new state.

m4_remark(
*** additional operations here could include: changing the log level,
*** enabling/disabling protocols (and thus offers), interface usage,
*** QoS value changes, etc.

*** once we have a large cluster, these notifications will be
*** problematic.  maybe it is better to always multicast the request,
*** and then rely on the NACK if things don't go as planned?

*** having done that, what if we were expecting a NACK (like, an
*** active server been told to go active) but don't see one?  do we
*** need a ConfigQuery?  or should we abort?  eek ...)

m4_heading(3, Server Negative Acknowledge)

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

m4_heading(3, Cluster Redirect)

Multicast to all servers, the Cluster Redirect packet specifies a set
of clients to be disconnected from their current server and
(optionally) redirected elsewhere.

m4_pre(
struct ClstRedir {
  id16 server_ids[];
  id64 client_ids[];
  string address[];
};)m4_dnl

The server identifiers list the servers in the cluster which this
redirection is directed at.  Server whos cluster ID is not
in the list MUST ignore the packet.

The client identifiers are full, 64bit identifiers, containing both a
server identifier and per-server client identifier.  Multiple clients
connected to multiple servers can be redirected with a single packet.
If the client identifiers list is empty, then all clients should be
disconnected and redirected to an URL in the address list.

The string address list MAY be zero length, in which case the clients
are disconnected without redirection (using the client Disconn
packet).  If multiple address values are provided, a server SHOULD
share the redirection specification across the provided addresses
approximately evenly using a pseudo-random selection method.

The server SHOULD redirect each client to a randomly selected URL from the
list.

m4_heading(3, Server Statistics Report)

m4_pre(
struct ServerStatsReport {
  id16 server_id;
  uint32 timestamp;

  /* lots of data */
	
};)m4_dnl


m4_heading(2, Data Packets)

m4_heading(3, Cluster Terms)

When a client changes its subscription at a server in a cluster, the server
MUST propagate this information to all other servers in the cluster. 
Subscription information is shared in the cluster by sending Cluster Term
packets.

m4_pre(
struct ClstTerms {
  id16 server_id;
  string add_names[];
  string del_names[];
};)m4_dnl

The server_id field identifies the server sending the information.

The add_names fields lists new attribute names the sending server now
has an active subscription for.  For example, if a server receives a
subscription for "temp > 100", then the server sends a ClstTerms
packet with "temp" in the add_names field.

The del_names field lists attribute names which the sending server no
longer has any client subscriptions for.

Nodes in the cluster receive a ClstTerms packets, and MUST keep account
of which attribute names each server in the cluster has subscriptions
for.

m4_heading(3, Cluster Notify)

Notifications received by each server from clients are forwarded to
other servers in the cluster as Cluster Notify packets.  When a
notification is received by as server from a client, as well as
comparing the notification against the client subscriptions, the
server compares it to the list of attribute names for each server in
the cluster.  If the notification matches any servers lists, a
ClstNotify packet MUST be multicast to other members of the clusters.

m4_pre(
struct ClstNotify {
  id16 server_id;
  id16 server_ids[];
  NameValue attributes[];
  boolean deliver_insecure;
  Keys conn_keys;
  Keys nfn_keys;
};)m4_dnl

The server_id field indicates the server in the cluster which sent
the packet and hence received the notifications from a client.

The server_ids list indicates which other servers in the cluster
have clients which will match the notification.  This is determined by
the shared attribute names list, maintained by each server.

When a server receives the multicast ClstNotify, if its local
identifier is not in the server_ids field, it MAY ignore the
notification and does not need to compare it to local client
subscriptions.  If the server_ids list does contain the receiving
server's identifier, the server MUST compare the notification
to its subscription table for delivery to clients.

The attributes, deliver_insecure and nfn_keys fields are identical
to the same attributes, deliver_insecure and keys fields in the
original notification sent by the client.  The additional conn_keys
field contains any session keys the client may have registered for its
connection which are implicitly added to each notification sent by
the client.  Note that these key lists are NOT transformed before
being multicast to other servers in the cluster.

m4_heading(2, Packet Encoding)

Elvin cluster packets are encoded using XDR [RFC1832] for each element in the
packet.  This mapping is as for the standard Elvin client-server XDR encoding.

do some examples - the whole lot?

m4_heading(1, LIMITATIONS)

managment protocol is weak

security of network

distribution of configuration information (eg scope)

m4_heading(1, REFERENCES)

.IP [EDP] 12
Arnold, D., et al,
"Elvin Discovery Protocol",
April 2001.

.IP [ELVIN] 12
Arnold, D., et al,
"Elvin - Content-Addressed Messaging Client Protocol",
April 2001.

.IP [RFC1832] 12
Srinivasan, R.,
"XDR: External Data Representation Standard",
RFC 1832, August 1995.

.IP [RLM] 12
Arnold, D., Boot, J.,
"Reliable Local Multicast"
April 2001.

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

Copyright (C) The Internet Society (__yr).  All Rights Reserved.

This document and translations of it may be copied and furnished to
others, and derivative works that comment on or otherwise explain it
or assist in its implementation may be prepared, copied, published and
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

