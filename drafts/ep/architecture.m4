m4_dnl  architecture.m4
m4_dnl
m4_dnl  system architecture overview.  should introduce all system
m4_dnl  components and their basic relationships.
m4_dnl
m4_heading(1, ARCHITECTURE)

This document describes a protocol used by lightweight clients to
access the Elvin service provided by one or more Elvin routers.
Typically, such clients are implemented as a library or class for a
particular programming language.  An Elvin router implementation can
support up to many thousands of clients, depending on service usage.

Additional protocols, not specified in this document, enable
clustering of Elvin routers [ERCP] and federation [ERFP] of routers to
form a wide-area Elvin routing network.

The client protocol is defined as an abstract specification, which may
be made available in any number of concrete specifications using
appropriate underlying facilities.

The client protocol is broken into several subsets.  An implementation
may choose which subsets to provide, depending upon the needs of its
intended application programs and the resources available from its
host platform.

m4_heading(2, Abstract Communication Model)

Elvin clients communicate with an Elvin router using a communications
channel.  A client process MAY open multiple simultaneous channels to
a one or more Elvin routers, but they remain distinct logical
entities.

Concrete implementations of this abstract channel MUST provide
ordered, reliable delivery of packets of known length, consisting of a
sequence of arbitrary octets.  The number of octets in a packet MAY be
constrained, but an implementation MUST allow packets of XXX octets at
minimum.

The minimal functionality subset (unreliable notification) requires
only unidirectional transmission, but all other functionality requires
bidirectional communications.

In addition to basic octet transmission, a concrete channel MAY
provide facilities for security and marshalling.  These facilities MAY
be provided as part of the concrete channel implementation, or as
separate, layered functions.

m4_heading(2, Endpoints)

Elvin router endpoints are stable, advertised entities to which
clients connect, establishing a channel.  This channel is used either
for a single packet (unreliable notification) or an ongoing
bidirectional packet exchange.

Endpoints are described using a Uniform Resource Identifier (URI).
The format of this URI is completely defined in [EURI].  In overview,
it describes the Elvin protocol version, the type and ordering of the
concrete modules forming the channels it offers, appropriate
addressing information and any other parameters required to establish
a connection.

As an example,

m4_pre(`elvin:/tcp,krb5,xdr/router.example.com:2917')

defines an endpoint using concrete protocol modules "tcp", "krb5" and
"xdr", and offered at an address "router.example.com:2917".



UNotify
sessions

An Elvin client must maintain a connection to its server.  If the
connection is closed (or lost), the registered subscriptions are freed
and all information about that client is destroyed.

The Elvin protocol is designed to be implemented over multiple
transport, security and marshalling options.  An implementation SHOULD
provide the standard protocol, and MAY provide alternatives better
suited to other application domains.

Clients MAY use the Elvin Router Discovery Protocol [ERDP] to locate
a suitable server.  Establishment of a connection can involve
negotiation of the server's capabilities, including underlying
protocol options, supported limits on notification content, and
available qualities of service.

m4_heading(3, Protocol Layers)
m4_heading(4, Marshalling)
m4_heading(4, Security)
m4_heading(4, Transport) 
m4_heading(2, Security)

Security of Elvin traffic is optional.  If required, the client can
select a protocol which will provide mutual authentication of the
server connection, and optional privacy of the channel.  
m4_dnl
m4_heading(3, Requirements)

Access control of content-routed traffic is a complex issue.
Obviously, the router process must have access to the message content
in order to perform routing decisions, and must therefore be trusted.

The principle difficulty comes because the server ensures that the
client does not know the identity of the message's receivers.
m4_dnl
m4_heading(3, Client-Server)
m4_dnl
m4_heading(4, Authentication)
m4_dnl
m4_heading(4, Privacy and Integrity)
m4_dnl
m4_heading(4, Access Control)
m4_dnl
m4_heading(3, Message Protection)
m4_dnl
m4_heading(2, Messages)

An Elvin message consists of a sequence of named, typed, attribute
values.  The client libraries support the creation of such messages
using idioms suited to the various languages.

An implementation MAY limit the number of attributes in a message
and/or the total size of the message data.  See section X on
Server Features.
m4_dnl
m4_heading(3, Message Attributes)

An attribute name is a string value from a subset of the printable
ASCII character set.  The maximum length of an attribute name is 1024
bytes.  An attribute name may have any value comprised of legal
characters; there are no reserved values.
m4_dnl
m4_heading(3, Data Types)

Elvin specifies a set of simple, platform-independent types for
communication of message data.  The types have been chosen to enable
implementation using a wide range of marshalling standards and
programming languages.  They are
m4_dnl
m4_heading(2, Subscription)

m4_dnl
m4_heading(2, Quenching)

description of quenching: problem, what it is, how it works, impact on
security, impact on federation

Quenching is a facility named for its ability to reduce notification
traffic by preventing the propagation of unwanted notifications.  It
has two components: manual and automatic.  Both cases use the server's
knowledge of consumers subscriptions to prevent producer clients from
notifying events for which no subscription exists.

m4_heading(3, Manual Quench)

Some types of producer clients must perform significant work to detect
events.  As an example, consider a file system monitor that reports
changes to the monitored file system.  Indiviually checking each
directory and file for modification would not only place significant
loading on the host processor, but would be unable to detect changes
within useful time bounds.

Manual quenching provides a mechanism through which the producer can
specify a filter over the set of subscriptions registered at the
server, and be informed of changes to the matching set of
subscriptions.

In this way, to continue our example above, the file and directory
names that are to be monitored can be isolated from the subscriptions
registered by consumers, and only those particular files need be
monitored for changes.

m4_heading(3, Automatic Quench)

Manual quench requires that clients take explicit action to filter the
registered subscriptions and determine what events to detect and
notify.

Automatic quench is an extension to the Elvin client library which
peforms quenching on behalf of the client code.  It monitors notified
events, building a profile of the notifications emitted.  This profile
is registered with the server as a quench filter (as for manual
quenching).  The server's updates of matching subscriptions are used
to filter notifications within the client library.

m4_remark( auto quench seems to have nothing to do with the
the client protocol and is just an implementaions issue of the
client library. does is need to be in the spec at all? is the
distinction useful at this level? j)


This specification describes the client/server protocol and semantic
requirements for client libraries and the server daemon.  It does not
describe any inter-server protocol.  The Elvin Router Cluster Protocol
[ERCP] describes how Elvin routers may be configured on a LAN as a cluster.
The Elvin Router Federation Protocol [ERFP] describes how single routers
or clusters may be linked across the Internet.


m4_include(operational-overview.m4)

m4_include(communication-model.m4)

