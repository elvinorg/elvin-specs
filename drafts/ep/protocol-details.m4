m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  protocol-details

m4_heading(2, Packet Contents)

This section provides detailed descriptions of each packet used in the
Elvin protocol. Packets are comprised from a set of simple base types
and described in a pseudo-C style as structs made up of these types.

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

    SubASTNode to_lower;
    SubASTNode to_upper;
    SubASTNode primary;
    SubASTNode secondary;
    SubASTNode tertiary;
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
a client may send single UNotify packets to the server.

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
   0        |  Undefined error opening connection  |  None
   1        |  ConnRqst version mismatch           |  None
   2        |  Authorisation failure               |  None
   3        |  Authentication failure              |  None
   4-  499  |  ( Reserved )                        |  Undefined
 500-  999  |  ( Implementation-specific           |  Undefined
            |    connection establishment error )  |
1000        |  Undefined protocol error. Requires  |  None
            |     connection abort                 |
1001        |  Protocol error                      |  None
1002        |  No such subscription                |  sub_id, id64
1003        |  No such quench                      |  quench_id, id64
1004        |  Bad keys scheme                     |  scheme_id, id32
1005        |  Bad keyset index                    |  scheme_id, id32
            |                                      |  index, int32
1006- 1499  |  ( Reserved )                        |  Undefined
1500- 1999  |  ( Implementation-specific error     |  Undefined
            |    requiring connection abort )      |
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

Option values not requested by the client are dictated by the server.
If an option has the specified default value, it SHOULD NOT be sent to
the client.  Where the server implementation uses a non-default value,
it MUST be sent to the client.

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
