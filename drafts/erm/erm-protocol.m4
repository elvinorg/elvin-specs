m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  protocol

m4_heading(1, PROTOCOL)

The protocol consists of several sections: normal operation,
synchronisation, lost packet, loss-of-member and loss-of-sequencer.
Each of these is described in turn.

All packets in the protocol share a common packet header, which is
extended by some packet types to hold additional data.

m4_pre(`
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
| Ver |   Type  |     Flags     |          Incarnation          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|            Member Id          |           Message Id          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|                        Sequence Number                        |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
')m4_dnl
m4_heading(2, Normal Operation)

Multicast groups are identified by a 16 bit group number.  The lower 8
bits of this number are used to select one of the 256 IP multicast
addresses in the range 239.255.123.0/8.  The upper 8 bits of the group
number select a UDP port to which the datagrams are sent, starting at
a base port of 8000.

m4_heading(3, Creating and Joining a Group)

A JREQ packet is multicast to the group address, solicting the
sequencer.  The current group sequencer responds with a JRPY.  If no
JRPY is received within 1 second, the JREQ is resent up to 4 times,
with a doubling backoff.  If no response is received, the initiating
node assumes the role of sequencer, selects an incarnation number, and
resets the packet sequence number to zero.

Alternatively, if a JRPY is received, the incarnation and sequence
numbers are saved, along with the unicast address of the sequencer.

m4_heading(3, Sending and Receiving Data)

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

m4_heading(3, Leaving a Group)

A member may leave the groups at any time by sending a LEAV message to
the sequencer, which multicasts it to the group.  The member must wait
until the multicast LEAV is received before closing the group socket.
The LEAV packet should be resent up to 10 times before assuming that
the sequencer is dead.

On receiving a LEAV message, a member should remove the indicated
member from its local table of acknowledged messages.

If the sequencer wishes to leave the group, it should multicast the
LEAV.  On receiving a LEAV from the current sequencer, the
lowest-numbered remaining member should adopt the sequencer role, and
multicast a NSEQ packet, containing its unicast address.  The old
sequencer must not disconnect until it has received the NSEQ packet.
Other members should send an ACK packet to the new sequencer, which
will continue to multicast NSEQ packets until it has received this.

The last member remaining in a group will be the sequenver.  It can
obviously leave at any time.

m4_heading(2, Synchronisation)

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

m4_heading(2, Lost Packet)

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

m4_heading(2, Loss of Member)

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

m4_heading(2, Loss of Sequencer)

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

m4_dnl .KS
m4_heading(2, Packet Types)

.nf 
  Packet Type         | Code |  Abbreviation |  Usage 
 ---------------------+------+---------------+----------
  JoinRequest         |  01  |  JREQ         |  M -> M*
  JoinReply           |  02  |  JRPY         |  S -> M
  Leave               |  03  |  LEAVE        |  M -> M*
  Data                |  04  |  DATA         |  M -> S*
  Accept              |  05  |  ACPT         |  S -> M*
  Retransmit          |  06  |  RETR         |  M -> S
  Synchronise         |  07  |  SYNC         |  M -> M*
  Acknowledge         |  08  |  ACK          |  M -> S
  Flush               |  09  |  FLUSH        |  S -> M*
  LostSequencer       |  10  |  LSEQ         |  M -> M*
  Close               |  11  |  CLOSE        |  M -> M*

.fi
.KE

m4_heading(3, `Join Request')

version: 1
type: 1
incarnation: 0
member_id: 0
message_id: randomly chosen
sequence_num: 0

m4_heading(3, `Join Reply')

version: 1
type: 2
incarnation: set by the sequencer
member_id: set by the sequencer
message_id: set to match that from the request
sequence_num: latest sequence number from sequencer

m4_heading(3, `Leave')

version: 1
type: 3
incarnation: for group
member_id: as from JRPY
message_id: 0
sequence_num: latest sequence number seen by member

m4_heading(3, `Data')

version: 1
type: 4
incarnation: for group
member_id: 
message_id: randomly chosen
sequence_num: 0

m4_heading(3, `Accept')

version: 1
type: 1
incarnation: 0
member_id: 0
message_id: randomly chosen
sequence_num: 0

m4_heading(3, `Retransmit')

version: 1
type: 1
incarnation: 0
member_id: 0
message_id: randomly chosen
sequence_num: 0

m4_heading(3, `Synchronise')

version: 1
type: 1
incarnation: 0
member_id: 0
message_id: randomly chosen
sequence_num: 0

m4_heading(3, `Acknoledge')

version: 1
type: 1
incarnation: 0
member_id: 0
message_id: randomly chosen
sequence_num: 0

m4_heading(3, `Flush')

version: 1
type: 1
incarnation: 0
member_id: 0
message_id: randomly chosen
sequence_num: 0

m4_heading(3, `Lost Sequencer')

version: 1
type: 1
incarnation: 0
member_id: 0
message_id: randomly chosen
sequence_num: 0

m4_heading(3, `Close')

version: 1
type: 1
incarnation: 0
member_id: 0
message_id: randomly chosen
sequence_num: 0


m4_pre(`
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
| Ver |   Type  |     Flags     |          Incarnation          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|            Sender Id          |           Message Id          |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|                        Sequence Number                        |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
|                             Length                            |
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
X                              Data                             X
|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|-+-+-+-+-+-+-+-|
')

version:  3 bits, set to 1, 7 (111) is reserved for expansion.
type: packet type
flags: reserved for now.
incarnation: 16bit incarnation number, used to prevent lost group
	     members corrupting a new group of the same name
sender-id: node identifier.  max 64k nodes.
message-id: unique identifier for message from a node.
sequence-number: identifier and ordering for a message.





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
