m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  abstract-protocol

m4_heading(1, ABSTRACT PROTOCOL)

This section describes the operation of the Elvin4 protocol, without
describing any particular protocol implementation.

m4_heading(2, Protocol Overview)

After an Elvin server has been located (see section on SLP) a client
requests a connection. The server MUST respond with either a
Connection Reply, a Redirect or a Nack.

*** fixme *** what params in a ConRqst.  how much is done in the ConRqst
compared to SLP attr's?

If the server accepts the request, it MUST respond with a Connection
Reply, containing the agreed parameters of the connection.

.KS
  +-------------+ ---ConRqst--> +---------+
  | Producer or |               |  Elvin  |  
  |  Consumer   |               |  Server |    SUCCESSFUL CONNECTION 
  +-------------+ <---ConRply-- +---------+
.KE

If the Elvin server cannot accept the connection itself, but is part
of a server cluster, it MUST respond with a Redirect response and then
close the socket connection on which the client made the request.  The
client MAY then send a Connection Request to the server address
supplied in the Redirect message.

.KS
  +-------------+ ---ConRqst--> +---------+
  | Producer or |               |  Elvin  |
  |  Consumer   |               |  Server |    REDIRECTED CONNECTION
  +-------------+ <--Redirect-- +---------+
.KE

If the Elvin server cannot accept the connection, it MUST send a Nack
response and then close the socket connection the client made the
request on. 

*** fixme *** under what situations will the server nack a connection
request.  This should be under the "Failures" a the end of the
section, but one or two examples here may be used for illustration].

.KS
  +-------------+ ---ConRqst--> +---------+
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

The NotifDel packet differs slightly from the original Notif sent 
by the producer.  As well as the sequence of named-typed-values,
it contains information about which subsciptions were used to match
the event.  This allows the client library of the consumer to
dispatch the event with out having to do any additional matching.

.KS
   +----------+            +--------+               +----------+
   | Producer | --Notif--> | Server | --NotifDel--> | Consumer |
   +----------+            +--------+               +----------+

                                                   NOTIFICATION PATH
.KE

A Consumer descibes what events it is interested in by sending a
predicate in the Elvin subscripton language to the Elvin server.  The
predicate is sent in a SubAddRqst.  On receipt of the request, the
server checks the syntatical correctness of the predicate. If valid,
an Ack is returned.

If the predicate fails to parse, a Nack is returned with the error
code set to indicate a parser error.

.KS
   +----------+ --SubAddRqst--> +--------+
   | Consumer |                 | Server |     ADDING A SUBSCRIPTION
   +----------+ <-----Ack------ +--------+
.KE

The next section describes in detail the content of each packet in
protocol and the requirements of both the server and the client 
library.

m4_heading(2, Packet Types)

The protocol specifies a number of packets used in interactions between 
clients and the server and bewteen federated servers.

.KS
Possible values for the type field in a packet are:

.nf 
  ---------------------------------------------------------------
  Packet Type                   Abbreviation       Packet ID
  ---------------------------------------------------------------
  Connect Request               ConRqst               0
  Connect Reply                 ConRply               1
  Disconnect Request            DisConRqst            2
  Disconnect		        DisCon                3
  Security Request              SecRqst               4
  QoS Request                   QosRqst               5
  Subscription Add Request      SubAddRqst            6
  Subscription Modify Request   SubModRqst            7
  Subscription Delete Request   SubDelRqst            8
  Quench Add Request            QnchAddRqst           9
  Quench Modify Request         QnchModRqst          10
  Quench Delete Request         QnchDelRqst          11
  Notification                  Notif                12
  Notification Deliver          NotifDel             13
  Quench Deliver                QnchDel              14
  Acknowledgement               Ack                  15
  Negative Acknowledgement      Nack                 16
  Subscription Reply            SubRply              17

  More...

  ---------------------------------------------------------------
.fi
.KE

*** fixme *** Note that the packet IDs given above are an example only.
Each encoding is free to use the most suitbale method for distinguishing
between different packet types.  For the default XDR encoding, an 
enum is used with values that match the above table.

m4_heading(2, Packet Descriptions)

This section provides detailed descrptions of each packet used in the
Elvin protocol. Packets are comprised of the Elvin base types and
described in a pseudo-C style as structs made up of these types.

The following definstions are used in several packets:

m4_pre(
struct NameValue{
   string name;
   Value  value;
};)m4_dnl

Where the "Value" type is one of int32, int64, string, real64 or opaque.

m4_heading(3, Connect Request)

Sent by client to the Elvin server.  Includes protocol version of the client library,
per-connection security keys, quality of service specifications, etc.

m4_pre(
struct ConRqst {
   int32 major_version;
   int32 minor_version;
   string protocol_preferences[];
   string qos_preferences[];
   opaque keys[];
};)

*** fixme *** whats the format of protocol_preferences strings? URLs
perhaps.

m4_pre(
Some required QoS parameters:
- max number of subscriptions per connection
- max number of elements in notification
- max byte size of notification
- max byte size of string
- max byte size of opaque
)

m4_heading(3, Connect Reply)

Sent by the Elvin server to a client.  Confirms a connection request.
Includes connection identifier, available QoS, and protocol version
agreed.

m4_pre(
struct ConRply {
   int32 major_version;
   int32 minor_version;
   string protocol_used;
};)m4_dnl

"protocol_used" tells the client

m4_heading(3, Disconnect Request)

Sent by client to the Elvin server.  Requests disconnection.

m4_pre(
struct DisConRqst {
   int32 xid;    
};)m4_dnl

With the exception of retrying this request, the client library MUST
NOT send any further messages to the server once this message has been
sent.
m4_dnl
m4_heading(3, Disconnect)

Sent by the Elvin server to a client.  This packet is sent in three
different circumstances: as a response to a Disconnect Request, to
direct the server to reconnect to another server, or to inform that
client that the server is shutting down.

m4_pre(
struct DisCon {
   int32 why;
   int32 xid;
   string args;
};)m4_dnl

.KS
where the defined values for "why" are

.nf
-----------------------------------------------------------------
Why  Definition
-----------------------------------------------------------------
 0   Reserved.
 1   Server is closing down.  xid MUST be zero.
 2   Server is closing this connection, in response to your 
     request (DisConRqst) with sequence number matching 
     xid.
 4   Server is closing this connection, and requests that client
     makes new connection to server address in "args".  
     xid MUST be zero.
---------------------------------------------------------------
.fi
.KE

This MUST be the last packet sent (by the server) on a connection.
The underlying (transport) link MUST be closed immediately after this
packet has been successfully delivered to the client.

The client connection SHOULD NOT be closed without sending this
packet.  If this client detects that the server connection has been
closed without receiving a Disconnect packet, it should assume network
or server failure.
m4_dnl
m4_heading(3, Security Request)

Sets the keys associated with the connection. Each notification sent
from the client on the connection will have the keys specified in this
packet attached implicitly;

m4_pre(
struct SecRqst {
  int32  xid;
  opaque subscription_keys[];
  opaque notification_keys[];
};)m4_dnl

m4_heading(3, QoS Request)

*** FIXME - tbd ***

m4_heading(3, Subscription Add Request)

Sent by client to the Elvin server.  Requests delivery of
notifications which match the supplied subscription expression.

m4_pre(
struct SubAddRqst {
  int32 xid;
  string expression;
  opaque keys[];
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
  int32 xid;
  int64 subscription_id;
  string expression;
  opaque add_keys[];
  opaque del_keys[];
};)m4_dnl

Any (and all) of the expression, add_keys and del_keys field MAY be
empty.  If all fields are empty, the modification SHALL be considered
successful.

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

Sent by client to the Elvin server.  An Nack will be returned if the subscription id is not valid.

m4_pre(
struct SubDelRqst {
  int32 xid;
  int64 subscription_id;
};)m4_dnl

m4_heading(3, Quench Add Request)

Sent by client to the Elvin server. 

m4_heading(3, Quench Modify Request)

Sent by client to the Elvin server. 

m4_heading(3, Quench Delete Request)

Sent by client to the Elvin server. 

m4_heading(3, Notification)

Sent by client to the Elvin server. 

m4_pre(
struct Notif{
   int32     xid;
   NameValue attributes[];
   opaque    keys[];
};)m4_dnl

m4_heading(3, Notification Deliver)

Sent by the Elvin server to a client. 

m4_pre(
struct NotifDel{
   int32     xid;
   NameValue attributes[];
   int64     matching_ids[];
};)m4_dnl

m4_heading(3, Quench Deliver)

Sent by the Elvin server to a client. 

headng(4, Acknowledgement)

Sent by the Elvin server to a client. 

m4_pre(
struct Ack {
  int32 xid;
};)m4_dnl

m4_heading(3, Negative Acknowledgement)

Sent by the Elvin server to a client. 

m4_pre(
struct Nack {
  int32  xid;
  int32  error;
  string message;
  Value  args[]
};)m4_dnl

m4_heading(3, Subscription Reply)

Sent from the Elvin server to the client as acknowledgement of a successful
subscription change.

m4_pre(
struct SubRply {
  int32 xid;
  int64 subscription_id;
};)m4_dnl

m4_heading(3, Add Link)
m4_heading(3, Update Link)
m4_heading(3, Delete Link)


m4_heading(2, Failures)

The different things that generate Nacks. 

Errors are reported as numbers so that language-specific error
messages may be used by the client.

.KS
  -----------------------------------------------------------------
  Error Description                    Abbreviation       Error ID 
  -----------------------------------------------------------------
  Reserved                                                   0
  Protocol Error                       ProtErr               1
  Syntax Error in Subscription         SynErr                2
  Identifier Too Long in Subscription  LongIdent             3
  Bad Identifier in Subscription       BadIdent              4
  No such subscription for client      BadSub                5
  ---------------------------------------------------------------
.KE

  *** fixme *** can 1,2,3 happen in a notif as well as sub?

.IP "Protocol Error"
Non-specific error related to client-server communications.  This willgenerally be sent to the client if the server recieves unexpected data.
The server SHOULD close the socket after sending a ProtErr Nack.

.IP "Syntax Error" 4
Non-specific syntactic problem.

.IP "Identifier Too Long" 4
the supplied element identifier exceeds the maximum allowed length.

.IP "Bad Identifier" 4
the supplied element identifier contains illegal characters. Remember
that the first character must be only a letter or underscore.

