m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  abstract-protocol

m4_heading(1, ABSTRACT PROTOCOL)

The Elvin4 protocol is specified at two levels: an abstract
description, able to be implemented using different marshalling and
transport protocols, and a concrete specification of one such
implementation, mandated as a standard protocol for interoperability
between different servers.

This section describes the operation of the Elvin4 protocol, without
describing any particular protocol implementation.
m4_dnl
.KS
m4_heading(2, Packet Types)
.LP
The Elvin abstract protocol specifies a number of packets used in
interactions between clients and the server.

.nf 
-------------------------------------------------------------
Packet Type                   Abbreviation    Usage    Subset
-------------------------------------------------------------
Unreliable Notification       UNotify         C -> S     A
Negative Acknowledgement      Nack            S -> C     B
Connect Request               ConnRqst        C -> S     B
Connect Reply                 ConnRply        S -> C     B
Disconnect Request            DisconnRqst     C -> S     B
Disconnect Reply              DisconnRply     S -> C     B
Disconnect                    Disconn         S -> C     B
Security Request              SecRqst         C -> S     B
Security Reply                SecRply         S -> C     B
Notification Emit             NotifyEmit      C -> S     B
Notification Deliver          NotifyDeliver   S -> C     B
Subscription Add Request      SubAddRqst      C -> S     B
Subscription Modify Request   SubModRqst      C -> S     B
Subscription Delete Request   SubDelRqst      C -> S     B
Subscription Reply            SubRply         S -> C     B
Dropped Packet Warning        DropWarn        S -> C     B
Test Connection               TestConn        C -> S     B
Confirm Connection            ConfConn        S -> C     B
Quench Add Request            QnchAddRqst     C -> S     C
Quench Modify Request         QnchModRqst     C -> S     C
Quench Delete Request         QnchDelRqst     C -> S     C
Quench Reply                  QnchRply        S -> C     C
Subscription Add Notify       SubAddNotify    S -> C     C
Subscription Change Notify    SubModNotify    S -> C     C
Subscription Delete Notify    SubDelNotify    S -> C     C
-------------------------------------------------------------
.fi
.KE

A concrete protocol implementation is free to use the most suitable
method for distinguishing packet types.  If a packet type number or
enumeration is used, it SHOULD reflect the above ordering.
m4_dnl
m4_heading(2, Protocol Subsets)

The subsets in the above table reflect capabilities of an
implementation.  An implementation MUST implement all or none of the
packet types in a subset.

Subsets A and B are independent.  An implementation MAY support either
or both of subsets A and B.  Subset A is OPTIONAL, subset B is
RECOMMENDED, and subset C is OPTIONAL.  Subsets C is dependent on
subset B.  An implementation supporting subset C MUST support subset
B.

m4_remark(i'd like the ability to have quenching only clients. jb

to do that, we'd have to separate the ConnRqst/Rply, SecRqst/Rply,
Disconn*, DropWarn and Test/ConfConn packets from Notif/Sub packets.
it's possible, and maybe nice? da)

m4_include(protocol-overview.m4)
m4_include(protocol-details.m4)
m4_include(connection-opts.m4)
