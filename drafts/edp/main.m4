m4_dnl ########################################################################
m4_dnl
m4_dnl              Elvin Router Disoovery Protocol
m4_dnl
m4_dnl File:        $Source: /Users/d/work/elvin/CVS/elvin-specs/drafts/edp/main.m4,v $
m4_dnl Version:     $RCSfile: main.m4,v $ $Revision: 1.3 $
m4_dnl Copyright:   (C) 2000-2001, DSTC Pty Ltd.
m4_dnl
m4_dnl This specification may be reproduced or transmitted in any form or by
m4_dnl any means, electronic or mechanical, including photocopying,
m4_dnl recording, or by any information storage or retrieval system,
m4_dnl providing that the content remains unaltered, and that such
m4_dnl distribution is under the terms of this licence.
m4_dnl 
m4_dnl While every precaution has been taken in the preparation of this
m4_dnl specification, DSTC Pty Ltd assumes no responsibility for errors or
m4_dnl omissions, or for damages resulting from the use of the information
m4_dnl herein.
m4_dnl 
m4_dnl DSTC Pty Ltd welcomes comments on this specification.  Please address
m4_dnl any queries, comments or fixes (please include the name and version of
m4_dnl the specification) to the address below:
m4_dnl 
m4_dnl     DSTC Pty Ltd
m4_dnl     Level 7, General Purpose South
m4_dnl     University of Queensland
m4_dnl     St Lucia, 4072
m4_dnl     Tel: +61 7 3365 4310
m4_dnl     Fax: +61 7 3365 4311
m4_dnl     Email: elvin@dstc.com
m4_dnl 
m4_dnl Elvin is a trademark of DSTC Pty Ltd.  All other trademarks and
m4_dnl registered marks belong to their respective owners.
m4_dnl ########################################################################*
m4_dnl
m4_dnl    internal section references
m4_dnl
m4_dnl
m4_dnl    general macros for I-D formatting
m4_dnl
m4_include(macros.m4)m4_dnl
m4_dnl
m4_dnl
.\" page length 10 inches
.pl 10.0i
.\" page offset 0 lines
.po 0
.\" line length (inches)
.ll 7.2i
.\" title length (inches)
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Arnold, et al
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH dd mmm yyyy
.ds CH Elvin Router Discovery Protocol
.\" hyphenation mode 0
.hy 0
.\" adjust left
.ad l
.\" indent 0
.in 0
Elvin Project                                                  D. Arnold
Preliminary INTERNET-DRAFT                                       J. Boot
                                                               T. Phelps
Expires: aa bbb cccc                                           B. Segall
                                                                    DSTC
                                                             dd mmm yyyy

.ce
Elvin Router Discovery Protocol
.ce
draft-arnold-elvin-discovery-prelim-00.txt

m4_heading(1, Status of this Memo)

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
m4_dnl
m4_dnl
m4_heading(1, Abstract)

This document describes a mechanism for automatic discovery of Elvin
routers by Elvin clients.

An Elvin router may be configured to accept connections from Elvin
clients using a variety of protocol stacks and points of attachment.
Each of these endpoints can be succinctly described using an Elvin URI
[EURI].

Configuring Elvin clients to connect using an appropriate URL is a
variation of a common problem.  The Elvin Router Discovery Protocol
provides a means of locating a suitable point of attachment to an
Elvin router that does not require external infrastructure support, in
contrast to alternative protocols such as SLP and DHCP.
m4_dnl
m4_dnl
m4_heading(1, Terminology)

This document discusses Elvin clients, client libraries, and routers.

An Elvin router (or server) is a daemon process that runs on a single
machine.  It acts as a distribution mechanism for Elvin messages. A
client is a program that uses the Elvin router, via a client library
for a particular programming language.  A client library implements
the Elvin protocol and manages clients' connections to an Elvin
router.

Further detail of these entities and their roles is provided in [EP].
m4_dnl
m4_dnl
m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in [RFC2119].
m4_dnl
m4_dnl
m4_heading(1, Introduction)

Elvin client programs require a connection to an Elvin router in order
to send and receive messages.  Locating a suitable router requires
some means of discovering what routers are available and communicating
this to clients as they execute.

This problem is shared by many other systems, and common mechanisms
have been implemented to resolve it in various ways suited to various
circumstances.  These methods include manual (or static)
configuration, the Service Location Protocol [RFC2608], Dynamic Host
Configuration Protocol [RFCxxxx] or use of a directory service, such a
LDAP [RFCxxxx].  Common to all these mechanisms is an external system
that provides the location mechanism, some of which also require human
intervention.

This document describes a lightweight discovery mechanism that does
not require external infrastructure or configuration.  It can be used
independently or in conjunction with other discovery or location
services as required.

The Elvin Router Discovery Protocol (ERDP) is an extension of the base
Elvin Protocol.  It is OPTIONAL for Elvin clients, and RECOMMENDED for
Elvin router implementations.

Interactions between ERDP and the Elvin clustering protocol are not
discussed in this specification, but are included in [ERCP].
m4_dnl
m4_dnl
m4_heading(1, Protocol Description)

ERDP uses multicast (or if multicast is not available, link-local
broadcast) to allow Elvin clients to solicit advertisements of
available endpoints from Elvin routers.  It controls the scope of the
multicast to implement an expanding search, looking progressively
further away (in network terms) for a suitable router.

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

Routers advertise their available endpoints and service properties
using the same multicast scope and address.  

m4_changequote({,})m4_dnl
.KS
      +-------------+
    +-------------+ |                     +---------+
  +-------------+ | | <--.                |  Elvin  |
  | Producers & | |-+ <--+-SvrAdvtClose-- |  Router |
  |  Consumers  |-+   <--'                +---------+  ADVERTISEMENT
  +-------------+                                         WITHDRAWAL
.KE
m4_changequote(`,')

The progressive expansion of the multicast request scope, careful use
of timeouts, and advertisement caching minimise the client traffic
used to locate routers.
m4_dnl
m4_dnl
m4_heading(2, Abstract Protocol Definitions)

ERDP is specified at two levels: an abstract description, able to be
implemented using different marshalling and transport protocols, and a
concrete specification of one such implementation, defined as a
standard protocol for IPv4 networks.

This section provides detailed descriptions of each packet used in the
Elvin protocol. Packets are comprised from a set of simple base types
and described in a pseudo-C style as structs made up of these types.

.KS
The following definition is used in several packets:
m4_pre(`
typedef uint32 id32;
')m4_dnl
This type is opaque 32-bit identifier.  No semantics is required other
than bitwise comparison.  In all cases, a value of all zero bits is
reserved.

Concrete protocol implementations are free to use any type capable of
holding the required number of bits for these values.  In particular,
the signedness of the underlying type does not matter.

m4_dnl
m4_dnl
m4_dnl
m4_dnl

.KE
m4_heading(2, Router Requests)

The client-side of the discovery protocol has two modes of operation:
passive and active.  During passive discovery, a client caches router
advertisements observed on the multicast channel(s).  During active
discovery, clients solict advertisements from routers.

Clients SHOULD implement active discovery and MAY add passive
discovery for better performance and network utilisation.

A client enters active discovery when the client application requests
solicitation of router advertisements.  A client program SHOULD NOT
commence active discovery unless it is necessary to satisfy a
connection request from the application.

m4_pre(
struct SvrRqst {
  uint8  major;
  uint8  minor;
  uint8  hop_limit;
};)m4_dnl

Clients and routers MUST discard SvrRqst packets with incompatible
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
find a router (such as when an existing router crashes, or hourly
batch jobs start), a client MUST wait before sending a SvrRqst and
only send its own request if no others (from other clients) are
observed during the waiting period.  

For a given hop limit, the waiting period before sending the SvrAdvt
MUST NOT be less than the intervals defined below, and the random
variation from the base value MUST be re-calculated every time a
SvrRqst is sent.

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
solicited (for example, because it cannot connect to the router
endpoints so far discovered).

If no requests for further solicitation have been received for a
period five minutes after sending the last SvrRqst, discovery MUST
revert to passive mode, and the hop limit and pre-request intervals
are reset to their starting values.

Note that a SvrRqst from a downstream client can cause the suppression
of a client's own SvrRqst with the same hop limit, even though the
downstream SvrRqst's hop limit is exhausted, thus preventing the
client's SvrRqst from reaching an upstream router that is within that
scope.  However, either of the two client's next SvrRqst (with higher
hop limit) will reach the router, and while the immediate client loses
one interval period, it has no permanent impact.  This could be
avoided by allowing the client to compare the hop limit with the
current hop count in the packet, but this is even more
protocol-specific, and not supported by the IPv4 socket API.

m4_heading(2, Advertisements)

A Server Advertisement packet SHOULD be sent when the router is
started, and MUST be sent response to SvrRqst packets received from
clients, but MUST NOT be sent more often than once every two seconds.

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
MUST use a compatible protocol version.  Where a router is capable of
using multiple protocol versions, this can be reflected in the
endpoint URLs.  Clients and routers MUST discard SvrAdvt packets with
incompatible protocol versions.

The advertising router is identified by a Unicode string name.
Routers MUST ensure this name is universally unique over time.  It is
RECOMMENDED that the combination of the Elvin router's process
identifier, fully-qualified domain name and starting timestamp are
used.

Clients identify subsequent advertisements from the same router using
the value of this string.  Although the value is Unicode text, the
comparison MUST use bitwise identity.  After the first observed
SvrAdvt from a router, additional advertisements SHOULD be discarded
unless the revision number has changed.

The revision number distinguishes advertisements from the same router,
reflecting changes in the available protocols.  A router MAY change
the URLs supplied in the advertisement without modifying the revision
number as a means of influencing the endpoints used by connecting
clients.  However, if an endpoint is withdrawn, the router's supported
scope name or the value of is_default is altered, the revision number
SHOULD be increased to flush client's caches.

The scope name is the string scope name for the router.  An empty
(zero length) scope name is allowed.  If this scope has been
configured to be the default scope for a site, the default flag should
be set true.

The set of URLs reflect the endpoints available from the router.  A
SvrAdvt message SHOULD include all endpoints offered by the router.
Where the limitations of the underlying concrete protocol prevent
this, the router cannot advertise all its endpoints.  Each SvrAdvt
MUST contain at least one URL.

Note that the URLs included in a SvrAdvt MAY specify multiple protocol
versions if the advertising router is capable of supporting this.  The
version information in the SvrAdvt body does not imply that the router
necessarily supports that protocol version alone, or indeed at all.

The protocol-specific scope limit of the initial SvrAdvt packet SHOULD
be configured in the router configuration parameters and MUST NOT
exceed 64.  SvrAdvt packets sent in response to a SvrRqst MUST set the
protocol-specific scope limit to the hop limit in the received
SvrRqst.  A router MUST remember the highest hop limit value it has
sent for use when withdrawing its advertisement.
 
m4_heading(3, Server Advertisement Close)

A router shutting down SHOULD send a Server Advertisement Close
message.

struct SvrAdvtClose {
  uint8    major;
  uint8    minor;
  string   server;
}

Clients and routers MUST discard SvrAdvtClose packets with
incompatible protocol version numbers.  Routers that have sent SvrAdvt
messages using multiple protocol versions SHOULD send a SvrAdvtClose
in each of those protocol versions.

The protocol-specific scope limit of the SvrAdvtClose packet MUST be
set to the highest value sent in a SvrAdvt during the lifetime of the
router process.  This ensures that the withdrawal notice reaches all
passive discovery clients that might have a cached copy of the
router's advertisement.

Passive discovery clients MUST monitor such messages and remove all
advertisements for the specified router (as determined by the router
identification string) from their cache.








.KS
m4_heading(2, Packet Types)

The Elvin abstract protocol specifies a number of packets used in
interactions between clients and the router.

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

















m4_dnl
m4_dnl  UDP/XDR implementation
m4_dnl

m4_heading(1, Protocol Implementation)

m4_heading(2, Use of IPv4)

m4_heading(3, Marshalling)

The standard Elvin 4 marshalling uses XDR [RFC1832] to encode data.
Messages sent between the a client and and Elvin router are encoded as
a sequence of encoded XDR types.

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

In XDR, enumerations are marshalled as 32 bit integral values.  For
Elvin, each packet marshalled using XDR starts with a value from
the above pkt_id enumeration.  The format for the remainder of the
packet is then specific to the value of the packet identifer.

       0   1   2   3    
     +---+---+---+---+---+---+---+...+---+---+---+
     |     pkt_id    |         remainder         |    ENCODED PACKET
     +---+---+---+---+---+---+---+...+---+---+---+
     |<---header---->|<-----------data---------->|

Note that the XDR marshalling layer does NOT indicate the length of the
packet.  This is left to the underlying transport layer being used. For
example, a UDP transport could use the fact that a datagram contains the
length of data in the packet.

m4_heading(4, Base Types)

The Elvin protocol relies on seven basic types used to construct each
packet: boolean, uint8, int32, int64, real64, string, byte[].

Below is a summary of how these types are represented when using XDR
encoding.Each datatype used in the abstract descriptions of the
packets has a one-to-one mapping to a corresponsing XDR data type as
defined in [RFC1832].

.KS
.nf
  -------------------------------------------------------------------
  Elvin Type  XDR Type       Encoding Summary
  -------------------------------------------------------------------
  boolean     bool           4 bytes, last byte is 0 or 1

  uint8       unsigned int   4 bytes, last byte has value

  int32       int            4 bytes, MSB first

  int64       hyper          8 bytes, MSB first

  real64      double         64-bit double precision float

  string      string         4 byte length, UTF8 encoded string, zero 
                             padded to next four byte boundary

  byte[]      variable-      4 byte length, data, zero padded to next
              length opaque  four byte boundary
  -------------------------------------------------------------------
.fi
.KE

When the type of following data needs to be described in a packet (eg,
the value in a name-value pair used in NotifyEmit packets), one of the
base type ID's is encoded as an XDR enumeration.  This is often needed
when a value in a packet is one of a number of possible types.  In these
cases, the encoded value is preceded a type code from the following
enumeration:

m4_pre(
`enum {
    int32_tc  = 1,
    int64_tc  = 2,
    real64_tc = 3,
    string_tc = 4,
    opaque_tc = 5
} value_typecode;')

Note that the above enumeration does not include all of the datatypes
used in the protocol.  It only describes data which can be contained
in the abstract Value segment of a packet.  A Value in an encoded
packet is thus typed by prepending four bytes which encode the type
code:
    
.KS
.nf
       0  1  2  3 
     +--+--+--+--+--+--+--+--+...+--+--+--+--+
     | typecode  |          value            |        TYPED VALUE
     +--+--+--+--+--+--+--+--+...+--+--+--+--+
     |<--enum--->|<--format depends on enum-->
.fi
.KE

For illustration, if an int64 of value 1024L is preceded by its type
for marshalling, it would be sent as four bytes for the type id of 1
and eight bytes for the value.

.KS
.nf
       0  1  2  3  4  5  6  7  8  9 10 11  
     +--+--+--+--+--+--+--+--+--+--+--+--+
     |    0x02   |        0x0400         |           INT64 EXAMPLE
     +--+--+--+--+--+--+--+--+--+----+---+
     |<--enum--->|<--------hyper-------->|
.fi
.KE

m4_heading(4, Encoding Arrays)

All arrays in the abstract protocol are of variable length.  Arrays of
objects are encoded by prepending the length of the array as an int32
- the items are in the array are then each encoded in sequence
starting at item 0.  The 32bit length places a theoretical limit of
(2**32) - 1 items per list.  In practice, implementations are expected
to have much lower maximums for the number of items in a list
transmitted per packet.  For example, an implemenation may restrict
the number of fields in a notification to 1024.  Such limitations
SHOULD be documented for each implemenation.  Service offers and
connection replys SHOULD also provide such limitations.  See the
section X on Connection Establishment.

.KS
.nf
       0  1  2  3  
     +--+--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+--+
     |     n     |  item 0   |  item 1   |...| item n-1  |  ARRAY
     +--+--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+--+
     |<--int32-->|<----------------n items-------------->|
                                                          
.fi
.KE

For illustration, *** FIXME *** ....

.KS
.nf
      0           4           8          12
     +--+--+--+--+--+--+--+--+--+--+--+--+
     |    0x01   |        0x400          |           ARRAY EXAMPLE
     +--+--+--+--+--+--+--+--+--+----+---+
     |<--enum--->|<--------hyper-------->|
.fi
.KE
m4_heading(4, Packet Encoding Example)

An Elvin notification is a list of name-value pairs, where
the value is one of the five base types of int32, int64, real64,
string and opaque.  The encoding of these pairs must also include
the data type for the value.  For both the Notif and the NotifDel
packets, we introduce a name-type-value (NTV) block used to encode
a notification attribute.

The name of an attribute is always encoded as an XDR string. The type
is an enumeration of five different values indicating one of int32,
int64, real64, string or opaque (byte array).  The value, encoded as a
standard XDR type, is determined by the preceding type.

On the wire, a name-value is laid out as follows:

.KS
.nf
  +------+...+------+------+------+...+------+
  |      name       | type |      value      |       NAME-TYPE-VALUE
  +------+...+------+------+------+...+------+

   name      (string)  name of this attribute
   type      (enum)    type of the encoded value. 0ne of int32, int64,
                       real64, string or opaque
   value     -         the encoded value for this attribute.
.fi
.KE

Notifications begin with the number of attributes as an
int32.  

.KS
.nf
  0      4      8     12      ...
 +------+------+------+------+...+------+...+------+...+------+
 |pkt id| xid  |len n |       ntv 0     |   |      ntv n-1    | >>>>
 +------+------+------+------+...+------+...+------+...+------+
                      |<----------n name-type-values--------->|

           +------+------+...+------+...+------+...+------+
      <<<< |len m |      key 0      |   |     key m-1     |
           +------+------+...+------+...+------+...+------+
                  |<----------------m keys--------------->|
                                                        NOTIFICATION
.fi
.KE
.KS
   pkt id        (enum)   packet type for Notif
   xid           (uint32) transaction number for this packet
   len n         (int32)  number of name-type-value triples in the 
                          notification. n MUST be greater than zero.
   ntv x         [block]  encoded as a name-type-value triple, 
                          described above. There MUST be n 
                          name-type-value blocks where n > 0.
   len m         (int32)  number of security keys in the notification
   key x         (opaque) uninterpreted bytes of a security key. There
                          MUST be m keys where m >= 0.
.fi
.KE

m4_heading(3, Framing)

m4_heading(2, Use of IPv6)

m4_heading(1, Security Considerations)

m4_heading(1, IANA Considerations)

protocol module names

key mechanism identifiers

m4_dnl  bibliography
m4_dnl
m4_dnl  -*-nroff-mode-*-
m4_dnl
.bp
m4_heading(1, References)

.IP [RFC1832] 12
Srinivasan, R.,
"XDR: External Data Representation Standard",
RFC 1832, August 1995.

.IP [RFC2234] 12
Crocker, D., Overell, P., 
"Augmented BNF for Syntax Specifications: ABNF", 
RFC 2234, November 1997.

.IP [RFC2279] 12
Yergeau, F.,
"UTF-8, a transformation format of ISO 10646",
RFC 2279, January 1998.

.IP [UNICODE] 12
Unicode Consortium, The,
"The Unicode Standard, Version 2.0",
Addison-Wesley, February 1997.

.IP [POSIX.1] 12
IEEE,
"POSIX.1-1990",
1990.

.KS
m4_heading(1, Contact)

Author's Address

.nf
David Arnold
Julian Boot
Ted Phelps
Bill Segall

Distributed Systems Technology Centre
Level7, General Purpose South
Staff House Road
University of Queensland
St Lucia QLD 4072
Australia

Phone:  +617 3365 4310
Fax:    +617 3365 4311
Email:  elvin@dstc.com
.fi
.KE

.KS
m4_heading(1, Full Copyright Statement)

Copyright (C) 2000-yyyy DSTC Pty Ltd, Brisbane, Australia.

All Rights Reserved.

This specification may be reproduced or transmitted in any form or by
any means, electronic or mechanical, including photocopying,
recording, or by any information storage or retrieval system,
providing that the content remains unaltered, and that such
distribution is under the terms of this licence.

While every precaution has been taken in the preparation of this
specification, DSTC Pty Ltd assumes no responsibility for errors or
omissions, or for damages resulting from the use of the information
herein.

DSTC Pty Ltd welcomes comments on this specification.  Please address
any queries, comments or fixes (please include the name and version of
the specification) to the address below:

.nf
    DSTC Pty Ltd
    Level 7, General Purpose South
    University of Queensland
    St Lucia, 4072
    Tel: +61 7 3365 4310
    Fax: +61 7 3365 4311
    Email: elvin@dstc.com
.fi

Elvin is a trademark of DSTC Pty Ltd.  All other trademarks and
registered marks belong to their respective owners.
.KE
m4_dnl
m4_dnl ########################################################################
