m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  protocol

m4_heading(1, PROTOCOL)

This section describes the operation of the protocol.

m4_dnl .KS
m4_heading(2, Packet Types)

.nf 
  Packet Type                |  Abbreviation |  Usage 
 ----------------------------+---------------+---------
  JoinRequest                |  JnRq         |  N -> S
  JoinReply                  |  JnRp         |  S -> N*
  Leave                      |  Leav         |  N -> N*
  Data                       |  Data         |  N -> N*
  Accept                     |  Acpt         |  S -> N*
  Retransmit                 |  Retr         |  N -> S
  Synchronise                |  Sync         |  S -> N*
  Acknowledge                |  Ackn         |  N -> S
  Flush                      |  Flsh         |  S -> N*
  Close                      |  Clos         |  N -> N*
.fi
.KE

A concrete protocol implementation is free to use the most suitable
method for distinguishing packet types.  If a packet type number or
enumeration is used, it SHOULD reflect the above ordering.

m4_heading(2, `Protocol Overview')

This section describes the protocol packet types and their allowed
use.  The following sections describe in detail the content of each
packet in protocol and the requirements of both the server and the
client library.

Server discovery SHOULD be implemented by client libraries.

Clients multicast a request for server URLs; servers respond with a
multicast list of URLs describing their available endpoints.  Where
multicast is not available for a concrete protcol, link-layer
broadcast MAY be used instead.

m4_changequote({,})
.KS
                             ,-->     +---------+
  +-------------+ ---SvrRqst-+-->   +---------+ |
  | Producer or |            `--> +---------+ | |
  |  Consumer   | <--.            |  Elvin  | |-+
  +-------------+ <--+-SvrAdvt--- | Servers |-+     SOLICITATION and
                  <--'            +---------+          ADVERTISEMENT
.KE

When a server is shutting down, it SHOULD multicast an announcement to
all clients that its endpoints are no longer available.

.KS
      +-------------+
    +-------------+ |                     +---------+
  +-------------+ | | <--.                |  Elvin  |
  | Producers & | |-+ <--+-SvrAdvtClose-- |  Server |
  |  Consumers  |-+   <--'                +---------+  ADVERTISEMENT
  +-------------+                                         WITHDRAWAL
.KE
m4_changequote(`,')
