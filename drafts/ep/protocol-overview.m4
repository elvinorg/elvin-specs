m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  protocol-overview

m4_heading(2, `Protocol Overview')

This section describes the protocol packet types and their allowed
use.  The following sections describe in detail the content of each
packet in protocol and the requirements of both the server and the
client library.

m4_heading(3, `Server Discovery')

Server discovery SHOULD be implemented by client libraries.

Clients multicast a request for server URLs; servers respond with a
multicast list of URLs describing their available endpoints.  Where
multicast is not available for a concrete protcol, link-layer
broadcast MAY be used instead.

m4_changequote({,})
.KS
                             ,-->     +---------+
  +-------------+ ---SvrRqst-+-->   +---------+ |
  | Producer or |            `--> +---------+ | |
  |  Consumer   | <--.            |  Elvin  | |-+
  +-------------+ <--+-SvrAdvt--- | Servers |-+     SOLICITATION and
                  <--'            +---------+          ADVERTISEMENT
.KE

When a server is shutting down, it SHOULD multicast an announcement to
all clients that its endpoints are no longer available.

.KS
      +-------------+
    +-------------+ |                     +---------+
  +-------------+ | | <--.                |  Elvin  |
  | Producers & | |-+ <--+-SvrAdvtClose-- |  Server |
  |  Consumers  |-+   <--'                +---------+  ADVERTISEMENT
  +-------------+                                         WITHDRAWAL
.KE
m4_changequote(`,')

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

m4_heading(3, Session-based Operation)

After an Elvin server has been located (see section on server
discovery) a client MAY request a connection. The server MUST respond
with either a Connection Reply, a Disconnect or a Nack.

If the server accepts the request, it MUST respond with a Connection
Reply, containing the agreed parameters of the connection.

.KS
  +-------------+ ---ConnRqst--> +---------+
  | Producer or |                |  Elvin  |  
  |  Consumer   |                |  Server |   SUCCESSFUL CONNECTION 
  +-------------+ <---ConnRply-- +---------+
.KE

If the Elvin server cannot accept the connection itself, but is part
of a server cluster, it MUST respond with a Disconnect and then close
the connection on which the client made the request.  The client MAY
then send a Connection Request to the server address supplied in the
Disconnect message.

A server MAY detect repeated connection attempts from a single client
ignoring a redirect, and SHOULD disconnect with a reason code
reflecting repeated protocol error.  Such servers SHOULD also take
appropriate steps at the concrete level to prevent or delay further
attempts at connection by this client.

.KS
  +-------------+ --ConnRqst--> +---------+
  | Producer or |               |  Elvin  |
  |  Consumer   |               |  Server |    REDIRECTED CONNECTION
  +-------------+ <--Disconn--- +---------+
.KE

If the Elvin server cannot accept the connection, it MUST send a
Negative Acknowledge response and close the connection upon which the
client made the request.

m4_remark(under what situations will the server nack a connection
request.  This should be under the "Failures" at the end of the
section, but one or two examples here may be used for illustration.)

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
   | Producer | <--SubAddNotify--- |        |
   +----------+                    +--------+
                                       SUBSCRIPTION ADD NOTIFICATION
.KE

.KS
   +----------+ ----SubModRqst---> +--------+
   | Consumer |                    |        |
   +----------+ <----SubRply------ |        |
                                   | Server |
   +----------+                    |        |
   | Producer | <--SubModNotify--- |        |
   +----------+                    +--------+
                                    SUBSCRIPTION MODIFY NOTIFICATION
.KE

.KS
   +----------+ ----SubDelRqst---> +--------+
   | Consumer |                    |        |
   +----------+ <----SubRply------ |        |
                                   | Server |
   +----------+                    |        |
   | Producer | <--SubDelNotify--- |        |
   +----------+                    +--------+
                                   SUBSCRIPTION DELETE NOTIFICATION
.KE

The server may choose to drop notification packets (NotifyEmit, SubAddNotify,
SubModNotify, SubDelNotify) packets if a client is not receiving them
quickly enough.  If this happens, the server is obliged to send a
DropWarn packet to the client in place of the notification, indicating
that one or more notification packets were dropped.

.KS
   +----------+                 +--------+
   | Consumer | <---DropWarn--- | Server |   DROPPED PACKET WARNING
   +----------+                 +--------+
.KE

At any time after a successful Connection Reply, the server can inform
the client that it is to be disconnected.  The Disconn packet includes
an explanation for the disconnection, and optionally, directs the
client to reconnect to an alternative server.

.KS
  +-------------+                  +---------+
  |  Producer   |                  |         |  
  |     or      | <----Disconn---- |  Server |
  |  Consumer   |                  |         |        DISCONNECTION 
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

