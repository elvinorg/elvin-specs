m4_dnl  architecture.m4
m4_dnl
m4_dnl  system architecture overview.  should introduce all system
m4_dnl  components and their basic relationships.
m4_dnl
m4_include(macros.m4)m4_dnl
m4_dnl
m4_heading(1, ARCHITECTURE)
m4_dnl
.LP
describe the basic concepts of notification, subscription, evaluation
of subscriptions, delivery. 

Elvin has two components: a client and a server.  Within an Elvin
system, mutliple clients may exist, supported by a single server.


m4_heading(2, Philosophy)
m4_heading(3, Simplicity)
API, data-types, administration

m4_heading(3, Speed)

Directed communication (like UDP or TCP) has a significant advantage
over undirected messaging in that its routing decisions are
comparitively simple.  If undirected messaging is to become a useful
part of the protocol suite, its performance is critical.

The architecture and implementation of an Elvin server are directedby
this concern.  The protocol design supports

m4_heading(3, Fail-stop Communications)
m4_heading(3, Best-effort Reliability)
m4_heading(3, Use of Multicast)

m4_heading(2, Server)
m4_heading(2, Client)
m4_heading(2, Communication Model)
m4_heading(3, Notification)
m4_heading(3, Subscription)
m4_heading(3, Delivery)
m4_heading(3, Quench)
m4_heading(2, Federation)
m4_heading(3, Local Area Clustering)
m4_heading(3, Wide Area)
m4_heading(2, Security)
m4_heading(3, Authentication)
m4_heading(3, Anonymous Access Control)

