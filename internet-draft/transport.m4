TCP Transport

Each packet transmitted by the client library and the server starts
with the length of the entire packet in bytes.  The first block of
actual packet data is a packet type idenifier.  This is encoded as a
XDR enumerated type (four bytes).  The second block of data is a
packet identifier as an int32.

.KS
      0        4        ...
     +--+--+--+--+--+--+...+--+--+
     | length n  |   n  bytes    |             LENGTH ENCODED PACKET
     +--+--+--+--+--+--+...+--+--+
                 |<---n bytes--->|
.KE

.KS
                   0      4      8     12
                  +------+------+------+
                  |pkt id|xid   |sub # |         SUBSCRIPTION DELETE
                  +------+------+------+
.KE
                                               

