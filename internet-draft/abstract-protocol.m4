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
Unreliable Notification       UNotify         C -> S    U    A
Negative Acknowledgement      Nack            S -> C    U    B
Connect Request               ConnRqst        C -> S    U    B
Connect Reply                 ConnRply        S -> C    U    B
Disconnect Request            DisconnRqst     C -> S    U    B
Disconnect Reply              DisconnRply     S -> C    U    B
Disconnect                    Disconn         S -> C    U    B
Security Request              SecRqst         C -> S    U    B
Security Reply                SecRply         S -> C    U    B
Notification Emit             NotifyEmit      C -> S    U    B
Notification Deliver          NotifyDeliver   S -> C    U    B
Subscription Add Request      SubAddRqst      C -> S    U    B
Subscription Modify Request   SubModRqst      C -> S    U    B
Subscription Delete Request   SubDelRqst      C -> S    U    B
Subscription Reply            SubRply         S -> C    U    B
Dropped Packet Warning        DropWarn        S -> C    U    B
Quench Add Request            QnchAddRqst     C -> S    U    C
Quench Modify Request         QnchModRqst     C -> S    U    C
Quench Delete Request         QnchDelRqst     C -> S    U    C
Quench Reply                  QnchRply        S -> C    U    C
Subscription Add Notify       SubAddNotify    S -> C    U    C
Subscription Change Notify    SubModNotify    S -> C    U    C
Subscription Delete Notify    SubDelNotify    S -> C    U    C
Server Request                SvrRqst         C -> S    M    D
Server Advertisement          SvrAdvt         S -> C    M    D
Server Advertisement Close    SvrAdvtClose    S -> C    M    D
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

Subsets A, B and D are independent.  An implementation MAY suport any
or all of subsets A, B and D.  Subset C is dependent on subset B.  An
implementation supporting subset C MUST support subset B.

m4_include(protocol-overview.m4)
m4_include(protocol-details.m4)
m4_include(connection-opts.m4)
m4_include(protocol-errors.m4)
