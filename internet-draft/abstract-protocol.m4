m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  abstract-protocol

m4_heading(1, ABSTRACT PROTOCOL)

The Elvin4 protocol is specified at two levels: an abstract
description, able to be implemented using different marshalling and
transport protocols, and a concrete specification of one such
implementation, mandated as a standard protocol for interoperability
between different servers.

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
close the connection on which the client made the request.  The client
MAY then send a Connection Request to the server address supplied in
the Redirect message.

*** fixme *** may a client ignore a redirect and re-attempt the same
server?  if not, how long until it may?


.KS
  +-------------+ ---ConRqst--> +---------+
  | Producer or |               |  Elvin  |
  |  Consumer   |               |  Server |    REDIRECTED CONNECTION
  +-------------+ <--Redirect-- +---------+
.KE

If the Elvin server cannot accept the connection, it MUST send a Nack
response and then close the connection upon which the client made the
request.

*** fixme *** under what situations will the server nack a connection
request.  This should be under the "Failures" at the end of the
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


Once connected, the client may request notification of changes in the
subscription database managed by the server.  The client lists the
attributes of subscriptions in which it is interest using a
QuenchRqst, and is returned an identifier for the request in a
QuenchRply.


Subscriptions containing terms using the requested attributes are sent
to the client using QuenchAddNtfy.  An initial set of such packets
describes the state of the database at the time of the request.

As matching subscriptions are subsequently removed, a QuenchDelNtfy
informs the client.

The set of attributes of interest can be altered using QuenchModify,
and the interest deregistered using QuenchRemove.



.KS
   +----------+            +--------+               +----------+
   | Producer | --Notif--> | Server | --NotifDel--> | Consumer |
   +----------+            +--------+               +----------+

                                                   NOTIFICATION PATH
.KE

The next section describes in detail the content of each packet in
protocol and the requirements of both the server and the client 
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
using a reply packet.

A single protocol error MUST NOT cause the client/server connection to
be closed.  Repeated protocol errors on a single connection MAY cause
the server to close the client connection, giving suspected denial of
service attack as a reason (see Disconnect packet).


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
  Disconnect	                DisCon                3
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
  <removed> Quench Deliver      QnchDel              14
  Acknowledgement               Ack                  15
  Negative Acknowledgement      Nack                 16
  Subscription Reply            SubRply              17
  Quench Reply                  QnchRply             18

  Subscription Change Notify    SubModNotif          19
  Subscription Remove Notify    SubDelNotif          20
  QoS Reply                     QosRply              21

  More ... ?

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

The following definitions are used in several packets:

m4_pre(
struct NameValue{
   string name;
   Value  value;
};)m4_dnl

Where the "Value" type is one of int32, int64, string, real64 or opaque.

m4_heading(3, Connect Request)

Using the protocol and endpoint information obtained either directly
or via server discovery, the client establishes a connection to the
server endpoint.  It MUST then send a ConRqst to establish protocol
options to be used for the session.

It is a protocol violation for the client to send anything to the
server before a ConRqst.  A server connection that has not received a
ConRqst within five (5) seconds of being opened SHOULD be closed by
the server.

*** fixme *** do we need to set a hard time limit here?  what is reasonable?

The ConRqst MAY contain requests for various protocol options to be
used by the connection.  These options are identified using a string
name.  Some options refer to properties of the server, while others
MAY be used by the protocol layers.

Legal option names, their semantics, and allowed range of values are
defined later in this document.

m4_pre(
struct ConRqst {
   int32 xid;
   int32 client_major_version;
   int32 client_minor_version;
   NameValue options[];   
};)

m4_heading(3, Connect Reply)

Sent by the Elvin server to a client.  Confirms a connection request.
Specifies the connection option values agreed by the server.

m4_pre(
struct ConRply {
   int32 xid;
   NameValue options[];
};)m4_dnl

For each legal option included in the ConRqst, a matching response
MUST be present in the ConRply.  Where the value returned differs from
that requested, the client MUST either use the returned value, or
request closure of the connection.  Unrecognised options MUST NOT be
returned by the server.

Option values not requested by the client are dictated by the server.
If an option has the specified default value, it SHOULD NOT be sent to
the client.  Where the server implementation uses a non-default value,
it MUST be sent to the client.

m4_heading(3, Disconnect Request)

Sent by client to the Elvin server.  Requests disconnection.

m4_pre(
struct DisConRqst {
  int32 xid;
};)m4_dnl

A client MUST send this packet and wait for confirmation via
Disconnect before closing the connection to the server.  The client
library MUST NOT send any further messages to the server once this
message has been sent.  The client library MUST continue to read from
the server connection until a Disconnect packet is received.

A server receiving a DisConRqst should suspend further evaluation of
subscriptions and notification of subscription changes for this
client.  A Disconnect packet should be appended to the client's output
buffer, and finally, the output buffer flushed before the connection
is closed.

It is a protocol violation for a client to close its connection
without sending a DisConRqst (see protocol violations below).

m4_dnl 
m4_heading(3, Disconnect)

Sent by the Elvin server to a client.  This packet is sent in three
different circumstances: as a response to a Disconnect Request, to
direct the server to reconnect to another server, or to inform that
client that the server is shutting down.

m4_pre(
struct DisCon {
  int32 xid;
  int32 why;
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

This MUST be the last packet sent by a server on a connection.  The
underlying (transport) link MUST be closed immediately after this
packet has been successfully delivered to the client.

The client connection MUST NOT be closed without sending this packet
except in the case of a protocol violation.  If a client detects that
the server connection has been closed without receiving a Disconnect
packet, it should assume network or server failure.

m4_dnl
m4_heading(3, Security Request)

Sets the keys associated with the connection.  Two sets of keys are
maintained by the server: those used when sending notifications, and
those used for registered subscriptions.

This packet allows keys to be added or removed from either or both
sets as an atomic operation.

m4_pre(
struct SecRqst {
  int32  xid;
  opaque not_keys_add[];
  opaque not_keys_del[];
  opaque sub_keys_add[];
  opaque sub_keys_del[];
};)m4_dnl

It is a protocol error to request the addition of a key already
registered, or the removal of a key not registered.

m4_heading(3, QoS Request)

Sent by clients to the Elvin server.  This packet allows the server to
request alterations to connection options.

m4_pre(
struct QosRqst {
  int32 xid;
  NameValue options[];
};)m4_dnl


m4_heading(3, QoS Reply)

Sent from server to client.  This packet specifies the results of a
requested modification of connection options.

m4_pre(
struct QosRply {
  int32 xid;
  NameValue options[];
};)m4_dnl

QosRply MUST be sent in response to a QosRqst.  For each legal option
in the QosRqst, a matching option MUST be returned, specifying the new
value.  If the request was unsuccessful, this value MAY NOT match the
value requested.

Unrecognised options in the QosRqst MUST NOT be returned.  The server
MUST NOT return an option that was not included in the QosRqst.

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

Sent by client to the Elvin server.  A Nack will be returned if the
subscription identifier is not valid.

m4_pre(
struct SubDelRqst {
  int32 xid;
  int64 subscription_id;
};)m4_dnl

m4_heading(3, Quench Add Request)

Sent by clients to the Elvin server.  Requests notification of
subscriptions referring to the specified attributes.

m4_pre(
struct QnchAddRqst {
  int32 xid;
  string names[];
};)m4_dnl


m4_heading(3, Quench Modify Request)

Sent by client to the Elvin server.  Requests changes to the list of
attribute names associated with a quench identifier.

m4_pre(
struct QnchModRqst {
  int32 xid;
  int64 quench_id;
  string names_add[];
  string names_del[];
};)m4_dnl


m4_heading(3, Quench Delete Request)

Sent by client to the Elvin server.  Requests that the server no
longer notify the client of changes to subscriptions with the
associated attribute names.

m4_pre(
struct QnchDelRqst {
  int32 xid;
  int64 quench_id;
};)m4_dnl


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
   int64     matching_ids[];
   NameValue attributes[];
};)m4_dnl


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

m4_heading(3, Quench Reply)

Sent from the Elvin server to the client as acknowledgement of a successful
quench change.

m4_pre(
struct QnchRply {
  int32 xid;
  int64 quench_id;
};)m4_dnl


m4_heading(3, Subscription Change Notification)

Sent from server to clients to inform them of a change to the set of
subscriptions matching their registered quench attribute name list.

m4_pre(
struct SubModNotif {
  int64 quench_id;
  int64 sub_id;
  SubAST sub_expr;
};)m4_dnl

m4_heading(3, Subscription Removal Notification)

Sent from server to clients to inform them of the removal of a
subscription which had matched their registered quench attribute name
list.

m4_pre(
struct SubDelNotif {
  int64 quench_id;
  int64 sub_id;
};)m4_dnl

m4_heading(2, Protocol Errors)

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
Non-specific error related to client-server communications.  This
will generally be sent to the client if the server recieves unexpected
data.  The server SHOULD close the socket after sending a ProtErr
Nack.

.IP "Syntax Error" 4
Non-specific syntactic problem.

.IP "Identifier Too Long" 4
the supplied element identifier exceeds the maximum allowed length.

.IP "Bad Identifier" 4
the supplied element identifier contains illegal characters. Remember
that the first character must be only a letter or underscore.


m4_heading(2, Connection Options)

Connection options control the behaviour of the server for the
specified connection.  Set during connection, they may also be
modified during the life of the connection using QosRqst.

A server implementation MUST support the following options.  It MAY
support additional, implementation-specific options.

.KS
  -----------------------------------------------------------------
  Name                                   Type     Min  Default Max
  -----------------------------------------------------------------
   sub_max                               int32
   sub_len_max                           int32
   attribute_max                         int32
   attribute_name_len_max                int32
   byte_size_max                         int32
   string_len_max                        int32
   opaque_len_max                        int32
   notif_buffer_min                      int32
   notif_buffer_drop_policy              int32    (see below)
  -----------------------------------------------------------------
.KE
