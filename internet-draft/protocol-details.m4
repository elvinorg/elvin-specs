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
    string str;    // length encoded UTF-8 Unicode string
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
struct Keys {
    struct KeySetList {
	id32 scheme;
	struct KeySet {
	    opaque keys[];
	} key_sets[];
    } key_set_lists[];
};

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

    SubASTNode exists;
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

Within the context of a session, most requests MAY return a Negative
Acknowledgement to indicate that although the server understood the
request, there was an error encountered performing the requested
operation.

m4_pre(
struct Nack {
    id32 xid;
    id32 error;
    string message;
    Value args[]
};)m4_dnl

*** fixme ***

we need to refer to the definition of errors here.  we also need to
decide what to do wrt the error numbers, as discussed in jun00 design
meetings.

*** fixme ***

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
struct DropWarn {
};)m4_dnl

Sent by servers to clients to indicate that notification packets have
been dropped.


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

m4_heading(3, Server Request)

A client MAY request that servers advertise their available endpoints
by multicasting a Server Request.  

All attempts to send a Sever Request MUST be delayed by a random
period of between zero (0) and five (5) seconds.  If any Server
Request packets (from other clients) are observed during this time,
the client MUST cancel its own pending request.

If a client observes any Server Advertisements during the startup
period, it SHOULD attempt to connect to them immediately.

A client MUST NOT send a Server Request more than once in any twenty
(20) second period.

m4_pre(
struct SvrRqst {
  uint8      major;
  uint8      minor;
};)m4_dnl

m4_heading(3, Server Advertisement)

Servers MUST respond to a SvrRqst with a multicast Server
Advertisement, but MUST NOT send SvrAdvt more often than once every
five (5) seconds.

m4_pre(
struct SvrAdvt {
  uint8    major;
  uint8    minor;
  string   server;
  id32     revision;
  string   scope;
  boolean  default;
  string   urls[];
};)m4_dnl

The returned major and minor version numbers MUST reflect the protocol
version of the reply packet.  Where a server is capable of using
multiple protocol versions, this MUST be reflected in the endpoint
URLs, and the SvrAdvt message MUST use the client's protocol version.

The SvrAdvt includes a server name that MUST be globally unique.  It
is RECOMMENDED that the fully-qualified DNS host name, server process
number and a random integer value be used to prevent collisions.

The revision number distinguishes between advertisements from the same
server reflecting changes in the available protocols.  As a server's
configuration is altered (at runtime), the advertisement version
number MUST be incremented.  This allows clients to discard duplicate
advertisements quickly.

The scope name must be the string scope name for the server.  An empty
scope name is allowed.  If this scope has been configured to be the
default scope for a site, the default flag should be set true.

The set of URLs reflect the endpoints available from the server.  A
SvrAdvt message SHOULD include all endpoints offered by the server.
Where the limitations of the underlying concrete protocol prevent
this, the server cannot advertise all its endpoints.  Each SvrAdvt
MUST contain at least one URL.

Clients SHOULD maintain a cached list of all endpoint URLs it has seen
announced.  If available, this list MUST be used to attempt connection
before sending a SvrRqst.  Cached URLs MUST be replaced by those in a
subsequent advertisement with higher version number from the same
server.  URLs cached for a given server SHOULD be flushed after eight
(8) observed SvrRqst/SvrAdvt cycles that have not included a SvrAdvt
from that server.

m4_heading(3, Server Advertisement Close)

A server shutting down SHOULD send a Server Advertisement Close
message.

m4_pre(
struct SvrAdvtClose {
  string   server;
};)m4_dnl

Caching clients MUST monitor such messages and remove all endpoints for
the specified server from their cache.
