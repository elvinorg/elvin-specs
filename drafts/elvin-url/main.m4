m4_dnl ########################################################################
m4_dnl
m4_dnl              Elvin URI Scheme specification
m4_dnl
m4_dnl File:        $Source: /Users/d/work/elvin/CVS/elvin-specs/drafts/elvin-url/main.m4,v $
m4_dnl Version:     $RCSfile: main.m4,v $ $Revision: 1.8 $
m4_dnl Copyright:   (C) 2001-2002, David Arnold.
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
m4_define(CONTACT_DETAILS,`16')m4_dnl
m4_define(PROTOCOL_REGISTRY,`11.2')m4_dnl
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
.ds CH Elvin URI Scheme
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
Elvin URI Scheme
.ce
NAME-VERSION.txt

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

m4_heading(1, Abstract)

This document describes a Uniform Resource Identifier (URI) scheme for
the identification of points of attachment to an Elvin router.

The scheme is used by Elvin routers when advertising their available
endpoints, by Elvin clients when attempting to establish a connection
to such an endpoint, and by human users when specifying Elvin
endpoints either to client programs or other users.

The scheme defines an opaque URI scheme, in accordance with the
requirements of [RFC2396].

m4_heading(1, Terminology)

This document discusses Elvin clients, client libraries and routers.

An Elvin router is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin messages. A client is a
program that uses an Elvin router, via a client library for a
particular programming language.  A client library implements the
Elvin protocols and manages clients' connections to an Elvin router.

Further details of the Elvin protocol, its entities and their roles is
available in [EP].
m4_dnl
m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in [RFC2119].

m4_heading(1, `URI Scheme Name')

The scheme name is: ``elvin''.

It is defined within the IETF scheme namespace, as defined by
[RFC2717], section 3.2, as indicated by the lack of a tree prefix.
However, the scheme is not yet registered with the change control
authority for the IETF tree, the IANA.

m4_heading(1, Syntax)

The ``elvin'' URI scheme is defined using a formal syntax derived from
that of the URI Generic Syntax, as defined in [RFC2396].  They differ
from most RFCs in that the grammars are defined not in terms of bytes,
but characters, independent of their representation.

In addition, the format used for IPv6 addresses is that defined in
[RFC2732], itself an extension of [RFC2396].

Some of the definitions of [RFC2396] and [RFC2732] are used in this
specification, without elaboration.

m4_heading(2, `Base Syntax')

The Elvin URI scheme is opaque, and MUST NOT be interpreted as
hierarchical.  It sub-classes the definition of [RFC2396]
``opaque_part'' to define the scheme-specific opaque part.

m4_pre(
elvin_opaque_part = [ version ] "/" protocol "/" endpoint options
)m4_dnl
m4_dnl
While some instances of the scheme can appear to be hierarchical,
there is no hierarchy of Elvin resources.  The use of a similar syntax
to an hierarchical authority component within the endpoint is a
reflection of the similar underlying technologies (ie. DNS host names;
Unix filesystem paths).

m4_heading(3, Version)m4_dnl

The version specification uses a two part major.minor format to
describe the protocol version implemented by the identified Elvin
router.

m4_pre(
version = 1*digit [ "." 1*digit ]
)m4_dnl
m4_dnl
The version of the syntax defined in this document is ``4.0''.

Elvin URI exported from an Elvin router MUST include the ``version''
component, describing the implemented protocol.  Where multiple
versions of the protocol are supported, separate URI MUST be used.

URI supplied to an Elvin client, for example by a command-line
parameter or configuration file, MAY include the ``version''
component.  Clients MUST NOT refuse URI lacking a version number. If
no version is supplied, the client should initiate connection to the
specified endpoint, and negotiate version compatibility upon
connection as described in [EP].

Note that the absence of a ``version'' component will cause the
resulting URI to violate the specification [RFC2396] for opaque scheme
URI, which requires the first character of an opaque URI to be an
element of ``uric_no_slash''.  For this reason, uses of the Elvin URI
scheme SHOULD always include the ``version'' component.  However, for
convenience of human users, all Elvin URI scheme parsers MUST accept
Elvin URI without the ``version'' component.  m4_dnl 

m4_heading(3, Protocol)

The ``protocol'' specification describes the stack of protocol modules
required to make a connection to the identified resource.

m4_pre(
protocol = protocol_name *( "," protocol_name )
protocol_name = official_name | experimental_name
official_name = alpha *( alphanum )
experimental_name = "x-" official_name
)m4_dnl

The resulting URI look like, for example,

m4_pre(`elvin:/tcp,krb5,xdr/router.example.com')m4_dnl

This syntax, with details of protocol usage within the general scheme
included between the ``/'' characters, is derived from a similar
usage within [RFC2608].

Protocol module names must be unique.  Names are allocated by DSTC,
within the Elvin Protocol registry, as described in section
PROTOCOL_REGISTRY.

In addition, two protocol stack aliases are defined.  These are
intended to simplify protocol stack selection for human users.  Elvin
clients MUST recognise the protocol aliases, and perform the required
textual substitution.  Elvin routers MUST NOT advertise URI containing
a protocol alias.

The string ``'' (a zero-length string) is defined as an alias for the
protocol stack ``tcp,none,xdr''.  This is informally known as the
default protocol.  Note that this enables a URI of the form

m4_pre(elvin://router.example.com)m4_dnl

identifying an Elvin router using the protocol stack ``tcp,none,xdr''.

The string ``secure'' is defined as an alias for the protocol stack
``ssl,none,xdr''.  This stack provides a basic level of security,
including privacy and integrity protection of message data and
optional certificate authentication.

m4_dnl
m4_heading(3, Options)

The ``options'' component is used to define parameters to be
interpreted by the Elvin client or its protocol modules to select
variant behaviour required to connect to the identified Elvin router.

m4_pre(
options = *( ";" option_name [ "=" option_value ] )
option_name = alpha *( unreserved | escaped )
option_value = *( unreserved | escaped )
)m4_dnl
Definition of legal option values MUST be part of a protocol module
specification.

m4_heading(2, `Endpoint Syntax')

The exact syntax of an ``endpoint'' component is determined by the
protocol specification component.  However, all endpoint components
are subject to a general syntax constraint

m4_pre(
endpoint = 1*uric_no_semi
uric_no_semi = unreserved | escaped | ":" | "@" | "&" |
               "=" | "+" | "$" | `","'
)m4_dnl

It is expected that most (if not all) IP-based protocols will require
a hostname in the endpoint specification to identify the machine
hosting the Elvin router process.  Where this is the case, protocol
endpoint specifications MUST use the syntax defined for ``host'' in
[RFC2732].
m4_dnl
m4_heading(3, `TCP Endpoint Syntax')

The Elvin client protocol [EP] defines a TCP transport protocol module
which it is RECOMMENDED that all implementations support.  The
endpoint syntax used by this module is

m4_pre(
tcp_endpoint = host [ ":" port]
)m4_dnl
where ``host'' is defined in [RFC2732] and ``port'' in [RFC2396].

m4_heading(1, `Character Encoding Considerations')

Elvin URI normally contain only those characters present in the DNS
names of the hosting servers.  However, it is possible that the URI
options, or a yet to be defined endpoint syntax, could require
non-ASCII characters.  In such cases, characters MUST be encoded as
UTF-8 [RFC2279, UNICODE], and represented using the normal URI escaped
encoding mechanism described in [RFC2396], section 2.4.

m4_heading(1, `Intended Usage')

Elvin URI are normally used in two ways: for specification of an
Elvin server in a client application by a human user, and, in
advertisements of server endpoints emitted by an Elvin server.

m4_heading(1, `Applications and/or Protocols Using the Scheme')

The scheme is used by implementations of the Elvin protocol to
identify Elvin router endpoints.  This usage includes advertisement by
Elvin routers using the Elvin router discovery protocol [ERDP], and
user input for Elvin client applications, similarly to URL used for
HTTP-accessible resources.

It is not intended that ``elvin'' scheme URI be used by a web browser,
nor that Elvin clients use existing web proxy networks.  The nature of
the resource identified (an Elvin router) makes such usage
non-sensical.

m4_heading(1, `Interoperability Considerations')

The ``elvin'' scheme has several features designed to promote
interoperability between implementations of the Elvin protocols.

The inclusion of the protocol version number as a distinct syntactic
element allows future revisions of the scheme to alter the definition
of the scheme's opaque component while ensuring continued correct
operation of previous versions' implementations.

Compatibility between different protocol versions can be determined
using the algorithm specified in [EP].

The scheme's protocol component allows multiple implementations of the
abstract protocol.  This enables different protocol properties to be
selected by users and administrators within the scheme definition.

m4_heading(1, `Security Considerations')

Multiple concrete implementations of the abstract protocol mean that
the Elvin protocol endpoint described by an ``elvin'' URI can have
many different properties, depending upon the protocol stack(s)
offered.

Elvin clients should be careful to select only endpoints offered using
protocols with the desired properties, especially those providing
appropriate security.

Similarly, administrators of Elvin routers should be careful to ensure
that only appropriate combinations of protocols are offered by their
routers.

The ability of client programs to specify both the protocol modules to
be used, and the address at which that protocol is expected gives
wide-ranging ability to reach an offered host, but does not provide
access beyond that which is already available.

m4_heading(1, `IANA Considerations')
m4_heading(2, `Elvin URI Scheme')

The ``elvin'' scheme is not yet registered with IANA, despite its use
of the IETF tree, as defined in [RFC2717].

It is intended that the scheme be registered as part of the
publication of the Elvin protocols.  Registration of a scheme via an
Informational RFC requires "wide usage" and "demonstrated utility",
both of which are subject to the discretion of the IESG.

m4_heading(2, `Protocol Modules')

This scheme defines a registry of ``protocol'' module names,
representing network transport, security, marshaling or other
functionality able to be used within an Elvin protocol stack, as
defined in [EP].

This registry is currently maintained by DSTC Pty Ltd.  Procedures for
registration of new protocol module names can be obtained from the
contact address in section CONTACT_DETAILS.

An unmanaged, experimental protocol name registry allows development
and testing of protocols prior to formal registration.  Experimental
registry names MUST use a "x-" prefix to distinguish them from
official names.

m4_heading(2, Future)

It is intended that the Elvin protocol specifications be contributed
to the IETF community, possibly as input to a future working group in
the area of content-based routing.  One possible outcome of this
contribution is that a future specification, derived or influenced by
this document, could require that the registry functions currently
performed by DSTC Pty Ltd be transferred to the IANA.

m4_heading(1, `Relevant Publications')

The Elvin client protocol [EP] defines an abstract protocol for
communication between Elvin clients and Elvin routers, and concrete
protocols for TCP-based transport and XDR-based data marshaling.

A RECOMMENDED extension to [EP] providing automatic router discovery
is defined in [ERDP].

Inter-router protocols for clustering [ERCP] and wide-area routing
[ERFP] are also available.  Elvin router implementations MAY support
clustering and SHOULD support federation.

m4_heading(1, `Contact for further information')

See section CONTACT_DETAILS for full contact details.

m4_heading(1, `Author/Change controller')

This specification is a component of the Elvin protocol suite.  Elvin
specifications are maintained by DSTC Pty Ltd, and change control
authority is retained by DSTC Pty Ltd, at this time.

Suggested revisions or extensions to this specification should be sent
to DSTC, at the address listed in section CONTACT_DETAILS.


m4_dnl  bibliography
m4_dnl
m4_dnl  -*-nroff-mode-*-
m4_dnl
.bp
m4_heading(1, REFERENCES)

.IP [EP] 12
D. Arnold, J. Boot, T. Phelps, B. Segall,
"Elvin Client Protocol",
Work in progress

.IP [ERCP] 12
D. Arnold, J. Boot, T. Phelps,
"Elvin Router Clustering Protocol",
Work in progress

.IP [ERDP] 12
D. Arnold, J. Boot, T. Phelps, B. Segall,
"Elvin Router Discovery Protocol",
Work in progress

.IP [ERFP] 12
D. Arnold, I.Lister,
"Elvin Router Federation Protocol",
Work in progress

.IP [RFC2119] 12
S. Bradner,
"Key words for use in RFCs to Indicate Requirement Levels"
RFC2119, March 1997

.IP [RFC2234] 12
D. Crocker, P. Overell, 
"Augmented BNF for Syntax Specifications: ABNF", 
RFC 2234, November 1997.

.IP [RFC2279] 12
F. Yergeau,
"UTF-8, a transformation format of ISO 10646",
RFC 2279, January 1998.

.IP [RFC2396] 12
R. Fielding, L. Masinter, T. Berners-Lee,
"Uniform Resource Identifiers: Generic Syntax",
RFC2396, August 1998

.IP [RFC2608] 12
E. Guttmann, C.Perkins, J. Veizades, M. Day,
"Service Location Protocol, Version 2",
RFC2608, June 1999.

.IP [RFC2717] 12
R. Petke, I. King,
"Registration Procedures for URL Scheme Names"
RFC2717, November 1999

.IP [RFC2718] 12
L. Masinter, H. Alvestrand, D. Zigmond, R. Petke,
"Guidelines for new URL Schemes"
RFC2718, November 1999

.IP [RFC2732] 12
R. Hinden, B.Carpenter, L.Masinter,
"Format for Literal IPv6 Addresses in URL's"
RFC2732, December 1999

.IP [UNICODE] 12
Unicode Consortium, The,
"The Unicode Standard, Version 2.0",
Addison-Wesley, February 1997.

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
.bp
m4_heading(1, `Full Copyright Statement')

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

m4_dnl
m4_dnl ########################################################################

