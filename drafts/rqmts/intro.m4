m4_heading(1, INTRODUCTION)


- undirected
  - sometimes unicast, sometimes multicast
    - adaptive overlay routing
- routed by subscription to content
  - structured content
  - no transparent encryption

- app/router protocol
- router/router protocol
- app api
  - assumption of app, not host, will need justification


- coordination of decoupled components
- descriptive, not communicative



Undirected communication, where the sender is unaware of the identity,
location or even existence of the receiver, is not currently provided
by the Internet protocol suite.  This style of messaging, also called
"publish/subscribe", is typically implemented using a notification
service.

Notification service clients can be characterised as producers, which
detect conditions, and emit notifications; and consumers, which
request delivery of notifications from the service.  Consumers
normally subscribe to receive notifications matching some supplied
criteria.

While directed communication is well serviced by the Internet protocol
suite, undirected communications is limited to UDP multicast.  While
UDP multicast is appropriate for many applications, it is inherently
channel-based: a particular address and port must be shared by the
communicating applications.

Elvin is a notification service which provides fast, simple,
undirected messaging, using content-based selection of delivered
messages.  It has been show to work on a wide-area scale and is
designed to complement the existing Internet protocols.

The Elvin protocol is designed to provide undirected, content-routed
messaging.  The raw protocol is expected to be accessed via an
interface library, not unlike the Berkeley sockets interface.  Unlike
sockets, however, the use of message content for routing requires that
the message body be structured.

The messages are routed from their source to required destinations by
Elvin server(s).  Delivery has best-effort, at-most-once semantics.
Under no circumstances will an Elvin client receive duplicate
messages.  Messages from a single source must be delivered in order,
but interleaving of messages from different sources is allowed in any
order.

Inter-server routing is not specified by this document.  It is noted,
however, that messages are routed between servers, and that such
journeys are subject to filtering and greater latency than messages
between clients of a single router process.

m4_heading(1, TERMINOLOGY)

This document discusses clients, client libraries, servers, producers,
consumers, quenchers, messages, and subscriptions.

An Elvin server is a daemon process that runs on a single machine.  It
acts as a distribution mechanism for Elvin message. A client is a
program that uses the Elvin server, via a client library for a
particular programming language.  A client library implements the
Elvin protocol and manages clients' connections to an Elvin server.

Clients can have three roles: producer, consumer or quencher.
Producer clients create structured messages and send them, using a
client library, to an Elvin server.  Consumer clients establish a
session with an Elvin server and register a request for delivery of
messages matching a subscription expression.  Quenching clients also
establish a session with a server, and register a request for
notification of changes to the server's subscription database that
match criteria supplied by the quencher.

Clients MAY take any number of the producer, consumer and quencher
roles concurrently.

