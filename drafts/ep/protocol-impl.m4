m4_heading(1, PROTOCOL IMPLEMENTATION)

The abstract protocol described in the previous section may be
implemented by multiple concrete protocols.  The concrete protocols
used to establish a connection can be specified at run time, and
selected from the intersection of those offered by the client and
server-side implementations.

m4_heading(2, Layering and Modules)

A connection supporting the Elvin protocol can be comprised of
multiple, layered components, referred to as protocol modules.  These
modules are layered to form a protocol stack, providing a connection
over which the abstract protocol packets are carried.

The combined stack must provide marshalling, security and data
transport facilities.

m4_heading(2, Standard Protocol)

overview: TCP/SSL, XDR

Elvin4 supports a 3-layer protocol stack, providing separate
marshalling, security and transport options.  While the content of the
resulting data packets composed by each of these layers is specified
by this document, the programming interfaces are internal to an
implementation.

An Elvin4 implementation MAY support any number of distinct
combinations of protocols.  An Elvin4 implementation MUST support the
standard protocol stack comprised of XDR marshalling, SSL-3 security
and TCP/IP transport.  This combination is known as the Elvin4
standard protocol.

Additional protocol layers must be proposed and registered via the
IETF RFC series, either as a revision to this document, or as a
separate specification.

m4_include(tcp-transport.m4)

m4_heading(3, Security)

null

m4_include(xdr-encoding.m4)

m4_heading(2, Environment)

.nf
ports
location
service names
environment variables
file usage
- /etc/elvind.conf
- /etc/slp.conf
registry
.fi
