m4_dnl  abstract-protocol
m4_dnl
m4_dnl  -*-nroff-mode-*-

m4_heading(2, Abstract Protocol)

This section describes the operation of the Elvin4 protocol.  

m4_heading(3, Protocol Overview)

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

m4_heading(3, Packet Types)

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
  Security Request              SecRqst               3
  QoS Request                   QosRqst               4
  Management Request            MgmtRqst              5
  Subscription Add Request      SubAddRqst            6
  Subscription Modify Request   SubModRqst            7
  Subscription Delete Request   SubDelRqst            8
  Quench Request                QnchRqst              9
  Notification                  Notif                10
  Notification Deliver          NotifDel             11
  Quench Deliver                QnchDel              12
  Acknowledgement               Ack                  13
  Negative Acknowledgement      Nack                 14
  Redirect                      Redir                15

  More...

  ---------------------------------------------------------------
.fi
.KE

*** fixme *** Note that the packet IDs given above are an example only.
Each encoding is free to use the most suitbale method for distinguishing
between different packet types.  For the default XDR encoding, an 
enum is used with values that match the above table.

m4_heading(3, Packet Descriptions)

This section provides detailed descrptions of each packet used in the
Elvin protocol. Packets are comprised of the Elvin base types and
described in a pseudo-C style as structs made up of these types.

m4_heading(4, Connect Request)

Sent by client to the Elvin server.  Includes protocol version of the client library,
per-connection security keys, quality of service specifications, etc.

m4_pre(
struct ConRqst {
   int32 major_version;
   int32 minor_version;
   string protocol_preferences[];
   string qos_preferences[];
   opaque keys[];
}
)

*** fixme *** whats the format of protocol_preferences strings? URLs
perhaps.

m4_heading(4, Connect Reply)

Sent by the Elvin server to a client.  Confirms a connection request.
Includes connection identifier, available QoS, and protocol version
agreed.

m4_pre(
struct ConRply {
   int32 major_version;
   int32 minor_version;
   string protocol_used;
}
)

"protocol_used" tells the client

m4_heading(4, Disconnect Request)

Sent by client to the Elvin server.  Requests disconnection.  This message is not acknowledged.

m4_pre(
struct DisConRqst {
    
}
)

m4_heading(4, Security Request)

m4_heading(4, QoS Request)

m4_heading(4, Management Request)

m4_heading(4, Subscription Add Request)

Sent by client to the Elvin server.  if your are going to get a ack
back, events may start arriving before the return of the sendSubscribe

m4_pre(
struct SubAddRqst {
  int32 sequence_no;
  int32 subscription_id;
  string expression;
  opaque keys[];
}
)

m4_heading(4, Subscription Modify Request)

Sent by client to the Elvin server.  An Nack will be returned if the
subscription id is not valid.

  struct SubModRqst {
    int32 sequence_no;
    int32 subscription_id;
    string expression;
    opaque add_keys[];
    opaque del_keys[];
  }

m4_heading(4, Subscription Delete Request)

Sent by client to the Elvin server.  An Nack will be returned if the subscription id is not valid.

  struct SubDelRqst {
    int32 sequence_no;
    int32 subscription_id;
  }

m4_heading(4, Quench Request)

Sent by client to the Elvin server. 

m4_heading(4, Notification)

Sent by client to the Elvin server. 


m4_heading(4, Notification Deliver)

Sent by the Elvin server to a client. 

m4_heading(4, Quench Deliver)

Sent by the Elvin server to a client. 

headng(4, Acknowledgement)

Sent by the Elvin server to a client. 

m4_heading(4, Negative Acknowledgement)

Sent by the Elvin server to a client. 

m4_heading(4, Add Link)
m4_heading(4, Update Link)
m4_heading(4, Delete Link)

m4_heading(3, Failures)

The different things that generate Nacks. 

Errors are reported as numbers so that language-specific error
messages may be used by the client.

.KS
  -----------------------------------------------------------------
  Error Type                           Abbreviation       Error ID 
  -----------------------------------------------------------------
  Protocol Error                       ProtErr               1
  Syntax Error in Subscription         SynErr                2
  Identifier Too Long in Subscription  LongIdent             3
  Bad Identifier in Subscription       BadIdent              4
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

