m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  protocol-overview

m4_heading(2, `Protocol Overview')

m4_remark(is there anythong that needs to be here anyore? j)

m4_heading(2, Protoccol Errors)

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

