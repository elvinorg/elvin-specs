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
m4_dnl
.KS
m4_heading(2, Packet Types)

The Elvin abstract protocol specifies a number of packets used in
interactions between clients and the server.

.nf 
  Packet Type                |  Abbreviation |  Usage 
 ----------------------------+---------------+---------
  Server Request             |  SvrRqst      |  C -> S
  Server Advertisement       |  SvrAdvt      |  S -> C
  Server Advertisement Close |  SvrAdvtClose |  S -> C
.fi
.KE

A concrete protocol implementation is free to use the most suitable
method for distinguishing packet types.  If a packet type number or
enumeration is used, it SHOULD reflect the above ordering.

m4_heading(2, `Protocol Overview')

This section describes the protocol packet types and their allowed
use.  The following sections describe in detail the content of each
packet in protocol and the requirements of both the server and the
client library.

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

m4_heading(2, Abstract Packet Definitions)

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
m4_heading(3, Server Request)

Clients MAY and servers SHOULD implement this automatic server
discovery mechanism.

The client-side of the discovery protocol has two modes of operation:
passive and active.  During passive discovery, a client caches server
advertisements observed on the multicast channel(s).  During active
discovery, clients solict advertisements from servers.

Clients SHOULD implement active discovery and MAY add passive
discovery for better performance and network utilisation.

A client enters active discovery when the client application requests
solicitation of server advertisements.  A client program SHOULD NOT
commence active discovery unless it is necessary to satisfy a
connection request from the application.

m4_pre(
struct SvrRqst {
  uint8  major;
  uint8  minor;
  uint8  hop_limit;
};)m4_dnl

Clients and servers MUST discard SvrRqst packets with incompatible
protocol version numbers.  Protocols are compatible when major version
numbers are the same, and the client's minor version is equal to or
less than the minor version of the advertisement.

To control the propagation of SvrRqst packets, a scoping mechanism for
the underlying multicast protocol SHOULD be used.  This is expressed
as a hop limit whose range of values are mapped onto the underlying
protocol.

When using IPv4 multicast, the client MUST use the hop limit setting
to set the IP header TTL field.  For IPv6 multicast, the client MUST
use the following table to translate hop limit values to multicast
scopes.

.KS
.nf
  Hop Limit  |  IPv6 Scope (and Name)
  -----------+---------------------------------
        0    |      1      (node)
        1    |      2      (link-local)
     2-15    |      5      (site-local)
    16-31    |      8      (organisation-local)
   32-255    |     14      (global)
.fi
.KE

Other protocols SHOULD interpret this value as appropriate.

SvrRqst packets MUST have an initial hop limit between 0 and 15, and
SHOULD default to zero.  Values used SHOULD come from the set defined
below.

To reduce packet storms when many clients simultaneously attempt to
find a server (such as when an existing server crashes, or hourly
batch jobs start), a client MUST wait before sending a SvrRqst and
only send its own request if no others (from other clients) are
observed during the waiting period.  

For a given hop limit, the waiting period before sending the SvrAdvt
MUST NOT be less than the intervals defined below, and the variation
from the base value MUST be determined randomly for each packet sent.

.KS
.nf
  Pre-Request Interval  |  Hop Limit
  ----------------------+-----------
       0.0 seconds      |      0
       0.4 +/- 0.2      |      1
       2.0 +/- 1.0      |      2
       2.0 +/- 1.0      |      4
       2.0 +/- 1.0      |      8
       4.0 +/- 2.0      |     16
       4.0 +/- 2.0      |     32
       8.0 +/- 4.0      |     64
.fi
.KE

If a version-compatible SvrRqst from another client with equal or
greater hop limit than that to be used for the next SvrRqst is
observed during the pre-request interval, sending of the SvrRqst MUST
be suppressed.

If the client receives one or more version-compatible SvrAdvt packets
during the pre-request interval, the SvrRqst MUST be postponed until
the client application requests that further advertisements be
solicited (for example, because it cannot connect to the server
endpoints so far discovered).

If no requests for further solicitation have been received for a
period five minutes after sending the last SvrRqst, discovery MUST
revert to passive mode, and the hop limit and pre-request intervals
are reset to their starting values.

Note that a SvrRqst from a downstream client can cause the suppression
of a client's own SvrRqst with the same hop limit, even though the
downstream SvrRqst's hop limit is exhausted, thus preventing the
client's SvrRqst from reaching an upstream server that is within that
scope.  However, either of the two client's next SvrRqst (with higher
hop limit) will reach the server, and while the immediate client loses
one interval period, it has no permanent impact.  This could be
avoided by allowing the client to compare the hop limit with the
current hop count in the packet, but this is even more
protocol-specific, and not supported by the IPv4 socket API.

m4_heading(3, Server Advertisement)

Servers SHOULD implement server discovery.  A Server Advertisement
packet SHOULD be sent when the server is started, and MUST be sent
response to SvrRqst packets received from clients, but MUST NOT be
sent more often than once every two seconds.

m4_pre(
struct SvrAdvt {
  uint8    major;
  uint8    minor;
  boolean  is_default;
  id32     revision;
  string   scope_name;
  string   server_name;
  string   urls[];
};)m4_pre

Server Advertisement packets specify the version of the Elvin protocol
which defines their format.  A SvrAdvt sent in response to a SvrRqst
MUST use a compatible protocol version.  Where a server is capable of
using multiple protocol versions, this can be reflected in the
endpoint URLs.  Clients and servers MUST discard SvrAdvt packets with
incompatible protocol versions.

The advertising server is identified by a Unicode string name.
Servers MUST ensure this name is universally unique over time.  It is
RECOMMENDED that the combination of the Elvin server's process
identifier, fully-qualified domain name and starting timestamp are
used.

Clients identify subsequent advertisements from the same server using
the value of this string.  Although the value is Unicode text, the
comparison MUST use bitwise identity.  After the first observed
SvrAdvt from a server, additional advertisements SHOULD be discarded
unless the revision number has changed.

The revision number distinguishes advertisements from the same server,
reflecting changes in the available protocols.  A server MAY change
the URLs supplied in the advertisement without modifying the revision
number as a means of influencing the endpoints used by connecting
clients.  However, if an endpoint is withdrawn, the server's supported
scope name or the value of is_default is altered, the revision number
SHOULD be increased to flush client's caches.

The scope name is the string scope name for the server.  An empty
(zero length) scope name is allowed.  If this scope has been
configured to be the default scope for a site, the default flag should
be set true.

The set of URLs reflect the endpoints available from the server.  A
SvrAdvt message SHOULD include all endpoints offered by the server.
Where the limitations of the underlying concrete protocol prevent
this, the server cannot advertise all its endpoints.  Each SvrAdvt
MUST contain at least one URL.

Note that the URLs included in a SvrAdvt MAY specify multiple protocol
versions if the advertising server is capable of supporting this.  The
version information in the SvrAdvt body does not imply that the server
necessarily supports that protocol version alone, or indeed at all.

The protocol-specific scope limit of the initial SvrAdvt packet SHOULD
be configured in the server configuration parameters and MUST NOT
exceed 64.  SvrAdvt packets sent in response to a SvrRqst MUST set the
protocol-specific scope limit to the hop limit in the received
SvrRqst.  A server MUST remember the highest hop limit value it has
sent for use when withdrawing its advertisement.
 
m4_heading(3, Server Advertisement Close)

A server shutting down SHOULD send a Server Advertisement Close
message.

struct SvrAdvtClose {
  uint8    major;
  uint8    minor;
  string   server;
}

Clients and servers MUST discard SvrAdvtClose packets with
incompatible protocol version numbers.  Servers that have sent SvrAdvt
messages using multiple protocol versions SHOULD send a SvrAdvtClose
in each of those protocol versions.

The protocol-specific scope limit of the SvrAdvtClose packet MUST be
set to the highest value sent in a SvrAdvt during the lifetime of the
server process.  This ensures that the withdrawal notice reaches all
passive discovery clients that might have a cached copy of the
server's advertisement.

Passive discovery clients MUST monitor such messages and remove all
advertisements for the specified server (as determined by the server
identification string) from their cache.

