m4_heading(1, `URL Scheme Name')

The scheme name is: elvin

m4_heading(1, Syntax)

elvin:/<protocol>/<endpoint>;<option>;<option=value>

m4_heading(2, `TCP Endpoint Syntax')

<hostname|IPv4-addr|IPv6-addr>[:port]

m4_heading(2, `UDP Endpoint Syntax')

<hostname|IPv4-addr|IPv6-addr>[:port]

m4_heading(2, `HTTP Endpoint Syntax')

[username[:password]@]<hostname|IPv4-addr|IPv6-addr>[:port]

m4_heading(2, `Unix Endpoint Syntax')

<hostname|IPv4-addr|IPv6-addr>/path[/path]*

m4_heading(1, `Character Encoding Considerations')

Elvin URLs normally contain only those characters present in the DNS
names of the hosting servers.  However, it is possible that the URL
options, or a yet to be defined endpoint syntax, could require
non-ASCII characters.  In such cases, characters should be encoded as
UTF-8, and represented using the normal URL encoding %xx.

m4_heading(1, `Intended Usage')

Elvin URLs are normally used in two ways: for specification of an
Elvin server in a client application by a human user, and, in
advertisements of server endpoints emitted by an Elvin server.

m4_heading(1, `Applications and/or Protocols Using the Scheme')

The scheme is used by the Elvin access protocol.

m4_heading(1, `Interoperability Considerations')

hmmmm.

m4_heading(1, `Security Considerations')

????

m4_heading(1, `IANA Considerations')

Are discussed in the Elvin Client Protocol.

m4_heading(1, `Relevant Publications')

m4_heading(1, `Contact for further information')

m4_heading(1, `Author/Change controller')
