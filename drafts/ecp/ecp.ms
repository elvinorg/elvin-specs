m4_include(macros.m4)m4_dnl
m4_define(__title, `Elvin Router Clustering Protocol')m4_dnl
m4_define(__abbrev, `ERCP')m4_dnl
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
.ds LF Arnold, Boot & Phelps
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH __date
.ds CH __abbrev
.\" hyphenation mode 0
.hy 0
.\" adjust left
.ad l
.\" indent 0
.in 0
Elvin Project                                                  D. Arnold
Preliminary INTERNET-DRAFT                                       J. Boot
                                                               T. Phelps
Expires: aa bbb cccc                                                DSTC
                                                             _d __m __yr

.ce
__title
.ce
__file

m4_heading(1, Status of this Memo)

This document specifies an Internet standards track protocol for the
Internet community, and requests discussion and suggestions for
improvements.  Please refer to the current edition of the "Internet
Official Protocol Standards" (STD 1) for the standardization state and
status of this protocol.  Distribution of this memo is unlimited.

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

This document describes a protocol for federation of Elvin [EP]
routers.  It enables exchange of message traffic and load-balancing
across local clusters.

It has no effect on the protocol used for Elvin client to router
communications.

m4_heading(1, Introduction)

Elvin is a notification service which provides fast, simple,
undirected messaging, using content-based selection of delivered
messages.  It has been shown to work on a wide-area scale and is
designed to complement the existing Internet protocols.

The __title describes the messages and interactions that allow
multiple Elvin routers to provide a single Elvin service.

m4_heading(1, Terminology)

This document discusses Elvin clients, client libraries and routers.

An Elvin router is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin messages. A client is a
program that uses an Elvin router, via a client library for a
particular programming language or platform.  A client library
implements the Elvin protocols and manages clients' connections to an
Elvin router.

Further details of the Elvin protocol, its entities and their roles is
available in [EP].

m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.


m4_heading(1, Basic Operation)

Elvin routers, in addition to whatever client-server protocols they
support, use a separate router cluster protocol.  This protocol has
two purposes:

.in 6
1. management of the router(s)

2. clustering of local routers for scaling or reliability
.in _default_in

m4_heading(2, Router Management)

All Elvin routers in a cluster listen for management commands from the
network.  Remote management clients emit commands to shutdown or
restart a router daemon, activate a router on standby or move an active
server to a standby state ready to be brought back on line later.

Apart from actions on individual routers, the management protocol
allows Elvin clients to be redirected from one router to another.
Elvin clients who are sent a Disconn packet [EP] SHOULD reconnect
automatically to the router specified in the redirection URL.  This
allows clients to be moved around a cluster to balance load.

One possible management client implementation would be to provide a
HTTP interface on one or more routers in the cluster which can display
cluster information and allow an administrator to remotely control the
nodes and clients of the cluster.

m4_heading(2, Clustering)

Clustering is used to link multiple local routers into a single
subscription space.

Where an address space has a large number of clients, it can be
necessary to share the evaluation of their subscriptions over multiple
host nodes to achieve adequate performance.  This is analogous to a
Web server farm, for example.

Alternatively, where performance is not an issue, it can still be
desirable to have multiple local routers for an address space to
continue service in the face of a server (daemon, node, network)
failure.

At a logical level, the cluster of Elvin routers must appear to
implement a single address space; effectively a virtual router
providing the same service semantics as a single router daemon with
better performance or reliability.

m4_heading(3, Subscription Sharing)

Each router in an Elvin cluster shares client subscription information
with every other node.  The information passed around the cluster
is the unique list of subscription terms the server has subscriptions
for. This is the union of all attributes mentioned in all subscriptions
by all of the clients at a node.  The list of terms is mapped to
unique identifiers for each router.

These subscription terms do not provide complete subscription 
information at every node.  However, by checking the term list
for the cluster, when a notification arrives from a client, the
receiving node can make an initial decision as to whether any
client attached to a remote router needs it at all.  If clients
are partitioned at particular servers to partition traffic according
to domain, it is possible to reduce network load in the cluster
and still provide complete access to all notifications at all
clients.

m4_heading(3, Notification Delivery)

When a notification arrives at a router, the evaluation engine MUST
match the contents of the notification against clients connected
directly and against the term list for each node in the cluster.  For
each matching locally connected client, the notification is delivered
using a standard NotifDel packet.  If the notification contains any
terms which are in a term list for one or more clustered router, it
MUST be multicast in a ClstNotify packet.  The packet MUST contain
the unique router identifier for every node in the cluster which
has a matching term.

m4_heading(3, Slave Role)

In normal operation, an Elvin router joins a cluster as a slave
to one master.  In this role, the slave router receives notifications
from clients, forwarding them into the cluster and receives notifications
from the cluster, forwarding them to its local clients.

A slave router MUST also listens to management traffic within the cluster
and keep information about every node. The router maintains a list of
participating routers with associated information including:

.in 6
.nf
\(bu current state (active or standby)
\(bu list of subscription terms
\(bu list of URL's offered by the router for client connection
\(bu management URL, if the router allows remote management
\(bu current router load and statistics
.fi
.in _default_in

This information is used if the slave node gets promoted to be
the cluster Master.

A slave node MUST NOT activate Elvin router discovery [ERDP].

m4_heading(3, Master Role)

An Elvin router acting as a Master in the cluster MUST perform
all the same tasks as a Slave node, as well as provide two
other functions for the cluster.

The first function is internal to the cluster.  The Master listens to
the traffic in the configured RLM group and looks for ClstJoinRqst
packets.  Seeing on, it MUST respond with a ClstJoinRply, thus
accepting the new router into the cluster.

The second function is external to the cluster.  The Elvin router
acting as Master is the only node in the cluster which MAY activate
Elvin router discovery.  If an Elvin scope has been set, or the
cluster is to provide default Elvin routing for a subnet, the Master
node SHOULD listen for SvrRqst's.  On seeing a request for its
services, the master node SHOULD select a random or load balanced
selection of offered URLs from all the nodes in the cluster and emit a
SvrAdvt.  See [ERDP] for full details of dynamic service discovery
with Elvin.

m4_heading(3, Master Fail-over)

There MUST be exactly one master router in every cluster.  When a
Elvin router is shutdown, if it is currently acting as the Master, it
MUST send a ServerReport packet selecting a new master node, if there
is one or more nodes still in the cluster.  When the router which is
shutting down sees the ServerReport which it multicast, it MUST
deactivate server discovery and complete its shutdown or restart.

If one or more Elvin routers detect that a Master node is no longer
active in the cluster, the cluster must elect a new Master.  This is
done by each active node checking to see if its router ID in the
cluster is the minimum.  If so, the router with the lowest ID sends a
ServerReport electing itself as the new master, and starts a timer.

If no other ServerReport's are seen within the timeout with a lower
router ID, the router assumes the Master role and MAY activate router
discovery.  If a lower ID is seen, the router MUST cancel its timer
and NOT assume the master role.

If a node in the cluster does not have the lowest ID, it SHOULD
start a timer.  When the router sees a Master ServerReport it
MUST cancel the timer.  If the timer expires with no other
node assuming the master role, this node MUST send a ServerReport
indicating it is the new Master.  A timer is then started as if
this node had the lowest ID.

If 

m4_heading(3, Load Balancing)

**** redir clients when ew get unbalanced

m4_heading(1, Abstract Protocol)

m4_heading(2, Protocol Overview)

An Elvin router is statically configured with an initial state.  This
state may include a direction to participate in a router cluster.
Routers in a cluster communicate using a reliable multicast protocol
over an IP network.

To implement a common subscription space, all clustered routers
maintain awareness of the traffic required by each router's clients.
Arriving notifications are forwarded to routers in the cluster as
required.  

The awareness of other router's subscriptions is currently limited to
the set of notification element names for which each router has
subscriptions.  Further knowledge that will enable the ingress router
to discard more traffic will be shared in a later protocol revision.

Incoming notifications are evaluated for forwarding to all routers
requiring traffic containing those element names.  On receiving a
forwarded notification, a router performs further evaluation,
delivering the notification to the subscriptions it matches.

.KS
.nf
                                  +--------------+ Elvin
   +----------+                   | +----------+ | Cluster
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

In addition to this basic data traffic, the clustered routers are able
to be managed from any individual router in the cluster.  This
management includes both reporting and control functions.  Individual
nodes accept management requests and, where required, forward these
commands to other nodes in the cluster.  Statistical and other
reporting information is emitted by each router, and a cluster-wide
summary is collated at each router.  This information is used for
reporting to users and for internal load balancing calculations.

m4_heading(2, Packet Types)

The protocol is defined in terms of individual packet specifications.
Each packet has two unique identifiers: a string name and a number.
In a concrete protocol implementation, if packets are identified using
a number or string, these numeric values SHOULD be used.

The numeric identifiers have been chosen such that they do not overlap
with the identifiers used for the Elvin client protocol [EP], and
both sets of identifiers can be encoded using a single byte.

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

Elvin Routers are statically configured to use a specified RLM group number
for cluster management operations.  When configured to become part of
a cluster, an Elvin router must discover other routers already in the
cluster, and synchronize its state before accepting client
connections.

m4_heading(3, Cluster Join Request)

Multicast request to the cluster to join its managed cluster.  The
router identification and URLs fields match the information sent in SvrAdvt
packets by the Elvin router, and are used to allow the cluster to take
over the role of advertising Elvin router endpoints to client
programs.

m4_pre(
struct ClstJoinRqst {
  id32 xid; 
  uint8 version_major;
  uint8 version_minor;
  id16 router_id;
  string urls[];
  string mgmt_url;
};)m4_dnl

The xid field should contain a random number which used to identify
corresponding ClstJoinRply packets.  The major version should be set
to 4 and the minor version should be 0.

The router_id value is a unique identifier the Elvin router has
selected to use.  This MUST be set the the RLM member identifier
generated by the RLM protocol during its connection process.

The urls field contains the Elvin URLs the Elvin router is configured 
with and will offer to clients when the Elvin router is activated.

The mgmt_url field is the secure HTTP URL which can be accessed
using a standard web browser for administration of the Elvin router.

On initial startup, an Elvin router configured to join a cluster MUST
join the RLM group specified.  The Elvin router MUST then send its
ClstJoinRqst.  When an Elvin router receives its own ClstJoinRqst, it
SHOULD calculate how long the packet took to arrive from the time it
was sent, RTT. The Elvin router should then start a new timer for
4*RTT waiting for a ClstJoinRply response.

Once an Elvin router has seen its own ClstJoinRqst, it MUST record all
observed packets.

If a ClstJoinRply is received during the 4*RTT period, the timer is
canceled, and the Elvin router initializes its internal state and enters
active operation.  The recorded ClstJoinRqst packets are discarded.

If no response is seen within the timeout period, and the Elvin router
has not seen any ClstJoinRply packets, the Elvin router declares
itself the master.  It multicasts its own ClstJoinRply to announce
this decision.  When this ClstJoinRply is received back, the Elvin
router then responds to each of the recorded ClstJoinRqst packets that
it has observed during the timeout with a ClstJoinRply.

If the Elvin router has observed a ClstJoinRply for another Elvin
router, this indicates another Elvin router is acting as the master
and this Elvin router MUST NOT assume the master role.  The Elvin
router SHOULD resend a ClstJoinRqst and start the join process again.

Should an Elvin router see multiple ClstJoinRply's in response to its
request, it MUST ignore the second and subsequent packets.

The master is responsible for responding to further ClstJoinRqst's and
also to client Elvin router discovery requests on behalf of the
cluster.

m4_heading(3, Cluster Join Reply)

Multicast reply from the master node in a cluster.  Includes the Elvin
router's newly allocated unique identifier, the current
subscription database of the cluster and the list of participating
routers in the cluster with their management URLs.

m4_pre(
struct ClstJoinRply {
  id32 xid;
  id16 master_id;          /* id of master node */
  id16 router_id;          /* newly allocated id for the requester */
  string scope;            /* the scope used for this cluster */
  struct {                
    id16 router_id;
    string mgmt_url;
    string offer_urls[];
  } routers[];
  struct {
    string attr_name;
    int32 reserved;
    id16 router_ids[];
  } subscriptions[];
};)m4_dnl

m4_remark(
*** all the bits exaplained
*** rant about shared initial state 
)

m4_heading(2, Leaving the Cluster)

Elvin Routers leave a cluster in several different circumstances.

Uncontrolled loss of an Elvin router is detected by the underlying reliable
multicast protocol, and reported to all (remaining) nodes.  Such a
loss can occur through exit of the Elvin router process either through a
failure or an uncontrolled termination (ie. kill -9), a crash of the
machine hosting the Elvin router process, or a loss of network connectivity.

Upon receiving such a report for the multicast layer, the Elvin router
should purge all state information held for those nodes no longer
active.  

Should a network partition heal, the multicast protocol will reject
those packets from previous members of the cluster.  An Elvin router
receiving notification of such a rejected packet MUST restart (see
below), but MUST NOT send the restart notification.

Leaving the cluster under control is initiated either by an interrupt
from the host operating system (ie. SIGINT), a request from the local
management API (via HTTP) or a remote request from another management
API within the cluster.

A locally initiated leave MUST multicast a Shutdown or Restart,
specifying the local Elvin router's identifier.
*** Elvin router reports do this now ...

m4_heading(3, Restart)

m4_pre(
struct Restart {
  id32 xid;
  id16 router_ids[];
};)m4_dnl

Request that the specified Elvin router or Elvin routers restart. 

m4_heading(3, Shutdown)

m4_pre(
struct Shutdown {
  id32 xid;
  id16 router_ids[];
};)m4_dnl

Request that the specified Elvin router or Elvin routers shutdown.

On receiving a Shutdown or Restart request, the Elvin router MUST withdraw
all client protocol offers, send a Disconn (with no redirect) to all
remaining clients, multicast a ServerReport with the mode set to
.B Closing,
and exit or restart the process as
required.  If redirection of clients to another node in the
cluster is required, a ClstRedir packet SHOULD be sent to Elvin router
by a management client before the Shutdown or Restart command.

m4_heading(3, Server Report)

m4_pre(
struct ServerReport {
  id32 xid;
  id16 router_id;
  id8  mode;
};)m4_dnl

Report a change of operating mode for an Elvin router.  The new mode is
specified.  The mode can by one of the following values:

.KS
.nf 
  ----------------------------------------------------------------
  Mode        Value   Action
  ----------------------------------------------------------------
  Start         1     Initialize structures for new router
  Activate      2     Change the state for the ID to active
  Standby       3     Change the state for the ID to active
  Closing       4     Remove all structures for the ID
  Master        5     If the ID is the same, assume Master role
  ----------------------------------------------------------------
.fi
.KE


Upon receiving an ServerReport for Shutdown or Restart, an Elvin
router SHOULD remove all state associated with that Elvin router.

When a master node leaves the cluster, if there are any remaining
nodes, it picks a new master and sends a ServerReport, mode
set to master, and the Elvin router id set to the newly chosen Elvin
router.  The router_ids list SHOULD be empty.  If a node receives
a ServerReport packet with its own ID in the router_id field and
mode equal to Master, it MUST assume the role of master in the
cluster, and MAY activate server discovery.

m4_heading(2, Additional Management Packets)

Management of an Elvin Elvin router is implemented using a secure
connection either directly to the Elvin router in question, or to any
Elvin router in the cluster of which it is a member.

All management operations are considered privileged, and MUST require
that the identity of the requester be authenticated prior to
authorization of the request.

When invoked from an Elvin router, a management operation may refer
either to that Elvin router alone, to another single Elvin router, or
to multiple Elvin routers.  When the operation applies to any Elvin
router other than that initiating the operation, the request MUST be
multicast.

Regardless of whether the operation was requested directly, or via
multicast from another Elvin router in the cluster, the affected Elvin
router(s) MUST multicast an Server Report packet describing
their new state.

m4_remark(
*** additional operations here could include: changing the log level,
*** enabling/disabling protocols (and thus offers), interface usage,
*** QoS value changes, etc.

*** once we have a large cluster, these notifications will be
*** problematic.  maybe it is better to always multicast the request,
*** and then rely on the NACK if things don't go as planned?

*** having done that, what if we were expecting a NACK (like, an
*** active Elvin router been told to go active) but don't see one?  do we
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

An Elvin router process operates in two modes: active, or standby.  An
Elvin router in standby state remains an active process, and continues
to process management requests, but it suspends any activity via the
Elvin client protocol.  This is used to provision Elvin routers for
periods of greater activity, in a hot-standby role for reliability,
etc.

A standby Elvin router process may be made active by sending this message.

m4_pre(
struct Activate {
  id32 xid;
  id16 router_ids[];
};)m4_dnl

m4_heading(3, Standby)

The Standby message forces an Elvin router from active into standby
mode.  The Elvin router MUST withdraw any currently offered protocols,
and stop accepting client connections.

Any clients connected to the specified Elvin router(s) MUST be
disconnected (without redirection).  It is RECOMMENDED that explicit
redirection be performed prior to a Standby.

m4_pre(
struct Standby {
  id32 xid;
  id16 router_ids[];
};)m4_dnl

m4_heading(3, Cluster Redirect)

Multicast to all Elvin routers, the Cluster Redirect packet specifies
a set of clients to be disconnected from their current Elvin router
and (optionally) redirected elsewhere.

m4_pre(
struct ClstRedir {
  id16 router_ids[];
  id64 client_ids[];
  string address[];
};)m4_dnl

The Elvin router identifiers list the Elvin routers in the cluster
which this redirection is directed at.  Elvin router who's cluster ID
is not in the list MUST ignore the packet.

The client identifiers are full, 64bit identifiers, containing both a
Elvin router identifier and per-Elvin router client identifier.
Multiple clients connected to multiple Elvin routers can be redirected
with a single packet.  If the client identifiers list is empty, then
all clients should be disconnected and redirected to an URL in the
address list.

The string address list MAY be zero length, in which case the clients
are disconnected without redirection (using the client Disconn
packet).  If multiple address values are provided, an Elvin router SHOULD
share the redirection specification across the provided addresses
approximately evenly using a pseudo-random selection method.

The Elvin router SHOULD redirect each client to a randomly selected
URL from the list.

m4_heading(3, Server Statistics Report)

In order share the work in a cluster, router nodes share statistical
information.  Each Elvin router publishes details about is recent load
based on Elvin client activity and the computer hardware the daemon
process is running on.

m4_pre(
struct Elvin ServerStatsReport {
  id16 router_id;
  struct {
    uint32 timestamp;
    id16 router_id;
    struct {
      /* length of report period in seconds */
      uint32  period;

      /* connections */
      uint32  clients;
      real64  connect_rate;
      real64  disconn_rate;
      real64  testconn_drop_rate;
      real64  error_drop_rate;

      /* subscription */
      uint32  active_subs;
      real64  sub_add_rate;
      real64  sub_mod_rate;
      real64  sub_del_rate;

      /* quench */
      uint32  active_quenches;
      real64  quench_add_rate;
      real64  quench_mod_rate;
      real64  quench_del_rate;

      /* production (received from clients) */
      real64  prod_rate;
      real64  prod_vol;

      /* consumption (sent to clients) */
      real64  cons_rate;
      real64  cons_vol;

      /* quench (sent to clients) */
      real64  quench_rate;
      real64  quench_vol;

      /* virtual CPU */
      real64  percent_idle;
      real64  percent_user;
      real64  percent_system;

      /* memory */
      uint32  avail_phys_k;
      uint32  total_phys_k;
      uint32  avail_swap_k;
      uint32  total_swap_k;
    } periods[];
  } stats[];
};)m4_dnl


m4_heading(2, Data Packets)

m4_heading(3, Cluster Terms)

When a client changes its subscription at an Elvin router in a
cluster, the Elvin router MUST propagate this information to all other
Elvin routers in the cluster.  Subscription information is shared in
the cluster by sending Cluster Term packets.

m4_pre(
struct ClstTerms {
  id16 router_id;
  string add_names[];
  string del_names[];
};)m4_dnl

The router_id field identifies the Elvin router sending the
information.

The add_names fields lists new attribute names the sending Elvin
router now has an active subscription for.  For example, if an Elvin
router receives a subscription for "temp > 100", then the Elvin router
sends a ClstTerms packet with "temp" in the add_names field.

The del_names field lists attribute names which the sending Elvin
router no longer has any client subscriptions for.

Nodes in the cluster receive a ClstTerms packets, and MUST keep
account of which attribute names each Elvin router in the cluster has
subscriptions for.

m4_heading(3, Cluster Notify)

Notifications received by each Elvin router from clients are forwarded
to other Elvin routers in the cluster as Cluster Notify packets.  When
a notification is received by as Elvin router from a client, as well
as comparing the notification against the client subscriptions, the
Elvin router compares it to the list of attribute names for each Elvin
router in the cluster.  If the notification matches any Elvin routers
lists, a ClstNotify packet MUST be multicast to other members of the
clusters.

m4_pre(
struct ClstNotify {
  id16 router_id;
  id16 router_ids[];
  NameValue attributes[];
  boolean deliver_insecure;
  Keys conn_keys;
  Keys nfn_keys;
};)m4_dnl

The router_id field indicates the Elvin router in the cluster
which sent the packet and hence received the notifications from a
client.

The router_ids list indicates which other Elvin routers in the
cluster have clients which will match the notification.  This is
determined by the shared attribute names list, maintained by each
Elvin router.

When an Elvin router receives the multicast ClstNotify, if its local
identifier is not in the router_ids field, it MAY ignore the
notification and does not need to compare it to local client
subscriptions.  If the router_ids list does contain the
receiving Elvin router's identifier, the Elvin router MUST compare the
notification to its subscription table for delivery to clients.

The attributes, deliver_insecure and nfn_keys fields are identical to
the same attributes, deliver_insecure and keys fields in the original
notification sent by the client.  The additional conn_keys field
contains any session keys the client may have registered for its
connection which are implicitly added to each notification sent by the
client.  Note that these key lists are NOT transformed before being
multicast to other Elvin routers in the cluster.

m4_heading(2, Packet Encoding)

m4_heading(3, Data Types)

Elvin cluster packets are encoded using XDR [RFC1832] for each element
in the packet.  This mapping is as for the standard Elvin
client-router XDR encoding.  The following rules are used to map
the data types used in the protocol to XDR buffers: 

.KS
.nf
  ---------------------------------------------------------------------
  Elvin Type  XDR Type         Encoding Summary
  ---------------------------------------------------------------------
  boolean     bool             4 bytes, last byte is 0 or 1

  uint8       unsigned int     4 bytes, last byte has value

  id16        unsigned int     4 bytes, MSB first

  id32        unsigned int     4 bytes, MSB first

  int32       int              4 bytes, MSB first

  id64        unsigned hyper   8 bytes, MSB first

  real64      double           64-bit double precision float

  string      string           4 byte length, UTF8 encoded string, zero 
                               padded to next four byte boundary

  byte[]      variable-        4 byte length, data, zero padded to next
              length opaque    four byte boundary
  ---------------------------------------------------------------------
.fi
.KE

m4_heading(3, Encoding Arrays)

All arrays in the  protocol are of variable length.  Arrays of
objects are encoded by prepending the length of the array as an int32
- the items are in the array are then each encoded in sequence
starting at item 0.  The 32bit length places a theoretical limit of
(2**32) - 1 items per list.  In practice, implementations are expected
to have much lower maximums for the number of items in a list
transmitted per packet.

.KS
.nf
       0  1  2  3  
     +--+--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+--+
     |     n     |  item 0   |  item 1   |...| item n-1  |  ARRAY
     +--+--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+--+
     |<--int32-->|<----------------n items-------------->|
                                                          
.fi
.KE

m4_heading(1, Limitations)

The protocol provides very limited means for individual routers to
share there local configuration information.  Currently, the scope
if the cluster will be the scope of the first Master node.   The scope
cannot be changed without shutting down all servers within the cluster.

No current scheme is defined to use more than one RLM group to partition
traffic.  This would be useful to separate sections of the cluster with
an IP router so that not every node needs to see every data packet.

m4_remark(
*** dealing with changes in the set of protocols or their options
*** offered by an Elvin router during its membership of the cluster is an
*** open issue.  do we forbid this?  is it controlled by the cluster
*** mgmt and so we know anyway?  or do we introduce an update packet?
*** or something else entirely?

*** this is related to the elvind.conf issue of specifying protocol
*** options.  the current URL-based scheme is bogus, and should go
*** away ASAP.  at that time, we should revisit this packet format.)

m4_heading(1, `Security Considerations')

When installing an Elvin cluster, careful consideration should be made
to the access of the machines from outside the cluster, eg the
Internet.

The __title is designed for Elvin router nodes operating on a LAN.
The protocol is designed to allow cluster nodes share information
via RLM and multicast.  Any traffic not originating from a cluster
node within the cluster SHOULD be blocked from entering any
LAN segments that a cluster is running on, all traffic for 
239.255.123.0/24.  Multicast client traffic for router discovery
MAY be allowed to enter the LAN and MUST be if clients are to
find nodes in the cluster dynamically.

Cluster nodes need to able to accept connections from clients on one
or more ports (2917 is the default IANA Elvin client port).  Individual
nodes have the same security considerations as stand-alone routers with
respect to client connections.  See [EP] for a detailed consideration
of Elvin client connections.

If a cluster is federated using [ERFP], then at least one federation port
MAY need be accessible to external Elvin routers (2916 is the default IANA
port for Elvin router-router connections.

m4_heading(1, `IANA Considerations')

There are no IANA considerations for the protocol.

m4_heading(1, References)


.IP [EP] 12
Arnold, D., Boot, J., Phelps, T., Segall, B.,
"Elvin Client Protocol",
Work in progress

.IP [ERDP] 12
Arnold, D., Boot, J., Phelps, T., Segall, B.,
"Elvin Router Discovery Protocol",
Work in progress

.IP [ERFP] 12
Arnold, D., Lister, I.,
"Elvin Router Federation Protocol",
Work in progress

.IP [RLM] 12
Arnold, D., Boot, J.,
"Reliable Local Multicast"
Work in progress

.IP [RFC1832] 12
Srinivasan, R.,
"XDR: External Data Representation Standard",
RFC 1832, August 1995.

.KS
.ti 0
.NH 1
CONTACT
.ft
.in _default_in

Author's Address

.nf
David Arnold
Julian Boot
Ted Phelps

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
.in 0
.NH 1
Full Copyright Statement
.ft
.in _default_in

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
