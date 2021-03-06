.\" -*- nroff -*-
.\" ################################################################
.\" COPYRIGHT_BEGIN
.\"
.\" Copyright (C) 2000-2007,2018 Elvin.Org
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
.\"
.\" General macros for I-D formatting
.\"
m4_define(__title, `Elvin Client Protocol 4.0')m4_dnl
m4_include(macros.m4)m4_dnl
.pl 11.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.nr PI 3n
.ds LF Arnold, ed.
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH __date
.ds CH __title
.hy 0
.ad l
Elvin.Org                                              D. Arnold, Editor
Preliminary INTERNET-DRAFT                           ZeroXOne Consulting

Expires: aa bbb cccc                                         _d __m __yr

.DS C
__title
__file
.DE
m4_dnl
m4_dnl Header macros end an indent, so make sure we have one operating here
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
m4_dnl
m4_heading(1, ABSTRACT)

This document describes a client access protocol for the Elvin
notification service.  It includes a general overview of the system
architecture, and defines an access protocol in terms of operational
semantics, an abstract protocol, and a default concrete implementation
of the abstract protocol.
m4_dnl
m4_dnl FIXME: tdb (probably last ;-)
m4_dnl
m4_dnl .ti 0
m4_dnl TABLE OF CONTENTS
m4_dnl
m4_dnl .bp
m4_dnl
m4_dnl
m4_dnl  INTRODUCTION
m4_dnl
m4_dnl
m4_heading(1, INTRODUCTION)

Elvin is a content-based publish/subscribe notification service.  An
Elvin implementation is comprised of Elvin routers that forward and
deliver messages, called notifications, after evaluating their
contents against a body of registered subscriptions.

Elvin notifications are collections of named, typed values.
Subscriptions are logical predicate expressions that the router
evaluates for each received notification.  Notifications are delivered
to the subscriber if the result of the predicate evaluation is true.

Elvin clients can be characterised as producers or publishers, which
send notifications; and consumers or subscribers, which request
delivery of notifications from the service.  Consumers normally
subscribe to receive notifications matching some supplied criteria.

While directed communication is well serviced by the Internet protocol
suite, undirected communications, where the sender is unaware of the
identity, location or even existence of the receiver, is limited to
the various forms of multicast.  While multicast is appropriate for
many applications, it is inherently channel-based: a particular
address and port must be shared by the communicating applications.

Elvin is a notification service that provides fast, simple, undirected
messaging, using content-based selection of delivered notifications.
It has been show to work on a wide-area scale and is designed to
complement the existing Internet protocols.

Elvin notifications are routed from their source to required
destinations by Elvin router(s).  Delivery has best-effort,
at-most-once semantics.  Under no circumstances should an Elvin client
receive duplicate notifications.  Notifications from a single source
must be delivered in order, but interleaving of notifications from
different sources is allowed in any order.

The inter-router protocol is not specified by this document.  It is
noted, however, that notifications are forwarded between routers, and
that such journeys are subject to filtering and greater latency than
notifications between clients of a single router process.
m4_dnl
m4_dnl
m4_dnl  TERMINOLOGY
m4_dnl
m4_dnl  terminology for both Elvin and the RFC series
m4_dnl
m4_heading(1, TERMINOLOGY)

This document discusses clients, client libraries, routers, producers,
consumers, quenchers, notifications and subscriptions.

An Elvin router is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin notifications. An Elvin
client is a program that uses the Elvin router, via a client library
for a particular programming language.  A client library implements
the Elvin protocol and manages clients' connections to an Elvin
router.

Clients can have three roles: producer, consumer or quencher.
Producer clients create notifications: a form of structured message,
and send them, using a client library, to an Elvin router.  Consumer
clients establish a session with an Elvin router and register a
request for delivery of notifications matching a subscription
expression.  Quenching clients also establish a session with an Elvin
router, and register a request to be informed of changes to the
router's subscription database that match criteria supplied by the
quencher.

Clients MAY take any number of the producer, consumer and quencher
roles concurrently.
m4_dnl
m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.
m4_dnl
m4_dnl
m4_dnl  ARCHITECTURE
m4_dnl
m4_dnl  system architecture overview.  should introduce all system
m4_dnl  components and their basic relationships.
m4_dnl
m4_heading(1, ARCHITECTURE)

This document describes a protocol used by lightweight clients to
access the Elvin service provided by an Elvin router.  Typically, such
clients are implemented as a library module for a particular
programming language.  An Elvin router implementation can support many
concurrent clients.

Additional protocols, not specified in this document, enable
federation [ERFP] of routers to form a message routing network, and
configuration of redundant routers [EFOP].

The client protocol is defined as an abstract specification, which may
be made available in any number of concrete specifications using
appropriate underlying facilities.

The client protocol is broken into several subsets.  An implementation
may choose which subsets to provide, depending upon the needs of its
intended application programs and the resources available from its
host platform.
m4_dnl
m4_dnl  Abstract Communcations Channel
m4_dnl
m4_heading(2, Abstract Communications Channel)

Elvin clients communicate with an Elvin router using a communications
channel.  A client process MAY open multiple simultaneous channels to
a one or more Elvin routers (including multiple channels to the same
router).  Each such channel is a distinct logical entity.

Concrete implementations of this abstract channel MUST provide
ordered, reliable, bi-directional delivery of messages of known size;
there is no requirement for streaming data.

Once created, a channel remains available for exchange of messages
until it is closed by either the Elvin client or router.
m4_dnl
m4_heading(3, Offers)

Elvin router offers are stable, advertised entities to which
clients can connect, creating a channel.

Offers are described using a Uniform Resource Identifier (URI).  The
format of this URI is completely defined in [EURI].  An offer's URI
specifies the concrete channel implementation offered, and appropriate
addressing and any other information required to establish a channel.

m4_dnl
m4_heading(3, Messages)

An abstract Elvin message consists of an ordered sequence of values.
Each value has a known type, being one of a set of basic data types
with a minimum required range of possible values, or an ordered
sequence of such basic values of known size.

Messages are transferred over the abstract channel.  They MUST be
delivered completely or not at all, and MUST be received in the order
they were sent.

m4_dnl
m4_dnl  Concrete Communcations Channel
m4_dnl
m4_heading(2, Concrete Communications Channels)

An implementation of the abstract channel provides a mechanism for
transporting messages between Elvin clients and routers.  This
mechanism may be composed of several parts, cooperating to provide the
abstract channel semantics and various qualities of service.  Each of
these components is referred to as a protocol module, and the
combination as the protocol stack.

More specifically, the minimum functionality required of a concrete
channel is conversion of Elvin messages into a form suitable for
transfer, and the transfer of that message form to its destination,
where the orginal message must be reconstructed.

This document describes two such concrete protocol modules: a means of
data transfer using TCP streams, and a means of message encoding and
decoding using XDR.  Protocol modules are named with a sequence of
ASCII characters.  These names must uniquely identify the mechanism
implemented by the protocol module.

A concrete endpoint is advertised using a URI.  An example of such a
URL might be,
m4_pre(`elvin:/tcp,krb5,xdr/router.example.com:2917')
specifying an endpoint using concrete protocol modules "tcp", "krb5"
and "xdr", and offered at an address of "router.example.com:2917".

As this example shows, protocol modules that provide additional
functionality, such as encryption, authentication, compression, etc,
may form part of the concrete channel's protocol stack.

A concrete channel MAY limit the size of messages, but MUST otherwise
support the full functionality of the abstract channel.
m4_dnl
m4_dnl  Protocol Overview
m4_dnl
m4_heading(2, `Protocol Overview')

Interactions between client applications and the Elvin router can be
characterised as either session-oriented or session-less.

Session-less operation is very restricted in its capabilitites.  It is
provided for specialised clients and is not the general mode of
operation.  Clients usually establish a session with an Elvin router
and maintain that session as long as required.

This section provides a high level overview of the protocol and its
basic operations.  The details of each specific packet and its
semantics is convered later, in the Protocol Details section.

m4_heading(3, Notification)

Elvin notifications are structured messages comprised of a set of
attributes.  Each attribute consists of a name and a typed value.

An attribute name is a string value from a subset of the printable
ASCII character set.  The maximum length of an attribute name is 1024
bytes.  An attribute name may have any value comprised of legal
characters; there are no reserved values.

m4_remark(Hard limit of 1024 ASCII chars in names?!?)

Attribute values may be any of a signed 32 bit integer, signed 64 bit
integer, 64 bit IEEE-954 floating point number, Unicode UTF-8 string,
or an ordered sequence of arbitrary octets of known length.

Notifications are constructed by Elvin clients, and forwarded to an
Elvin router for dissemination.

m4_heading(3, Subscription)

An Elvin subscription is a UTF-8 string forming an expression in the
Elvin Subscription Language.

The expression is registered with an Elvin router, which determines
whether to deliver notifications to the subscriber by evaluating the
expression in the context of the notification's attributes.  If the
result of this evaluation is a logical true, a copy of the
notification is queued for delivery.

m4_heading(3, Quenching)

An Elvin client can also register a set of attribute names with the
Elvin router, and is subsequently kept informed of active subscription
expressions that refer to any of the registered names.

The router sends a quenching client branches of the compiled syntax
tree created when it compiles the subscriptions during their
registration.

Quenching clients can use this information for any purpose; the
facility was named after its use enabling a producer client to emit
only those notifications for which it has been informed a subscription
exists, thus \fIquenching\fP the flow of published information.

m4_heading(2, `Protocol Interactions')
m4_dnl
m4_heading(3, Session-less Notification)

Client libraries MAY implement session-less transfer of messages from
the client to the router.  It is not possible for clients to receive
notifications outside of a session.

.KS
  +-------------+                  +---------+
  |  Producer   | ----UNotify----> |  Router |          NOTIFICATION
  +-------------+                  +---------+
.KE

No other packets are allowed during session-less operation.
m4_dnl
m4_heading(3, Establishing a Session)

A Elvin client-router session is a bi-directional communciations link.
It is used by the client to request deliveries from the router.  The
router uses the same link to acknowledge client requests and to
asynchronously deliver the messages selected by the client.

When a client requests a connection, the router MUST react by
sending either a Connection Reply, a Negative Acknowledgement, or a
Disconnect.

If the router accepts the request, it will respond with a Connection
Reply, containing the agreed parameters of the connection.

.KS
  +-------------+ ---ConnRqst--> +---------+
  |   Client    |                |  Router |   SUCCESSFUL CONNECTION
  +-------------+ <---ConnRply-- +---------+
.KE

If the request is rejected due to an error, the router SHOULD
respond with a Negative Acknowledgement.

.KS
  +-------------+ ---ConnRqst--> +---------+
  |   Client    |                |  Router |     REJECTED CONNECTION
  +-------------+ <----Nack----- +---------+
.KE

If the router is not currently accepting connections, it SHOULD
send a Disconn packet.  If it has been configured to redirect clients
to an alternative router, the Disconn MAY contain the URI of the other
router.

.KS
  +-------------+ ---ConnRqst--> +---------+
  |   Client    |                |  Router |                REDIRECT
  +-------------+ <---Disconn--- +---------+
.KE

m4_dnl
m4_heading(3, Sending Notifications)

After a successful connection exchange, the session is active and a
client may start emitting notifications by sending them to the router
for distribution. If the attributes in the notification match any
subscriptions held at the router for consumers, the consumers matching
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
   +----------+                   |        |
                                  | Router |       NOTIFICATION PATH
   +----------+                   |        |
   | Consumer | <--NotifyDeliver- |        |
   +----------+                   +--------+
.KE
m4_dnl
m4_heading(3, Setting Subscriptions)

When a session is first established, the router MUST NOT send any
Notify Deliver packets until at least one subscription has been added
by the client.

A Consumer client describes the events it is interested in by sending
a predicate expression in the Elvin subscripton language (and its
associated security keys) to the Elvin router.  The predicate is sent
in a Subscription Add Request (SubAddRqst).  On receipt of the
request, the router checks the syntactic correctness of the
predicate. If valid, a Subscription Reply (SubRply) is returned which
includes a router-allocated indentifier for the subscription.

.KS
   +----------+ --SubAddRqst--> +--------+
   | Consumer |                 | Router |     ADDING A SUBSCRIPTION
   +----------+ <---SubRply---- +--------+
.KE

If the predicate fails to parse, the router MUST send a Negative
Acknowledgement (Nack) to the client with the error code set to
indicate a parser error.  This is effectively an RPC-style
interaction.  All operations that modify a client's session
information at the router use this RPC style.

A client may alter its registered predicate using the Subscription
Modify Request or remove it entirely by sending a Subscription Delete
Request. Such requests use the subscription identifier returned from
the SubAddRqst.  The router MAY allocate a new subscription identifier
when a subscription is changed.  An attempt to modify or delete a
subscription identifier that is not registered is a protocol error,
and the router MUST send a Nack to the client (see Protocol Errors).
.\"
m4_dnl m4_heading(3, Quenching)

Quenching is a facility named for its ability to reduce notification
traffic by preventing the propagation of unwanted notifications.  It
enables clients to use therouter's knowledge of consumers
subscriptions to prevent producers from notifying events for which no
subscription exists.

Once connected, the client MAY request that it be notified when there
are changes in the subscription database managed by the router.  The
client can request such information on subscriptions referring to
named attributes.

Requesting notification of changes to subscriptions referring to a set
of named attributes uses the Quench Add Request (QnchAddRqst)
message.  The Quench Reply (QnchRply) message returns an identifier
for the registered request.

.KS
   +----------+ --QnchAddRqst--> +--------+
   | Quencher |                  | Router |          ADDING A QUENCH
   +----------+ <---QnchRply---- +--------+
.KE

As for subscriptions a quench MAY be modified and/or removed later by a
client using the quench-id.  Modifying a quench request MAY change the
identifier used by the router to refer to the request.

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
                                   | Router |
   +----------+                    |        |
   | Quencher | <--SubAddNotify--- |        |
   +----------+                    +--------+
                                       SUBSCRIPTION ADD NOTIFICATION
.KE
m4_dnl
m4_heading(3, Renegotiating Connection Options)

A client can request alterations to the session's properties at any
time during the life of the session.

When a client requests the the connection options be renegotiated, the
router will respond with either a QoS Reply or Negative
Acknowledgement.

.KS
  +-------------+ ---QosRqst---> +---------+
  |   Client    |                |  Router |   OPTION RENEGOTIATION
  +-------------+ <---QosRply--- +---------+
.KE

m4_dnl
m4_heading(3, Lost Packets)

The router may choose to drop notification packets (NotifyEmit,
SubAddNotify, SubModNotify, SubDelNotify) packets if a client is not
reading them quickly enough.  If this happens, the router is obliged
to send a DropWarn packet to the client, indicating that one or more
notification packets were dropped.

.KS
   +----------+                 +--------+
   | Consumer | <---DropWarn--- | Router |   DROPPED PACKET WARNING
   +----------+                 +--------+
.KE
m4_dnl
m4_heading(3, Ending a Session)

At any time after a establishing a concrete communications channel, 
the router MAY inform the client that it is to be disconnected.  The
Disconn packet includes an explanation for the disconnection, and 
optionally, directs the client to reconnect to an alternative router.

.KS
  +-------------+                  +---------+
  |   Client    | <----Disconn---- |  Router |        DISCONNECTION
  +-------------+                  +---------+
.KE

To disconnect from the router, the client sends a Disconnect Request.
It SHOULD then wait for the router's response Disconnect Reply, which
ensures that both directions of the communication channel have been
flushed.

The router MUST NOT refuse to disconnect a client (ie. using a Nack).

.KS
  +-------------+ ---DisconnRqst--> +---------+
  |   Client    |                   |  Router |       DISCONNECTION
  +-------------+ <--DisconnRply--- +---------+
.KE
m4_dnl
m4_heading(1, SUBSCRIPTION LANGUAGE)

Consumer clients register subscription expressions with a router to
request delivery of messages.  The language used for these expressions
is defined in this section.  The subscription language syntax and
semantics are considered part of the protocol: all routers supporting
a particular protocol version will understand the same subscription
language.  There is no provision for alternative languages.

A consumer client registers a subscription expression that the router
evaluates on its behalf for each message delivered to the router. If
the expression evaluates to true then the notification is delivered,
otherwise, it it not delivered.
m4_dnl
m4_heading(2, Subscription Expressions)
m4_heading(3, Logic)

The evaluation of a subscription uses Lukasiewicz's tri-state logic
that adds the value bottom (which represents "undecideable" or
"indefinite") to the familiar true and false.
.DS I 6
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
.DE
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
(Example != 0)
.ID 3
m4_dnl
m4_heading(3, Grouping)

Clauses in an expression may be grouped using parentheses to override
precedence of evaluation.  Unlike the logical or arithmetic operators,
parentheses need not be separated from attribute identifiers or
literal values by whitespace.

An implementation MAY limit the depth of nesting able to be evaluated
in subscription expressions; an expression that exceeds this limit
MUST generate a NESTING_TOO_DEEP error in response to registration
with the router.
m4_dnl
m4_heading(3, Logical Operators)

A subscription expression may be a single predicate, or it may consist
of multiple predicates composed by logical operators. The logical
operators are
.ID 3
&&   Logical AND
||   Logical OR
^^   Logical Exclusive-OR
!    Logical NOT (unary)
.DE
Logical NOT has highest precedence, followed by AND, XOR and then OR.
m4_dnl
m4_heading(3, Literal Syntax)
.LP
A subscription expression may include literal values for most of the
message data types.  These types are

.KS
Integer Numbers
.RS
.IP int32 10
A 32 bit, signed, 2's complement integer.
.IP int64 10
A 64 bit, signed, 2's complement integer.
.RE
.LP
Integer literals can be expressed in decimal (the default),
hexadecimal, using a 0x prefix, or octal, using a 0 prefix.  In all
cases, an optional leading minus sign negates the value, and a
trailing "l" or "L" indicates that the value should be of type int64.
.KE

Literal values too large to be converted to an int32, but without the
suffix specifying an int64 type MUST cause an OVERFLOW error.
Similarly, values with the suffix and too large to be converted to an
int64, MUST cause an OVERFLOW error.
.KS
Real Numbers
.RS
.IP real64 10
An IEEE 754 double precision floating point number.
.RE
.LP
Real literals can be expressed only in decimal, and must include a
decimal point and both whole and fractional parts.  An optional
integer exponent may be added following an "e" or "E" after the
fractional part.

A real literal with an exponent too large for the IEEE 754 double
precision format MUST cause an OVERFLOW error.  Superfluous precision
in the mantissa SHOULD be discarded.
.KE

.KS
Character Strings
.RS
.IP string 10
A UTF-8 encoded Unicode string of known length, with no NUL (0x00)
bytes.
.RE
.LP
String literals must be quoted using either double (Unicode QUOTATION
MARK U+0022) or single (Unicode APOSTROPHE U+0027) quote characters.
Within the (un-escaped) quotes, a backslash (Unicode REVERSE SOLIDUS
U+005C) character functions as an escape for the following character.
All escaped characters except the quotes represent themselves.
.KE
There is no mechanism for including special characters in string
literals; each language mapping is expected to use its own mechanism
to achieve this.

.KS
Opaque Octet Data
.RS
.IP opaque 10
An opaque octet string of known length.
.RE
.LP
The subscription language does not support opaque literals; reference
to opaque attributes in a subscription expression is limited to use of
the size() function.
.KE

There are no structured data types (C struct, enum or union), nor is
there a boolean data type.  All of these can be implemented simply
using the existing types and structured naming.

String and opaque data values have known sizes (ie. they don't use a
termination character).  An implementation MAY enforce limits on these
sizes; see section X on Router Features.
m4_dnl
m4_heading(3, Reference Syntax)

Predicates and function may also use values obtained from the message
under evaluation.  Values are referred to using the name of the
message attribute.

m4_remark(Names must be separated from operators by whitespace.  What
other rules here?)
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
m4_heading(3, Equality and Set Membership)

The most common operation in typical subscription expressions is a
test for equality.

.IP "equals(attribute, attribute-or-literal+)" 4
Returns true if the type and value of the first parameter match those
of any of the subsequent parameters.
.LP
For convenience, two operators are defined using this basic predicate.
.IP "==" 4
Equal to.
.LP
Compares its two operands, each of which may be a literal value or an
attribute name.  Comparing two attribute names is allowed, but
comparing two literal values is pointless and SHOULD return an error.

m4_remark(Mantara's implementation currently rejects any pair of
operands without at least one attribute name, but the returned error
is not defined in this specification.)

.IP "!=" 4
Not equal to.
.LP
This operator is defined to be implemented as
.QP
!(A == B)
.LP
Note that this can lead to unexpected results when the attributes are
not defined.

m4_dnl
m4_heading(3, String predicates)

Some of the most used features of the subscription language are its
string predicates.  The most general provides regular-expression
("regex") matching, but simpler predicates are also provided, ranging
from wildcarding (or "globbing") to simple string comparision.  While
these could all be replaced by regular-expression operations, it is
generally clearer to use and more efficient to implement the simpler
forms when they suit.
.LP
The string predicates are:
.IP "contains(attr, stringconst+)" 4
Returns true if any stringconst is a substring of the value of attr.
.IP "begins-with(attr, stringconst+)" 4
Returns true if any stringconst is an initial substring (prefix) of
the value of attr.
.IP "ends-with(attr, stringconst+)" 4
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
.B begins-with
and
.B ends-with
imply
.B contains,
and
.B equals
(the general predicate) implies all three of them.
.LP
There are no predicates for string comparison, i.e. testing whether one
string "is less than" another string.
m4_dnl
m4_heading(3, Size Function)
.\"
.IP size(attribute) 4
Where \fIattribute\fP is the name of a string or opaque value, this
function returns its size in bytes.  For all other value types, the
enclosing expression is set to bottom.

Note that the size in bytes of a UTF-8 string value does not
necessarily reflect the number of characters.
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
LATIN SMALL LETTER A WITH GRAVE (U+00E0)
.LP
decomposes to the two characters
.QP
LATIN SMALL LETTER A + COMBINING GRAVE ACCENT (U+0061 + U+0300)
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
.IP "decompose-compat(string)" 4
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
m4_remark(false?  or bottom?)
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
.\"
.\"
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
.\"
.\"
m4_heading(2, Subscription Errors)

Elvin subscriptions are compiled by the router during registration.
Various errors are possible; this section documents the basic error
conditions.

Errors detected when adding or modifying a subscription are reported
as protocol errors. The router returns a failure code, some additional
parameters, and a default text message.  Clients can use the error
code to generate localized text including the parameter values, if
desirable.

Router implementations MAY return error codes not specified here, but
SHOULD use the standard codes where appropriate.

This section refers to names from the error table in section "Negative
Acknowledgement", which defines the error codes, parameters and
required client action.

.IP PARSE_ERROR 4
A non-specific problem occured when parsing the expression.
.IP INVALID_TOKEN 4
An invalid token was parsed in the expression.
.IP UNTERM_STRING 4
A string literal in the expression is missing a terminating quote
character.
.IP OVERFLOW 4
A numeric literal value in the expression is too large for its type.
.IP TYPE_MISMATCH 4
The type of a literal value in the expression does not match its
usage.
.IP UNKNOWN_FUNC 4
An unrecognised predicate function is used in the expression.
.IP TOO_FEW_ARGS 4
A predicate function is called with too few arguments.
.IP TOO_MANY_ARGS 4
A predicate function is called with too many arguments.
.IP EXP_IS_TRIVIAL 4
When compiled, the expression reduced to a constant value.
.IP INVALID_REGEXP 4
A regular expression was invalid.
.IP REGEXP_TOO_COMPLEX 4
A regular expression was too complex.
.LP
Note also that a router implementation MAY reject a subscription
expression that exceeds its internal limits on the length of attribute
identifiers and strings.  Such errors SHOULD be reported using the
QOS_LIMIT error code.
.\"
m4_dnl
m4_heading(3, Runtime evaluation errors in numeric expressions)

During the evaluation of a numeric predicate (including the evaluation of
any expressions that are the arguments to the predicate), the following
classes of errors may occur:

.IP 1. 3
Errors that cause the predicate to return bottom:
.IP
o Use of an attribute that does not exist in the notification,
.IP
o Use of an attribute, constant or expression that has an
  inappropriate type (for example, real64, string or opaque in a
  function that expects int32 or int64)
.IP
o Integer division by zero.
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

m4_heading(1, ABSTRACT PROTOCOL)

The Elvin4 protocol is specified at two levels: an abstract
description, able to be implemented using different marshalling and
transport protocols, and a concrete specification of one such
implementation, mandated as a standard protocol for interoperability
between different routers.

This section describes the operation of the Elvin4 protocol, without
describing any particular protocol implementation.
m4_dnl
.KS
m4_heading(2, Packet Types)
.LP
The Elvin abstract protocol specifies a number of packets used in
interactions between clients and the router.

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
QoS Request                   QosRqst         C -> S     C
QoS Reply                     QosRply         S -> C     C
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
.\"
.\"
m4_heading(2, Errors)

Several types of errors are recognised in the protocol specification.
This section describes each type of error, and its required handling.
.\"
m4_heading(3, Communications Errors)
.LP
A communications error occurs when an abstract communcications channel
closes at an unexpected point in the protocol sequence.

The protocol does not support re-establishment of broken abstract
communications channel.

When a communications error is detected, a router implementation
SHOULD clean up all state associated with the channel (and its
client), including negotiated connection options, keys, subscriptions,
quenches, and queued packets.

A client implementation MAY attempt to open a new channel, and
create a new connection with its current state.  However, such
a reconnection might cause notification and quench deliveries to be
lost, and therefore client applications MUST be notified if such an
attempt is made.
.\"
m4_heading(3, Protocol Violations)
.LP
A protocol violation is defined to occur when a message is received
that
.IP
cannot be unmarshalled,
.IP
has a type that is not expected at the current point in the protocol
sequence, or,
.IP
is a reply to an unknown request.
.LP
In all cases of protocol violation, an implementation MAY immediately
terminate the communications channel, without performing a connection
closure packet exchange.

However, a more robust implementation MAY attempt to ignore such
messages and maintain the connection, relying on timeouts to initiate
a suitable recovery process in its peer implementation.
.\"
m4_heading(3, Protocol Errors)
.LP
A protocol error occurs when a message is received whose values are
inconsistent with the state of the receiving entity or otherwise
incorrect, but is not a protocol violation.  Examples include attempts
to modify or delete a non-existent subscription, or sending a
notification whose attributes exceed the negotiated connection limits.

In general, client implementations SHOULD and router implementations
MUST, maintain a connection in the face of protocol errors.

A router implementation that detects a protocol error in a NotifyEmit
packet SHOULD ignore it, and in any other packet SHOULD respond using
the Negative Acknowledge (Nack) packet.

A client implementation that detects a protocol error in any packet
received from the router MAY ignore it or MAY abort the connection.

Repeated protocol errors on a channel MAY cause a router
implementation to close the client's connection, giving suspected
denial of service attack as a reason (see the Disconnect packet).

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
These types are opaque n-bit identifiers.  No semantics are required
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
description of router options.  The value type defines the range of
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

Unreliable notifications are sent by a client to a router outside the
context of a session (see ConnRqst below).  Using the protocol and
endpoint information obtained either directly or via router discovery,
a client creates a channel to the router.  Over this channel, one or
more UNotify packets MAY be sent to the router.

The router MUST NOT send any data to the client over the channel.  The
router MAY close the channel after receiving a single UNotify packet.
UNotify packets with an incompatible version number MUST be silently
discarded by the router.

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
Acknowledgement to indicate that although the router understood the
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

.KS
.nf
 Range       | Category
-------------+------------------------------------------------------------
       0     | Reserved value.
             |
   1 - 999   | A connection establishment error.
             |
1000 - 1999  | An error has been detected in a protocol message.
             | This might imply corruption of the connection or
             | an implementation error.
             |
2000 - 2999  | An error has been detected in a request.
             |
3000 - 65535 | Reserved values.
.fi
.KE

Clients MAY interpret implementation-specific error codes, on the
basis of router identity determined during connection negotiation.
Unrecognised codes MUST be handled according to their general
category.

Receiving a reserved error code SHOULD be handled as a protocol error.

.nf
 Code  | Name               | Arguments        | Description
-------+--------------------+------------------+--------------------------
 1     | PROT_INCOMPAT      | None             | ConnRqst rejected due to
       |                    |                  | protocol incompatibility
 2     | AUTHZ_FAIL         | None             | Authorisation failure
 3     | AUTHN_FAIL         | None             | Authentication failure
       |                    |                  |
 4     |                    |                  | Reserved
 -499  |                    |                  |
 500   |                    |                  | Implementation-specific
 -999  |                    |                  | connection establishment
       |                    |                  | error
       |                    |                  |
 1001  | PROT_ERROR         | None             | General error in protocol
 1002  | NO_SUCH_SUB        | subid, id64      | No such subscription
 1003  | NO_SUCH_QUENCH     | quench_id, id64  | No such quench
 1004  | BAD_KEY_SCHEME     | scheme_id, id32  | Bad keys scheme
 1005  | BAD_KEY_INDEX      | scheme_id, id32  | Bad keyset index
       |                    | index, int32     |
 1006  | BAD_UTF8           | offset, int32    | Invalid UTF-8 string
       |                    |                  | FIXME (libelvin 2301)
       |                    |                  |
 1007  |                    |                  | Reserved
 -1499 |                    |                  |
 1500  |                    |                  | Implementation-specific
 -1999 |                    |                  | connection error
       |                    |                  |
 2001  | NO_SUCH_KEY        | None             | No such key
 2002  | KEY_EXISTS         | None             | Key already exists
 2003  | BAD_KEY            | None             | Invalid key
 2004  | NOTHING_TO_DO      | None             | Request required no
       |                    |                  | action
 2005  | QOS_LIMIT          | property, string | Request exceeds QoS limit
 2006  | IMPL_LIMIT         | None             | Request exceeds
       |                    |                  | implementation limit
 2007  | NOT_IMPL           | None             | Requested feature is
       |                    |                  | not implemented by router
       |                    |                  |
 2008  |                    |                  | Reserved
 -2100 |                    |                  |
       |                    |                  |
 2101  | PARSE_ERROR        | offset, int32    | Parse error at offset
       |                    | token, string    |
 2102  | INVALID_TOKEN      | offset, int32    | Invalid token
       |                    | token, string    |
 2103  | UNTERM_STRING      | offset, int32    | Unterminated string
 2104  | UNKNOWN_FUNC       | offset, int32    | Unknown function
       |                    | name, string     |
 2105  | OVERFLOW           | offset, int32    | Numeric constant overflow
       |                    | token, string    |
 2106  | TYPE_MISMATCH      | offset, int32    | Type mismatch
       |                    | expr, string     |
       |                    | type, string     |
 2107  | TOO_FEW_ARGS       | offset, int32    | Too few arguments
       |                    | function, string |
 2108  | TOO_MANY_ARGS      | offset, int32    | Too many arguments
       |                    | function, string |
 2109  | INVALID_REGEXP     | offset, int32    | Invalid regular expression
       |                    | regexp, string   |
 2110  | EXP_IS_TRIVIAL     |                  | FIXME (libelvin has args)
 2111  | REGEXP_TOO_COMPLEX | offset, int32    | FIXME (libelvin doesn't
       |                    | regexp, string   | have offset)
 2112  | NESTING_TOO_DEEP   | offset, int32    | Expression nesting too deep
       |                    |                  |
 2113  |                    |                  | Reserved
 -2200 |                    |                  |
 2201  | EMPTY_QUENCH       | None             | Empty quench
 2202  | ATTR_EXISTS        | name, string     | Quench attribute exists
 2203  | NO_SUCH_ATTR       | name, string     | No such attribute
       |                    |                  |
 2110  |                    |                  | Reserved
 -2499 |                    |                  |
 2500  |                    |                  | Implementation-specific
 -2999 |                    |                  | request failure
.fi

The Nack message field is a Unicode string template containing
embedded tokens of the form %n, where n is an index into the args
array.  When preparing the error message for presentation to the user,
each %n should be replaced by the appropriately formatted value from
the args array.

The language in which the Nack message is sent by a router MAY be
negotiated during connection establishment.  Alternatively, clients
MAY provide local templates to be used for generating the formatted
text for presentation to the application.

m4_heading(3, Connect Request)

Using the protocol and endpoint information obtained either directly
or via router discovery, a client can establish a channel to a router,
via an endpoint.  It MAY then send a ConnRqst to establish protocol
options to be used for the session, and MUST send either a ConnRqst or
UNotify.

A router SHOULD close a channel from which it has received neither a
ConnRqst or a UNotify within a reasonable time period.

The ConnRqst MAY contain requests for various protocol options to be
used by the connection.  These options are identified using a string
name.  Some options refer to properties of the router, while others
MAY be used by the protocol layers.

Legal option names, their semantics, and allowed range of values are
defined later in the Connection Options section.

A router receiving a ConnRqst MUST send a ConnRply, a Nack or a
disconnect in reply.

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

Sent by the Elvin router to a client, a ConnRply accepts the client's
connection request. and specifies the connection option values to be
provided by the router.

m4_pre(
struct ConnRply {
    id32 xid;
    NameValue options[];
};)m4_dnl

For each legal, understood option included in the ConnRqst, a matching
response MUST be present in the ConnRply.  Where the value returned
differs from that requested, the client MUST either use the returned
value, or request closure of the session (using a DisconnRqst).
Unrecognised options MUST NOT be returned by the router.

Additional option values, not requested by the client, MAY be dictated
by the router.  If an option has the specified default value, it MAY
be sent to the client, but where the router implementation uses a
non-default value, it MUST be sent to the client.

m4_heading(3, Disconnect Request)

Sent by clients to the Elvin router to request closure of the session.

m4_pre(
struct DisconnRqst {
    id32 xid;
};)m4_dnl

A client MUST send this packet and wait for confirmation via
DisconnRply before closing the channel to the router.  The client
library MUST NOT send any further messages to the router once this
message has been sent.  The client library MUST continue to read from
the channel until a DisconnRply packet is received.

A router receiving a DisconnRqst MUST suspend further evaluation and
notification of subscriptions and quenches for this client.  A
DisconnRply packet MUST be sent to the client's channel, the channel
then flushed before being closed.

It is a protocol violation for a client to close its channel without
sending a DisconnRqst (see protocol violations below).

m4_dnl
m4_heading(3, Disconnect Reply)

Sent by the Elvin router to a client.  This packet is sent in response
to a Disconnect Request, prior to breaking the connection.

m4_pre(
struct DisconnRply {
    id32 xid;
};)m4_dnl

This MUST be the last packet sent by a router in a session.  The
underlying channel MUST be closed immediately after this packet has
been successfully delivered to the client.

m4_dnl
m4_heading(3, Disconnect)

Sent by the Elvin router to a client.  This packet is sent in two
different circumstances: to direct the client to reconnect to another
router, or to inform that client that the router is shutting down.

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
     1    |  Router is closing down.
     2    |  Router is closing this connection, and directs the
          |  client to connect to the router address in "args".
     4    |  Router is closing this connection for repeated
          |  protocol errors.
.fi
.KE

This MUST be the last packet sent by a router in a session.  The
underlying channel MUST be closed immediately after this packet has
been successfully delivered to the client.

The router MUST NOT close the client's session (or channel) without
sending either a DisconnRply or Disconn packet except in the case of a
protocol violation.  If a client detects that the router channel has
been closed without receiving one of these packets, it should assume
network or router failure.

A client receiving a redirection via a Disconn MUST attempt to connect
to the specified router before attempting any other routers for which
it has address information.  If the channel establishment fails or is
refused (via ConnRply), the default router selection process SHOULD be
performed.

A client MAY perform loop detection for redirection to cater for a
misconfiguration of routers redirecting a client indefinitely.  If a
loop is detected, the default router selection process SHOULD be
performed.

m4_dnl
m4_heading(3, Security Request)

Sets the keys associated with the session.  Two sets of keys are
maintained by the router: those used when sending notifications, and
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

A client MUST NOT request the addition of a key already registered, or
the removal of a key not registered.  Such an action is treated as a
protocol error.

The client's session keys MUST be updated prior to processing any
further packets in this session.  A notification sent immediately
after a SecRqst within the same session MUST match a subscription
requiring the updated keys.

m4_heading(3, Security Reply)

Sent by the router to clients to confirm a successful change of keys.

m4_pre(
struct SecRply {
    id32 xid;
};)m4_dnl

A router MUST respond to a client's SecRqst by sending a SecRply, if
the request was successful, or a Nack if the request was unable to be
completed successfully.

All notifications and quench notifications delivered within the
session after the SecRply MUST match the changes acknowledged by the
SecRply.

m4_heading(3, QoS Request)

Sent by clients to the router to request renegotiation of the options
for the current session.  Legal option names, their semantics, and
allowed range of values are defined later in the Connection Options
section.

The router MAY respond with a Nack if renegotiation is not supported.
Otherwise, it MUST respond with a QosRply specifying the active
option values following its processing of the request.

m4_pre(
struct QosRqst {
    id32 xid;
    NameValue options[];
};)m4_dnl

m4_heading(3, QoS Reply)

Sent by the router to inform a client of the active connection options
after processing a QosRqst.  For a description of the contents of the
returned options table, see the Connection Options section below.

m4_pre(
struct QosRply {
    id32 xid;
    NameValue options[];
};)m4_dnl

m4_heading(3, Drop Warning)

Sent by routers to clients to indicate that notification packets have
been dropped from this place in the data stream due to congestion in
the router.  Dropped packets MAY include NotifyDeliver, SubAddNotify,
SubModNotify and SubDelNotify.

m4_pre(
struct DropWarn {
};)m4_dnl

The router may also drop ConnConf packets, but this MUST NOT result in
in a DropWarn being sent to the client.  As a ConnConf is only sent to
confirm the connection between a client and the router is still
active, a ConnConf will be dropped if there is any other pending data
to be sent ot the client.  The client can determine from the fact that
other packets have arrived that the connection still works.

m4_heading(3, Test Connection)

A client's connection to the Elvin router can be inactive for long
periods.  This is especially the case for subscribers for whom
matching messages are seldom generated.  Clients and routers MUST
implement Test Connection and Confirm Connection packets to allow
verification of connectivity.

This application-level functionality is an alternative to a channel
level carrier-loss reporting mechanism.  If an Elvin channel does not
provide support for carrier loss detection, this mechanism can be
used.

m4_pre(
struct TestConn {
};)m4_dnl

A Test Connection packet MAY be sent by either client or router to
verify that the channel remains active after a period during which no
packets have been received.

If, after a TestConn has been sent, no traffic has been received on
the channel within a timeout period, the channel is assumed to have
failed and the session MUST be closed as for a protocol violation.

A TestConn MAY be sent if no packets have been received within a
configured timeout period.  This period MUST be configurable, sending
MUST be able to be disabled, and SHOULD be disabled by default.  These
restrictions serve to limit the load on routers servicing TestConn
requests.

m4_heading(3, Confirm Connection)

m4_pre(
struct ConfConn {
};)m4_dnl

Clients and routers MUST implement support for ConfConn.

A router receiving a TestConn packet MUST queue a ConfConn response if
there are no other packets waiting for the client to read.  If other
packets are waiting for the client to service its connection, the
router MUST NOT send the ConfConn (since the client's reading of the
other packets will indicate that its connection is active).

Routers MAY drop ConfConn packets queued for delivery to a client if
there is any other packet about to be sent to the client.  The client
MUST use use the fact that any packet arriving from the router indicates
an active connection.

Clients MUST send a ConfConn in response to a TestConn from the
router.

m4_heading(3, Notification Emit)

Sent by client to the Elvin router.  There are two possible delivery
modes, determining how the router should match supplied security keys.
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

Sent by the Elvin router to a client.

m4_pre(
struct NotifyDeliver {
    NameValue attributes[];
    id64 secure_matches[];
    id64 insecure_matches[];
};)m4_dnl

m4_heading(3, Subscription Add Request)

Sent by client to the Elvin router.  Requests delivery of
notifications which match the supplied subscription expression.

m4_pre(
struct SubAddRqst {
    id32 xid;
    string expression;
    boolean accept_insecure;
    Keys keys;
};)m4_dnl

If successful, the router MUST respond with a SubRply.

If the client has registered too many subscriptions, the router MUST
return a Nack with the QOS_LIMIT error code.

If the router has too many registered subscriptions, or exceeds some
other internal limit, it MUST return a Nack with error code
IMPL_LIMIT.

If the subscription expression fails to parse, the router MUST return
a Nack with an appropriate error code.  The standard codes are
specified in "Subscription Errors" or an implementation specific code
MAY be used.

m4_heading(3, Subscription Modify Request)

Sent by client to the Elvin router.  Update the specified subscription
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
unchanged from that registered at the router, and all other fields are
empty, the modification SHALL be considered successful.

A successful modification of the subscription MUST return a SubRply to
the client.

A Nack, with error code NO_SUCH_SUB, MUST be returned if the
subscription_id is not valid.

If the subscription expression fails to parse, the router MUST return
a Nack describing the error.  An invalid expression MUST NOT alter the
current state of the specified subscription.

An attempt either to add a key already associated with the specified
subscription or to remove a key not currently associated with the
specified subscription MUST be ignored, and the remainder of the
operation processed.  No indication that any part of the operation was
ignored is returned to the client.

m4_heading(3, Subscription Delete Request)

Sent by client to the Elvin router.  A Nack will be returned if the
subscription identifier is not valid.

m4_pre(
struct SubDelRqst {
    id32 xid;
    id64 subscription_id;
};)m4_dnl

m4_heading(3, Subscription Reply)

Sent from the Elvin router to the client as acknowledgement of a successful
subscription change.

m4_pre(
struct SubRply {
    id32 xid;
    id64 subscription_id;
};)m4_dnl

m4_heading(3, Quench Add Request)

Sent by clients to the Elvin router.  Requests notification of
subscriptions referring to the specified attributes.

m4_pre(
struct QnchAddRqst {
    id32 xid;
    string names[];
    boolean deliver_insecure;
    Keys keys;
};)m4_dnl

m4_heading(3, Quench Modify Request)

Sent by client to the Elvin router.  Requests changes to the list of
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

Sent by client to the Elvin router.  Requests that the router no
longer notify the client of changes to subscriptions with the
associated attribute names.

m4_pre(
struct QnchDelRqst {
    id32 xid;
    id64 quench_id;
};)m4_dnl

m4_heading(3, Quench Reply)

Sent from the Elvin router to the client as acknowledgement of a successful
quench requirements change (QnchAddRqst, QnchModRqst, QnchDelRqst):

m4_pre(
struct QnchRply {
    id32 xid;
    id64 quench_id;
};)m4_dnl

m4_heading(3, Subscription Add Notification)

Sent from router to clients to inform them of a new subscription
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

Sent from router to clients to inform them of the removal of a
subscription predicate component that had matched their registered
attribute name list for each of the identified quench registrations.

m4_pre(
struct SubDelNotify {
  id64 quench_ids[];
  id64 term_id;
};)m4_dnl

m4_heading(2, Connection Options)

Connection options control the behaviour of the router for the
specified connection.  They may be set during connection establishment
and modified during the life of the connection.

At the point of connection, the client may submit a set of requested
option values in its ConnRqst packet.  The router evaluates the
client's request, and returns a set of proposed option values in the
ConnRply packet.  Once a connection is established, the client can
request a modification of the connection options by sending a QosRqst
packet.  The router's response is delivered in a QosReply packet.

The router evaluates received connection options requests, and for
each option requested, the router MUST either

a) Understand and accept the requested value.  The ConnRply/QosRply
   options table MUST contain an entry for this option, and its value
   MUST be that requested.  Or,

b) Understand but reject the requested value.  The ConnRply/QosRply
   options table MUST contain an entry for this option.  Its value
   MUST NOT match the request, but MUST be that which the router is
   prepared to provide.  Or,

c) Not recognise the requested option.  The ConnRply/QosRply options
   table MUST NOT contain an entry for this option.

A router implementation MAY add entries to the ConnRply/QosRply
options tables that do not reflect options requested by the client.

A client implementation, upon receiving a ConnRply, SHOULD enable the
client application to examine the offered option values.  The
application SHOULD be able to reject the connection if the offered
options are unsatisfactory.

On receiving a QosRply, a client implementation SHOULD enable the
client application to examine the revised options.  If they are not
satisfactory, the client SHOULD be able to close the connection.

A router implementation MUST support the following options.

.KS
.nf
  Name                        |  Type
  ----------------------------+--------
  Attribute.Max-Count         |  int32
  Attribute.Name.Max-Length   |  int32
  Attribute.Opaque.Max-Length |  int32
  Attribute.String.Max-Length |  int32
  Packet.Max-Length           |  int32
  Receive-Queue.Drop-Policy   |  string
m4_dnl  Receive-Queue.High-Water    |  int32
m4_dnl  Receive-Queue.Low-Water     |  int32
  Receive-Queue.Max-Length    |  int32
  Send-Queue.Drop-Policy      |  string
m4_dnl  Send-Queue.High-Water       |  int32
m4_dnl  Send-Queue.Low-Water        |  int32
  Send-Queue.Max-Length       |  int32
  Subscription.Max-Count      |  int32
  Subscription.Max-Length     |  int32
  ----------------------------+--------
.fi
.KE

A router implementation SHOULD return the following options.

.KS
.nf
  Name                        |  Type
  ----------------------------+--------
  Supported-Key-Schemes       |  string
  Vendor-Identification       |  string
  ----------------------------+--------
.fi
.KE

m4_heading(3, Option Semantics)

em4_unnumbered(Attribute.Max-Count)
.\"
Maximum number of attributes in a notification.  The minumum value
supported by an implementation SHOULD be at least 16.

em4_unnumbered(Attribute.Name.Max-Length)
Maximum length, in bytes, of an attribute name.  The minimum value
supported by an implementation SHOULD be at least 64.

Attribute.Opaque.Max-Length Maximum length, in bytes, for opaque
values. The minimum value supported by an implementation SHOULD be at
least 1024.

em4_unnumbered(Attribute.String.Max-Length)
.\"
Maximum length, in bytes, for opaque values.  Note that this value
is not the number of characters: some characters may take up to 5
bytes to respresent using the require UTF-8 encoding. The minimum
value supported by an implementation SHOULD be at least 1024.

em4_unnumbered(Packet.Max-Length)
.\"
Maximum length, in bytes, of a marshalled packet.  The minimum value
SHOULD be at least 1024.

em4_unnumbered(Receive-Queue.Drop-Policy)
.\"
It is expected that most router implementations will maintain a queue
of packets received from a client prior to processing them.  This
property describes the desired behaviour of this packet queue if it
exceeds the negotitated maximum size.

A packet queue implementation SHOULD distinguish between packets that,
if discarded, would cause a protocol error, and those that can be
discarded without losing state synchronisation between the client and
the router: NotifyDeliver, SubAddNotify, SubModNotify, and
SubDelNotify.

A router implementation SHOULD support the following drop policy
values:
.I oldest
.I newest
.I largest
.I none

If a router implementation does not use a queue for received packets,
it MUST accept any legal value for this property.

m4_dnl em4_unnumbered(Receive-Queue.High-Water)
m4_dnl em4_unnumbered(Receive-Queue.Low-Water)
m4_dnl
em4_unnumbered(Receive-Queue.Max-Length)
.\"
This property sets a maximum size of the router's per-client incoming
packet queue, in bytes.  If the queue exceeds this size, the router
SHOULD drop one or more packets, according to the queue's drop policy.

If a router implementation does not use a queue for received packets,
it MUST accept any legal value for this property.

em4_unnumbered(Send-Queue.Drop-Policy)
.\"
It is expected that most router implementations will maintain, for
each connected client, a queue of packets for delivery.  This property
describes the desired behaviour of this packet queue if it exceeds the
negotitated maximum size.

See the description of the receive queue drop policy.

m4_dnl em4_unnumbered(Send-Queue.High-Water)
m4_dnl em4_unnumbered(Send-Queue.Low-Water)
em4_unnumbered(Send-Queue.Max-Length)
.\"
See the description of the receive queue maximum length.

em4_unnumbered(Subscription.Max-Count)
.\"
This numeric option specifies the maximum number of subscriptions that
may be registered by a client.

em4_unnumbered(Subscription.Max-Length)
.\"
This numeric option specifies the maximum allowed length, in bytes, of
a subscription expression registered with the router.

em4_unnumbered(Supported-Key-Schemes)
.\"
A router implementation may support various key schemes for the
control of Elvin message delivery.  This string property contains the
list of key schemes names, separated by the ASCII space character,
supported by the router.

Clients MAY request their required schemes, but regardless, a router
implementation SHOULD always include the set of supported schemes in
its ConnRply options table.

m4_heading(3, Additional Options)

A router implementation MAY support additional,
implementation-specific options.  The name and semantics of a
non-standard option SHOULD be registered with elvin.org to enable
other implementations to adopt or avoid it.

m4_heading(3, Compatibility)

One popular Elvin implementation uses non-standard names for its
connection options.  In the interests of compatibility,
implementations MAY provide special handling for these options.

.KS
.nf
  Standard Name               | Compatibility Name
  ----------------------------+------------------------------------
  Attribute.Max-Count         | router.attribute.max-count
  Attribute.Name.Max-Length   | router.attribute.name.max-length
  Attribute.Opaque.Max-Length | router.attribute.opaque.max-length
  Attribute.String.Max-Length | router.attribute.string.max-length
  Packet.Max-Length           | router.packet.max-length
  Receive-Queue.Drop-Policy   | router.recv-queue.drop-policy
m4_dnl  Receive-Queue.High-Water    | router.recv-queue.high-water
m4_dnl  Receive-Queue.Low-Water     | router.recv-queue.low-water
  Receive-Queue.Max-Length    | router.recv-queue.max-length
  Send-Queue.Drop-Policy      | router.send-queue.drop-policy
m4_dnl  Send-Queue.High-Water       | router.send-queue.high-water
m4_dnl  Send-Queue.Low-Water        | router.send-queue.low-water
  Send-Queue.Max-Length       | router.send-queue.max-length
  Subscription.Max-Count      | router.subscription.max-count
  Subscription.Max-Length     | router.subscription.max-length
  Supported-Key-Schemes       | router.supported-keyschemes
  Vendor-Identification       | router.vendor-identification
  ----------------------------+------------------------------------
.fi
.KE

m4_heading(1, PROTOCOL IMPLEMENTATION)

The abstract protocol described in the previous section may be
implemented by multiple concrete protocols.  The concrete protocols
used to establish a channel can be specified at run time, and selected
from the intersection of those offered by the client and router-side
implementations.

m4_heading(2, Layering and Modules)

A channel supporting the Elvin protocol can be comprised of multiple,
layered components, referred to as protocol modules.  These modules
are layered to form a protocol stack, providing the channel over which
the abstract protocol packets are carried.

The combined stack MUST provide marshalling and data transport
facilities, and MAY provide other features.

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
a communications error.

m4_heading(4, Protocol Options)

An implementation of the TCP protocol SHOULD support a connection
option to control the use of Nagle's algorithm (normally implemented
as the TCP_NODELAY socket option).

.KS
.nf
  Name                        |  Type
  ----------------------------+--------
  TCP.Send-Immediately        |  int32
.fi
.KE

The value should be set to zero to enable Nagle's algorithm, and
non-zero to request that it be disabled.

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
offered by the proxy router, and requesting that it tunnel further
data on the connection to the specified Elvin router endpoint.

This request takes the form of

   CONNECT host.example.com HTTP/1.1
   Proxy-Authorization: Basic XXXXXX

with the optional parameter lines terminated by a blank line.

The client then waits for a response from the proxy router, indicating
whether its request was successful.  The response from the proxy
router consists of CRLF-delimited lines of text, terminated by a blank
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
Messages sent between the a client and and Elvin router are encoded as
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
    QosRqst        = 70,   QosRply        = 71,
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
    xdr_int32  = 1,
    xdr_int64  = 2,
    xdr_real64 = 3,
    xdr_string = 4,
    xdr_opaque = 5
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
for marshalling, it would be sent as four bytes for the type id of 2
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
to have much lower maxima for the number of items in a list
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
    empty_tc  = 0,

    name_tc   = 1,
    int32_tc  = 2,
    int64_tc  = 3,
    real64_tc = 4,
    string_tc = 5,

    equals_tc = 8,
    not_equals_tc = 9,
    less_than_tc = 10,
    less_than_equals_tc = 11,
    greater_than_tc = 12,
    greater_than_equals_tc = 13,

    or_tc = 16,
    xor_tc = 17,
    and_tc = 18,
    not_tc = 19,

    unary_plus_tc = 20,
    unary_minus_tc = 21,
    multiply_tc = 22,
    divide_tc = 23,
    modulo_tc = 24,
    add_tc = 25,
    subtract_tc = 26,

    shift_left_tc = 27,
    shift_right_tc = 28,
    logical_shift_right_tc = 29,
    bit_and_tc = 30,
    bit_xor_tc = 31,
    bit_or_tc = 32,
    bit_negate_tc = 33,

    func_int32_tc = 40,
    func_int64_tc = 41,
    func_real64_tc = 42,
    func_string_tc = 43,
    func_opaque_tc = 44,
    func_nan_tc = 45,

    func_begins_with_tc = 48,
    func_contains_tc = 49,
    func_ends_with_tc = 50,
    func_wildcard_tc = 51,
    func_regex_tc = 52,

    func_fold_case_tc = 56,
    func_decompose_tc = 57,
    func_decompose_compat_tc = 58,

    func_require_tc = 64,
    func_equals_tc = 65,
    func_size_tc = 66
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
.nf
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

m4_dnl sub-syntax
m4_dnl
.bp
m4_heading(1, APPENDIX A - ELVIN SUBSCRIPTION LANGUAGE)
.\"
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

bool-function-exp	= bool-pred "(" name ")"

function-exp		= function-pred "(" args ")"

args                    = arg *( "," arg )

arg                     = name / string-literal / num-literal

;
; predicates
;

bool-pred		= "require" / "int32" / "int64" /
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

Author's Addresses

.nf
David Arnold
Julian Boot
Michael Henderson
Ian Lister
Ted Phelps
Bill Segall

Email:  specs@elvin.org
.fi
.KE

.KS
m4_heading(1, FULL COPYRIGHT STATEMENT)

Copyright (C) 1999-__yr Elvin.Org
All Rights Reserved.

This specification may be reproduced or transmitted in any form or by
any means, electronic or mechanical, including photocopying,
recording, or by any information storage or retrieval system,
providing that the content remains unaltered, and that such
distribution is under the terms of this licence.

While every precaution has been taken in the preparation of this
specification, Elvin.Org assumes no responsibility for errors or
omissions, or for damages resulting from the use of the information
herein.

Elvin.Org welcomes comments on this specification.  Please address any
queries, comments or fixes (please include the name and version of the
specification) to the address below:

.nf
    Email: specs@elvin.org
.fi
.KE
