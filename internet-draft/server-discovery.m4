m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  server-discovery

m4_heading(2, Server Discovery)

Server discovery SHOULD be implemented by client libraries.  In
addition, a client library MAY implement a cache of discovered server
addresses.

Clients multicast a request for server URLs; servers respond with a
list of URLs describing their available endpoints.  Multicast is not
available for all physical network types, however broadcast MAY be
used where multicast is unavailable.

This specification describes an abstract discovery protocol, and a
concrete implementation for IP-based networks (section x.x)

A client MAY request that servers advertise their available endpoints
prior to establishing a connection, by multicasting a Server Request.
Attempts to send a SvrRqst MUST be delayed by a random time of between
zero (0) and five (5) seconds after process startup.  If any SrvRqst
packets (from other clients) are observed during this time, the client
MUST cancel its own pending request.

If a client observes any Server Advertisments during the startup
period, it SHOULD attempt to connect to them immediately.

A SvrRqst MUST NOT be sent more than once in any twenty (20) second
period.

m4_pre(
struct SvrRqst {
  uint8      major;      /* requested server major version */
  uint8      minor;      /* minimum server minor version */
};)m4_dnl

Servers MUST respond to a SvrRqst with a multicast Server
Advertisement.  

m4_pre(
struct SvrAdvt {
  uint8    major;        /* major version for *this packet* */
  uint8    minor;        /* minor version for *this packet* */
  string   server;       /* unique name for server */
  string   urls[];       /* set of URLs for server (with properties) */
};)m4_dnl

The returned major and minor version numbers MUST reflect the protocol
version of the reply packet.  Where a server is capable of using
multiple protocol versions, this MUST be reflected in the endpoint
URLs, and the SvrAdvt message MUST use the client's protocol version.

The SvrAdvt includes a server name that MUST be globally unique.  It
is suggested the fully-qualified DNS host name, server process number
and current time-of-day be used.

The set of URLs reflect the endpoints available from the server.  A
SvrAdvt message SHOULD include all endpoints offered by the server.
Where the limitations of the underlying concrete protocol prevent
this, the server cannot advertise all its endpoints.  Each SvrAdvt
MUST contain at least one URL.

A server MUST NOT send SvrAdvt more often than once every five (5)
seconds.

Clients MAY maintain a cached list of all endpoint URLs it has seen
announced.  If available, this list MUST be used to attempt connection
before sending a SvrRqst.  Cached URLs MUST be replaced by a
subsequent message from the same server.  Cached URLs for a server not
replaced after eight (8) observed SvrRqst/SvrAdvt cycles SHOULD be
removed.

A server shutting down SHOULD send a Server Advertisement Close
message.

m4_pre(
struct SvrAdvtClose {
  string   server;       /* unique name for server */
};)m4_dnl

Caching clients MUST monitor such messages and remove all endpoints for
the specified server from their cache.
