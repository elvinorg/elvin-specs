PACKET

Each packet transmitted by the client library and the server starts
with the length of the entire packet in bytes.  The first block of
actual packet data is a packet type idenifier.  This is encoded as a
XDR enumerated type (four bytes).  The second block of data is a
packet identifier as an int32.  This identifier has different meanings
depending of the type of the packet.

       0        4           8          12    ...
     +--+--+--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+
     | length n  |    type   |    xid    |   n-8 bytes   |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+...+----+---+
                 |<---------------n bytes--------------->|

                                                  LENGTH ENCODED PACKET

