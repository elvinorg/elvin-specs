.\" -*- nroff -*-
.\" ################################################################
.\" COPYRIGHT_BEGIN
.\"
.\" Copyright (C) 2000-2007 Elvin.Org
.\" All rights reserved.
.\"
.\" Redistribution and use in source and binary forms, with or without
.\" modification, are permitted provided that the following conditions
.\" are met:
.\"
.\" * Redistributions of source code must retain the above
.\"   copyright notice, this list of conditions and the following
.\"   disclaimer.
.\"
.\" * Redistributions in binary form must reproduce the above
.\"   copyright notice, this list of conditions and the following
.\"   disclaimer in the documentation and/or other materials
.\"   provided with the distribution.
.\"
.\" * Neither the name of the Elvin.Org nor the names
.\"   of its contributors may be used to endorse or promote
.\"   products derived from this software without specific prior
.\"   written permission. 
.\"
.\" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
.\" "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
.\" LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
.\" FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
.\" REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
.\" INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
.\" BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
.\" LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
.\" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
.\" LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
.\" ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
.\" POSSIBILITY OF SUCH DAMAGE.
.\"
.\" COPYRIGHT_END
.\" ################################################################
.\"
.\" General macros for I-D formatting
.\"
m4_define(__title, `Elvin Router Discovery Protocol')m4_dnl
m4_include(macros.m4)m4_dnl
.\"
.\"
.pl 11.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.nr PI 3n
.ds LF Arnold, ed.
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH __date
.ds CH __title
.hy 0
.ad l
Elvin.Org                                              D. Arnold, Editor
Preliminary INTERNET-DRAFT                                  Mantara, Inc

Expires: aa bbb cccc                                         _d __m __yr

.DS C
__title
__file
.DE
.\"
.\" Header macros close an indent, so make sure we having one open
.RS
m4_heading(1, STATUS OF THIS MEMO)

This document is an Internet-Draft and is NOT offered in accordance
with Section 10 of RFC2026, and the author does not provide the IETF
with any rights other than to publish as an Internet-Draft.

Internet-Drafts are working documents of the Internet Engineering Task
Force (IETF), its areas, and its working groups.  Note that other
groups may also distribute working documents as Internet-Drafts.

Internet-Drafts are draft documents valid for a maximum of six months
and may be updated, replaced, or obsoleted by other documents at any
time.  It is inappropriate to use Internet- Drafts as reference
material or to cite them other than as "work in progress."

The list of current Internet-Drafts can be accessed at
http://www.ietf.org/1id-abstracts.html

The list of Internet-Draft Shadow Directories can be accessed at
http://www.ietf.org/shadow.html
.\"
.\"
m4_heading(1, ABSTRACT)

This document describes a mechanism for automatic discovery of Elvin
routers by Elvin clients.

An Elvin router may be configured to accept connections from Elvin
clients using a variety of protocol stacks and points of attachment.
Each of these endpoints can be succinctly described using an Elvin URI
[EURI].

Configuring Elvin clients to connect using an appropriate URI is a
variation of a common problem.  The Elvin Router Discovery Protocol
provides a means of locating a suitable point of attachment to an
Elvin router that does not require external infrastructure support, in
contrast to alternative protocols such as SLP and DHCP.
.\"
.\"
.\" TERMINOLOGY
.\"
.\" Terminology for both Elvin and the RFC series
.\"
m4_heading(1, TERMINOLOGY)

This document discusses Elvin clients, client libraries, and routers.

An Elvin router is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin notifications. An Elvin
client is a program that uses the Elvin router, via a client library
for a particular programming language.  A client library implements
the Elvin protocol and manages clients' connections to an Elvin
router.

Further detail of these entities and their roles is provided in [EP].

Within this document, the term "router" should be interpreted to mean
an Elvin router.  Any reference to an IP router will be explicitly
identified as such.
.\"
.\"
m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in [RFC2119].
.\"
.\"
.\" INTRODUCTION
.\"
m4_heading(1, INTRODUCTION)

Elvin client programs require a connection to an Elvin router in order
to send and receive messages.  Locating a suitable Elvin router
requires some means of discovering what Elvin routers are available
and communicating this to clients as they execute.

This problem is shared by many other systems, and common mechanisms
have been implemented to resolve it in various ways suited to various
circumstances.  These methods include manual (or static)
configuration, the Service Location Protocol [RFC2608], Dynamic Host
Configuration Protocol [RFC2131] or use of a directory service, such a
LDAP [RFC2251].  Common to all these mechanisms is an external system
that provides the location mechanism, some of which also require human
intervention.

This document describes a lightweight discovery mechanism that does
not require external infrastructure, administrator privileges or
manual configuration.  It can be used independently or in conjunction
with other discovery or location services as required.

The Elvin Router Discovery Protocol (ERDP) is an extension of the base
Elvin Protocol [EP].  It is OPTIONAL for Elvin clients, and
RECOMMENDED for Elvin router implementations.

The deployment of this protocol predates the development of DNS-SD
[DNSSD], a general purpose service discovery protocol that can be
deployed in conjunction with other protocols to provide
infrastructure-less service discovery.  DNS-SD is available as Apple's
Bonjour [BONJOUR], Avahi [AVAHI] and elsewhere.  ERDP is less general
than DNS-SD, but also simpler to implement.

Interactions between ERDP and the Elvin clustering protocol are not
discussed in this specification, but are included in [ERCP].
.\"
.\"
m4_heading(1, PROTOCOL)

The basic principle of the discovery protocol is that clients solicit
advertisements from routers, and routers respond, advertising their
available endpoint URI.  The client can examine the URI as they are
discovered, discarding or selecting a particular router and point of
attachment using whatever criteria are applicable.

m4_changequote({,})m4_dnl
.KS
                             ,-->     +---------+
  +-------------+ ---SvrRqst-+-->   +---------+ |
  | Producer or |            `--> +---------+ | |
  |  Consumer   | <--.            |  Elvin  | |-+
  +-------------+ <--+-SvrAdvt--- | Routers |-+     SOLICITATION and
                  <--'            +---------+          ADVERTISEMENT
.KE
m4_changequote(`,')m4_dnl

Both the solicitation and the resulting advertisements use a multicast
transport.  The use of multicast for the advertisements allows active
clients to maintain a cache of available routers, to be used for
future connection attempts.

The protocol manipulates the scope of the multicast packets to control
the locality of solicitation and advertisement.  This enables router
and client configuration to match network topologies, and minimises
the impact of the discovery traffic.

In addition to responses to solicitations, routers advertise their
availability on startup, and whenever their offered configuration
changes.  A separate withdrawal packet is used to cancel the previous
advertisements, normally on router shutdown.

m4_changequote({,})m4_dnl
.KS
      +-------------+
    +-------------+ |                     +---------+
  +-------------+ | | <--.                |  Elvin  |
  | Producers & | |-+ <--+-SvrAdvtClose-- |  Router |
  |  Consumers  |-+   <--'                +---------+  ADVERTISEMENT
  +-------------+                                         WITHDRAWAL
.KE
m4_changequote(`,')m4_dnl
.\"
m4_heading(2, Selecting Router URI)

Client libraries can expose the advertised URI to client applications,
enabling them to select a particular endpoint on the basis of protocol
stack, endpoint address or other properties of the URI itself.

But these properties pertain only to the specific endpoint, not the
router.  Advertisement packets contain two properties of the router
itself used by the client to select a URI: a scope name and a default
flag.
.\"
m4_heading(3, Scope Names)

Scope names provide a means of selecting specifically provisioned
Elvin routers without knowledge of their location or identity.

A router MUST advertise a ``scope name''.  A scope name is a UTF-8
encoded character string.  It MUST NOT contain the Unicode colon
(U+003a). Scope names MAY be zero-length.

A client configured with an Elvin scope name MUST NOT connect to an
endpoint of a discovered router not advertising itself as a provider
of that scope.

The use of scope names retains the location transparency of dynamic
router discovery, while giving a simple means of provisioning multiple
Elvin routers or router networks, within a LAN environment.

Note that while there are no explicit semantics associated with a
scope name in the discovery protocol, the Elvin Router Clustering
Protocol requires that all routers in a cluster provide the same named
scope [ERCP].
.\"
m4_heading(3, Default Routers)

In addition to the scope name, a router MAY advertise itself as a
default router.  Clients not configured with a scope name but using
router discovery to obtain router URI, MUST ignore all advertisements
without the ``default'' flag set.

This mechanism is the simplest means for a client to find its local
router.  The expanding search will search in an increasing radius from
the client's network location, and return the discovered routers URI.
.\"
m4_heading(2, Abstract Protocol Definitions)

The discovery protocol is specified at two levels: an abstract
description, able to be implemented using different marshaling and
transport protocols, and a concrete specification of one such
implementation, defined as a standard protocol for IPv4 networks.

.KS
The abstract protocol specifies three packets used in discovery
interactions between clients and routers.

.nf 
  Packet Type                      |  Abbreviation |  Usage 
 ----------------------------------+---------------+---------
  Router Solicitation Request      |  SvrRqst      |  C -> R
  Router Advertisement             |  SvrAdvt      |  R -> C
  Router Advertisement Withdrawal  |  SvrAdvtClose |  R -> C
.fi
.KE

A concrete protocol implementation is free to use the most suitable
method for distinguishing packet types.  If a packet type number or
enumeration is used, it SHOULD reflect the above ordering.

.KS
Packets are described using a set of simple base types in a pseudo-C
style as structures composed of these types.  The following definition
is used in several packets:
m4_pre(`
typedef uint32 id32;
')m4_dnl
This type is an opaque 32-bit identifier.  No semantics is required
other than bitwise comparison.  In all cases, a value of all zero bits
is reserved.

Concrete protocol implementations are free to use any type capable of
holding the required number of bits for these values.  In particular,
the signedness of the underlying type does not matter.
.KE
m4_heading(3, Router Solicitation Request)

The client-side of the discovery protocol has two modes of operation:
passive and active.  During passive discovery, a client caches
observed router advertisements.  During active discovery, clients
explicitly solicit advertisements from routers.

Clients SHOULD implement active discovery and MAY add passive
discovery for better performance and network utilisation.

A client enters active discovery when the client application requests
solicitation of router advertisements.  A client program SHOULD NOT
commence active discovery unless it is necessary to satisfy a
connection request from the application.

During active discovery, router solicitation requests are multicast
such that all active clients and routers observe the request packet.

m4_pre(
struct SvrRqst {
  uint8  major_version;
  uint8  minor_version;
  uint8  locality;
};)m4_dnl

Both clients and routers MUST discard SvrRqst packets with
incompatible protocol version numbers.  Protocols are defined to be
compatible when the major version numbers are the same, and the
client's minor version is equal to or less than the minor version of
the SvrRqst packet.

The protocol described in this document is major version 4 and minor
version 0.

To control the propagation of SvrRqst packets, a scoping mechanism for
the underlying multicast protocol SHOULD be used.  This is expressed
as a locality attribute whose range of values are mapped onto the
underlying protocol.

SvrRqst packets MUST have an initial locality between 0 and 15, and
SHOULD default to zero.  Values used SHOULD come from the set defined
below.

To reduce packet storms when many clients simultaneously attempt to
find a router (such as when an existing router crashes, or hourly
batch jobs start), a client MUST wait before sending a SvrRqst and
only send its own request if no other requests (from other clients)
are observed during the waiting period.

For a given locality value, the waiting period before sending the
SvrAdvt MUST NOT be less than the intervals defined below, and the
random variation from the base value MUST be re-calculated every time
a SvrRqst is sent.

.KS
.nf
  Pre-Request Interval  |  Locality
  ----------------------+-----------
       0.0 seconds      |      0
       0.2 +/- 0.1      |      1
       1.0 +/- 0.5      |      2
       1.0 +/- 0.5      |      4
       1.0 +/- 0.5      |      8
       2.0 +/- 1.0      |     16
       2.0 +/- 1.0      |     32
       4.0 +/- 2.0      |     64
.fi
.KE

If a version-compatible SvrRqst from another client with equal or
greater locality than that to be used for the next SvrRqst is observed
during the pre-request interval, sending of the SvrRqst MUST be
suppressed.

If the client receives one or more version-compatible advertisement
(SvrAdvt) packets during the pre-request interval, the SvrRqst MUST be
postponed until the client application requests that further
advertisements be solicited (for example, because it cannot connect to
the router endpoints discovered so far).

If no requests for further solicitation have been received for a
period of five minutes after sending the last SvrRqst, discovery MUST
revert to passive mode, and the locality and pre-request intervals are
reset to their starting values.

Note that a SvrRqst from a downstream client can cause the suppression
of a client's own SvrRqst with the same locality value, even though
the downstream SvrRqst's locality is exhausted, thus preventing the
client's SvrRqst from reaching an upstream router that is within the
range of its locality value.

However, either of the two clients' next SvrRqst (with higher locality
value) will reach the router, and while the immediate client loses one
interval period, it has no permanent impact.  

This could be avoided by allowing the client to compare the packet's
locality value with the current concrete protocol equivalent, but this
facility is not widely support by available multicast protocols.  For
example, in IPv4, the locality value maps to the IP TTL field, but the
ability to examine the TTL of a received UDP packet is not supported
by the IPv4 socket API.

m4_heading(2, Router Advertisements)

A router advertisement packet SHOULD be sent when the router is
started, and MUST be sent in response to version-compatible SvrRqst
packets received from clients, except, that it MUST NOT be sent more
often than once every one second.

m4_pre(
struct SvrAdvt {
  uint8    major_version;
  uint8    minor_version;
  boolean  default_flag;
  id32     revision;
  string   scope_name;
  string   server_name;
  string   uri[];
};)m4_pre

Router advertisement packets specify the version of the discovery
protocol which defines their format.  A SvrAdvt sent in response to a
SvrRqst MUST use a compatible protocol version.  Where a router is
capable of using multiple Elvin protocol versions, this can be
reflected in the endpoint URI.  Clients and routers MUST discard
SvrAdvt packets with incompatible protocol versions.

The advertising router is identified by a Unicode string name.
Routers MUST ensure this name is universally unique over time.  It is
RECOMMENDED that the combination of the Elvin router's process
identifier, fully-qualified domain name and starting timestamp are
used.  The bitwise value of a router's name MUST NOT change during its
execution.

Clients identify subsequent advertisements from the same router using
the value of this string.  Although the value is Unicode text, the
comparison MAY use bitwise identity.  After the first observed SvrAdvt
from a router, additional advertisements SHOULD be discarded unless
the revision number has changed.

The revision number distinguishes advertisements from the same router,
reflecting changes in the available protocols.  If an endpoint is
withdrawn, the router's supported scope name or the value of the
default flag is altered, the revision number SHOULD be increased to
flush client's caches.

A router MAY add additional URI or change the order of URI supplied in
the advertisement without modifying the revision number as a means of
influencing the endpoints selected by connecting clients.

The scope name is the UTF-8 encoded scope name for the router.  The
scope name MAY be empty (zero length).

The set of URI reflect the endpoints available from the router.  A
SvrAdvt message SHOULD incl`'ude all endpoints offered by the router.
Where the limitations of the underlying concrete protocol prevent
this, the router cannot advertise all its endpoints.  Each SvrAdvt
MUST contain at least one URI.

Note that the URI included in a SvrAdvt MAY specify multiple protocol
versions if the advertising router is capable of supporting this.  The
version information in the SvrAdvt body does not imply that the router
necessarily supports that protocol version alone, or indeed at all.

The transmission of the initial SvrAdvt packet MUST use an equivalent
locality limit not exceeding 64 (one quarter of the available range).
SvrAdvt packets sent in response to a SvrRqst MUST set the
protocol-specific locality limit to that specified in the received
SvrRqst.  A router MUST remember the highest locality value it has
sent for use when withdrawing its advertisement.
 
m4_heading(3, Router Advertisement Withdrawal)

A router shutting down SHOULD send a Router Advertisement Withdrawal
message.

struct SvrAdvtClose {
  uint8    major_version;
  uint8    minor_version;
  string   server;
}

Clients and routers MUST ignore SvrAdvtClose packets with incompatible
protocol version numbers.  Clients using active discovery only (ie. no
caching of router advertisements) SHOULD ignore all SvrAdvtClose
packets.

Clients using passive discovery MUST monitor such messages and remove
all advertised URI for the specified router (as determined by the
router identification string) from their cache.

Routers that have sent SvrAdvt messages using multiple protocol
versions SHOULD send a SvrAdvtClose in each of those protocol
versions.

The protocol-specific locality limit of the SvrAdvtClose packet MUST
be set to the highest value sent in a SvrAdvt during the lifetime of
the router process.  This ensures that the withdrawal notice reaches
all passive discovery clients that might have a cached copy of the
router's advertisement.
.\"
.\"  UDP/XDR implementation
.\"
m4_heading(1, PROTOCOL IMPLEMENTATION)

The router discovery protocol can be implemented using different
lower-layer protocols.  These concrete protocol implementations map
the abstract specification from the preceding section onto the
facility of a network layer protocol.

Currently, mappings are defined for IPv4 and IPv6 protocols. 

m4_heading(2, Use of IPv4)

The implementation of ERDP on IPv4 uses IP any-source multicast as the
basic transport, and the XDR marshaling protocol for packet data.

m4_heading(3, Multicast Transport)

Clients and routers MUST use the EDRP IP address and port for all of
the discovery packets.  The IPv4 multicast address is 224.4.0.1 and
the Elvin client port number 2917.

Packets MUST be sent using a direct mapping of the locality value, to
the IPv4 TTL field.

m4_heading(3, Marshalling)

The Elvin client protocol uses XDR [RFC1832] to encode data.  All
messages sent between the a client and and Elvin router are encoded as
a sequence of encoded XDR types.  The ERDP IPv4 concrete protocol
follows this lead.

This section uses diagrams to illustrate clearly certain segment and
packet layouts.  In most illustrations, each box (delimited by a plus
sign at the 4 corners and vertical bars and dashes) depicts a 4 byte
block as XDR is 4 byte aligned.  Ellipses (...) between boxes show
zero or more additional bytes where required. Some packet diagrams
extend over multiple lines.  In these cases, '>>>>' at the end of the
line indicates continuation to the next line and '<<<<' at the
beginning of a line indicates a segment has some preceding blocks on
the previous line.  Numbers used along the top line of packet diagrams
indicate byte lengths.

.nf
        +---------+---------+---------+...+---------+
        | block 0 | block 1 | block 2 |...|block n-1|   PACKET
        +---------+---------+---------+...+---------+
.fi

m4_heading(4, Packet Identification)

The abstract packet descriptions deliberately leave the method for
identifying packets to the concrete encoding.  For XDR, each packet is
identified by the pkt_id enumeration below:

m4_pre(
`enum {
    SvrRqst        = 16,
    SvrAdvt        = 17,
    SvrAdvtClose   = 18,
} pkt_id;')

In XDR, enumerations are marshaled as 32 bit integral values.  Each
packet starts with a value from the above pkt_id enumeration.  The
format for the remainder of the packet is then specific to the value
of the packet identifier.

       0   1   2   3    
     +---+---+---+---+---+---+---+...+---+---+---+
     |     pkt_id    |         remainder         |    ENCODED PACKET
     +---+---+---+---+---+---+---+...+---+---+---+
     |<---header---->|<-----------data---------->|

Note that the XDR marshaling layer does not provide packet
framing. This is left to the underlying UDP layer.

m4_heading(4, Base Types)

The protocol relies on four basic types used to construct each packet:
boolean, uint8, id32, string.

Below is a summary of how these types are represented when using XDR
encoding.  Each data type used in the abstract descriptions of the
packets has a one-to-one mapping to a corresponding XDR data type as
defined in [RFC1832].
.KS
.nf
  -------------------------------------------------------------------
  Elvin Type  XDR Type       Encoding Summary
  -------------------------------------------------------------------
  boolean     bool           4 bytes, last byte is 0 or 1

  uint8       unsigned int   4 bytes, last byte has value

  id32        int            4 bytes, MSB first

  string      string         4 byte length, UTF-8 encoded string, zero 
                             padded to next four byte boundary
  -------------------------------------------------------------------
.fi
.KE
m4_heading(2, Use of IPv6)

m4_remark(The protocol mapping to IPv6 is incomplete)

For IPv6 multicast, the client MUST use the following table to
translate locality values to multicast scopes.

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

m4_heading(1, SECURITY CONSIDERATIONS)

There are several possible attacks against the abstract discovery
protocol.  Additional weaknesses might be introduced by a concrete
protocol implementation.

m4_heading(2, Attacks)

This section discusses attacks against the abstract protocol which
will transcend concrete implementations.

m4_heading(3, Router Advertisement Solicitation)

An attacker could send a constant stream of SvrRqst packets to an ERDP
multicast group.  Aside from the loss of network bandwidth and
consumption of CPU in processing these requests, the protocol requires
that routers advertise no more often than once every two seconds,
preventing a packet storm.

Additionally, the SvrRqst packet could be initialised with a high
locality value, forcing router responses to be broadly distributed.

m4_heading(3, Router Advertisement)

This protocol provides no means of authenticating packets.  Thus, it
is a simple matter for an attacker to forge Elvin router
advertisements, and ``steal'' clients, directing them to an imposter
router.

More subtly, an attacker could alter the URI list in the
advertisement, and/or increase the revision number to force improper
URI into passive discovery client caches.

Clients SHOULD authenticate the router's identity on connection,
leaving this avenue only as a denial of service attack.

m4_heading(3, Router Advertisement Withdrawal)

Again, since packets are not authenticated, an attacker could send
fake withdrawal packets for a router, causing a denial of service for
its clients.  The effect would be limited to delaying reconnection to
a router, because the client's solicitation would generate a new
advertisement from the router.

m4_heading(2, Preventative Measures)

The are no novel preventative measures effective against these
attacks.  Most measures will rely on the underlying concrete protocol
implementation, but as an example, IP firewalling technology will
reduce the ability of an attacker to inject the false packets required
for the above attacks.


m4_heading(1, IANA CONSIDERATIONS)

The abstract protocol requires no support from the IANA registry.

The IPv4 concrete protocol currently uses an unofficial IP multicast
address.  An official address allocation is being pursued.  The UDP
port number used is officially allocated for Elvin by the IANA.

.bp
m4_heading(1, REFERENCES)

.IP [AVAHI] 12
m4_remark(needs reference)

.IP [BONJOUR] 12
m4_remark(needs reference)

.IP [DNSSD] 12
S. Cheshire, M. Krochmal,
"DNS-Based Service Discovery",
Internet Draft, draft-cheshire-dnsext-dns-sd-04.txt,
Work in progress

.IP [EP] 12
D. Arnold, editor,
"Elvin Client Protocol 4.0",
Work in progress

.IP [ERCP] 12
D. Arnold, J. Boot, T. Phelps,
"Elvin Router Clustering Protocol",
Work in progress

.IP [EURI] 12
D. Arnold, J. Boot, T. Phelps, B. Segall,
"Elvin URI Scheme",
Work in progress

.IP [RFC1832] 12
R. Srinivasan,
"XDR: External Data Representation Standard",
RFC 1832, August 1995.

.IP [RFC2119] 12
S. Bradner,
"Key words for use in RFCs to Indicate Requirement Levels"
RFC2119, March 1997

.IP [RFC2131] 12
R. Droms,
"Dynamic Host Configuration Protocol",
RFC 2131, March 1997.

.IP [RFC2234] 12
D. Crocker, P. Overell,
"Augmented BNF for Syntax Specifications: ABNF", 
RFC 2234, November 1997.

.IP [RFC2251] 12
M. Wahl, T. Howes, S. Kille,
"Lightweight Directory Access Protocol (v3)",
RFC 2251, December 1997

.IP [RFC2279] 12
F. Yergeau,
"UTF-8, a transformation format of ISO 10646",
RFC 2279, January 1998.

.IP [RFC2608] 12
E. Guttmann, C.Perkins, J. Veizades, M. Day,
"Service Location Protocol, Version 2",
RFC2608, June 1999.

.IP [UNICODE] 12
Unicode Consortium, The,
"The Unicode Standard, Version 2.0",
Addison-Wesley, February 1997.

.IP [POSIX.1] 12
IEEE,
"POSIX.1-1990",
1990.

.KS
m4_heading(1, CONTACT)

Author's Addresses

.nf
David Arnold
Julian Boot
Ian Lister
Ted Phelps
Bill Segall

Email: specs@elvin.org
.fi
.KE

.KS
m4_heading(1, FULL COPYRIGHT STATEMENT)

Copyright (C) 2000-__yr Elvin.Org
All Rights Reserved.

This specification may be reproduced or transmitted in any form or by
any means, electronic or mechanical, including photocopying,
recording, or by any information storage or retrieval system,
providing that the content remains unaltered, and that such
distribution is under the terms of this licence.

While every precaution has been taken in the preparation of this
specification, Elvin.Org assumes no responsibility for errors or
omissions, or for damages resulting from the use of the information
herein.

Elvin.Org welcomes comments on this specification.  Please address
any queries, comments or fixes (please include the name and version of
the specification) to the address below:

.nf
    Email: specs@elvin.org
.fi
.KE
.\"
.\" ########################################################################
