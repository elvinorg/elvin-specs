m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  xdr-encoding
m4_heading(1, PROTOCOL IMPLEMENTATION)

m4_heading(2, Use of IPv4)

m4_heading(3, Marshalling)

The standard Elvin 4 marshalling uses XDR [RFC1832] to encode data.
Messages sent between the a client and and Elvin server are encoded as
a sequence of encoded XDR types.

This section uses diagrams to illustrate clearly certain segment and
packet layouts.  In most illustrations, each box (delimited by a plus
sign at the 4 corners and vertical bars and dashes) depicts a 4 byte
block as XDR is 4 byte aligned.  Ellipses (...) between boxes show
zero or more additional bytes where required. Some packet diagrams
extend over multiple lines.  In these cases, '>>>>' at the end of the
line indicates continuation to the next line and '<<<<' at the
beginning of a line indicates a segment has some preceding blocks on
the previous line.  Numbers used along the top line of packet diagrams
indicate byte lengths.

.nf
        +---------+---------+---------+...+---------+
        | block 0 | block 1 | block 2 |...|block n-1|   PACKET
        +---------+---------+---------+...+---------+
.fi

m4_heading(4, Packet Identification)

The abstract packet descriptions deliberately leave the method for
identifying packets to the concrete encoding.  For XDR, each packet is
identified by the pkt_id enumeration below:

m4_pre(
`enum {
    SvrRqst        = 16,
    SvrAdvt        = 17,
    SvrAdvtClose   = 18,
} pkt_id;')

In XDR, enumerations are marshalled as 32 bit integral values.  For
Elvin, each packet marshalled using XDR starts with a value from
the above pkt_id enumeration.  The format for the remainder of the
packet is then specific to the value of the packet identifer.

       0   1   2   3    
     +---+---+---+---+---+---+---+...+---+---+---+
     |     pkt_id    |         remainder         |    ENCODED PACKET
     +---+---+---+---+---+---+---+...+---+---+---+
     |<---header---->|<-----------data---------->|

Note that the XDR marshalling layer does NOT indicate the length of the
packet.  This is left to the underlying transport layer being used. For
example, a UDP transport could use the fact that a datagram contains the
length of data in the packet.

m4_heading(4, Base Types)

The Elvin protocol relies on seven basic types used to construct each
packet: boolean, uint8, int32, int64, real64, string, byte[].

Below is a summary of how these types are represented when using XDR
encoding.Each datatype used in the abstract descriptions of the
packets has a one-to-one mapping to a corresponsing XDR data type as
defined in [RFC1832].

.KS
.nf
  -------------------------------------------------------------------
  Elvin Type  XDR Type       Encoding Summary
  -------------------------------------------------------------------
  boolean     bool           4 bytes, last byte is 0 or 1

  uint8       unsigned int   4 bytes, last byte has value

  int32       int            4 bytes, MSB first

  int64       hyper          8 bytes, MSB first

  real64      double         64-bit double precision float

  string      string         4 byte length, UTF8 encoded string, zero 
                             padded to next four byte boundary

  byte[]      variable-      4 byte length, data, zero padded to next
              length opaque  four byte boundary
  -------------------------------------------------------------------
.fi
.KE

When the type of following data needs to be described in a packet (eg,
the value in a name-value pair used in NotifyEmit packets), one of the
base type ID's is encoded as an XDR enumeration.  This is often needed
when a value in a packet is one of a number of possible types.  In these
cases, the encoded value is preceded a type code from the following
enumeration:

m4_pre(
`enum {
    int32_tc  = 1,
    int64_tc  = 2,
    real64_tc = 3,
    string_tc = 4,
    opaque_tc = 5
} value_typecode;')

Note that the above enumeration does not include all of the datatypes
used in the protocol.  It only describes data which can be contained
in the abstract Value segment of a packet.  A Value in an encoded
packet is thus typed by prepending four bytes which encode the type
code:
    
.KS
.nf
       0  1  2  3 
     +--+--+--+--+--+--+--+--+...+--+--+--+--+
     | typecode  |          value            |        TYPED VALUE
     +--+--+--+--+--+--+--+--+...+--+--+--+--+
     |<--enum--->|<--format depends on enum-->
.fi
.KE

For illustration, if an int64 of value 1024L is preceded by its type
for marshalling, it would be sent as four bytes for the type id of 1
and eight bytes for the value.

.KS
.nf
       0  1  2  3  4  5  6  7  8  9 10 11  
     +--+--+--+--+--+--+--+--+--+--+--+--+
     |    0x02   |        0x0400         |           INT64 EXAMPLE
     +--+--+--+--+--+--+--+--+--+----+---+
     |<--enum--->|<--------hyper-------->|
.fi
.KE

m4_heading(4, Encoding Arrays)

All arrays in the abstract protocol are of variable length.  Arrays of
objects are encoded by prepending the length of the array as an int32
- the items are in the array are then each encoded in sequence
starting at item 0.  The 32bit length places a theoretical limit of
(2**32) - 1 items per list.  In practice, implementations are expected
to have much lower maximums for the number of items in a list
transmitted per packet.  For example, an implemenation may restrict
the number of fields in a notification to 1024.  Such limitations
SHOULD be documented for each implemenation.  Service offers and
connection replys SHOULD also provide such limitations.  See the
section X on Connection Establishment.

.KS
.nf
       0  1  2  3  
     +--+--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+--+
     |     n     |  item 0   |  item 1   |...| item n-1  |  ARRAY
     +--+--+--+--+--+--+--+--+--+--+--+--+...+--+--+--+--+
     |<--int32-->|<----------------n items-------------->|
                                                          
.fi
.KE

For illustration, *** FIXME *** ....

.KS
.nf
      0           4           8          12
     +--+--+--+--+--+--+--+--+--+--+--+--+
     |    0x01   |        0x400          |           ARRAY EXAMPLE
     +--+--+--+--+--+--+--+--+--+----+---+
     |<--enum--->|<--------hyper-------->|
.fi
.KE
m4_heading(4, Packet Encoding Example)

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
  0      4      8     12      ...
 +------+------+------+------+...+------+...+------+...+------+
 |pkt id| xid  |len n |       ntv 0     |   |      ntv n-1    | >>>>
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
   xid           (uint32) transaction number for this packet
   len n         (int32)  number of name-type-value triples in the 
                          notification. n MUST be greater than zero.
   ntv x         [block]  encoded as a name-type-value triple, 
                          described above. There MUST be n 
                          name-type-value blocks where n > 0.
   len m         (int32)  number of security keys in the notification
   key x         (opaque) uninterpreted bytes of a security key. There
                          MUST be m keys where m >= 0.
.fi
.KE

m4_heading(3, Framing)

m4_heading(2, Use of IPv6)
