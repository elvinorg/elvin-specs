m4_dnl  architecture.m4
m4_dnl
m4_dnl  system architecture overview.  should introduce all system
m4_dnl  components and their basic relationships.
m4_dnl
m4_include(macros.m4)m4_dnl
m4_dnl
m4_heading(1, ARCHITECTURE)
m4_dnl
.LP
describe the basic concepts of notification, subscription, evaluation
of subscriptions, delivery. 

Elvin has two components: a client and a server.  Within an Elvin
system, mutliple clients may exist, supported by a single server.

*** FIXME ***

we need to update this section to reflect clustering and federation

*** FIXME ***

An Elvin system is comprised of communicating programs which use the
services of the system through a client library, Elvin servers which
act as local routers and a network of inter-server tunnels which
distribute messages beyond the domain of a single server.

This specification describes the client/server protocol and semantic
requirements for client libraries and the server daemon.  It does not
describe the inter-server protocol.

m4_heading(2, Philosophy)

The Elvin protocol is designed to provide undirected, content-routed
messaging.  The raw protocol is expected to be accessed via an
interface library, not unlike the Berkeley sockets interface.  Unlike
sockets, however, the use of message content for routing requires that
the message body be structured.

The messages are routed from their source to required destinations by
Elvin server(s).  Delivery has best-effort, at-most-once semantics.
Under no circumstances will an Elvin client receive duplicate
messages.  Messages from a single source must be delivered in order,
but interleaving of messages from different sources is allowed in any
order.

Inter-server routing is not specified by this document.  It is noted,
however, that messages are routed between servers, and that such
journeys are subject to filtering and greater latency than messages
between clients of a single router process.

m4_heading(3, Simplicity)

API, data-types, administration

m4_heading(3, Speed)

Directed communication (like UDP or TCP) has a significant advantage
over undirected messaging in that its routing decisions are
comparitively simple.  If undirected messaging is to become a useful
part of the protocol suite, its performance is critical.

The architecture and implementation of an Elvin server are directed by
this concern.  The protocol design supports

m4_heading(3, Fail-stop Communications)
m4_heading(3, Best-effort Reliability)

m4_heading(3, Use of Multicast)

It is often suggested that delivery of Elvin messages make use of IP
multicast.  While this is certainly possible, it is important to note
that the use of subscriptions to filter delivered messages means that
few clients receive that same message traffic.

m4_heading(2, Server)

The Elvin server is central to the implementation of the protocol.  It
acts as a local router for message traffic, evaluating message content
against registered subscriptions and queuing messages for delivery to
clients.

m4_heading(2, Client)

m4_heading(2, Communication Model)

An Elvin client must maintain a connection to its server.  If the
connection is closed (or lost), the registered subscriptions are freed
and all information about that client is destroyed.

The Elvin protocol is designed to be implemented over multiple
transport, security and marshalling options.  An implementation SHOULD
provide the standard protocol, and MAY provide alternatives better
suited to other application domains.

Clients use the standard protocol to locate a suitable server.
Establishment of a connection can involve negotiation of the server's
capabilities, including underlying protocol options, supported limits
on notification content, and available qualities of service.

m4_heading(3, Notification)
m4_heading(3, Subscription)
m4_heading(3, Delivery)
m4_heading(3, Quench)

m4_heading(2, Security)

Security of Elvin traffic is optional.  If required, the client can
select a protocol which will provide mutual authentication of the
server connection, and optional privacy of the channel.  

*** FIXME ***

do we need to flag messages that were sent on a secured channel and
prohibit their distribution through an unsecured link????

*** FIXME ***

Access control of content-routed traffic is a complex issue.
Obviously, the router process must have access to the message content
in order to perform routing decisions, and must therefore be trusted.

The principle difficulty comes because the server ensures that the
client does not know the identity of the message's receivers.

m4_heading(3, Authentication)

m4_heading(3, Anonymous Access Control)

m4_heading(2, Federation)

Federation refers to the inter-connection of multiple Elvin servers to
provide a routing network.  Federation is desirable for several
reasons, which can be divided into two categories: local and wide
area.

m4_heading(3, Local Area Clustering)

The capacity of a single Elvin server is limited.  The computation
required to evaluate subscriptions, the maintenance of connections,
and the network bandwidth used for delivery all contribute to an upper
limit on the scalability of a single server.

In addition, a single server is vulnerable to network or host
failures.  Server clustering provides redundancy in the service
provision and allows the traffic load to be balanced across multiple
host machines with consequent sharing of both processing and network
load.

An Elvin server cluster should provide a "single-system" image to its
clients.  This requires support for automatic failover, consistent
ordering of message delivery and transparent connection management.

m4_heading(3, Wide Area)

Wide-area federation addresses different goals.  While it is possible
to implement a server cluster over a wide-area network, the need for
global access to content-routed messages requires different
implementation choices.

The wide-area federation protocol provides for filtering of messages
at enterprise boundaries and routing of message traffic between local
Elvin domains through analysis of message generation and subscription
patterns.
