m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  protocol-overview

m4_heading(2, Protocol Overview)

After an Elvin server has been located (see section on server
discovery) a client requests a connection. The server MUST respond
with either a Connection Reply, a Disconnect or a Nack.

If the server accepts the request, it MUST respond with a Connection
Reply, containing the agreed parameters of the connection.

.KS
  +-------------+ ---ConnRqst--> +---------+
  | Producer or |               |  Elvin  |  
  |  Consumer   |               |  Server |    SUCCESSFUL CONNECTION 
  +-------------+ <---ConnRply-- +---------+
.KE

If the Elvin server cannot accept the connection itself, but is part
of a server cluster, it MUST respond with a Disconnect and then close
the connection on which the client made the request.  The client MAY
then send a Connection Request to the server address supplied in the
Disconnect message.

*** fixme *** may a client ignore a redirect and re-attempt the same
server?  if not, how long until it may?

.KS
  +-------------+ --ConnRqst--> +---------+
  | Producer or |               |  Elvin  |
  |  Consumer   |               |  Server |    REDIRECTED CONNECTION
  +-------------+ <--DisConn--- +---------+
.KE

If the Elvin server cannot accept the connection, it MUST send a
Negative Acknowledge response and close the connection upon which the
client made the request.

*** fixme *** under what situations will the server nack a connection
request.  This should be under the "Failures" at the end of the
section, but one or two examples here may be used for illustration].

.KS
  +-------------+ --ConnRqst--> +---------+
  | Producer or |               |  Elvin  |
  |  Consumer   |               |  Server |        FAILED CONNECTION
  +-------------+ <----Nack---- +---------+
.KE

After a successful connection, a client may start emitting
notifications by sending them to the server for distribution. If the
attributes in the notification match any subscriptions held at the
server for consumers, the consumers matching those subscriptions SHALL
be be sent a notification deliver message with the content of the
original notification.

The NotifyDeliver packet differs slightly from the original NotifyEmit
sent by the producer.  As well as the sequence of named-typed-values,
it contains information about which subsciptions were used to match
the event.  This allows the client library of the consumer to dispatch
the event with out having to do any additional matching.

.KS
   +----------+                   +--------+
   | Producer | ---NotifyEmit---> |        |
   +----------+                   |        |
                                  | Server |       NOTIFICATION PATH
   +----------+                   |        |
   | Consumer | <--NotifyDeliver- |        |
   +----------+                   +--------+
.KE

A Consumer describes the events in which it is interested by sending a
predicate in the Elvin subscripton language (and its associated
security keys) to the Elvin server.  The predicate is sent in a
Subscription Add Request (SubAddRqst).  On receipt of the request, the
server checks the syntactic correctness of the predicate. If valid, a
Subscription Reply (SubRply) is returned.

.KS
   +----------+ --SubAddRqst--> +--------+
   | Consumer |                 | Server |     ADDING A SUBSCRIPTION
   +----------+ <---SubRply---- +--------+
.KE

If the predicate fails to parse, a Nack is returned with the error
code set to indicate a parser error.

A Consumer may alter its registered predicate or the associated keys
using the Subscription Modify Request (SubModRqst). This alteration
MUST occur atomically: a notification matching both the previous
predicate and the new predicate MUST be delivered to the consumer.

An attempt to modify a subscription that is not registered is a
protocol error, and generates a Nack.

.KS
   +----------+ --SubModRqst--> +--------+
   | Consumer |                 | Server |  MODIFYING A SUBSCRIPTION
   +----------+ <---SubRply---- +--------+
.KE

Note that when a subscription is modified, its server-allocated
identifier MAY change.

A registered subscription is removed using Subscription Delete Request
(SubDelRqst).  An attempt to remove a subscription that is not
registered is a protocol error, and generates a Nack.

.KS
   +----------+ --SubDelRqst--> +--------+
   | Consumer |                 | Server |   DELETING A SUBSCRIPTION
   +----------+ <---SubRply---- +--------+
.KE

Once connected, the client may request notification of changes in the
subscription database managed by the server.  The client may request
such information on subscriptions referring to named attributes.

Requesting notification of changes to subscriptions referring to a set
of named attributes uses the Quench Add Request (QnchAddRqst)
message.  The Quench Reply (QnchRply) message returns an identifier
for the registered request.

.KS
   +----------+ --QnchAddRqst--> +--------+
   | Producer |                  | Server |          ADDING A QUENCH
   +----------+ <---QnchRply---- +--------+
.KE

Changing either the set of attribute names, or the associated security
keys for a registered quench request uses the Quench Modify Request
(QnchModRqst) and the returned identifier.

.KS
   +----------+ --QnchModRqst--> +--------+
   | Producer |                  | Server |       MODIFYING A QUENCH
   +----------+ <---QnchRply---- +--------+
.KE

As for subscriptions, modifying a quench request MAY change the
identifier used by the server to refer to the request.

Removing a quench request uses Quench Delete Request (QnchDelRqst) and
the quench identifier.

.KS
   +----------+ --QnchDelRqst--> +--------+
   | Producer |                  | Server |        DELETING A QUENCH
   +----------+ <---QnchRply---- +--------+
.KE

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
   | Producer | <--QnchAddNotify-- |        |
   +----------+                    +--------+
                                QUENCH SUBSCRIPTION ADD NOTIFICATION
.KE

.KS
   +----------+ ----SubModRqst---> +--------+
   | Consumer |                    |        |
   +----------+ <----SubRply------ |        |
                                   | Server |
   +----------+                    |        |
   | Producer | <--QnchModNotify-- |        |
   +----------+                    +--------+
                            QUENCH SUBSCRIPTION MODIFY NOTIFICATION
.KE

.KS
   +----------+ ----SubDelRqst---> +--------+
   | Consumer |                    |        |
   +----------+ <----SubRply------ |        |
                                   | Server |
   +----------+                    |        |
   | Producer | <--QnchDelNotify-- |        |
   +----------+                    +--------+
                           QUENCH SUBSCRIPTION DELETE NOTIFICATION
.KE

The following sections describes in detail the content of each packet
in protocol and the requirements of both the server and the client
library.

m4_heading(2, Errors)

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

