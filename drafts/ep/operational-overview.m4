m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  operational-overview

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

At any time after a successful Connection Reply, the server can inform
the client that it is to be disconnected.  The Disconn packet includes
an explanation for the disconnection, and optionally, directs the
client to reconnect to an alternative server.

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


