m4_dnl  architecture.m4
m4_dnl
m4_dnl  system architecture overview.  should introduce all system
m4_dnl  components and their basic relationships.
m4_dnl
m4_heading(1, ARCHITECTURE)

.LP
describe the basic concepts of notification, subscription, evaluation
of subscriptions, delivery. 

Elvin has two components: a client and a server.  Within an Elvin
system, multiple clients may exist, supported by a single server.

m4_remark(we need to update this section to reflect clustering and federation)

An Elvin system is comprised of communicating programs which use the
services of the system through a client library, Elvin servers which
act as local routers and a network of inter-server tunnels which
distribute messages beyond the domain of a single server.

This specification describes the client/server protocol and semantic
requirements for client libraries and the server daemon.  It does not
describe the inter-server protocol.

m4_include(operational-overview.m4)

m4_include(communication-model.m4)

