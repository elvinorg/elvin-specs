m4_dnl -*- nroff -*-
m4_dnl ########################################################################
m4_dnl
m4_dnl              Tickertape Message Format Specification
m4_dnl
m4_dnl File:        $Source: /Users/d/work/elvin/CVS/elvin-specs/drafts/ticker/main.m4,v $
m4_dnl Version:     $RCSfile: main.m4,v $ $Revision: 1.3 $
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

The for`'mat is derived from a series of earlier for`'mats, as
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
The name of the group to which this message is sent.
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
m4_heading(2, `Replies and Intra-group Threads')

When sending a message as a reply to a previously received message,
implementations SHOULD identify that message as a means of supporting
presentation of threaded conversations.
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
_
.TE
.\"
m4_heading(2, `Private or Extra-group Threads')

It is possible to send messages directed to a group for which the
sender is not subscribed.  This is commonly used when the sender wants
to initiate a convesation with the user(s) of the channel, but does
not want to see traffic on that channel from other threads.

The sender includes a Thread-Id attribute in the initial message, and
subscribes to all messages with a matching Thread-Id value.
Responding clients copy the received Thread-Id value into any replies
made to that message, and thus the responses are visible to the
original poster.
.\"
.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
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
m4_heading(2, `Optional Attributes')
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
inc`'lude "local", "company_name", "unclassified", etc.

Note that no global interpretation is placed on the values of this
field.  Its meaning is defined within an administrative domain, to be
interpreted at its administrative boundaries.  Multiple levels of such
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

m4_heading(1, `Access Control')

Elvin supports the use of keys to control visibility of both messages
and subscriptions [EP].  This specification does not mandate the use
of a particular key scheme, or a method of applying the general Elvin
access control facilities to Tickertape Chat messages.

It is likely that a companion document, or a future revision of this
document, will describe such a method.
.\"
.\"
m4_heading(1, `Security Considerations')
.\"
m4_heading(2, `Access Control')

Unless a Tickertape client uses a proprietry method to constrain the
visibility of Tickertape messages using Elvin access control, all
messages and subscriptions should be considered exposed to any user
with access to the supporting Elvin router infrastructure.
.\"
m4_heading(2, `Sender Identity')

The presented user identity, obtained from the `From' attribute of the
message, can be either empty or misleading.  
.\"
m4_heading(2, `Attachments')

The optional use of the `Attachment' attribute to deliver a
MIME-encoded object allows arbitrary data to be present on the
receiver's machine.  This data can be interpreted by the client
program, and this interpretation could involve the execution of
arbitrary code.

Client application developers and end-users should ensure that the
interpretation of MIME data occurs within appropriate safeguards.

Some user agents also provide a facility to automatically invoke the
interpretation of MIME attachments.  This practice introduces an
additional risk, precluding a manual vetting of the data before
interpretation.
.\"
m4_heading(2, `Denial of Service')

It is possible to attack either an Tickertape individual client, or
the Elvin routing network, by sending a large number of Tickertape
messages.  

This type of attack could impact local network bandwidth, Elvin router
latency and CPU usage, and Tickertape client host CPU usage.

The combination of many messages and automatically invoked attachment
interpretation has particularly high risk of substantial impact.
.\"
.\"
m4_heading(1, `IANA Considerations')

This specification places no requirements on the IANA.
.\"
.\"
m4_heading(1, `Relevant Publications')

The Elvin client protocol [EP] defines an abstract protocol for
communication between Elvin clients and Elvin routers, and concrete
protocols for TCP-based transport and XDR-based data marshaling.

A RECOMMENDED extension to [EP] providing automatic router discovery
is defined in [ERDP].

Inter-router protocols for clustering [ERCP] and wide-area routing
[ERFP] are also available.  Elvin router implementations MAY support
clustering and SHOULD support federation.
.\"
.\"
m4_heading(1, `Contact for further information')

See section CONTACT_DETAILS for full contact details.
.\"
.\"
m4_heading(1, `Author/Change controller')

This specification is a component of the Elvin protocol suite.  Elvin
specifications are maintained by DSTC Pty Ltd, and change control
authority is retained by DSTC Pty Ltd, at this time.

Suggested revisions or extensions to this specification should be sent
to DSTC, at the address listed in section CONTACT_DETAILS.


m4_dnl  bibliography

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
.\"
.\"
.bp
em4_unnumbered(`Appendix A \- Previous Versions')

The protocol specified by this document has undergone several years of
evolutionary development.  Several dozen implementations exist, with
varying levels of functionality and compatibility.

The naming for attributes in this specification is deliberately
different from previous versions, in an attempt to both enable
backward compatibility and to encourage migration to current best
practice for Elvin applications.

\fBBasic Attributes\fR

.B `Replacement'

.B `Threads'

.B `Attachments'





m4_dnl
m4_dnl ########################################################################

