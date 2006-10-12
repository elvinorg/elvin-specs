m4_include(macros.m4)
.pl 10.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Arnold
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH __cur_date_
.ds CH Elvin
.hy 0
.ad l
.in 0
Elvin.Org                                                      D. Arnold
Preliminary INTERNET-DRAFT                              Mantara Software
Expires: aa bbb cccc                                         __cur_date_

.ce
Elvin SHA-1 Key Scheme

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

This document describes the use of the FIPS-181 Secure Hashing
Function (SHA-1) within the Elvin client protocol.  

m4_heading(1, Introduction)

The Elvin protocol provides content-based publish/subscribe messaging
between any number of clients connected one or more federated Elvin
routers.  Within the protocol, delivery of messages can be controlled
using sets of keys: unless a message that otherwise matches a
subscription also carries a matching key, delivery is prohibited.

The specification described the specific use of the SHA-1 algorithm

m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.


m4_heading(1, `Basic Operation')

- Overview of mechanism
  - Keys are byte arrays
  - Key are packaged into sets, set-lists and blocks according to a
    scheme
  - Keys are transformed before being distributed.  The router will
    also transform keys before comparing them
  - Apps use keys blocks for connections, notifications, subscriptions
    or quenches
  - Keys may be used in a private production, private subscription or
    dual mode

m4_heading(1, Elvin SHA-1 Key Schemes)

An Elvin key scheme is identified by a unique number.

m4_heading(2, `Elvin SHA-1 Producer Scheme')
m4_heading(2, `Elvin SHA-1 Consumer Scheme')
m4_heading(2, `Elvin SHA-1 Dual Scheme')

m4_heading(1, `Recommended Usage')

m4_heading(1, `Security Considerations')


m4_heading(1, `IANA Considerations')

Allocation of Elvin key scheme identifiers is managed through the
registry at elvin.org.  There are no requirements of the IANA created
by this specification.


.KS
m4_heading(Contact)

Author's Address

.nf
David Arnold
Mantara Software
PO Box 1820
Toowong QLD 4066
Australia

Phone:  +61 3 9281 3276
Fax:    +61 7 9910 5510
Email:  davida@pobox.com
.fi
.KE
.bp
m4_heading(1, `Full Copyright Statement')

Copyright (C) __yr elvin.org
All Rights Reserved.

This specification may be reproduced or transmitted in any form or by
any means, electronic or mechanical, including photocopying,
recording, or by any information storage or retrieval system,
providing that the content remains unaltered, and that such
distribution is under the terms of this licence.

While every precaution has been taken in the preparation of this
specification, Mantara Software assumes no responsibility for errors
or omissions, or for damages resulting from the use of the information
herein.

Elvin.Org welcomes comments on this specification.  Please address any
queries, comments or fixes (please include the name and version of the
specification) to the address below:

.nf
    Elvin.Org
    www.elvin.org
    support@mantara.com
.fi

Elvin is a trademark of Mantara Software.  All other trademarks and
registered marks belong to their respective owners.
