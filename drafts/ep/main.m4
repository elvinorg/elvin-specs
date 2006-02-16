m4_define(__title, `Elvin Client Access Protocol')
m4_include(macros.m4)m4_dnl
.pl 10.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Arnold, ed.
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH __date
.ds CH Elvin
.hy 0
.ad l
.in 0
Elvin.Org                                              D. Arnold, Editor
Preliminary INTERNET-DRAFT                              Mantara Software

Expires: aa bbb cccc                                         _d __m __yr

.ce
__title
.ce
__file

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

m4_heading(1, ABSTRACT)

This document describes a client access protocol for the Elvin
notification service.  It includes a general overview of the system
architecture, and defines an access protocol in terms of operational
semantics, an abstract protocol, and a default concrete implementation
of the abstract protocol.

m4_dnl .ti 0
m4_dnl TABLE OF CONTENTS
m4_dnl (tdb) (probably last ;-)
.bp

m4_heading(1, INTRODUCTION)

Elvin is a content-based publish/subscribe messaging service.  An
Elvin implementation is comprised of Elvin routers which forward and
deliver messages after evaluating their contents against a body of
registered subscriptions.

To facilitate evaluation of subscriptions, Elvin messages are
collections of named, typed values.  Subscriptions are a logical
predicate expression which the router evaluates for each received
message.  Messages are delivered to the subscriber if the result of
the predicate evaluation is true.

There is no requirement that 

Publishers generate 
Undirected communication, where the sender is unaware of the identity,
location or even existence of the receiver, is not currently provided
by the Internet protocol suite.  This style of messaging, sometimes
called "publish/subscribe", is typically implemented using a
notification service.

Notification service clients can be characterised as producers, which
detect conditions, and emit notifications; and consumers, which
request delivery of notifications from the service.  Consumers
normally subscribe to receive notifications matching some supplied
criteria.

While directed communication is well serviced by the Internet protocol
suite, undirected communications is limited to UDP multicast.  While
UDP multicast is appropriate for many applications, it is inherently
channel-based: a particular address and port must be shared by the
communicating applications.

Elvin is a notification service which provides fast, simple,
undirected messaging, using content-based selection of delivered
messages.  It has been show to work on a wide-area scale and is
designed to complement the existing Internet protocols.



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
m4_dnl
m4_dnl  terminology for both Elvin and the RFC series
m4_dnl
m4_dnl
m4_heading(1, TERMINOLOGY)

This document discusses clients, client libraries, servers, producers,
consumers, quenchers, messages, and subscriptions.

An Elvin server is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin message. A client is a
program that uses the Elvin server, via a client library for a
particular programming language.  A client library implements the
Elvin protocol and manages clients' connections to an Elvin server.

Clients can have three roles: producer, consumer or quencher.
Producer clients create structured messages and send them, using a
client library, to an Elvin server.  Consumer clients establish a
session with an Elvin server and register a request for delivery of
messages matching a subscription expression.  Quenching clients also
establish a session with a server, and register a request for
notification of changes to the server's subscription database that
match criteria supplied by the quencher.

Clients MAY take any number of the producer, consumer and quencher
roles concurrently.

m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.

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

m4_dnl
m4_dnl  operational-overview
m4_dnl

m4_heading(2, `Operational Overview')

Interactions between client applications and the Elvin server can be
characterised as either session-oriented or session-less.
Session-less operation is very restricted in its capabilitites.  It is
provided for specialised clients and is not the general mode of
operation.  Clients usually establish as session with the Elvin server
and maintain that session as long as required.

This section provides a high level overview of the protocol and the
basic operations that MAY occur in establishing a session, sharing
information with an Elvin server and also the limitaions of session-less
interactions.  The details of each specific packet and semantics is
convered in Protocol Details section.

m4_heading(3, Establishing a Session)

A Elvin client-server session is a bi-directional communciations link.
It is used by the client to set delivery criteria at the server. The
server uses the same link to acknowledge client changes and to
asynchronously deliver the messages selected by the client.

When a client requests a connection, the server MUST respond with
either a Connection Reply, a Disconnect or a Negative Acknowledgement.

If the server accepts the request, it MUST respond with a Connection
Reply, containing the agreed parameters of the connection.

.KS
  +-------------+ ---ConnRqst--> +---------+
  | Producer or |                |  Elvin  |  
  |  Consumer   |                |  Server |   SUCCESSFUL CONNECTION 
  +-------------+ <---ConnRply-- +---------+
.KE

m4_heading(3, Sending Notifications)

After a successful connection exchange, the session is active and a
client may start emitting notifications by sending them to the server
for distribution. If the attributes in the notification match any
subscriptions held at the server for consumers, the consumers matching
those subscriptions SHALL be be sent a notification deliver message
with the content of the original notification.

The NotifyDeliver packet differs slightly from the original NotifyEmit
sent by the producer.  As well as the sequence of named-typed-values,
it contains information about which subsciptions were used to match
the event.  This allows the client library of the consumer to dispatch
the event with out having to do any additional filtering.

.KS
   +----------+                   +--------+
   | Producer | ---NotifyEmit---> |        |
   +----------+                   | Elvin  |
                                  | Server |       NOTIFICATION PATH
   +----------+                   |        |
   | Consumer | <--NotifyDeliver- |        |
   +----------+                   +--------+
.KE

m4_heading(3, Setting Subscriptions)

When a session is first established, the server MUST NOT send any
Notify Deliver packets until at least one subscription has been added
by the client.

A Consumer client describes the events it is interested in by sending
a predicate in the Elvin subscripton language (and its associated
security keys) to the Elvin server.  The predicate is sent in a
Subscription Add Request (SubAddRqst).  On receipt of the request, the
server checks the syntactic correctness of the predicate. If valid, a
Subscription Reply (SubRply) is returned which includes a server
allocated indentifier for the subscription.

.KS
   +----------+ --SubAddRqst--> +--------+
   | Consumer |                 | Server |     ADDING A SUBSCRIPTION
   +----------+ <---SubRply---- +--------+
.KE

If the predicate fails to parse, the server MUST send Nack to the
client with the error code set to indicate a parser error.  This is
effectively and RPC-style interaction.  All operations that modify
a clients session information at the server use this RPC-style.

A client may alter its registered predicate using the Subscription
Modify Request or remove it entirley by sending a Subscription Delete
Request. Such requests use the subscription-ID returned from the
SubAddRqst.  The server MAY allocate a new subscription-id when a
subscription is changed.  An attempt to modify or delete a
subscription-id that is not registered is a protocol error, and
the server MUST send a Nack to the client.

m4_heading(3, Using Quench)

Once connected, the client MAY request that it be notified when there
are changes in the subscription database managed by the server.  The
client may request such information on subscriptions referring to
named attributes.

Requesting notification of changes to subscriptions referring to a set
of named attributes uses the Quench Add Request (QnchAddRqst)
message.  The Quench Reply (QnchRply) message returns an identifier
for the registered request.

.KS
   +----------+ --QnchAddRqst--> +--------+
   | Producer |                  | Server |          ADDING A QUENCH
   +----------+ <---QnchRply---- +--------+
.KE

As for subscriptions a quench MAY be modified and/or removed later by a
client using the quench-id.  Modifying a quench request MAY change the
identifier used by the server to refer to the request.

Subscriptions containing the requested quenching terms are sent to the
client as an abstract syntax tree.  Three types of changes are
possible: a new subscription referring to the registered attribute
names is registered, a subscription is modified to either refer to or
no longer refer to the specified attributes, or a matching
subscription is removed.

.KS
   +----------+ ----SubAddRqst---> +--------+
   | Consumer |                    |        |
   +----------+ <----SubRply------ |        |
                                   | Server |
   +----------+                    |        |
   | Producer | <--SubAddNotify--- |        |
   +----------+                    +--------+
                                       SUBSCRIPTION ADD NOTIFICATION
.KE

m4_heading(3, Lost Packets)

The server may choose to drop notification packets (NotifyEmit,
SubAddNotify, SubModNotify, SubDelNotify) packets if a client is not
reading them quickly enough.  If this happens, the server is obliged
to send a DropWarn packet to the client, indicating that one or more
notification packets were dropped.

.KS
   +----------+                 +--------+
   | Consumer | <---DropWarn--- | Server |   DROPPED PACKET WARNING
   +----------+                 +--------+
.KE

m4_heading(3, Ending a Session)

At any time after a receiving a Connection Reply, the server can
inform the client that it is to be disconnected.  The Disconn packet
includes an explanation for the disconnection, and optionally, directs
the client to reconnect to an alternative server.

.KS
  +-------------+                  +---------+
  |   Client    | <----Disconn---- |  Server |        DISCONNECTION 
  +-------------+                  +---------+
.KE

To disconnect from the server, the client sends a Disconnect Request.
It SHOULD then wait for the server's response Disconnect Reply, which
ensures that both directions of the communication channel have been
flushed. 

The server MUST NOT refuse to disconnect a client (ie. using a Nack).

.KS
  +-------------+ ---DisconnRqst--> +---------+
  | Producer or |                   |  Elvin  |  
  |  Consumer   |                   |  Server |       DISCONNECTION 
  +-------------+ <--DisconnRply--- +---------+
.KE

m4_heading(3, Session-less Operation)

Client libraries MAY implement session-less transfer of messages from
the client to the server.  It is not possible to receive messages or
quench notifications outside of a session.

.KS
  +-------------+                  +---------+
  |  Producer   | ----UNotify----> |  Server |          NOTIFICATION
  +-------------+                  +---------+
.KE

No other packets are allowed during session-less operation.


m4_dnl  communication-model.m4
m4_dnl
m4_heading(2, Communication Model)

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

m4_dnl
m4_dnl  this is the basic implementation details
m4_dnl

m4_heading(1, SUBSCRIPTION LANGUAGE)

Consumer clients register subscription expressions with a server to
request delivery of messages.  The language used for these expressions
is defined in this section.  The subscription language syntax and
semantics are considered part of the protocol: all servers supporting
a particular protocol version will understand the same subscription
language.  There is no provision for alternative languages.

A consumer client registers a subscription expression that the server
evaluates on its behalf for each message delivered to the server. If
the expression evaluates to true then the notification is delivered,
otherwise, it it not delivered.
m4_dnl
m4_heading(2, Subscription Expressions)

m4_heading(3, Logic)

The evaluation of a subscription uses Lukasiewicz's tri-state logic
that adds the value bottom (which represents "undecideable" or
"indefinite") to the familiar true and false.

.nf
.KS
 ---------------------------------------------------------
           Lukasiewicz tri\-state logic table
 ---------------------------------------------------------
    A       B    |  ! A       A && B    A || B    A ^^ B
 ----------------+----------------------------------------
 true     true   |  false     true      true      false 
 true     bottom |  false     bottom    true      bottom 
 true     false  |  false     false     true      true  
 bottom   true   |  bottom    bottom    true      bottom 
 bottom   bottom |  bottom    bottom    bottom    bottom 
 bottom   false  |  bottom    false     bottom    bottom 
 false    true   |  true      false     true      true  
 false    bottom |  true      false     bottom    bottom 
 false    false  |  true      false     false     false
 ----------------+----------------------------------------
.KE
.fi

Any subscription expression that refers to a name that is not present in the
notification being evaluated results in bottom.

In addition, many of the functions in Elvin have constraints on their
parameters (ie. data type) and an undefined result should these constraints not
be met. For example, where a string parameter is expected but the type of the
actual parameter is a 32 bit integer, the result of the function begins-with()
is bottom.

Notifications are delivered only if the result of subscription evaluation is
true.

It should be emphasized that:
.QP
There is neither an explicit boolean type nor are there boolean
constants for true or false.
.QP
Whereas some programming languages, such as C and C++, provide an
implicit conversion from numeric values to truth values (zero means
false, nonzero means true), the Elvin subscription language requires
such a conversion to be made explicit, for example 
.QP
(i-have-been-notified != 0)
m4_dnl
m4_heading(3, Grouping)

Clauses in an expression may be grouped to override precedence of
evaluation using parentheses.  Unlike the logical or arithmetic
operators, parentheses need not be separated from attribute
identifiers or literal values by whitespace.

An implementation MAY limit the depth of nesting able to be evaluated
in subscription expressions; an expression which exceeds this limit
MUST generate a NESTING_TOO_DEEP error in response to registration
with the server.
m4_dnl
m4_heading(3, Logical Operators)

A subscription expression may be a single predicate, or it may consist
of multiple predicates composed by logical operators. The logical
operators are
.ID 2
&&   Logical AND
||   Logical OR
^^   Logical Exclusive-OR
!    Logical NOT (unary)
.DE
Logical NOT has highest precedence, followed by AND, XOR and then OR.

m4_heading(3, Literal Syntax)
.LP
A subscription expression may include literal values for most of the
message data types.  These types are
.KS
Integer Numbers
m4_dnl ***FIXME*** we lose our indent here  ***
.IP int32 10
A 32 bit, signed, 2's complement integer.
.IP int64 10
A 64 bit, signed, 2's complement integer.
.LP
Integer literals can be expressed in decimal (the default) or
hexadecimal, using a 0x prefix.  In either case, an optional leading
minus sign negates the value, and a trailing "l" or "L" indicates that
the value should be of type int64.
.KE
.LP
Literal values too large to be converted to an int32, but without the
suffix specifying an int64 type, are illegal.  Similarly, values with
the suffix, too large to be converted to an int64, are illegal.

.KS
Real Numbers
.IP real64 10
An IEEE 754 double precision floating point number.
.LP
Real literals can be expressed only in decimal, and must include a
decimal point and both whole and fractional parts.  An optional
integer exponent may be added following an "e" or "E" after the
fractional part.
.KE

.KS
Character Strings
.IP string 10
A UTF-8 encoded Unicode string of known length, with no NUL (0x00)
bytes.
.LP
String literals must be quoted using either the UTF-8 single or double
quote characters.  Within the (un-escaped) quotes, a backslash
character functions as an escape for the following character.  All
escaped characters except the quotes represent themselves.
.KE
There is no mechanism for including special characters in string
literals; each language mapping is expected to use its own mechanism
to achieve this.

.KS
Opaque Octet Data
.IP opaque 10
An opaque octet string of known length.
.LP
The subscription language does not support opaque literals; reference
to opaque attributes in a subscription expression is limited to use of
the sizeof() function.
.KE

There are no structured data types (C struct, enum or union), nor is
there a boolean data type.  All of these can be implemented simply
using the existing types and structured naming.

String and opaque data values have known sizes (ie. they don't use a
termination character).  An implementation MAY enforce limits on these
sizes; see section X on Server Features.
m4_dnl
m4_heading(3, Reference Syntax)

Predicates and function may also use values obtained from the message
under evaluation.  Values are referred to using the name of the
message attribute.

Names must be separated from operators by whitespace.  What other
rules here?
m4_dnl
m4_heading(3, General predicates)
.LP
The subscription language defines a number of predicates that return
boolean values.

Any predicate may be applied to any attribute name. If the named attribute
does not exist in the current notification, or exists but has an
inappropriate type for the predicate, the predicate returns bottom.
.IP require(attribute) 4
Returns true if the notification contains an attribute whose name
exactly matches that specified (even if the attribute's value is, say,
an empty string or a zero-length opaque value).
.IP int32(attribute) 4
Returns true if the type of the attribute is 
.B int32.
.KS
.IP int64(attribute) 4
Returns true if the type of the attribute is 
.B int64.
.KE
.KS
.IP real64(attribute) 4
Returns true if the type of the attribute is 
.B real64.
.KE
.KS
.IP nan(attribute) 4
Returns true if the type of the specified attribute is
.B real64
and its value is the IEEE 754-defined constant NaN (not a number).
There is no literal constant value for NaN because comparing the value
of an attribute against such a numeric expression is equivalent to
using this predicate.
.KE
.KS
.IP string(attribute) 4
Returns true if the type of the attribute is 
.B string.
.KE
.KS
.IP opaque(attribute) 4
Returns true if the type of the attribute is 
.B opaque.
.KE
m4_dnl
m4_heading(3, String predicates)

Some of the most used features of the subscription language are its
string predicates.  The most general provides regular-expression
("regex") matching, but simpler predicates are also provided, ranging
from wildcarding (or "globbing") down to straight-forward string
equality.  While these could all be replaced by regular-expression
operations, it is generally clearer to use and more efficient to
implement the simpler forms when they suit.
.LP
The string predicates are:
.IP "equals(attr, stringconst+)" 4
Returns true if any stringconst equals the value of attr.
.IP "contains(attr, stringconst+)" 4
Returns true if any stringconst is a substring of the value of attr.
.IP "begins_with(attr, stringconst+)" 4
Returns true if any stringconst is an initial substring (prefix) of
the value of attr.
.IP "ends_with(attr, stringconst+)" 4
Returns true if any stringconst is a final substring (suffix) of the
value of attr.
.IP "wildcard(attr, stringconst+)" 4
Returns true if the value of attr matches a wildcard ("glob")
expression specified by any stringconst value. Need pointer to glob
semantics.
.IP "regex(attr, stringconst)" 4
Returns true if the value of attr matches the regular expression
specified by the stringconst. Need pointer to (E?)RE semantics.
.LP
In the definitions above, the empty (zero-length) substring is
defined to be a substring of every string, and any string is a
substring of itself. Thus
.B begins_with 
and
.B ends_with 
imply
.B contains, 
and 
.B equals 
implies all three of them.
.LP
For many subscriptions, string (in)equality is the most used
predicate.  For simplicity, the following shorthand notations may also
be used:
.QP 
string-expr-1 == string-expr-2
.LP
is equivalent to 
.QP 
equals(string-expr-1, string-expr-2)
.LP
and
.QP 
string-expr-1 != string-expr-2
.LP
is equivalent to 
.QP
!equals(string-expr-1, string-expr-2)
.LP
There are no predicates for string comparison, i.e. testing whether one
string "is less than" another string.
m4_dnl
m4_heading(3, Implications of International Characters)

Unicode characters introduce some complexity to the string
predicates.  Comparison of Unicode characters must consider two
aspects: character decomposition, and strength of the comparison.
m4_dnl
m4_heading(4, Decomposition)

A single Unicode "character" might consist of a base character
together with a number of combining characters (such as accents),
represented as either a single, pre-composed character, or as a
sequence of characters which are combined for presentation.  In
addition, because the Unicode standard attempts to encompass existing
character sets, there can be multiple representations of the same
basic character.

In order to compare two Unicode strings, you might want to ensure that
two different representations of the same character compare as equal.
In order to do this, pre-composed characters (consisting of a base
character and some combining characters), can be decomposed to a
canonical representation.

For example,
.QP
LATIN SMALL LETTER A WITH GRAVE (\\u00e0)
.LP
decomposes to the two characters
.QP
LATIN SMALL LETTER A + COMBINING GRAVE ACCENT (\\u0061 + \\u0300)
.LP
As an additional complication, there exist Unicode characters that
have multiple pre-composed representations, and in performing
decomposition, the information about which original character was used
is lost.  The process of performing decomposition of these characters
(in addition to those for which the process is straight-forward) is
called compatibility decomposition.

Two string functions are provided to perform decomposition of Unicode
strings prior to comparison:
.IP "decompose(string)" 4
Perform canonical decomposition of the supplied string and return the
resulting string value.
.IP "decompose_compat(string)" 4
Perform compatible (and canonical) decomposition of the supplied string
and return the resulting string value.
m4_dnl
m4_heading(4, Comparison Strength)
.LP
Unicode defines four levels of comparison, in which equivalence of any
two strings depends on the comparison level and the locale, as well as
the strings themselves [UNICODE]. Because the locale of a notification
is not available to an Elvin router, locale-dependent comparisons are
not appropriate.

Unicode also defines a mapping from each character to a form of that
same character in a canonical case, known as folded case, which is
typically the same as lower case for characters with case (note that
most characters have only one case form). Folded case is largely
independent of locale, with only a very small number of exceptions.

The string function "fold-case(string)" is provided to transform strings
to folded case and allow case-insensitive string comparison.
m4_dnl
m4_heading(3, Numeric predicates)

The numeric predicates are the usual arithmetic comparison operators:
.IP "==" 4
Equal to
.IP "<" 4
Less than
.IP "<=" 4
Less than or equal to
.IP ">" 4
Greater than
.IP ">=" 4
Greater than or equal to
.LP
These predicates can be applied to numeric literals, attributes and
expressions.  When applied to attributes, or expressions containing an
attribute, it is important to understand the effect of using an
undefined attribute name.
.QP
A reference to an undefined attribute sets the closest enclosing
boolean expression to false.
.LP
This will normally mean that the numeric predicate will return false,
leading to apparently anomalous cases:
.KS
.RS 2

Consider an expression referring to two int32 attributes
.QP
A <= B || A > B
.LP
While it could be expected that this expression would always return
true, in fact it will return false if neither A nor B is defined.

.RE
.KE
.LP
The application of the equality predicate to values of type real64 can
also appear anomalous due to rounding errors.  Two real64 values are
defined to be equal if their sign, mantissa and exponent are all
equal.  More useful comparison of real64 numbers can be achieved using
the less-than and greater-than predicates.

In addition to these predicate, the following syntactic sugar is
defined for convenience
.IP "!=" 4
Not equal to. 
.LP
While superficially similar to the predicates above, it is in fact
implemented using other predicates, like
.QP
!(A == B)
.LP
which can again cause confusion when the attributes are not defined.
m4_dnl
m4_heading(3, Numeric functions)

The following functions are defined on all three numeric types:
.IP "+" 4
Addition
.IP "-" 4
Subtraction (also unary negation)
.IP "*" 4
Multiplication
.IP "/" 4
Division
.LP
The following operators are defined only on the two integer types, int32 and
int64: 
.QP
m4_remark(Need to pin down 5- and 6-bit shifts (and different promotion
rules?), as Java does.  Also modulus could be done for real64 too
(Java does), but why?)
.IP "%" 4
Remainder (modulus)
.IP "<<" 4
Left `shift'
.IP ">>" 4
Right `shift', signed/arithmetic (`shift' in the value of the sign bit)
.IP ">>>" 4
Right `shift', unsigned/logical (`shift' in 0)
.IP "&" 4
Bitwise AND
.IP "|" 4
Bitwise OR
.IP "^" 4
Bitwise XOR
.IP "~" 4
Bitwise inversion (unary)
m4_dnl
m4_heading(2, Numeric type promotion)

The three numeric types (int32, int64 and real64) may be mixed freely
in numeric expressions, and Elvin performs automatic type promotions
when necessary.

If the arguments to a numeric predicate or the components of an
expression have different numeric types, their values are promoted to
a common numeric type before the predicate or expression is
evaluated. For an expression, the type of the result value is always
the promoted type, even if the result would fit in a smaller type.

The promotion rule is "real64 > int64 > int32", or in other words:

.IP "1." 3
If either operand is real64, the promoted type is also real64.
.IP "2." 3
Otherwise, if either operand is int64, the promoted type is also int64.
.IP "3." 3
Otherwise, both operands must be int32, and no promotion is required.
m4_dnl
m4_heading(2, Subscription Errors)

Elvin subscriptions are compiled by the server after submission at runtime.
Various errors are possible; this section documents the error conditions.

Errors are reported as numbers so that language-specific error
messages may be used by the client. This section shows symbols from
the C language binding; for the corresponding error numbers, please
see <elvin4/errors.h> or documentation for your language binding.

m4_remark(do we need ANY language/API specific stuff here?  better to
refer to a section on abstract errors independent of any particular
naming conventions.  ie like the different packet types are current
defined. Is this the Failures section in abstract-protocol.m4? jb)

.IP SYNTAX_ERROR 4
Non-specific syntactic problem.
.IP IDENTIFIER_TOO_LONG 4
the supplied element identifier exceeds the maximum allowed length.
.IP BAD_IDENTIFIER 4
the supplied element identifier contains illegal characters. Remember
that the first character must be only a letter or underscore.
m4_dnl
m4_heading(3, Runtime evaluation errors in numeric expressions)

During the evaluation of a numeric predicate (including the evaluation of
any expressions that are the arguments to the predicate), the following
classes of errors may occur:

.IP 1. 3
Errors that cause the predicate to return false:
.IP
o Use of an attribute that does not exist in the notification,
.IP
o Use of an attribute, constant or expression that has an
  inappropriate type (for example, real64, string or opaque in a
  function that expects int32 or int64)
.IP
o int32 or int64 division by zero.
.IP 2. 3
Integer overflow. This is silently ignored and the result is undefined,
or do we define it to be wrapped to 32 or 64 bits?
.IP 3. 3
Floating-point errors, including underflow, overflow and division by
zero, are silently mapped to the appropriate IEEE 754 values.

.QP
m4_remark(Do we want predicates for 754 values, e.g. isNan()?

Need to check whether 754 defines all relationals to return FALSE if
either argument is NaN. (What about other magic numbers, e.g.
underflow?) Does 754 specify behaviour of != with NaN, and how does
that compare to Elvin semantics?)

m4_dnl
m4_dnl  abstract-protocol
m4_dnl

m4_heading(1, ABSTRACT PROTOCOL)

The Elvin4 protocol is specified at two levels: an abstract
description, able to be implemented using different marshalling and
transport protocols, and a concrete specification of one such
implementation, mandated as a standard protocol for interoperability
between different servers.

This section describes the operation of the Elvin4 protocol, without
describing any particular protocol implementation.
m4_dnl
.KS
m4_heading(2, Packet Types)
.LP
The Elvin abstract protocol specifies a number of packets used in
interactions between clients and the server.

.nf 
-------------------------------------------------------------
Packet Type                   Abbreviation    Usage    Subset
-------------------------------------------------------------
Unreliable Notification       UNotify         C -> S     A
Negative Acknowledgement      Nack            S -> C     B
Connect Request               ConnRqst        C -> S     B
Connect Reply                 ConnRply        S -> C     B
Disconnect Request            DisconnRqst     C -> S     B
Disconnect Reply              DisconnRply     S -> C     B
Disconnect                    Disconn         S -> C     B
Security Request              SecRqst         C -> S     B
Security Reply                SecRply         S -> C     B
Notification Emit             NotifyEmit      C -> S     B
Notification Deliver          NotifyDeliver   S -> C     B
Subscription Add Request      SubAddRqst      C -> S     B
Subscription Modify Request   SubModRqst      C -> S     B
Subscription Delete Request   SubDelRqst      C -> S     B
Subscription Reply            SubRply         S -> C     B
Dropped Packet Warning        DropWarn        S -> C     B
Test Connection               TestConn        C -> S     B
Confirm Connection            ConfConn        S -> C     B
Quench Add Request            QnchAddRqst     C -> S     C
Quench Modify Request         QnchModRqst     C -> S     C
Quench Delete Request         QnchDelRqst     C -> S     C
Quench Reply                  QnchRply        S -> C     C
Subscription Add Notify       SubAddNotify    S -> C     C
Subscription Change Notify    SubModNotify    S -> C     C
Subscription Delete Notify    SubDelNotify    S -> C     C
-------------------------------------------------------------
.fi
.KE

A concrete protocol implementation is free to use the most suitable
method for distinguishing packet types.  If a packet type number or
enumeration is used, it SHOULD reflect the above ordering.
m4_dnl
m4_heading(2, Protocol Subsets)

The subsets in the above table reflect capabilities of an
implementation.  An implementation MUST implement all or none of the
packet types in a subset.

Subsets A and B are independent.  An implementation MAY support either
or both of subsets A and B.  Subset A is OPTIONAL, subset B is
RECOMMENDED, and subset C is OPTIONAL.  Subsets C is dependent on
subset B.  An implementation supporting subset C MUST support subset
B.

m4_remark(i'd like the ability to have quenching only clients. jb

to do that, we'd have to separate the ConnRqst/Rply, SecRqst/Rply,
Disconn*, DropWarn and Test/ConfConn packets from Notif/Sub packets.
it's possible, and maybe nice? da)

m4_dnl
m4_dnl  protocol-overview
m4_dnl

m4_heading(2, `Protocol Overview')

m4_remark(is there anythong that needs to be here anyore? j)

m4_heading(2, Protoccol Errors)

Two types of errors are recognised: protocol violations, and protocol
errors.

A protocol violation is behaviour contrary to that required by this
specification.  Examples include marshalling errors, packet
corruption, and protocol sequence constraint violations.

In all cases of protocol violation, a client or server MUST
immediately terminate the connection, without performing a connection
closure packet exchange.

A protocol error is a fault in processing a request.  Protocol errors
are detected by the server, and the client is informed of the error
using the Negative Acknowledge (Nack) packet.

A single protocol error MUST NOT cause the client/server connection to
be closed.  Repeated protocol errors on a single connection MAY cause
the server to close the client connection, giving suspected denial of
service attack as a reason (see the Disconnect packet).

m4_dnl
m4_dnl  protocol-details
m4_dnl

m4_heading(2, Packet Details)

This section provides detailed descriptions of each packet and their
use in the Elvin protocol. Packets are comprised from a set of simple
base types and described in a pseudo-C style as structs made up of
these types.

.KS
The following definitions are used in several packets:
m4_pre(`
typedef uint32 id32;
typedef uint64 id64;
')m4_dnl
These types are opaque n-bit identifiers.  No semantics is required
other than bitwise comparison.  In all cases, an all zeros value is
reserved.

Implementations are free to use any type capable of holding the
required number of bits for these values.  In particular, the
signedness of the underlying type does not matter.

.KE
.KS
m4_pre(`
typedef byte[] opaque;

union Value {
    int32 i32;     // 4 byte signed integer
    int64 i64;     // 8 byte signed integer
    real64 r64;    // 8 byte double precision float
    string str;    // length encoded UTF-8 Unicode string; no NUL bytes
    opaque bytes;  // binary data sequence
};

struct NameValue {
    string  name;
    Value   value;
};')m4_dnl

Arrays of NameValue elements are used for notification data and
description of server options.  The value type defines the range of
data that may be exchanged using Elvin messages.  Note that there are
no unsigned integer types, nor an explicit boolean type.

.KE
.KS
m4_pre(`
struct Keys {
    struct KeySetList {
	id32 scheme;
	struct KeySet {
	    opaque keys[];
	} key_sets[];
    } key_set_lists[];
};')m4_dnl

Keys and keysets are explained more fully in a later section.
.KE

.KS 
m4_pre(`
struct SubASTNode {
    SubAST[] children;
};

union SubAST {
    string name;
    int32 i32;
    int64 i64;
    real64 r64;
    string str;
    string regular_expression;

    SubASTNode equals;
    SubASTNode not_equals;
    SubASTNode less_than;
    SubASTNode less_than_equals;
    SubASTNode greater_than;
    SubASTNode greater_than_equals;

    SubASTNode or;
    SubASTNode xor;
    SubASTNode and;
    SubASTNode not;

    SubASTNode unary_plus;
    SubASTNode unary_minus;
    SubASTNode multiply;
    SubASTNode divide;
    SubASTNode modulo;
    SubASTNode add;
    SubASTNode subtract;

    SubASTNode shift_left;
    SubASTNode shift_right;
    SubASTNode logical_shift_right;
    SubASTNode bit_and;
    SubASTNode bit_xor;
    SubASTNode bit_or;
    SubASTNode bit_negate;

    SubASTNode is_int32;
    SubASTNode is_int64;
    SubASTNode is_real64;
    SubASTNode is_string;
    SubASTNode is_opaque;
    SubASTNode is_nan;

    SubASTNode begins_with;
    SubASTNode contains;
    SubASTNode ends_with;
    SubASTNode wildcard;
    SubASTNode regex;

    SubASTNode fold_case;
    SubASTNode decompose;
    SubASTNode decompose_compat;

    SubASTNode require;
    SubASTNode equals;
    SubASTNode size;
};')m4_dnl
The subscription AST types are used to describe the compiled form of
subscription expressions in the quench notification packets.

.KE
.KS
m4_pre(
  id32 xid
)m4_dnl
.na
Where a request packet is sent by the client (other than NotifyEmit or
UNotify), it MUST include transaction identifier (xid), used to match
its reply.  The xid is a 32 bit number, allocated by the client.  The
allocation MUST ensure that no packet is sent with the same identifier
as an outstanding request.  Also, the value zero is reserved, and MUST
NOT be used.
.KE
m4_heading(3, Unreliable Notification)

Unreliable notifications are sent by a client to a server outside the
context of a session (see ConnRqst below).  Using the protocol and
endpoint information obtained either directly or via server discovery,
a client may make a transport level connection to the server.  Over
this connection, one or more UNotify packets MAY be to the server.

The server MUST NOT send any data to the client over the transport
connection (if the the trasport is bi-directional, etc TCP).  However,
The server MAY 

m4_pre(
struct UNotify {
    uint8 client_major_version;
    uint8 client_minor_version;
    NameValue attributes[];
    boolean deliver_insecure;
    Keys keys;
};)m4_dnl

m4_heading(3, Negative Acknowledgement)

Within the context of a session, many requests can return a Negative
Acknowledgement to indicate that although the server understood the
request, there was an error encountered performing the requested
operation.

m4_pre(
struct Nack {
    id32 xid;
    uint16 error;
    string message;
    Value args[]
};)m4_dnl

The error field is a decimal value structured into ranges with a
general category that indicates what action should be taken by the
client, and a specific error number that identifies the problem.
Clients MUST handle error values according to their category, and
SHOULD present meaningful information to the application derived from
the defined error values.

Clients MAY interpret implementation specific error codes, on the
basis of server identity determined during connection negotiation.
Unrecognised codes MUST be reported using the undefined category error
(ie. value x000).

Receiving a reserved error code SHOULD be handled as a protocol error.

.KS
.nf
Error Code  |  Meaning / Action                    |  Arguments
------------+--------------------------------------+------------
   0        |  No error - Illegal value            |  None
            |                                      |
   1        |  ConnRqst version mismatch           |  None
   2        |  Authorisation failure               |  None
   3        |  Authentication failure              |  None
   4-  499  |  ( Reserved )                        |  Undefined
 500-  999  |  ( Implementation-specific           |  Undefined
            |    connection establishment error )  |
            |                                      |
1000        |  Undefined protocol error. Requires  |  None
            |  connection abort                    |
1001        |  Protocol error                      |  None
1002        |  No such subscription                |  sub_id, id64
1003        |  No such quench                      |  quench_id, id64
1004        |  Bad keys scheme                     |  scheme_id, id32
1005        |  Bad keyset index                    |  scheme_id, id32
            |                                      |  index, int32
1006- 1499  |  ( Reserved )                        |  Undefined
1500- 1999  |  ( Implementation-specific error     |  Undefined
            |    requiring connection abort )      |
            |                                      |
2000        |  Undefined error with request        |  None
2001        |  No such key                         |  None
2002        |  Key exists                          |  None
2003        |  Bad key                             |  None
2004        |  Nothing to do                       |  None
2005- 2100  |  ( Reserved )                        |  Undefined
2101        |  Parse error                         |  offset, int32
            |                                      |  token, string
2102        |  Invalid token                       |  offset, int32
            |                                      |  token, string
2103        |  Unterminated string                 |  offset, int32
2104        |  Unknown function                    |  offset, int32
            |                                      |  name, string
2105        |  Overflow                            |  offset, int32
            |                                      |  token, string
2106        |  Type mismatch                       |  offset, int32
            |                                      |  expr, string
            |                                      |  type, string
2107        |  Too few arguments                   |  offset, int32
            |                                      |  function, string
2108        |  Too many arguments                  |  offset, int32
            |                                      |  function, string
2109        |  Invalid regular expression          |  offset, int32
            |                                      |  regexp, string
2110- 2200  |  ( Reserved )                        |  Undefined
2201        |  Empty quench                        |  None
2202        |  Attribute exists                    |  name, string
2203        |  No such attribute                   |  name, string
2110- 2499  |  ( Reserved )                        |  Undefined
2500- 2999  |  ( Implementation-specific           |  Undefined
            |    operation failure )               |
            |                                      |
3000-65535  |  ( Reserved )                        |  Undefined   
.fi
.KE

The message field is a Unicode string template containing embedded
tokens of the form %n, where n is an index into the args array.  When
preparing the error message for presentation to the user, each %n
should be replaced by the appropriately formatted value from the args
array.

The language in which the Nack message is sent by a server MAY be
negotiated during connection establishment.  Alternatively, clients
MAY provide local templates to be used for generating the formatted
text for presentation to the application.

m4_heading(3, Connect Request)

Using the protocol and endpoint information obtained either directly
or via server discovery, a client MAY initiate a session with the
server endpoint.  It MUST then send a ConnRqst to establish protocol
options to be used for the session.

Concrete protocols MAY choose not to provide an implementation of the
concept of a session.  Such protocols MUST NOT support ConnRqst or any
other packets from subsets B or C.

An initiated session that has not received a ConnRqst within a limited
time period SHOULD be closed by the server.  This time period MUST NOT
be less than five (5) seconds.

The ConnRqst MAY contain requests for various protocol options to be
used by the connection.  These options are identified using a string
name.  Some options refer to properties of the server, while others
MAY be used by the protocol layers.

Legal option names, their semantics, and allowed range of values are
defined later in this document.

m4_pre(
struct ConnRqst {
    id32 xid;
    uint8 client_major_version;
    uint8 client_minor_version;
    NameValue options[];
    Keys nfn_keys;
    Keys sub_keys;
};)m4_dnl

m4_heading(3, Connect Reply)

Sent by the Elvin server to a client.  Confirms a connection request.
Specifies the connection option values agreed by the server.

m4_pre(
struct ConnRply {
    id32 xid;
    NameValue options[];
};)m4_dnl

For each legal option included in the ConnRqst, a matching response
MUST be present in the ConnRply.  Where the value returned differs from
that requested, the client MUST either use the returned value, or
request closure of the connection.  Unrecognised options MUST NOT be
returned by the server.

Option values not requested by the client are dictated by the server.  If
an option has the specified default value, it MAY be sent to the client.
Where the server implementation uses a non-default value, it MUST be sent
to the client.

m4_heading(3, Disconnect Request)

Sent by client to the Elvin server.  Requests disconnection.

m4_pre(
struct DisconnRqst {
    id32 xid;
};)m4_dnl

A client MUST send this packet and wait for confirmation via
Disconnect before closing the connection to the server.  The client
library MUST NOT send any further messages to the server once this
message has been sent.  The client library MUST continue to read from
the server connection until a Disconnect packet is received.

A server receiving a DisconnRqst should suspend further evaluation of
subscriptions and notification of subscription changes for this
client.  A Disconnect packet should be appended to the client's output
buffer, and finally, the output buffer flushed before the connection
is closed.

It is a protocol violation for a client to close its connection
without sending a DisconnRqst (see protocol violations below).

m4_dnl 
m4_heading(3, Disconnect Reply)

Sent by the Elvin server to a client.  This packet is sent in response
to a Disconnect Request, prior to breaking the connection.

m4_pre(
struct DisconnRply {
    id32 xid;
};)m4_dnl

This MUST be the last packet sent by a server on a connection.  The
underlying (transport) link MUST be closed immediately after this
packet has been successfully delivered to the client.

m4_dnl 
m4_heading(3, Disconnect)

Sent by the Elvin server to a client.  This packet is sent in two
different circumstances: to direct the client to reconnect to another
server, or to inform that client that the server is shutting down.

m4_pre(
struct Disconn {
    id32  reason;
    string args;
};)m4_dnl

.KS
where the defined values for "reason" are

.nf
  Reason  |  Definition
  --------+--------------------------------------------------------
     0    |  Reserved.
     1    |  Server is closing down.
     2    |  Server is closing this connection, and directs the
          |  client to connect to the server address in "args".  
     4    |  Server is closing this connection for repeated 
          |  protocol errors.
.fi
.KE

This MUST be the last packet sent by a server on a connection.  The
underlying (transport) link MUST be closed immediately after this
packet has been successfully delivered to the client.

The server MUST NOT close the client connection without sending either
a DisconnRply or Disconn packet except in the case of a protocol
violation.  If a client detects that the server connection has been
closed without receiving one of these packets, it should assume
network or server failure.

A client receiving a redirection via a Disconn MUST attempt to connect
to the specified server before attempting any other servers for which
it has address information.  If the connection fails or is refused
(via ConnRply), the default server selection process SHOULD be
performed.

A client MAY perform loop detection for redirection to cater for a
misconfiguration of servers redirecting a client indefinitely.  If a
loop is detected, the default server selection process SHOULD be
performed.


m4_dnl
m4_heading(3, Security Request)

Sets the keys associated with the connection.  Two sets of keys are
maintained by the server: those used when sending notifications, and
those used for registered subscriptions.

This packet allows keys to be added or removed from either or both
sets as an atomic operation.

m4_pre(
struct SecRqst {
    id32 xid;
    Keys add_nfn_keys;
    Keys del_nfn_keys;
    Keys add_sub_keys;
    Keys del_sub_keys;
};)m4_dnl

It is a protocol error to request the addition of a key already
registered, or the removal of a key not registered.

m4_heading(3, Security Reply)

Sent by the server to clients to confirm a successful change of keys.

m4_pre(
struct SecRply {
    id32 xid;
};)m4_dnl

m4_heading(3, Drop Warning)

Sent by servers to clients to indicate that notification packets have
been dropped from this place in the data stream due to congestion in
the server.  Dropped packets MAY include NotifyDeliver, SubAddNotify,
SubModNotify and SubDelNotify.

m4_pre(
struct DropWarn {
};)m4_dnl

The server may also drop ConnConf packets, but this MUST NOT result in
in a DropWarn being sent to the client.  As a ConnConf is only sent to
confirm the connection between a client and the server is still
active, a ConnConf will be dropped if there is any other pending data
to be sent ot the client.  The client can determine from the fact that
other packets have arrived that the connection still works.

m4_heading(3, Test Connection)

A client's connection to the Elvin server can be inactive for long
periods.  This is especially the case for subscribers for whom
matching messages are seldom generated.  Clients and servers MUST
implement Test Connection and Confirm Connection packets to allow
verification of connectivity.

This application-level functionality is an alternative to a protocol
level connectivity-loss reporting mechanism.  If an Elvin transport
protocol does not provide support for lost connection detection, this
mechanism can be used.  In particular, it is defined because of the
lack of wide support for the TCP_KEEPALIVE socket option used to
control the interval of inactivity that triggers a keep-alive exchange
in TCP/IP.

m4_pre(
struct TestConn {
};)m4_dnl

A Test Connection packet MAY be sent by either client or server to
verify that it is still connected after a period where no packets have
been received.  After a TestConn has been sent, but no traffic has
been received from the peer within the standard synchronous operation
timeout period, the connection is assumed dead, and MUST be closed as
for a protocol error.

For clients, a TestConn MUST NOT be sent within 30 seconds of
receiving other traffic from the server.  This delay period MUST be
configurable, sending MUST be able to be disabled, and SHOULD be
disabled by default.  These restrictions serve to limit the load on
servers servicing TestConn requests.

m4_heading(3, Confirm Connection)

m4_pre(
struct ConfConn {
};)m4_dnl

Clients and servers MUST implement support for ConfConn.

A server receiving a TestConn packet MUST queue a ConfConn response if
there are no other packets waiting for the client to read.  If other
packets are waiting for the client to service its connection, the
server MUST NOT send the ConfConn (since the client's reading of the
other packets will indicate that its connection is active).

Servers MAY drop ConfConn packets queued for delivery to a client if
there is any other packet about to be sent to the client.  The client
MUST use use the fact that any packet arriving from the server indicates
an active connection.

Clients MUST send a ConfConn in response to a TestConn from the
server.

m4_heading(3, Notification Emit)

Sent by client to the Elvin server.  There are two possible delivery
modes, determining how the server should match supplied security keys.
Delivery can be specified as requiring the consumer to have a matching
key (deliver_insecure is not set).  Alternatively, the producer can
not require that the consumer have a key, but if one or more are
supplied, then at least one MUST match (deliver_insecure is set).

m4_pre(
struct NotifyEmit {
    NameValue attributes[];
    boolean deliver_insecure;
    Keys keys;
};)m4_dnl


m4_heading(3, Notification Deliver)

Sent by the Elvin server to a client. 

m4_pre(
struct NotifyDeliver {
    NameValue attributes[];
    id64 secure_matches[];
    id64 insecure_matches[];
};)m4_dnl

m4_heading(3, Subscription Add Request)

Sent by client to the Elvin server.  Requests delivery of
notifications which match the supplied subscription expression.

m4_pre(
struct SubAddRqst {
    id32 xid;
    string expression;
    boolean accept_insecure;
    Keys keys;
};)m4_dnl

If successful, the server MUST respond with a SubRply.

If the client has registered too many subscriptions, the server MUST
return a Nack with error code X.

If the server has too many registered subscriptions, it MUST return a
Nack with error code X.

If the subscription expression fails to parse, the server MUST return
a Nack with errors codes 1, 2, 3 or 4.

m4_heading(3, Subscription Modify Request)

Sent by client to the Elvin server.  Update the specified subscription
to request notifications matching a different subscription expression,
or to alter the security keys associated with the subscription.

m4_pre(
struct SubModRqst {
    id32 xid;
    id64 subscription_id;
    string  expression;
    boolean accept_insecure;
    Keys add_keys;
    Keys del_keys;
};)m4_dnl

Any (and all) of the expression, add_keys and del_keys field MAY be
empty.  The accept_insecure field cannot be empty: it must always be
set to the required value. If the accept_insecure field value is
unchanged from that registered at the server, and all other fields are
empty, the modification SHALL be considered successful.

A successful modification of the subscription MUST return a SubRply to
the client.

A Nack, with error code 5, MUST be returned if the subscription_id is
not valid.

If the subscription expression fails to parse, the server MUST return
a Nack describing the error.  Allowed error codes are 1, 2, 3 or 4.
An invalid expression MUST NOT alter the current state of the
specified subscription.

An attempt either to add a key already associated with the specified
subscription or to remove a key not currently associated with the
specified subscription MUST be ignored, and the remainder of the
operation processed.  No indication that any part of the operation was
ignored is returned to the client.

m4_heading(3, Subscription Delete Request)

Sent by client to the Elvin server.  A Nack will be returned if the
subscription identifier is not valid.

m4_pre(
struct SubDelRqst {
    id32 xid;
    id64 subscription_id;
};)m4_dnl

m4_heading(3, Subscription Reply)

Sent from the Elvin server to the client as acknowledgement of a successful
subscription change.

m4_pre(
struct SubRply {
    id32 xid;
    id64 subscription_id;
};)m4_dnl

m4_heading(3, Quench Add Request)

Sent by clients to the Elvin server.  Requests notification of
subscriptions referring to the specified attributes.

m4_pre(
struct QnchAddRqst {
    id32 xid;
    string names[];
    boolean deliver_insecure;
    Keys keys;
};)m4_dnl

m4_heading(3, Quench Modify Request)

Sent by client to the Elvin server.  Requests changes to the list of
attribute names associated with a quench identifier.

m4_pre(
struct QnchModRqst {
    id32 xid;
    id64 quench_id;
    string names_add[];
    string names_del[];
    boolean deliver_insecure;
    Keys add_keys;
    Keys del_keys;
};)m4_dnl

m4_heading(3, Quench Delete Request)

Sent by client to the Elvin server.  Requests that the server no
longer notify the client of changes to subscriptions with the
associated attribute names.

m4_pre(
struct QnchDelRqst {
    id32 xid;
    id64 quench_id;
};)m4_dnl

m4_heading(3, Quench Reply)

Sent from the Elvin server to the client as acknowledgement of a successful
quench requirements change (QnchAddRqst, QnchModRqst, QnchDelRqst):

m4_pre(
struct QnchRply {
    id32 xid;
    id64 quench_id;
};)m4_dnl

m4_heading(3, Subscription Add Notification)

Sent from server to clients to inform them of a new subscription
predicate component matching the registered quench attribute name
list for each of the identified quench registrations.

The secure quench ids represent the quenches whose keys matched the
corresponding subscription keys, whereas the insecure quenches did not
have matching keys but both the subscription's accept_insecure and the
quench's deliver_insecure flags were set.

m4_pre(
struct SubAddNotify {
    id64 secure_quench_ids[];
    id64 insecure_quench_ids[];
    id64 term_id;
    SubAST sub_expr;
};)m4_dnl

m4_heading(3, Subscription Modify Notification)

This packet indicates that a subscription predicate component matching
their registered quench attribute name list changed for each of the
identified quench registrations.

Note that a subscription term that had a key replaced might no longer
match a particular quench registeration.  This is notified using a
SubDelNotify.  Similarly a key replacement might cause a SubAddNotify
if its key list now intersects with that of a registered quench
request.

m4_pre(
struct SubModNotify {
    id64 secure_quench_ids[];
    id64 insecure_quench_ids[];
    id64 term_id;
    SubAST sub_expr;
};)m4_dnl

m4_heading(3, Subscription Delete Notification)

Sent from server to clients to inform them of the removal of a
subscription predicate component that had matched their registered
attribute name list for each of the identified quench registrations.

m4_pre(
struct SubDelNotify {
  id64 quench_ids[];
  id64 term_id;
};)m4_dnl

m4_dnl
m4_dnl  connection-opts
m4_dnl

m4_heading(2, Connection Options)

Connection options control the behaviour of the server for the
specified connection.  Set during connection, they may also be
modified during the life of the connection using QosRqst.

A server implementation MUST support the following options.  It MAY
support additional, implementation-specific options.

.KS
.nf
  Name                        |  Type    |  Min   Default      Max
  ----------------------------+----------+-------------------------
  attribute_max               |  int32   |    64     256     2**31
  attribute_name_len_max      |  int32   |    64    2048     2**31
  byte_size_max               |  int32   |    1K      1M     2**31  
  lang                        |  string  |   (server defined)
  notif_buffer_drop_policy    |  string  | { "oldest", "newest",
                                             "largest", "fail" }
  notif_buffer_min            |  int32   |    1       1K     2**31
  opaque_len_max              |  int32   |    1K      1M     2**31
  string_len_max              |  int32   |    1K      1M     2**31
  sub_len_max                 |  int32   |    1K      2K     2**31
  sub_max                     |  int32   |    1K      8K     2**31
.fi
.KE
m4_heading(1, PROTOCOL IMPLEMENTATION)

The abstract protocol described in the previous section may be
implemented by multiple concrete protocols.  The concrete protocols
used to establish a connection can be specified at run time, and
selected from the intersection of those offered by the client and
server-side implementations.

m4_heading(2, Layering and Modules)

A connection supporting the Elvin protocol can be comprised of
multiple, layered components, referred to as protocol modules.  These
modules are layered to form a protocol stack, providing a connection
over which the abstract protocol packets are carried.

The combined stack must provide marshalling, security and data
transport facilities.

m4_heading(2, Standard Protocol)

overview: TCP/SSL, XDR

Elvin4 supports a 3-layer protocol stack, providing separate
marshalling, security and transport options.  While the content of the
resulting data packets composed by each of these layers is specified
by this document, the programming interfaces are internal to an
implementation.

An Elvin4 implementation MAY support any number of distinct
combinations of protocols.  An Elvin4 implementation MUST support the
standard protocol stack comprised of XDR marshalling, SSL-3 security
and TCP/IP transport.  This combination is known as the Elvin4
standard protocol.

Additional protocol layers must be proposed and registered via the
IETF RFC series, either as a revision to this document, or as a
separate specification.

m4_dnl
m4_dnl  tcp-transport
m4_dnl
m4_heading(3, TCP Protocol)

The default Elvin transport module uses a TCP connection to link
clients with an Elvin router.

Elvin routers offer a TCP endpoint, at a particular port.  The
IANA-assigned port number for Elvin client protocol is 2917.  Clients
initiate the TCP connection to the router's host and port.

The abstract protocol requires that packet boundaries are preserved.
Since TCP provides a stream-oriented protocol, an additional layer of
framing must be implemented to support this requirement.

Each packet, passed to the TCP module from higher layer(s) in the
stack, is sent preceded by a 4-octet framing header.  The header value
is an unsigned 2's complement integer in network byte order,
specifying the length of the contained packet in octets.

.KS
.nf
          0   1   2   3
        +---+---+---+---+---+---+---+...+---+---+---+
        |    length     |       packet data         |    FRAMED PACKET
        +---+---+---+---+---+---+---+...+---+---+---+
.fi
.KE

The receiving side of the connection should first read the header,
record the expected length, and then read until the complete packet is
received.

An implementation MAY limit the size of packets it is willing to
receive.  After reading a header preceding a packet exceeding that
length, the implementation MUST reset the TCP connection.  Note that
the use of a 4 octet header puts an upper limit on this size.  Elvin
clients SHOULD negotiate the maximum packet length during connection.

An open TCP connection may be closed only between the last byte of
packet data, and the following framing header.  If the connection is
lost mid-packet, it MUST be reported to the abstract protocol layer as
a protocol error.

m4_heading(4, Use of Proxies)

In some environments, it is necessary to use proxy services to
circumvent firewall policies that would otherwise block Elvin protocol
connections.  Lest we be misunderstood, this practice is NOT
RECOMMENDED.

Having said that, the prevalence of administrative policy requiring
such breakage is such that Elvin TCP protocol modules SHOULD support
establishment of connections via HTTP proxies, SHOULD support basic
authentication and MAY support alternative authentication mechanisms.

A proxy connection is established by connecting first to an endpoint
offered by the proxy server, and requesting that it tunnel further
data on the connection to the specified Elvin router endpoint.

This request takes the form of

   CONNECT host.example.com HTTP/1.1
   Proxy-Authorization: Basic XXXXXX

with the optional parameter lines terminated by a blank line.

The client then waits for a response from the proxy server, indicating
whether its request was successful.  The response from the proxy
server consists of CRLF-delimited lines of text, terminated by a blank
line.  Note that this text can be a substantial length.

The text is a properly formatted HTTP response, and should be parsed
according to XXX.  Common response codes are 200, 404 and 407.  As an
example,

   HTTP/1.0 200 Connection established

is a successful response.




m4_heading(3, Security)

null

m4_dnl
m4_dnl  xdr-encoding
m4_dnl
m4_heading(3, Marshalling)

The standard Elvin 4 marshalling uses XDR [RFC1832] to encode data.
Messages sent between the a client and and Elvin server are encoded as
a sequence of encoded XDR types.

This section uses diagrams to illustrate clearly certain segment and
packet layouts.  In most illustrations, each box (delimited by a plus
sign at the 4 corners and vertical bars and dashes) depicts a 4 byte
block as XDR is 4 byte aligned.  Ellipses (...) between boxes show
zero or more additional bytes where required. Some packet diagrams
extend over multiple lines.  In these cases, '>>>>' at the end of the
line indicates continuation to the next line and '<<<<' at the
beginning of a line indicates a segment has some preceding blocks on
the previous line.  Numbers used along the top line of packet diagrams
indicate byte lengths.

.nf
        +---------+---------+---------+...+---------+
        | block 0 | block 1 | block 2 |...|block n-1|   PACKET
        +---------+---------+---------+...+---------+
.fi

m4_heading(4, Packet Identification)

The abstract packet descriptions deliberately leave the method for
identifying packets to the concrete encoding.  For XDR, each packet is
identified by the pkt_id enumeration below:

m4_pre(
`enum {
    UNotify        = 32,

    Nack           = 48,   ConnRqst       = 49,
    ConnRply       = 50,   DisconnRqst    = 51,
    DisconnRply    = 52,   Disconn        = 53,
    SecRqst        = 54,   SecRply        = 55,
    NotifyEmit     = 56,   NotifyDeliver  = 57,
    SubAddRqst     = 58,   SubModRqst     = 59,
    SubDelRqst     = 60,   SubRply        = 61,
    DropWarn       = 62,   TestConn       = 63,
    ConfConn       = 64,

    QnchAddRqst    = 80,   QnchModRqst    = 81,
    QnchDelRqst    = 82,   QnchRply       = 83,
    SubAddNotify   = 84,   SubModNotify   = 85,
    SubDelNotify   = 86
} pkt_id;')

In XDR, enumerations are marshalled as 32 bit integral values.  For
Elvin, each packet marshalled using XDR starts with a value from
the above pkt_id enumeration.  The format for the remainder of the
packet is then specific to the value of the packet identifer.

       0   1   2   3    
     +---+---+---+---+---+---+---+...+---+---+---+
     |     pkt_id    |         remainder         |    ENCODED PACKET
     +---+---+---+---+---+---+---+...+---+---+---+
     |<---header---->|<-----------data---------->|

Note that the XDR marshalling layer does NOT indicate the length of the
packet.  This is left to the underlying transport layer being used. For
example, a UDP transport could use the fact that a datagram contains the
length of data in the packet.

m4_heading(4, Base Types)

The Elvin protocol relies on seven basic types used to construct each
packet: boolean, uint8, int32, int64, real64, string, byte[].

Below is a summary of how these types are represented when using XDR
encoding.  Each datatype used in the abstract descriptions of the
packets has a mapping to a corresponsing XDR data type as defined in
[RFC1832].

.KS
.nf
  -------------------------------------------------------------------
  Elvin Type  XDR Type       Encoding Summary
  -------------------------------------------------------------------
  boolean     bool           4 bytes, last byte is 0 or 1

  uint8       unsigned int   4 bytes, last byte has value

  int32       int            4 bytes, MSB first

  int64       hyper          8 bytes, MSB first

  real64      double         64-bit double precision float

  string      string         4 byte length, UTF8 encoded string, zero 
                             padded to next four byte boundary

  byte[]      variable-      4 byte length, data, zero padded to next
              length opaque  four byte boundary
  -------------------------------------------------------------------
.fi
.KE

When the type of following data needs to be described in a packet (eg,
the value in a name-value pair used in NotifyEmit packets), one of the
base type ID's is encoded as an XDR enumeration.  This is often needed
when a value in a packet is one of a number of possible types.  In these
cases, the encoded value is preceded a type code from the following
enumeration:

m4_pre(
`enum {
    int32_tc  = 1,
    int64_tc  = 2,
    real64_tc = 3,
    string_tc = 4,
    opaque_tc = 5
} value_typecode;')

Note that the above enumeration does not include all of the datatypes
used in the protocol.  It only describes data which can be contained
in the abstract Value segment of a packet.  A Value in an encoded
packet is thus typed by prepending four bytes which encode the type
code:
    
.KS
.nf
       0  1  2  3 
     +--+--+--+--+--+--+--+--+...+--+--+--+--+
     | typecode  |          value            |        TYPED VALUE
     +--+--+--+--+--+--+--+--+...+--+--+--+--+
     |<--enum--->|<--format depends on enum-->
.fi
.KE

For illustration, if an int64 of value 1024L is preceded by its type
for marshalling, it would be sent as four bytes for the type id of 1
and eight bytes for the value.

.KS
.nf
       0  1  2  3  4  5  6  7  8  9 10 11  
     +--+--+--+--+--+--+--+--+--+--+--+--+
     |    0x02   |        0x0400         |           INT64 EXAMPLE
     +--+--+--+--+--+--+--+--+--+----+---+
     |<--enum--->|<--------hyper-------->|
.fi
.KE

m4_heading(4, Encoding Arrays)

All arrays in the abstract protocol are of variable length.  Arrays of
objects are encoded by prepending the length of the array as an int32
- the items are in the array are then each encoded in sequence
starting at item 0.  The 32bit length places a theoretical limit of
(2**32) - 1 items per list.  In practice, implementations are expected
to have much lower maximums for the number of items in a list
transmitted per packet.  For example, an implemenation may restrict
the number of fields in a notification to 1024.  Such limitations
SHOULD be documented for each implemenation.  Service offers and
connection replys SHOULD also provide such limitations.  See the
section X on Connection Establishment.

.KS
.nf
       0  1  2  3  
     +--+--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+--+
     |     n     |  item 0   |  item 1   |...| item n-1  |  ARRAY
     +--+--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+--+
     |<--int32-->|<----------------n items-------------->|
                                                          
.fi
.KE

For illustration, *** FIXME *** ....

.KS
.nf
      0           4           8          12
     +--+--+--+--+--+--+--+--+--+--+--+--+
     |    0x01   |        0x400          |           ARRAY EXAMPLE
     +--+--+--+--+--+--+--+--+--+----+---+
     |<--enum--->|<--------hyper-------->|
.fi
.KE

m4_heading(4, Subscription Abstract Syntax Trees)

m4_pre(
`enum {
    name_tc   = 0,
    int32_tc  = 1,
    int64_tc  = 2,
    real64_tc = 3,
    string_tc = 4,
    regular_expression_tc = 5,

    equals_tc = 8,
    not_equals_tc = 9,
    less_than_tc = 10,
    less_than_equals_tc = 11,
    greater_than_tc = 12,
    greater_than_equals = 13,

    or_tc = 16,
    xor_tc = 17,
    and_tc = 18,
    not_tc = 19,

    unary_plus_tc = 24,
    unary_minus_tc = 25,
    multiply_tc = 26,
    divide_tc = 27,
    modulo_tc = 28,
    add_tc = 29,
    subtract_tc = 30,

    shift_left_tc = 32,
    shift_right_tc = 33,
    logical_shift_right_tc = 34,
    bit_and_tc = 35,
    bit_xor_tc = 36,
    bit_or_tc = 37,
    bit_negate_tc = 38,

    is_int32_tc = 40,
    is_int64_tc = 41,
    is_real64_tc = 42,
    is_string_tc = 43,
    is_opaque_tc = 44,
    is_nan_tc = 45,

    begins_with_tc = 48,
    contains_tc = 49,
    ends_with_tc = 50,
    wildcard_tc = 51,
    regex_tc = 52,

    exists_tc = 56,
    equals_tc = 57,
    size_tc = 58
} subast_typecode;')

m4_heading(4, Packet Encoding Example)

An Elvin notification is a list of name-value pairs, where
the value is one of the five base types of int32, int64, real64,
string and opaque.  The encoding of these pairs must also include
the data type for the value.  For both the NotifyEmit and the
NotifyDeliver packets, we introduce a name-type-value (NTV) block
used to encode a notification attribute.

The name of an attribute is always encoded as an XDR string. The type
is an enumeration of five different values indicating one of int32,
int64, real64, string or opaque (byte array).  The value, encoded as a
standard XDR type, is determined by the preceding type.

On the wire, a name-value is laid out as follows:

.KS
.nf
  +------+...+------+------+------+...+------+
  |      name       | type |      value      |       NAME-TYPE-VALUE
  +------+...+------+------+------+...+------+

   name      (string)  name of this attribute
   type      (enum)    type of the encoded value. 0ne of int32, int64,
                       real64, string or opaque
   value     -         the encoded value for this attribute.
.fi
.KE

Notifications begin with the number of attributes as an
int32.  

.KS
.nf
  0      4      8      12         ...
 +------+------+------+...+------+...+------+...+------+
 |pkt id|len n |       ntv 0     |   |      ntv n-1    | >>>>
 +------+------+------+...+------+...+------+...+------+
               |<----------n name-type-values--------->|

           +------+------+...+------+...+------+...+------+
      <<<< |len m |      key 0      |   |     key m-1     |
           +------+------+...+------+...+------+...+------+
                  |<----------------m keys--------------->|
                                                        NOTIFICATION
.fi
.KE
.KS
   pkt id        (enum)   packet type for NotifyEmit
   len n         (int32)  number of name-type-value triples in the 
                          notification. n MUST be greater than zero.
   ntv x         [block]  encoded as a name-type-value triple, 
                          described above. There MUST be n 
                          name-type-value blocks where n > 0.
   len m         (int32)  number of security keys in the notification
   key x         (opaque) uninterpreted bytes of a security key. There
                          MUST be m keys where m >= 0.
.fi
.KE


m4_heading(2, Environment)

.nf
ports
location
service names
environment variables
file usage
- /etc/elvind.conf
- /etc/slp.conf
registry
.fi
m4_heading(1, SECURITY CONSIDERATIONS)

m4_heading(1, IANA CONSIDERATIONS)

protocol module names

key mechanism identifiers

m4_dnl
m4_dnl sub-syntax
m4_dnl
.bp
m4_heading(1, APPENDIX A - ELVIN SUBSCRIPTION LANGUAGE)
.LP
The Elvin subscription language is used by clients to select
notifications for delivery.  This section documents the formal syntax
for the language.

Subscription expressions are normally represented as strings in the
programming language of the client application.  These strings SHOULD
allow the entry of the full Unicode character set, either directly or
through an escaping mechanism.  The subscription string MUST be
encoded as Unicode UTF-8 prior to transmission by the client library.

While full Unicode strings are required, they are only used within the
language for representing string literals.  Attribute names are
restricted to a subset of the ASCII character set.

The specification is written using ABNF [RFC2234].

.ID 2
;  Elvin subscription language
;
;  version: 4.0

;
;  expressions
;


sub-exp			= sub-exp bool-op sub-exp /
			  bool-exp

bool-exp		= value "==" value /
			  value "!=" value /
			  value "<" value /
			  value "<=" value /
			  value ">" value /
			  value ">=" value /
			  bool-function-exp /
			  "!" bool-exp /
			  "(" sub-exp ")"

value			= string-literal /
			  math-exp

math-exp		= math-exp math-op math-exp /
			  num-value

num-value		= num-literal /
			  name /
			  function-exp /
			  unary-math-op num-value /
			  "(" value ")"

name			= id-literal

bool-function-exp	= bool-pred "(" args ")"

function-exp		= function-pred "(" args ")"


;
; predicates
;

bool-pred		= "exists" / "int32" / "int64" /
			  "real64" / "string" / "opaque" /
			  "nan"

function-pred		= "begins-with" / "ends-with" / 
			  "contains" / "wildcard" / "regex" /
			  "equals" / "size" /
			  "fold-case" /
			  "decompose" / "decompose-compat"

;
; operators
;

bool-op			= "&&" / "^^" / "||"

math-op			= "&" / "^" / "|" /
			  "<<" / ">>" / ">>>" /
			  "+" / "-" / "*" / "/" / "%"

unary-math-op		= "+" | "-" | "~"


;
; literals
;

string-literal		= DQUOTE 0*(string-char / quote) DQUOTE /
			  quote 0*(string-char / DQUOTE) quote

string-char		= safe-utf8-char /
			  backslash safe-utf8-char /
			  magic-char

magic-char		= backslash DQUOTE /
			  backslash quote /
			  backslash backslash

safe-utf8-char		= %x01-21 / %x23-26 / %x28-5b / %x5d-fd
			; not single quote, double quote or backslash


num-literal		= int32-literal / int64-literal / real64-literal

int32-literal		= decimal-literal / octal-literal / hex-literal

int64-literal		= int32-literal "l"
			; ABNF is case insensitive so this includes "L"

real64-literal		= 1*DIGIT "." 1*DIGIT [exponent]

exponent		= "e" [ "+" | "-" ] 1*DIGIT
			; ABNF is case insensitive so this includes "E"

backslash		= %x5c

quote			= %x27

id-literal		= id-first 0*id-char

id-first		= ALPHA / "_" / backslash safe-utf8-char

id-char			= %x21 / %x23-26 / %x28 / %x2a-2b /
			  %x2d-5a / %5e-ff / backslash safe-utf8-char

owsp			= 0*swsp
wsp			= 1*swsp
swsp			=  SP / HTAB / CR / LF


.DE

m4_dnl
m4_dnl  bibliography
m4_dnl
.bp
m4_heading(1, REFERENCES)

.IP [ERDP] 12
Arnold, D., Boot, J., Phelps, T., Segall, B.,
"Elvin Router Discovery Protocol",
Work in progress

.IP [ERCP] 12
Arnold, D., Boot, J., Phelps, T.,
"Elvin Router Clustering Protocol",
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

.IP [RFC2234] 12
Crocker, D., Overell, P., 
"Augmented BNF for Syntax Specifications: ABNF", 
RFC 2234, November 1997.

.IP [RFC2279] 12
Yergeau, F.,
"UTF-8, a transformation format of ISO 10646",
RFC 2279, January 1998.

.IP [UNICODE] 12
Unicode Consortium, The,
"The Unicode Standard, Version 3.0",
Addison-Wesley, 2000.

.IP [POSIX.1] 12
IEEE,
"POSIX.1-1990",
1990.
.KS
m4_heading(1, CONTACT)

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
m4_heading(1, FULL COPYRIGHT STATEMENT)

Copyright (C) 2003-__yr Mantara Software
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

Mantara Software welcomes comments on this specification.  Please address
any queries, comments or fixes (please include the name and version of
the specification) to the address below:

.nf
    Mantara Software
    PO Box 1820
    Toowong QLD 4066
    Australia
    Tel: +61 7 3876 8844
    Fax: +61 7 3876 8843
    Email: support@mantara.com
.fi

Elvin is a trademark of Mantara Software.  All other trademarks and
registered marks belong to their respective owners.
.KE
