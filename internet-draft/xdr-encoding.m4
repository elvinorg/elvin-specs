m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  xdr-encoding

The standard Elvin 4 transport uses XDR encoding (see RFC 1832) to
marshal base data types.  Each packet is a sequence of encoded XDR
types.

In most illustrations, each box (delimited by a plus sign at the 4
corners and vertical bars and dashes) depicts a 4 byte block as XDR is
4 byte aligned.  Ellipses (...) between boxes show zero or more
additional bytes where required. Some packet diagrams extend over
multiple lines.  '>>>>' at the end of the line indicates continuation
to the next line.  '<<<<' at the beginning of a line indicates a
segment has some preceding blocks on the previous line.  Numbers used
along the top line of packet diagrams indicate byte lengths.

.nf
        +---------+---------+---------+...+---------+
        | block 0 | block 1 | block 2 |...|block n-1|   PACKET
        +---------+---------+---------+...+---------+
.fi


m4_heading(4, Base Types)

The XDR encoding for Elvin relies on five basic types used to
construct each packet: int32, int64, real64, opaque.

.KS
Below is a summary of encodings for the different base types
used in the protocol.  Implementors should refer to RFC 1832 for
details.

.nf
  ---------------------------------------------------------------
  Base Type  Type ID  XDR Type   Encoding Summary
  ---------------------------------------------------------------
  int32         0     int        4 bytes, MSB first

  int64         1     hyper      8 bytes, MSB first

  string        2     string     4 byte length, UTF8 encoded 
                                 string, zero padded to next four 
                                 byte boundary

  real64        3     double     64-bit double precision float

  opaque        4     opaque     4 byte length, data, zero padded
                                 to next four byte boundary
  ---------------------------------------------------------------
.fi
.KE

When the type of following data needs to be described in a packet
(eg, the value type in a name-value pair), one of the base type ID's
is encoded as an XDR enumeration.  This is often needed when a value
in a packet is one ofa number of possible types.

.KS
.nf
       0           4  
     +--+--+--+--+--+--+--+...+--+--+--+--+
     | type id   |        value           |             TYPED VALUE
     +--+--+--+--+--+--+--+...+--+----+---+
     |<--enum--->|
.fi
.KE

For illustration, if an int64 of value 1024L is encoded preceded by
its type, it would be sent as four bytes for the type id of 1 and
eight bytes for the value.

.KS
.nf
      0           4           8          12
     +--+--+--+--+--+--+--+--+--+--+--+--+
     |    0x01   |        0x400          |           INT64 EXAMPLE
     +--+--+--+--+--+--+--+--+--+----+---+
     |<--enum--->|<--------hyper-------->|
.fi
.KE

m4_heading(4, Packet Encodings)

This section describes the layout of each packet sent in the Elvin
protocol when using XDR encoding.

Each packet transmitted using the Elvin protocol starts
with a standard header of a packet type and a packet sequence 
identifier.  In the XDR encoding, the packet type is encoded as
an enumeration, the value being the appropriate Packet ID.  The
sequence identfier is a 32-bit integer.  Using XDR, both values
are represented in four bytes each.  Following the eight byte
header is the remainder of the packet.  The format of the rest
of the packet varies and is determined by the packet type.

       0           4          8        ...
     +--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+
     | packet id |sequence # |      remainder      |
     +--+--+--+--+--+--+--+--+--+--+--+...+----+---+
     |<----8 byte header---->|<--------data------->|

                                                      ENCODED PACKET
m4_heading(5, Connection Request)

m4_heading(5, Connection Reply)

m4_heading(5, Disconnection Request)

m4_heading(5, DisConnection)

m4_heading(5, Security Request)

m4_heading(5, QoS Request)

m4_heading(5, Subscription Add Request)

.nf
   0      4      8     12      ...
  +------+------+------+------+...+------+
  |pkt id|seq # |sub # |    expression   | >>>>
  +------+------+------+------+...+------+

           +------+------+...+------+...+------+...+------+
      <<<< |len n |      key 0      |   |     key n-1     |
           +------+------+...+------+...+------+...+------+
                  |<----------------n keys--------------->|

   pkt id      (enum)   packet type for SubAddRqst
   seq #       (int32)  sequence number for this packet
   sub #       (int32)  number identifier for this subscription, 
                        allocated by the client library
   expression  (string) the predicate to be used to select
                        notifications.
   len n       (int32)  number of security keys in the packet
   key x       (opaque) uninterpreted bytes of a security key.  
                        There will be n keys where n >= 0.
.fi

m4_heading(5, Subscription Modify Request)

It is an error to send a SubModRqst with an id not currently held at
the server.

.KS
   0      4      8     12      ...
  +------+------+------+------+...+------+
  |pkt id|seq # |sub # |    expression   | >>>>
  +------+------+------+------+...+------+
.KE

.KS
           +------+------+...+------+...+------+...+------+
      <<<< |len n |    add key 0    |   |  add key n-1    | >>>>
           +------+------+...+------+...+------+...+------+
                  |<------------n keys to add------------>|
.KE

.KS
           +------+------+...+------+...+------+...+------+
      <<<< |len m |    del key 0    |   |  del key m-1    |
           +------+------+...+------+...+------+...+------+
                  |<----------m keys to delete----------->|

                                                 SUBSCRIPTION MODIFY
.KE

.KS
 pkt id      (enum)   packet type for SubModRqst
 seq #       (int32)  sequence number for this packet
 sub #       (int32)  number identifier for the subscription to 
                      modify
 expression  (string) new predicate
 len n       (int32)  number of security keys to add
 add key x   (opaque) uninterpreted bytes of a security key
 len m       (int32)  number of security keys to remove
 del key x   (opaque) uninterpreted bytes of a security key   
.KE

m4_heading(5, Subscription Delete Request)

It is an error to send a SubDelRqst with an sub id not currently held
at the server.
.KS
                   0      4      8     12
                  +------+------+------+
                  |pkt id|seq # |sub # |         SUBSCRIPTION DELETE
                  +------+------+------+
.KE
.KS
 pkt id      (enum)   packet type for SubDelRqst
 seq #       (int32)  sequence number for this packet
 sub #       (int32)  number identifier for the subscription to 
                        delete.
.KE
m4_heading(5, Quench Add Request)
m4_heading(5, Quench Modify Request)
m4_heading(5, Quench Delete Request)

m4_heading(5, Notification)

An Elvin notification is a list of name-value pairs, where
the value is one of the five base types of int32, int64, real64,
string and opaque.  The encoding of these pairs must also include
the data type for the value.  For both the Notif and the NotifDel
packets, we introduce a name-type-value (NTV) block used to encode
a notification attribute.

The name of an attribute is always encoded as an XDR string. The type
is an enumeration of five different values indicating one of int32,
int64, real64, string or opaque (byte array).  The value, encoded as a
standard XDR type, is determined by the preceding type.

On the wire, a name-value is laid out as follows:

.KS
.nf
  +------+...+------+------+------+...+------+
  |      name       | type |      value      |       NAME-TYPE-VALUE
  +------+...+------+------+------+...+------+

   name      (string)  name of this attribute
   type      (enum)    type of the encoded value. 0ne of int32, int64,
                       real64, string or opaque
   value     -         the encoded value for this attribute.
.fi
.KE

Notifications begin with the number of attributes as an
int32.  

.KS
.nf
   0      4      8     12     ...
 +------+------+------+------+...+------+...+------+...+------+
 |pkt id|seq # |len n |       ntv 0     |   |      ntv n-1    | >>>>
 +------+------+------+------+...+------+...+------+...+------+
                      |<----------n name-type-values--------->|

           +------+------+...+------+...+------+...+------+
      <<<< |len m |      key 0      |   |     key m-1     |
           +------+------+...+------+...+------+...+------+
                  |<----------------m keys--------------->|
                                                        NOTIFICATION
.fi
.KE
.KS
   pkt id        (enum)   packet type for Notif
   seq #         (int32)  sequence number for this packet
   len n         (int32)  number of name-type-value triples in the 
                          notification.
   ntv x         [block]  encoded as a name-type-value triple, 
                          described above. There MUST be n 
                          name-type-value blocks where n > 0.
   len m         (int32)  number of security keys in the notification
   key x         (opaque) uninterpreted bytes of a security key. There
                          MUST be m keys where m >= 0.
.fi
.KE


m4_heading(5, Notification Deliver)

  0      4      8     12      ...
 +------+------+------+------+...+------+...+------+...+------+
 |pkt id|seq # |len n |  name-value 0   |   | name-value n-1  | >>>>
 +------+------+------+------+...+------+...+------+...+------+
                       |<-------------n name-values----------->|

           +------+-------------+...+--------------+
      <<<< |len m |   sub id 0  |   |  sub id m-1  |
           +------+-------------+...+--------------+
                  |<-----------m sub ids---------->|
                                                NOTIFICATION DELIVER

 pkt id        (enum)   packet type for NotifDel
 seq #         (int32)  sequence number for this packet
 len n         (int32)  number of name-value pairs in the 
                        notification.
 name-value x  [block]  encoded as a name-type-value triple, 
                        described above. There will be n 
                        name-value blocks where n > 0.
 len m         (int32)  number of subscription ids this 
                        notification matched.
 sid x         (int64)  there MUST be m sub ids where m > 0

m4_heading(5, Quench Deliver)

m4_heading(5, Acknowledgement)

                     0      4      8
                    +------+------+
                    |pkt id|seq # |                              ACK
                    +------+------+

 pkt id      (enum)   packet type for Ack
 seq #       (int32)  sequence number of the request this packet
                      is acknowledging

m4_heading(5, Negative Acknowledgement)

.KS
 0     4     8    12      ...
 +-----+-----+-----+-----+...+-----+
 |pktid|seq #|error|    message    | >>>>  
 +-----+-----+-----+-----+...+-----+

          +-----+-----+----+...+----+...+-----+----+...+-----+
     <<<< |len n| t 0 |   param 0   |   |t n-1|  param n-1   |
          +-----+-----+----+...+----+...+-----+----+...+-----+
                |<-----------n type-value parameters-------->|
                                                               NACK
.KE
.KS
 pkt id      (enum)   packet type for Nack
 seq #       (int32)  sequence number of the request this packet
                      is responding to.
 error       (int32)  error code indicating the reason for this
                      response. error != 0.
 message     (string) default description of the error causing the Nack.
                      This is in the language of the server and is used
                      if the local error string for the client library
                      is unavailable. 
 len n       (int32)  number of parameters following
 t x         (enum)   base type of the next encoded parameter. 
                      0ne of int32, int64, string, real64.  The value 
                      cannot be of type opaque.
 value        -       the encoded value for this parameter.
.KE






