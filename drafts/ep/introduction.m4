m4_heading(1, INTRODUCTION)

Elvin is a content-based publish/subscribe messaging service.  An
Elvin implementation is comprised of Elvin routers which forward and
deliver messages after evaluating their contents against a body of
registered subscriptions.

To facilitate evaluation of subscriptions, Elvin messages are
collections of named, typed values.  Subscriptions are a logical
predicate expression which the router evaluates for each received
message.  Messages are delivered to the subscriber if the result of
the predicate evaluation is true.

There is no requirement that 

Publishers generate 
Undirected communication, where the sender is unaware of the identity,
location or even existence of the receiver, is not currently provided
by the Internet protocol suite.  This style of messaging, sometimes
called "publish/subscribe", is typically implemented using a
notification service.

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
