m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  protocol

m4_heading(1, PROTOCOL)m4_dnl

The protocol consists of several sections: normal operation,
synchronisation, lost packet, loss-of-member and loss-of-sequencer.
Each of these is described in turn.

All packets in the protocol share a common packet header, which is
extended by some packet types to hold additional data.

m4_pre(`
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
| Ver |   Type  |     Flags     |          Incarnation          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|            Member Id          |            Packet Id          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|                        Sequence Number                        |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
')m4_dnl

The version field is 3 bits, and for the protocol specified in this
document, should be set to 1.  A value of 7 is reserved for expansion
of the version field.

The type field is 5 bits, and identifies the contents of the packet.
The defined types are:
m4_pre(` 
  Packet              | Type |  Abbreviation |  Usage 
 ---------------------+------+---------------+----------
  JoinRequest         |   1  |  JREQ         |  M -> M*
  JoinReply           |   2  |  JRPY         |  S -> M
  Leave               |   3  |  LEAVE        |  M -> M*
  Data                |   4  |  DATA         |  M -> S*
  Accept              |   5  |  ACPT         |  S -> M*
  Retransmit          |   6  |  RETR         |  M -> S
  Synchronise         |   7  |  SYNC         |  M -> M*
  Acknowledge         |   8  |  ACK          |  M -> S
  Flush               |   9  |  FLUSH        |  S -> M*
  LostSequencer       |  10  |  LSEQ         |  M -> M*
  Close               |  11  |  CLOSE        |  M -> M*')m4_dnl

The incarnation field is used to prevent members isolated by a network
partition, or otherwise separated from the group for a period of time,
from re-joining the group after it has been reformed.  The 16 bit
value is randomly assigned when the group is created.

The member identifier is a 16 bit number, allocated by the sequencer
when a member joins the group.  This puts an upper limit of 65535
members in a group.

The packet identifier is used to allow the sender of a packet to match
it with the packet sent by the sequencer with an assigned sequence
number.  This means that a member cannot have more than 65535 packets
outstanding at any one time.

The sequence number is used as a group-wide identifier and ordering
for a packet.  It is allocated by the sequencer, and may roll over if
the 32 bit limit is exceeded.  Members should accept a packet with
matching incarnation number and a sequence number of 1 if their
previous sequence number was greater than 2^31.

m4_heading(2, Normal Operation)m4_dnl

Multicast groups are identified by a 16 bit group number.  The lower 8
bits of this number are used to select one of the 256 IP multicast
addresses in the range 239.255.123.0/8.  The upper 8 bits of the group
number select a UDP port to which the datagrams are sent, starting at
a base port of 8000.

m4_heading(3, Creating and Joining a Group)m4_dnl

A JREQ packet is multicast to the group address, solicting the
sequencer.  The current group sequencer responds with a JRPY.  If no
JRPY is received within 1 second, the JREQ is resent up to 4 times,
with a doubling backoff.  If no response is received, the initiating
node assumes the role of sequencer, selects an incarnation number, and
resets the packet sequence number to zero.

Alternatively, if a JRPY is received, the incarnation and sequence
numbers are saved, along with the unicast address of the sequencer.

m4_heading(3, Sending and Receiving Data)m4_dnl

Messages are sent to the sequencer using the DATA packet. Within the
DATA packet, members send a piggybacked acknowledgement of the highest
contiguous sequence number they have seen.  The sequencer then
multicasts the data as an ACCEPT packet, together with an allocated
sequence number, to all group members.

Each member maintains a buffer of received messages, and a table of
sequence numbers for each known member.  When all members have
acknowledged a buffered message, it can be removed from the buffer.

After a timeout period without sending a DATA packet, a member should
multicast an ACK, allowing the group to update their history buffers.
This applies equally to the sequencer.

m4_heading(3, Leaving a Group)m4_dnl

A member may leave the groups at any time by sending a LEAVE message
to the sequencer, which multicasts it to the group.  The member must
wait until the multicast LEAVE is received before closing the group
socket.  The LEAVE packet should be resent up to 10 times before
assuming that the sequencer is dead.

On receiving a LEAVE message, a member should remove the indicated
member from its local table of acknowledged messages.

If the sequencer wishes to leave the group, it should multicast the
LEAVE.  On receiving a LEAVE from the current sequencer, the
lowest-numbered remaining member should adopt the sequencer role, and
multicast a NSEQ packet, containing its unicast address.  The old
sequencer must not disconnect until it has received the NSEQ packet.
Other members should send an ACK packet to the new sequencer, which
will continue to multicast NSEQ packets until it has received this.

The last member remaining in a group will be the sequenver.  It can
obviously leave at any time.

m4_heading(2, Synchronisation)m4_dnl

If a member's history buffer becomes full, it should unicast a SYNC
request to the sequencer.  On receiving the SYNC, the sequencer must
stop accepting DATA messages, and multicast the SYNC, together with
the latest allocated sequence number, to the group.

Members receiving a SYNC, should request retransmission of any missing
messages using RETR, and once up to date, should unicast an ACK to the
sequencer.  Any outstanding DATA messages should be held for
retransmission after synchronisation is complete.

The sequencer will resend the SYNC until all members have sent an ACK,
at which point it will send a FLUSH.

On receiving a FLUSH, all members may prune their history to the
synchronised sequence number, and must unicast an ACK to the
sequencer.  After sending the ACK, members with outstanding DATA
packets should resend them.

The sequencer will resend the FLUSH until all members have sent an
ACK, at which point it will begin handling DATA/ACCEPT packets again.

m4_heading(2, Lost Packet)m4_dnl

If a sender has not seen the matching ACCEPT packet within a timeout
(see later discussion), it resends the initial DATA.

The sequencer, receiving a duplicate DATA packet, re-multicasts the
ACCEPT.  A member receiving a duplicate ACCEPT can ignores it.

On receiving a packet with a sequence number greater than expected
(ie. having missed a packet), a member unicasts a RETR packet to the
sequencer requesting a retransmission.

The sequencer, receiving a RETR, re-multicasts the ACCEPT.

The member resends the RETR up to 10 times at 1 second intervals.  If
no response from the sequencer is seen, it assumes the sequencer node
has crashed (see later discussion).

m4_heading(2, Loss of Member)m4_dnl

Loss of a member other than the sequencer is detected during
synchronisation (itself caused by the failure of that member to
acknowledge ongoing traffic).  

After retrying the SYNC, the sequencer can determine that a member has
crashed.  At this point, the group must be closed.  All remaining
members will have synchronised their buffers, and instead of a FLUSH,
the sequencer should send a CLOSE.

The using application might decide to re-create the group, but the
incarnation number chosen will distinguish it from the previous
instance.  Should the "crashed" member recover, the sequencer should
unicast a NACK to the member(s), which should report this failure to
the application.

m4_heading(2, Loss of Sequencer)m4_dnl

Loss of the sequencer can be detected either by repeated failure of a
DATA message or SYNC request.  The detecting member should multicast
an LSEQ packet to the group, and the lowest-numbered remaining member
should adopt the role of sequencer for the shutdown process.

The new sequencer should respond with a multicast SYNC.  If no SYNC is
received from the lowest-numbered member within a timeout, the
next-lowest-numbered member should become the sequencer and multicast
the SYNC.  Members should respond with RETRs and ACKs until all nodes
synchronised, at which point the new sequencer multicasts the CLOSE,
and all members return the failure to the application.

If multiple members multicast a SYNC, the lowest-numbered member
should be treated as the sequencer by the group.  This node should
resend its SYNC.  A new sequencer receiving a SYNC from a
lower-numbered member must revert to normal member operation.

m4_heading(2, Packet Types)m4_dnl

In all cases, the version field should be set to 1.  For all packets
except JREQ, the incarnation number should be set to that of the
group.

m4_heading(3, `Join Request')m4_dnl

The incarnation, member_id and sequence_number fields should all be
set to zeros.  The packet_id field is used to match the request with
the reply, and should be randomly chosen.

m4_heading(3, `Join Reply')m4_dnl

The member_id value is allocated by the sequencer, and may reuse
values of previous members.  The packet_id is set to match that of
the member's request. The sequence number is that of the last message
sent by the sequencer, thus initialising the member to the state of
the group at the time it joins.

The packet should be multicast to the group, and all existing members
should allocate space in their history buffer for the new member.

m4_heading(3, `Leave')m4_dnl

The member_id is set to that of the leaving member (as specified in
JRPY).  The packet_id should be 0, and the sequence number the last
message seen by the member.

m4_heading(3, `Data')m4_dnl

The member_id is set to that of the sending member, and the packet_id
should be sequentially allocated by the member.

The sequence number should be the highest, contiguous sequence number
seen so far by the sending member.
m4_pre(`
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
| Ver |   Type  |     Flags     |          Incarnation          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|            Member Id          |            Packet Id          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|                         Sequence Number                       |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|                             Length                            |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
X                              Data                             X
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|')m4_dnl

m4_heading(3, `Accept')m4_dnl

The member_id and packet_id should be set from the triggering DATA
packet.  The sequence number should be set from the DATA packet, and
the message sequence allocated sequentially by the sequencer.

m4_pre(`
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
| Ver |   Type  |     Flags     |          Incarnation          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|            Member Id          |            Packet Id          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|                         Sequence Number                       |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|                        Message Sequence                       |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|                             Length                            |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
X                              Data                             X
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
')m4_dnl

m4_heading(3, `Retransmit')m4_dnl

The member_id is set to that of the requesting member.  The packet_id
should be zero.  The sequence number is that of the missing packet.

m4_heading(3, `Synchronise')m4_dnl

The member_id is set to that of the requesting group member.  The
packet_id should be 0.  The requesting member should set the sequence
number to 0, and the sequencer should set the sequence number to that
of the last message sent to the group.

m4_heading(3, `Acknowledge')m4_dnl

The member_id is set to that of the sending member, and the sequence
number to that of the last packet seen.  The packet_id should be 0.

m4_heading(3, `Flush')m4_dnl

The member_id and packet_id should be zero, and the sequence number to
that of the last message sent to the group.

m4_heading(3, `Lost Sequencer')m4_dnl

The member_id and packet_id should be zero, and the sequence number to
that of the last message seen.

m4_heading(3, `Close')m4_dnl

The member_id, packet_id and sequence number should be zero.




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
