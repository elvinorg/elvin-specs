m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  tcp-transport
m4_heading(3, TCP Protocol)

The default Elvin transport module uses a TCP connection to link
clients with an Elvin router.

Elvin routers offer a TCP endpoint, at a particular port.  The
IANA-assigned port number for Elvin client protocol is 2917.  Clients
initiate the TCP connection to the router's host and port.

The abstract protocol requires that packet boundaries are preserved.
Since TCP provides a stream-oriented protocol, an additional layer of
framing must be implemented to support this requirement.

Each packet, passed to the TCP module from higher layer(s) in the
stack, is sent preceded by a 4-octet framing header.  The header value
is an unsigned 2's complement integer in network byte order,
specifying the length of the contained packet in octets.

.KS
.nf
          0   1   2   3
        +---+---+---+---+---+---+---+...+---+---+---+
        |    length     |       packet data         |    FRAMED PACKET
        +---+---+---+---+---+---+---+...+---+---+---+
.fi
.KE

The receiving side of the connection should first read the header,
record the expected length, and then read until the complete packet is
received.

An implementation MAY limit the size of packets it is willing to
receive.  After reading a header preceding a packet exceeding that
length, the implementation MUST reset the TCP connection.  Note that
the use of a 4 octet header puts an upper limit on this size.  Elvin
clients SHOULD negotiate the maximum packet length during connection.

An open TCP connection may be closed only between the last byte of
packet data, and the following framing header.  If the connection is
lost mid-packet, it MUST be reported to the abstract protocol layer as
a protocol error.

m4_heading(4, Use of Proxies)

In some environments, it is necessary to use proxy services to
circumvent firewall policies that would otherwise block Elvin protocol
connections.  Lest we be misunderstood, this practice is NOT
RECOMMENDED.

Having said that, the prevalence of administrative policy requiring
such breakage is such that Elvin TCP protocol modules SHOULD support
establishment of connections via HTTP proxies, SHOULD support basic
authentication and MAY support alternative authentication mechanisms.

A proxy connection is established by connecting first to an endpoint
offered by the proxy server, and requesting that it tunnel further
data on the connection to the specified Elvin router endpoint.

This request takes the form of

   CONNECT host.example.com HTTP/1.1
   Proxy-Authorization: Basic XXXXXX

with the optional parameter lines terminated by a blank line.

The client then waits for a response from the proxy server, indicating
whether its request was successful.  The response from the proxy
server consists of CRLF-delimited lines of text, terminated by a blank
line.  Note that this text can be a substantial length.

The text is a properly formatted HTTP response, and should be parsed
according to XXX.  Common response codes are 200, 404 and 407.  As an
example,

   HTTP/1.0 200 Connection established

is a successful response.



