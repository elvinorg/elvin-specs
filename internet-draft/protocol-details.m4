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
typedef byte[] opaque;

union Value {
    int32   i32;   // 4 byte signed integer
    int64   i64;   // 8 byte signed integer
    real64  r64;   // 8 byte double precision float
    string  str;   // length encoded string
    opaque  blob;  // binary data sequence
};

struct NameValue {
    string  name;
    Value   value;
};

struct SubASTNode {
    SubAST[] children;
};

struct SubASTName {
    int32 flags;
    string name;
};

union SubAST {
    SubASTName name;
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

    SubASTNode exists;
    SubASTNode equals;
    SubASTNode size;
};')m4_dnl

.KE

Arrays of NameValue elements are used for notification data and
description of server options.

.KS
m4_pre(
  int32 xid
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
context of a session.  Using the protocol and endpoint information
obtained either directly or via server discovery, a client may send
single UNotify packets to the server.

m4_pre(
struct UNotify {
   uint8     client_major_version;
   uint8     client_minor_version;
   NameValue attributes[];
   opaque    raw_keys[];
};)m4_dnl

m4_heading(3, Negative Acknowledgement)

Within the context of a session, most requests MAY return a Negative
Acknowledgement to indicate that although the server understood the
request, there was an error encountered performing the requested
operation.

m4_pre(
struct Nack {
  int32  xid;
  int32  error;
  string message;
  Value  args[]
};)m4_dnl

m4_heading(3, Connect Request)

Using the protocol and endpoint information obtained either directly
or via server discovery, the client establishes a connection to the
server endpoint.  It MUST then send a ConnRqst to establish protocol
options to be used for the session.

It is a protocol violation for the client to send anything other than
a UNotify to the server before a ConnRqst.  A server connection that
has not received a UNotify or a ConnRqst within five (5) seconds of
being opened SHOULD be closed by the server.

*** fixme *** do we need to set a hard time limit here?  what is reasonable?

The ConnRqst MAY contain requests for various protocol options to be
used by the connection.  These options are identified using a string
name.  Some options refer to properties of the server, while others
MAY be used by the protocol layers.

Legal option names, their semantics, and allowed range of values are
defined later in this document.

m4_pre(
struct ConnRqst {
   int32 xid;
   uint8 client_major_version;
   uint8 client_minor_version;
   NameValue options[];
   opaque raw_keys[];
   opaque prime_keys[];
};)m4_dnl

m4_heading(3, Connect Reply)

Sent by the Elvin server to a client.  Confirms a connection request.
Specifies the connection option values agreed by the server.

m4_pre(
struct ConnRply {
   int32 xid;
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
  int32 xid;
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
  int32  xid;
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
  int32  reason;
  string args;
};)m4_dnl

.KS
where the defined values for "reason" are

.nf
-----------------------------------------------------------------
Reason  Definition
-----------------------------------------------------------------
 0   Reserved.
 1   Server is closing down.
 2   Server is closing this connection, and requests that client
     makes new connection to server address in "args".  
 4   Server is closing this connection for repeated protocol errors.

---------------------------------------------------------------
.fi
.KE

This MUST be the last packet sent by a server on a connection.  The
underlying (transport) link MUST be closed immediately after this
packet has been successfully delivered to the client.

The client connection MUST NOT be closed without sending either a
DisconnRply or Disconn packet except in the case of a protocol
violation.  If a client detects that the server connection has been
closed without receiving one of these packets, it should assume
network or server failure.

A client receiving a redirection via a Disconn MUST attempt to connect
to the specified server before attempting any other servers for which
it has address information.  If the connection is fails or is refused
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
  int32  xid;
  opaque add_raw_keys[];
  opaque del_raw_keys[];
  opaque add_prime_keys[];
  opaque del_prime_keys[];
};)m4_dnl

It is a protocol error to request the addition of a key already
registered, or the removal of a key not registered.

m4_heading(3, Security Reply)

Sent by the server to clients to confirm a successful change of keys.

m4_pre(
struct SecRply {
  int32 xid;
};)m4_dnl

m4_heading(3, Notification Emit)

Sent by client to the Elvin server. 

m4_pre(
struct NotifyEmit {
   NameValue attributes[];
   opaque    raw_keys[];
};)m4_dnl


m4_heading(3, Notification Deliver)

Sent by the Elvin server to a client. 

m4_pre(
struct NotifyDeliver {
   int64     insecure_matches[];
   int64     secure_matches[];
   NameValue attributes[];
};)m4_dnl

m4_heading(3, Subscription Add Request)

Sent by client to the Elvin server.  Requests delivery of
notifications which match the supplied subscription expression.

m4_pre(
struct SubAddRqst {
  int32   xid;
  string  expression;
  boolean accept_insecure;
  opaque  prime_keys[];
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
  int32   xid;
  int64   subscription_id;
  string  expression;
  boolean accept_insecure;
  opaque  add_prime_keys[];
  opaque  del_prime_keys[];
};)m4_dnl

Any (and all) of the expression, add_keys and del_keys field MAY be
empty.  If all fields are empty, the modification SHALL be considered
successful.

*** FIXME *** when (if?) the accept_insecure is removed:

Client libraries SHOULD not send SubModRqst's with all of expression,
add_prime_keys and del_prime_keys as empty.  Server implementations,
however, MUST still handle such packets by sending a SubRply with the
xid and subscription_id set to the same corresponding values in the
SubModRqst.

***

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

m4_heading(3, Subscription Reply)

Sent from the Elvin server to the client as acknowledgement of a successful
subscription change.

m4_pre(
struct SubRply {
  int32 xid;
  int64 subscription_id;
};)m4_dnl

m4_heading(3, Quench Add Request)

Sent by clients to the Elvin server.  Requests notification of
subscriptions referring to the specified attributes.

m4_pre(
struct QnchAddRqst {
  int32   xid;
  string  names[];
  boolean accept_insecure;
  opaque  raw_keys[];
};)m4_dnl

m4_heading(3, Quench Modify Request)

Sent by client to the Elvin server.  Requests changes to the list of
attribute names associated with a quench identifier.

m4_pre(
struct QnchModRqst {
  int32   xid;
  int64   quench_id;
  string  names_add[];
  string  names_del[];
  boolean accept_insecure;
  opaque  add_raw_keys[];
  opaque  del_raw_keys[];
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

m4_heading(3, Quench Reply)

Sent from the Elvin server to the client as acknowledgement of a successful
quench requirements change (QnchAddRqst, QnchModRqst, QnchDelRqst):

m4_pre(
struct QnchRply {
  int32   xid;
  int64   quench_id;
};)m4_dnl

m4_heading(3, Subscription Add Notification)

Sent from server to clients to inform them of a new subscription
predicate component matching the registered quench attribute name
list for each of the identified quench registrations.

If the insecure flag is set, it indicates that the matching
subscription has no associated keys.

m4_pre(
struct SubAddNotify {
  int64   quench_ids[];
  int64   term_id;
  boolean insecure;
  SubAST  sub_expr;
};)m4_dnl

m4_heading(3, Subscription Modify Notification)

This packet indicates that a subscription predicate component matching
their registered quench attribute name list changed for each of the
identified quench registrations.

If the insecure flag is set, it indicates that the matching
subscription has no associated keys.

Note that a subscription term that had a key replaced might no longer
match a particular quench registeration.  This is notified using a
SubDelNotify.  Similarly a key replacement might cause a SubAddNotify
if its key list now intersects with that of a registered quench
request.

m4_pre(
struct SubModNotify {
  int64   quench_ids[];
  int64   term_id;
  boolean insecure;
  SubAST  sub_expr;
};)m4_dnl

m4_heading(3, Subscription Delete Notification)

Sent from server to clients to inform them of the removal of a
subscription predicate component that had matched their registered
attribute name list for each of the identified quench registrations.

m4_pre(
struct SubDelNotify {
  int64   quench_ids[];
  int64   term_id;
};)m4_dnl

