m4_include(macros.m4)
.pl 10.0i
.po 0
.ll 7.2i
.lt 7.2i
.nr LL 7.2i
.nr LT 7.2i
.ds LF Arnold, Boot & Segall
.ds RF PUTFFHERE[Page %]
.ds CF Expires in 6 months
.ds LH Internet Draft
.ds RH _date_
.ds CH Elvin
.hy 0
.ad l
.in 0
XXX Working Group                                              D. Arnold
Internet Draft                                                   J. Boot
Category: Standards Track                                      T. Maslen
                                                               T. Phelps 
                                                               B. Segall
                                                                    DSTC
                                                            dd mmmm _yr_

.ce
Elvin Server Federation Protocol

.ti 0
Status of this Memo

.in 3
This document specifies an Internet standards track protocol for the
Internet community, and requests discussion and suggestions for
improvements.  Please refer to the current edition of the "Internet
Official Protocol Standards" (STD 1) for the standardization state and
status of this protocol.  Distribution of this memo is unlimited.

.ti 0
Copyright Notice

.in 3
Copyright (C) The Internet Society (_yr_).  All Rights Reserved.


.ti 0
ABSTRACT

.in 3
This document describes a protocol for federation of Elvin []
servers.  It enables exchange of message traffic, load-balancing
across local clusters and wide-area links between administrative
domains.

It has no effect on the protocol used for Elvin client to server
communications.

.ti 0
TABLE OF CONTENTS

(tdb) (probably last ;-)

.bp
m4_heading(1, INTRODUCTION)
m4_heading(1, TERMINOLOGY)

Wide-area federation

Local-area federation

Clustering

Scope

Subscription scope

Address space

Elvin domain

m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.


m4_heading(1, Basic Operation)

Elvin servers, in addition to whatever client/server protocols they
support, use a separate server federation protocol.  This protocol has
several purposes:

1. management of the server(s)
2. clustering of local servers for scaling or reliability
3. linking servers to form wide-area routing networks



m4_heading(2, Clustering)

Clustering is used to link multiple local servers into a single
address space or subscription scope.

Where an address space has a large number of clients, it can be
necessary to share the evaluation of their subscriptions over multiple
host nodes to achieve adequate performance.  This is analagous to a
web server farm, for example.

Alternatively, where performance is not an issue, it can still be
desirable to have multiple local servers for an address space to
continue service in the face of a server (daemon, node, network)
failure.

At a logical level, the cluster of Elvin servers must appear to
implement a single address space; effectively a virtual server
providing the same service semantics as a single server daemon with
better performance or reliability.

m4_heading(2, Wide-area Federation)

Wide-area federation (in future referred to simply as federation) is
used to link islands of Elvin address spaces together into a single
routing network.  


m4_heading(1, Protocol Overview)

An Elvin server is statically configured with an initial state,
including one or more scope names which it is to provide.  The server
advertises these scope names (together with other information) via a
well-known multicast address as described in [ELVIN].

If other servers are found providing the same scopes, the server
contacts them to obtain the (dynamically allocated) multicast address
used for communication within that scope.

[[[
      this is bogus because we could get multiple copies of a
      message, and we could end up sending it out on multiple mcast
      channels.  if we have just one for the domain however, how do we
      figure what a domain is?  ie. all works fine until a server
      starts that has two configured scopes which join two previously
      independent domains.

      i *think* that i need to change scopes back to having less
      significance.  they are simply a way of controlling clients'
      connectivity to servers, including the ability to partition a
      cluster from a client's POV.

      the principle concept from a clustering POV is the address space
      or domain, which shares a multicast channel, and is orthogonal
      to scopes.  the important thing then is defining a domain.  how
      do we ensure that clients cannot find multiple domains unless we
      want them too.

      or maybe in other words, how do we make all the servers in a
      domain are equally visible to any client (esp wrt server
      discovery).
]]]




Clustered servers communicate using a reliable multicast protocol over
an IP network.  







.KS
.ti 0
.NH 1
CONTACT
.ft
.in 3

Author's Address

.nf
David Arnold
Julian Boot
Thomas Maslen
Bill Segall

Distributed Systems Technology Centre
Level7, General Purpose South
Staff House Road
University of Queensland
St Lucia QLD 4072
Australia

Phone:  +617 3365 4310
Fax:    +617 3365 4311
Email:  elvin@dstc.edu.au
.fi
.KE

.KS
.ti 0
.NH 1
FULL COPYRIGHT STATEMENT
.ft
.in 3

Copyright (C) The Internet Society (1999).  All Rights Reserved.

This document and translations of it may be copied and furnished to
others, and derivative works that comment on or otherwise explain it
or assist in its implmentation may be prepared, copied, published and
distributed, in whole or in part, without restriction of any kind,
provided that the above copyright notice and this paragraph are
included on all such copies and derivative works.  However, this
document itself may not be modified in any way, such as by removing
the copyright notice or references to the Internet Society or other
Internet organizations, except as needed for the purpose of
developing Internet standards in which case the procedures for
copyrights defined in the Internet Standards process must be
followed, or as required to translate it into languages other than
English.

The limited permissions granted above are perpetual and will not be
revoked by the Internet Society or its successors or assigns.

This document and the information contained herein is provided on an
"AS IS" basis and THE INTERNET SOCIETY AND THE INTERNET ENGINEERING
TASK FORCE DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO ANY WARRANTY THAT THE USE OF THE INFORMATION
HEREIN WILL NOT INFRINGE ANY RIGHTS OR ANY IMPLIED WARRANTIES OF
MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE."
.KE

