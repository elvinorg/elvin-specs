m4_dnl  architecture.m4
m4_dnl
m4_dnl  system architecture overview.  should introduce all system
m4_dnl  components and their basic relationships.
m4_dnl
m4_heading(1, ARCHITECTURE)

Elvin is a network service providing messaging for connected clients.
Software built using Elvin is comprised of communicating programs
which access the functionality of the service through a client libray
and share information via subscriptions and matching notifications.

The Elvin service itself may be provided by a single stand-alone
router, such as a daemon process on a workstation.  It may also be
implemented by a number of co-operating routers acting as a cluster to
provide a single Elvin service.  Finally, an Elvin service may be
teired accross the Internet with local routers importing and exporting
sets of information to and from other disperse routers.

This specification describes the client/server protocol and semantic
requirements for client libraries and the server daemon.  It does not
describe any inter-server protocol.  The Elvin Router Cluster Protocol
[ERCP] describes how Elvin routers may be configured on a LAN as a cluster.
The Elvin Router Federation Protocol [ERFP] describes how single routers
or clusters may be linked accross the Internet.

m4_include(operational-overview.m4)

m4_include(communication-model.m4)

