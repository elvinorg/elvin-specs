m4_dnl  terminology.m4
m4_dnl
m4_dnl  terminology for both Elvin and the RFC series
m4_dnl
m4_dnl
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

m4_heading(2, Notation Conventions)

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.

