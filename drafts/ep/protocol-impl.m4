m4_heading(1, PROTOCOL IMPLEMENTATION)

m4_heading(2, Layering and Modules)
m4_heading(3, Marshalling)
m4_heading(3, Security)
m4_heading(3, Transport)

m4_heading(2, Interoperability)
m4_heading(3, Server Discovery)
m4_heading(3, Protocol Selection)
m4_heading(3, Server Features)

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
