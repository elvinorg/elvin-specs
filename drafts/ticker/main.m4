m4_dnl -*- nroff -*-
m4_dnl ########################################################################
m4_dnl
m4_dnl              Tickertape Message Format Specification
m4_dnl
m4_dnl File:        $Source: /Users/d/work/elvin/CVS/elvin-specs/drafts/ticker/main.m4,v $
m4_dnl Version:     $RCSfile: main.m4,v $ $Revision: 1.2 $
m4_dnl Copyright:   (C) 2001, David Arnold.
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
.ds LF Arnold
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH dd mmm yyyy
.ds CH Tickertape Chat Protocol
.\" hyphenation mode 0
.hy 0
.\" adjust left
.ad l
.\" indent 0
.in 0
Elvin Project                                                  D. Arnold
Preliminary INTERNET-DRAFT                                          DSTC
                          
Expires: aa bbb cccc                                         dd mmm yyyy

.ce
Tickertape Chat Protocol
.ce
draft-arnold-ticker-chat-v3-00.txt

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

This document describes an Elvin message for`'mat as used by the
Tickertape family of applications.  It supports group-oriented instant
messaging and provides a simple, consistent interface for
presentation of a variety of interactive-time data.

The for`'mat is derived from a series of earlier formats, as
documented in the appendix.

m4_heading(1, Terminology)

This document referrs Elvin clients, producers, and consumers; client
libraries and routers.

An Elvin router is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin messages. A client is a
program that uses an Elvin router, via a client library for a
particular programming language.  A client library implements the
Elvin protocols and manages clients' connections to an Elvin router.

A sender of an Elvin message is often referred to as a ``producer'',
and receivers as ``consumers''.  A single program may perform either
or both roles.

Further details of the Elvin protocol, its entities and their roles is
available in [EP].
m4_dnl
m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in [RFC2119].

m4_heading(1, `Tickertape')

The `Tickertape' application, as the name suggests, originally
consisted of a single scrolling li`'ne of text presented as a
graphical user interface.  The content of the scrolling text was
composed from messages received via Elvin, selected by the
application's subscriptions.

In addition to this scrolling display, facilities to compose and send
messages and modify the subscriptions were provided.

Alternative styles of presentation have since become available, but
the name `Tickertape' has remained descriptive of the whole family of
protocol implementations.

m4_heading(1, Messages)

This document specifies the basic Tickertape ``chat'' message
for`'mat.  Several other message formats are frequently implemented by
a Tickertape client, for example those for reception of Usenet-style
messages and presence notifications.

A Tickertape chat message has three fundamental properties: the
sending user's name, a specified target group, and a textual message
body.  These basic properties are then augmented to allow message
ageing, threaded conversations, attachments and other features.

m4_heading(2, `Base Attributes')

The base attributes MUST be present in all Tickertape chat messages.
.\"
.TS 
tab(;); 
lb lb lb
l l lw(32).  
Name;Type;Description
_
org.tickertape.message;int32;T{
The version of this specification implemented by the message.  For
this revision, the value MUST be an Elvin int32, with a value of 3000.
T}

Group;string;T{
The name of the group to which this message is sent.  Group names may
be any UTF-8 string.
T}

From;string;T{
The name of the sender of the message.
T}

Message;string;T{
Text to be displayed in the scroller (or similar user interface
location).
T}

Timeout;int32;T{
Suggested lifetime of the message, in minutes, mostly useful for
scrolling presentation.

A positive value suggests that the message be removed from the
scroller after that many minutes.  A value of zero indicates that the
message should be scrolled once only.  A negative value suggests that
it not be scrolled at all, but displayed only in a threaded or
historical view.
T}

Message-Id;string;T{
Globally unique identifier for this message.  The use of a UUID (or
GUID), optionally hashed (using SHA.1, MD5, etc) to ensure anonymity
(since the UUID includes the MAC address of the generating machine) is
RECOMMENDED.
T}
_
.TE
.\"
Messages SHOULD provide the following attributes to enable their
involvement in threaded conversations.  All thread-capable messages
contain a unique message identifier.  A message that is intended as a
reply to a previous message identifies its antecedent using this
identifier.
.\"
.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
In-Reply-To;string;T{
The Message-Id of a previous message to which this is a reply.
T}

Thread-Id;string;T{
When sending a message to a group to which the sender is not
subscribed, but wishes to see any replies, this field should be set
(and the sender's user agent should alter its subscription so as to
receive any messages with this Thread-Id value).

User agents, receiving a message with a Thread-Id set, should copy the
supplied value into the same-named attribute of any reply messages.

This value must be globally unique.  See Message-Id for
recommendations.
T}
_
.TE
.\"
The following attributes may optionally be provided
.\"
.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
User-Agent;string;T{
The name and version of the user agent generating this message.
T}

No-Archive;int32;T{
If this message should not be archived, this field should be present,
and the value should be non-zero.
T}

Distribution;string;T{
A value, intended for interpretation by forwarding filters at
administrative boundaries, describing restrictions on the distribution
of this message.

No constraints are set on the value of this field, but examples might
inc`'lude "local", "company_name", etc.

Note that no global interpretation is placed on the values of this
field.  Its meaning is defined within an administrative boundary, to
be interpreted at that boundary.  Multiple levels of such
interpretation are possible.
T}

Attachment;opaque;T{
A MIME-encoded addition to the message.  multiple objects should be
encoded using the multipart/mixed MIME type.

Note that this field is an opaque type, and thus an array of bytes.
therefore, it is not necessary to encode attachments (using, for
example, base64) as is the usual practice for email.
T}
_
.TE


m4_pre(
elvin_opaque_part = [ version ] "/" protocol "/" endpoint options
)m4_dnl
m4_dnl


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

.IP [UNICODE] 12
Unicode Consortium, The,
"The Unicode Standard, Version 2.0",
Addison-Wesley, February 1997.

.KS
m4_heading(1, Contact)

Author's Address

.nf
David Arnold

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

