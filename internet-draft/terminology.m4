m4_dnl  terminology.m4
m4_dnl
m4_dnl  terminology for both Elvin and the RFC series
m4_dnl
m4_dnl
m4_heading(1, TERMINOLOGY)

This document discusses clients, client libraries, servers, producers,
consumers, subscription, notification, events and federation.  

The Elvin server is a background process that runs on a single server.
It acts as a distribution mechanism for event notifications. A client
is a program which uses the Elvin server, via the client library for a
particular programming language.  The client library implements the
Elvin protocol and manages that client's connection to the server.

Clients can have two roles: producer or consumer.  Producer clients
detect events of interest, and send a notification describing that
event to the server using the client library.  Consumer clients
subscribe to the server, requesting delivery of notifications matching
a subscription language query.  Some clients can be both producers and
consumers of notifications.

Elvin servers can also act as clients, enabling groups of servers to
exchange notifications.  This grouping, called federation, allows the
system to scale beyond a single company or network.

.nf
   int32    Signed 32-bit integer

   int64    Signed 64-bit integer

   real64   Double precision float using IEEE standard encoding 

   string   Variable length string, UTF8 encoded and are NOT null
            terminated.  
  
   opaque   Variable length byte array

   server   the process and/or host computer distributing 
            notifications to and from connected clients.

   client   A process that interacts with an Elvin server as a
            producer or consumer of notifications.
.fi

m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.

