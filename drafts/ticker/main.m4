m4_dnl -*- nroff -*-
m4_dnl ########################################################################
m4_dnl
m4_dnl              Tickertape Message Format Specification
m4_dnl
m4_dnl File:        $Source: /Users/d/work/elvin/CVS/elvin-specs/drafts/ticker/main.m4,v $
m4_dnl Version:     $RCSfile: main.m4,v $ $Revision: 1.11 $
m4_dnl Copyright:   (C) 2001-2003, David Arnold.
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
m4_define(CONTACT_DETAILS,`13')m4_dnl
m4_define(PROTOCOL_REGISTRY,`11.2')m4_dnl
m4_define(HISTORICAL_FORMATS,`Appendix B')m4_dnl
m4_define(EXAMPLE_FORMATS,`Appendix A')m4_dnl
.\"
m4_dnl
m4_dnl    general macros for I-D formatting
m4_dnl
m4_include(macros.m4)m4_dnl
m4_dnl
m4_dnl
.\" page length 10 inches
m4_dnl .pl 10.0i
.\" page offset 0 lines
.po 0
.\" line length (inches)
.ll 7.2i
.\" title length (inches)
m4_dnl .lt 7.2i
m4_dnl .nr LL 7.2i
m4_dnl .nr LT 7.2i
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
Elvin Project                                          D. Arnold, Editor
Preliminary INTERNET-DRAFT                                          DSTC
                          
Expires: aa bbb cccc                                         dd mmm yyyy

.ce
Tickertape Chat Protocol
.ce
PUBLISHED

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
Tickertape family of applications.  It supports group-oriented,
inter-person and machine-to-person instant messaging and provides a
simple, consistent interface for presentation of a variety of
interactive-time data.

This specification is derived from a series of earlier message
for`'mat conventions, as documented in HISTORICAL_FORMATS.

m4_heading(1, Terminology)

This document refers to Elvin clients, producers, and consumers;
client libraries and routers.

An Elvin router is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin messages. A client is a
program that uses an Elvin router, via a client library for a
particular programming language.  A client library implements the
Elvin protocols and manages one or more connections to Elvin routers.

The sender of an Elvin message is often referred to as a ``producer'',
and receivers as ``consumers''.  A single client may perform either or
both roles.

Further details of the Elvin protocol, its entities and their roles is
available in [EP].
m4_dnl
m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in [RFC2119].

m4_heading(1, `Tickertape')

The Tickertape family of applications provide person-to-person and
software-to-person instant messaging.  As the name suggests, the
original user interface consisted of a scrolling li`'ne of text,
showing a series of messages.

Alternative styles of presentation have since become available, but
the name Tickertape has remained descriptive of the whole family of
applications which variously support the creation, reception and often
both, of instant messages.

Producers support composition of messages and sending them to a
specified group.  A particular message can be sent independently, or
as a reply to a preceding message.

Consumers subscribe to messages, often by channel, but alternatively
by some combination of attributes of the message.

Interactive clients normally display a subset of the received
messages' attributes, and facilitate composition of initial or reply
messages.

From its earliest prototypes, the facility has been used by software
to interact with human users.  Both unidirectional messages, such as
hardware alerts, and automated responders (or bots) have long formed a
part of the Tickertape culture.

What distinguishes Tickertape from other messaging applications and
protocols such as [xy]talk, IRC, Jabber/XMPP, and the various
proprietary instant messaging systems, is its ability to extend beyond
a point-to-point, group or channel-based communications using the
content-based routing abilities of the underlying Elvin transport.

m4_heading(1, Messages)

This document specifies the basic Tickertape 'chat' message for`'mat.
Several other message formats are frequently implemented by a
Tickertape client, for example that for presence notifications
[PRESENCE].

A Tickertape chat message has three fundamental properties: the
sending entity's name, a specified target group, and a textual message
body.  These basic properties are then augmented to allow message
ageing, threaded conversations, attachments and other features.

m4_heading(2, `Base Attributes')

The base attributes MUST be present in all Tickertape chat messages.
.\"
.TS 
tab(;); 
lb lb lb
l l lw(42).  
Name;Type;Description
_
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

Message-Id;string;T{
A globally unique identifier for this message.  

The use of some combination of host name, process identifier and time
of day (for example a GUID or UUID), hashed (using SHA.1, MD5, etc) to
ensure anonymity is RECOMMENDED.  
T}
_
.TE
.\"
Tickertape client applications typically provide the ability to
subscribe to messages using the 'Group' name, and frequently arbitrary
subscriptions over the 'From', 'Message' and other attributes.

String-valued Elvin attributes use the UTF-8 [RFC2279] Unicode
[UNICODE] character encoding.  In some cases, a single character may
have multiple representations in Unicode.  As an example, a base
character combined with an accent can sometimes have a single code for
the combination, or use multiple codes to represent the base character
plus a combining accent.

The Elvin subscription language provides operations to transform
strings to canonical representations to ensure that strings using
different representations of the same characters are correctly
matched.  Implementors of Tickertape protocol clients SHOULD use these
features to overcome this issue.

m4_heading(2, `Replies and Intra-group Threads')

When sending a message as a reply to a previously received message,
implementations MUST identify that message as a means of supporting
presentation of conversations in order.
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

It is possible to send messages directed to a group to which the
sender is not subscribed.  This is commonly used when the sender wants
to initiate a convesation with the user(s) of the channel, but does
not want to see traffic on that channel from other conversations.

The sender includes a Thread-Id attribute in the initial message, and
temporarily subscribes to all messages with a matching Thread-Id
value.

Responding clients copy the received Thread-Id value into any replies
made to that message, and thus the responses are visible to the
original poster.

A client responding to a message containing a Thread-Id attribute MUST
include a Thread-Id attribute with that value in its response. 
.\"
.KS
.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
Thread-Id;string;T{
When sending a message to a group to which the sender is not
subscribed but wishes to see any replies, this field should be set
(and the sender's user agent should alter its subscription so as to
receive any messages with this Thread-Id value).

This value must be globally unique.  See Message-Id for
recommendations.
T}
_
.TE
.KE
.\"
m4_heading(2, `Optional Attributes')

The following attributes MAY be included, at the discretion of the
application writer or controlling user.
.\"
m4_heading(3, `Protocol Version')

Elvin messages are sufficiently self-descriptive that applications can
be written to cater for missing or additional attributes to those
expected.  It is therefore not necessary for robust communication that
the protocol version in use be formally specified.

However, if a producer wishes to indicate that it supports this
specification, it MAY do so using the following attribute.

Note that this information is purely informative, and an application
MUST NOT fail because of a discrepancy between the version indicated
with this attribute, and the format of the message.
.\"
.KS
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
_
.TE
.KE
.\"
m4_heading(3, `Message Validity')

For Tickertape consumer applications, it is sometimes useful to have
an indication of the valid or useful lifespan of a message.  This
attribute allows the producer to suggest a time period after which the
message might be removed from the display or otherwise deprioritised.

A positive value suggests that the message be removed from display
after that many minutes.  A value of zero indicates that the message
should be shown briefly: less than one minute, but still shown.  A
negative value suggests that it not be shown at all, but displayed
only in logs or historical views.

.KS
.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
Timeout;int32;T{
Suggested lifetime of the message, in minutes.
T}
_
.TE
.KE
.\"
m4_heading(3, `User Agent Identification')

User agents (clients) MAY identify themselves as the sending agent of
Tickertape messages.  If they do, this attribute SHOULD be used for
that purpose.

.KS
.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
User-Agent;string;T{
The name and version of the user agent (program) generating this
message.
T}
_
.TE
.KE
.\"
m4_heading(3, `Archiving')

One common class of Tickertape consumer programs makes a permanent
record of message traffic, usually on a per-channel basis.  Producers
can optionally allow the user to indicate that a message should not be
archived in this manner.

Archiver clients SHOULD implement support for this attribute, and
SHOULD NOT store messages for which it exists, and has a non-zero
value.
.KS
.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
No-Archive;int32;T{
The sender of a message can request that it not be archived by setting
this attribute with a non-zero value.
T}
_
.TE
.KE
.\"
m4_heading(3, `Distribution')

This attribute is intended for interpretation by forwarding filters at
administrative boundaries and describes restrictions on the
distribution of this message.

No constraints are set on the value of this field, but examples might
inc`'lude "local", the company name, "unclassified", etc.

Note that no global interpretation is placed on the values of this
field.  Its meaning is defined within an administrative domain, to be
interpreted at its administrative boundaries.  Multiple levels of such
interpretation are possible.

Future standardisation of the semantics of this attribute is likely.

.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
Distribution;string;T{
A value, intended for interpretation by forwarding filters at
administrative boundaries, describing restrictions on the distribution
of this message.

No constraints are set on the value of this field, except that it
SHOULD have a string value.
T}
_
.TE
.\"
m4_heading(3, `Attachments')

In addition to the simple textual message content, it is often useful
to attach URLs, file references, sounds, email addresses or other
content to a Tickertape message.

This attribute provides a means to attach additional content encoded
using the MIME standards [RFC2045-RFC2049].

Note that this field is a string type, and thus must be legitimate
UTF-8.  The MIME specification provides various options for encoding
data which is is not pure 7 bit ASCII (ie. base64 encoding, see
[RFC1421] section 4.3.2.4).  These mechanisms should be used to ensure
binary content is safely transported.

In choosing to use a string type for this attribute, our major
motivation was to enable subscription to the attached information
(where it is in un-encoded form).  This includes things like MIME
content types, etc.  Content that is valid UTF-8 SHOULD NOT be
additionally encoded so as to facilitate subscription to messages by
their attached content.

The most common form of attachment is a URL which SHOULD use the
text/uri-list MIME type.  Multiple attached objects SHOULD be encoded
using the multipart/mixed MIME type.

.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
Attachment;string;T{
A MIME-encoded addition to the message.  Note that this value must be
a legitimate UTF-8 Unicode string, and consequently, binary
values must be encoded using, for example, base 64 encoding.
T}
_
.TE
.\"
m4_heading(3, `Updating Existing Messages')

In a scrolling user interface, it can be useful to have messages which
are constantly visible, but whose content is updated over time.  An
example of such a message might be the current score in a sporting
event.

A producer application that wishes to enable such replacement MAY
include this field in sent messages.  The value MUST be globally
unique unless the message is intended to replace a previous message;
see Message-Id for recommended practice in generating unique
identifiers.

A consumer application that wishes to allow update of currently
displayed messages should compare the value of an arriving message's
Replaces field with those of existing messages.  The attributes of the
arriving message should replace those of any previous message(s) with
matching Replaces value(s).

If no currently displayed message's Replaces field matches this value,
the arriving message is presented as usual.

.KS
.TS
tab(;);
lb lb lb
l l lw(42).
Name;Type;Description
_
Replaces;string;T{
An identifier, either unique to this message, or matching a previous
message's Replaces value.
T}
_
.TE
.KE

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

The optional use of the 'Attachment' attribute to deliver a
MIME-encoded object allows arbitrary data to be delivered to the
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
m4_heading(2, `Message Replacement')

The use of the 'Replaces' attribute to update a previous message's
content can be abused by an attacker to rewrite any replaceable
message.
.\"
m4_heading(2, `Denial of Service')

It is possible to attack either an individual Tickertape client, or
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

.IP [RFC1421] 12
J. Linn,
"Privacy Enhancement for Internet Electronic Mail: Part I: Mesage Encryption and Authentication Procedures",
RFC1421, February 1993.

.IP [RFC2045] 12
N. Freed, N. Borenstein,
"Multipurpose Internet Mail Extensions (MIME) Part One: Format of Internet Message Bodies",
RFC2045, November 1996.

.IP [RFC2046] 12
N. Freed, N. Borenstein,
"Multipurpose Internet Mail Extensions (MIME) Part Two: Media Types",
RFC2046, November 1996.

.IP [RFC2047] 12
K. Moore,
"Multipurpose Internet Mail Extensions (MIME) Part Three: Message Header Extensions for Non-ASCII Text",
RFC2047, November 1996.

.IP [RFC2048] 12
N. Freed, J. Klensin, J. Postel,
"Multipurpose Internet Mail Extensions (MIME) Part Four: Registration Procedures",
RFC2048, November 1996.

.IP [RFC2049] 12
N. Freed, N. Borenstein,
"Multipurpose Internet Mail Extensions (MIME) Part Five: Conformance Criteria and Examples",
RFC2049, November 1996.

.IP [RFC2119] 12
S. Bradner,
"Key words for use in RFCs to Indicate Requirement Levels"
RFC2119, March 1997.

.IP [RFC2234] 12
D. Crocker, P. Overell, 
"Augmented BNF for Syntax Specifications: ABNF", 
RFC 2234, November 1997.

.IP [RFC2279] 12
F. Yergeau,
"UTF-8, a transformation format of ISO 10646",
RFC 2279, January 1998.

.IP [RFC2483] 12
M. Mealling, R. Daniel, Jr,
"URI Resolution Services Necessary for URN Resolution",
RFC 2483, January 1999.

.IP [UNICODE] 12
Unicode Consortium, The,
"The Unicode Standard, Version 4.0",
Addison-Wesley, Reading, MA, 2003,
ISBN 0-321-18578-1.

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
em4_unnumbered(`Appendix A \- Example Notifications')

This section shows some example notifications using previous versions
of the Tickertape specification, and compares them with their
representation using this version of the specification.

Consider a simple message, with an attached URL:

.nf
Message-Id: "1d906567-e491-48c6-9607-1b9f79f926da"
TICKERTAPE: "Chat"
TICKERTEXT: "check this out!"
USER: "Spammeister"
TIMEOUT: 5
MIME_TYPE: "x-elvin/url"
MIME_ARGS: "http://www.spamradio.net"
.fi

This would now be sent as

.nf
Message-Id: "1d906567-e491-48c6-9607-1b9f79f926da"
Group: "Chat"
Message: "check this out!"
From: "Spammeister"
Timeout: 5
MIME-Attachment: "MIME-Version: 1.0\\r\\n" \\
                 "Content-type:text/uri-list\\r\\n" \\
                 "\\r\\n" \\
                 "http://www.spamradio.net\\r\\n"
User-Agent: "Example Ticker v1.0"
.fi

The MIME-Attachment field is the most changed.  It has been renamed,
and is now a proper MIME document, rather than putting the content
type and encoding as separate attributes.

This makes for simpler handling using standard library facilities, and
enables the proper use of all features from the MIME standards.

Note also the recommended change from the experimental "x-elvin/url"
content type, to the standard type "text/uri-list" when attaching a
URL to a message.

.bp
em4_unnumbered(`Appendix B \- Previous Versions')

The protocol specified by this document has undergone several years of
evolutionary development.  Several dozen implementations exist, with
varying levels of functionality and compatibility.

The naming for attributes in this specification is deliberately
different from previous versions, in an attempt to both enable
backward compatibility and to encourage migration to current best
practice for Elvin applications.

\fBBasic Attributes\fR

The basic attributes have remained unchanged since the first
implementation of the Tickertape protocol for Elvin3.  All subsequent
revisions have expanded on this basic set.
.\"
.TS 
tab(;); 
lb lb lb
l l lw(32).  
Name;Type;Description
_
TICKERTAPE;string;T{
The name of the group to which this message is sent.
T}

USER;string;T{
The name of the sender of the message.
T}

TICKERTEXT;string;T{
Text to be displayed in the scroller (or similar user interface
location).
T}

TIMEOUT;int32;T{
Suggested lifetime of the message, in minutes, mostly useful for
scrolling presentation.
T}
_
.TE
.\"
.B `Attachments'

The attachment of URLs to Tickertape messages was popularised using a
debased form of MIME-style encoding.  Few clients supported MIME types
other than the informal 'x-elvin/url' type.
.\"
.TS 
tab(;); 
lb lb lb
l l lw(32).  
Name;Type;Description
_
MIME_TYPE;string;T{
The MIME type of the attached data.
T}

MIME_ARGS;string;T{
The body of the MIME object.
T}

MIME_ENCODING;string;T{
The content transfer encoding of the body of the MIME object.  If not
supplied, defaults to '8bit'.
T}
_
.TE
.\"
.B `Replacement'

Replacement of previous messages was introduced to support sports
scores and similar situations where a constantly updating value should
not generate a new presented message for each update.
.\"
.TS 
tab(;); 
lb lb lb
l l lw(32).  
Name;Type;Description
_
REPLACEMENT;string;T{
A string identifier.  Subsequent messages with the same REPLACEMENT
value should replace this message when presented.
T}
_
.TE
.\"
.B `Threads'

The most recent addition to be widely implemented used message
identifiers to allow a client to present responses to previous
messages in order.  This reflects the introduction of clients with
tablular presentation instead of or in addition to a scrolling
interface.
.\"
.TS 
tab(;); 
lb lb lb
l l lw(32).  
Name;Type;Description
_
Message-Id;string;T{
A string identifier for this message.  Use of a UUID (GUID) is suggested.
T}

In-Reply-To;string;T{
A string identifier for the message to which this is a response.
T}
_
.TE
.\"

No other attributes have been widely accepted by developers of
Tickertape clients to date.  This document represents the first formal
standardisation of the protocol, and codifies best-practice as
developed by the Tickertape community over the course of these
enhancements.

m4_dnl
m4_dnl ########################################################################

