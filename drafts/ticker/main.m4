m4_dnl -*- nroff -*-
m4_dnl ########################################################################
m4_dnl
m4_dnl              Tickertape Message Format Specification
m4_dnl
m4_dnl File:        $Source: /Users/d/work/elvin/CVS/elvin-specs/drafts/ticker/main.m4,v $
m4_dnl Version:     $RCSfile: main.m4,v $ $Revision: 1.13 $
m4_dnl Copyright:   (C) 2001-2004, David Arnold.
m4_dnl
m4_dnl This specification may be reproduced or transmitted in any form or by
m4_dnl any means, electronic or mechanical, including photocopying,
m4_dnl recording, or by any information storage or retrieval system,
m4_dnl providing that the content remains unaltered, and that such
m4_dnl distribution is under the terms of this licence.
m4_dnl 
m4_dnl While every precaution has been taken in the preparation of this
m4_dnl specification, the authors assume no responsibility for errors or
m4_dnl omissions, or for damages resulting from the use of the information
m4_dnl herein.
m4_dnl 
m4_dnl We welcome comments on this specification.  Please address
m4_dnl any queries, comments or fixes (please include the name and
m4_dnl version of the specification) to the address below:
m4_dnl 
m4_dnl     ticker-dev@tickertape.org
m4_dnl 
m4_dnl Elvin is a trademark of Mantara Software.  All other trademarks
m4_dnl and registered marks belong to their respective owners.
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
.ds CH Tickertape Chat Protocol v3
.ds PU PUBLISHED
.\" hyphenation mode 0
.hy 0
.\" adjust left
.ad l
.\" indent 0
.in 0
INTERNET-DRAFT                                         D. Arnold, Editor
                                                          tickertape.org
Expires: aa bbb cccc                                         dd mmm yyyy

.ce
Tickertape Chat Protocol version 3
.ce
\*(PU

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

This specification is derived from a series of earlier informal
message for`'mat conventions, as documented in HISTORICAL_FORMATS.

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
available in [ELVIN].
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

Consumers subscribe to messages, often by group name, but
alternatively by some other combination of attributes of the message.

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

m4_heading(2, `Groups')

The basic structural element of the Tickertape communications space is
the concept of groups.  A group is defined by its name: a string that
is specified by the message producer, and this provides a basic point
of context for rendezvous with consumers.  The group name performs the
role of a channel or forum, for selecting messages with related
content.

Most Tickertape clients maintain a persistent list of group names
which are simply selectable during message composition.  Many clients
also allow group names to be entered directly, allowing ad hoc group
creation.

Group names need not be predefined, nor do they have any required
structure.  Collisions between same-named groups from previously
unconnected administrative domains are both possible and likely.  Such
collisions can be desirable: the two communities might share a common
interest or purpose.  Where the collision is not productive, the
normal response is to restrict the distribution of messages in that
group to within the administrative domain.

m4_heading(2, `Sender Identity')

Tickertape messages include the identity of the sending entity as a
string value.  

While there are no constraints on the values that may be used for this
attribute, common usage has evolved several conventions for the
identity string:

Most clients default to using an identity string of the form

  user@domain

thus providing a simple distinction between users, derived from the
implicit uniqueness of their login name in combination with their
machine's domain name.

The obvious similarity with email addresses is not unintentional.
Rather than requiring a new naming scheme, use of an email address
reduces the likelyhood of collisions, and takes advantage of users'
familiarity with this form of identifier.

However, a second convention has evolved that uses the form

  user@location

This usage, while similar in appearance, is quite distinct.  One
typical value for the location component is the user's company name,
which provides some level of uniqueness, but is not as robust as a
complete domain name.  However, a second common usage has the location
as "home", which provides very little distinction between users.

These issues have not been addressed in the protocol specification
because no clear consensus has arisen that it is a problem.  Collision
between identifiers does occur, but it is resolved by social, rather
than protocol, mechanisms.

m4_heading(1, Elvin)

Tickertape uses Elvin as its underlying communications layer.  Elvin
provides a one-to-any, publish/subscribe transport with atomic,
consistent per-source ordering, best-effort delivery semantics.
Defined mappings exist for TCP, UDP and other bearer protocols.

Elvin messages are structured, using a flat name space of basic data
types, including Unicode strings.  Messages are transmitted to an
Elvin router, where they are compared against the registered
subscriptions.  A copy of the message is delivered to the owner of
each matching subscription and to other connected routers.

Subscriptions are expressed as predicates in a simple, C-like syntax.
In addition to the usual comparison and arithmetic operators,
functions are provided to test the existence and type of values, to
perform case folding and normalisation, and for regular expression and
glob-style wildcard matching.

Further details of the protocol and subscription language are
available in [ELVIN].


m4_heading(1, Message Specification)

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
features to ensure that user expectations are fulfilled.

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
after that many seconds.  Clients MAY interpret this value liberally;
a resolution in the order of minutes is normally adequate.

Special interpretation SHOULD be applied for a value of zero,
indicating that the message be shown briefly; and negative values,
suggesting that it not be shown at all, but displayed only in logs or
historical views.

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

Note that this field is an Elvin string type, and thus its value must
be legitimate UTF-8.  The MIME specification provides various options
for encoding data which is not compatible with its containing protocol
(ie. base64 encoding, see [RFC1421] section 4.3.2.4).  One of these
mechanisms MUST be used to ensure that binary content is safely
transported.

In choosing to use a string type for this attribute, our major
motivation was to enable subscription to the attached information
(where it is in un-encoded form).  This includes things like the MIME
content types, etc.  Content that is valid UTF-8 SHOULD NOT be
additionally encoded so as to facilitate subscription to messages by
their attached content.

The most common form of attachment is a URL.  URLs SHOULD use the
text/uri-list MIME type.  Multiple attached objects can be encoded
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

In a scrolling user interface, it can be useful to have messages that
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
and subscriptions [ELVIN].  This specification does not mandate the
use of a particular key scheme, or a method of applying the general
Elvin access control facilities to Tickertape Chat messages.

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

The Elvin client protocol [ELVIN] defines an abstract protocol for
communication between Elvin clients and Elvin routers, and concrete
protocols for TCP-based transport and XDR-based data marshaling.

A recommended extension to [ELVIN] providing automatic router
discovery is defined in [ERDP].

An inter-router protocol wide-area routing [ERFP] are also available.
Elvin router implementations normally support federation.
.\"
.\"
m4_heading(1, `Contact for further information')

See section CONTACT_DETAILS for full contact details.
.\"
.\"
m4_heading(1, `Author/Change controller')

This specification is a product of the informal Tickertape developer
community.  It is derived from work originally done at DSTC
(www.dstc.com), and now conducted through the facilities of
tickertape.org with the cooperation of Mantara Software.

Suggested revisions or extensions to this specification should be sent
to the working group, at the address listed in section
CONTACT_DETAILS.


m4_dnl  bibliography

.bp
m4_heading(1, REFERENCES)

.IP [ELVIN] 12
D. Arnold, Editor,
"Elvin Client Access Protocol",
Work in progress

.IP [ERDP] 12
D. Arnold, J. Boot, T. Phelps, B. Segall,
"Elvin Router Discovery Protocol",
Work in progress

.IP [ERFP] 12
D. Arnold, I. Lister,
"Elvin Router Federation Protocol",
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

Editor's Address

.nf
David Arnold
tickertape.org

Email:  ticker-dev@tickertape.org
.fi
.KE

.KS
Contributors

.nf
David Arnold
Julian Boot
Phil Cook
Anna Gerber
Michael Henderson
Michael Lawley
Ian Lister
Thomas Maslen
Ted Phelps
Matthew Phillips
Clinton Roy
Bill Segall
Martin Wanicki
.fi
.KE
.bp
m4_heading(1, `Full Copyright Statement')

Copyright (C) 2003-yyyy by tickertape.org.
.br
Copyright (C) 2001-2003 DSTC Pty Ltd.
.br
All Rights Reserved.

This specification may be reproduced or transmitted in any form
or by any means, electronic or mechanical, including photocopying,
recording, or by any information storage or retrieval system,
providing that the content remains unaltered, and that such
distribution is under the terms of this licence.

While every precaution has been taken in the preparation of this
specification, the authors assume no responsibility for errors or
omissions, or for damages resulting from the use of the information
herein.

Comments on this specification are welcome.  Please address any
queries, comments or fixes (please include the name and version of
the specification) to the mailing list below:

.nf
    ticker-dev@tickertape.org
.fi

Elvin is a trademark of Mantara Software.  All other trademarks and
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
Timeout: 300
Attachment: "MIME-Version: 1.0\\r\\n" \\
            "Content-type:text/uri-list\\r\\n" \\
            "\\r\\n" \\
            "http://www.spamradio.net\\r\\n"
User-Agent: "Example Ticker v1.0"
.fi

The Attachment field is the most changed.  It has been renamed, and is
now a proper MIME document, rather than putting only the content type
and the data as separate attributes.

This makes for simpler handling using standard library facilities, and
enables the proper use of all features from the MIME standards.

Note also the recommended change from the experimental "x-elvin/url"
content type, to the standard type "text/uri-list" when attaching a
URL to a message.

Also note that the Timeout field has changed from using units of
minutes, to seconds.  While minutes are sufficient resolution for this
application, in other Elvin applications, Timeout normally uses
seconds, and so that usage is adopted here.

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
implementation of the Tickertape protocol for Elvin 3.  All subsequent
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
_
.TE
.\"
.KS
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
.KE
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

