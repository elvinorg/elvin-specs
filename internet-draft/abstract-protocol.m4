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
-----------------------------------------------------------------
Packet Type                   Abbreviation    Usage   Cast Subset
-----------------------------------------------------------------
Server Request                SvrRqst         C -> S    M    A
Server Advertisement          SvrAdvt         S -> C    M    A
Server Advertisement Close    SvrAdvtClose    S -> C    M    A
Unreliable Notification       UNotify         C -> S    U    B
Negative Acknowledgement      Nack            S -> C    U    C
Connect Request               ConnRqst        C -> S    U    C
Connect Reply                 ConnRply        S -> C    U    C
Disconnect Request            DisconnRqst     C -> S    U    C
Disconnect Reply              DisconnRply     S -> C    U    C
Disconnect                    Disconn         S -> C    U    C
Security Request              SecRqst         C -> S    U    C
Security Reply                SecRply         S -> C    U    C
Notification Emit             NotifyEmit      C -> S    U    C
Notification Deliver          NotifyDeliver   S -> C    U    C
Subscription Add Request      SubAddRqst      C -> S    U    C
Subscription Modify Request   SubModRqst      C -> S    U    C
Subscription Delete Request   SubDelRqst      C -> S    U    C
Subscription Reply            SubRply         S -> C    U    C
Dropped Packet Warning        DropWarn        S -> C    U    C
Test Connection               TestConn        C -> S    U    D
Confirm Connection            ConfConn        S -> C    U    D
Quench Add Request            QnchAddRqst     C -> S    U    E
Quench Modify Request         QnchModRqst     C -> S    U    E
Quench Delete Request         QnchDelRqst     C -> S    U    E
Quench Reply                  QnchRply        S -> C    U    E
Subscription Add Notify       SubAddNotify    S -> C    U    E
Subscription Change Notify    SubModNotify    S -> C    U    E
Subscription Delete Notify    SubDelNotify    S -> C    U    E
-----------------------------------------------------------------
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

Subsets A, B and C are independent.  An implementation MAY suport any
or all of subsets A, B and C.  Subset A is RECOMMENDED, subset B is
OPTIONAL, subset C is RECOMMENDED and subset E is OPTIONAL.  Subsets D
and E are dependent on subset C.  An implementation supporting subset
D and/or E MUST support subset C.

m4_remark(is subset E really depeneding on subset B?  i'd like the ability
to have	quenching only clients. jb

to do that, we'd have to separate the ConnRqst/Rply, SecRqst/Rply,
Disconn*, DropWarn and Test/ConfConn packets from Notif/Sub packets.
it's possible, and maybe nice? da)

m4_include(protocol-overview.m4)
m4_include(protocol-details.m4)
m4_include(connection-opts.m4)
