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

m4_heading(2, Packet Types)

The Elvin abstract protocol specifies a number of packets used in
interactions between clients and the server.

.KS
.nf 
  ---------------------------------------------------------------
  Packet Type                   Abbreviation	Usage	Subset
  ---------------------------------------------------------------
  Unreliable Notification	UNotify		C -> S	 1

  Negative Acknowledgement      Nack		S -> C	 2

  Connect Request               ConnRqst	C -> S	 2
  Connect Reply                 ConnRply	S -> C	 2

  Disconnect Request            DisconnRqst	C -> S	 2
  Disconnect Reply		DisconnRply	S -> C	 2
  Disconnect	                Disconn		S -> C	 2

  Security Request              SecRqst		C -> S	 2
  Security Reply		SecRply		S -> C	 2

  Notification Emit             NotifyEmit	C -> S	 2
  Notification Deliver          NotifyDeliver	S -> C	 2

  Subscription Add Request      SubAddRqst	C -> S	 2
  Subscription Modify Request   SubModRqst	C -> S	 2
  Subscription Delete Request   SubDelRqst	C -> S	 2
  Subscription Reply            SubRply		S -> C	 2

  Quench Add Request            QnchAddRqst	C -> S	 3
  Quench Modify Request         QnchModRqst	C -> S	 3
  Quench Delete Request         QnchDelRqst	C -> S	 3
  Quench Reply                  QnchRply	S -> C	 3

  Subscription Add Notify	SubAddNotify	S -> C	 3
  Subscription Change Notify	SubModNotify	S -> C	 3
  Subscription Delete Notify	SubDelNotify	S -> C	 3

  ---------------------------------------------------------------
.fi
.KE

A concrete protocol implementation is free to use the most suitable
method for distinguishing packet types.  If a packet type number or
enumeration is used, it SHOULD reflect the above ordering.

The subset numbers in the above table reflect capabilities of an
implementation.  An implementation MUST implement all or none of the
packet types in a subset.

m4_include(protocol-overview.m4)
m4_include(protocol-details.m4)
m4_include(server-discovery.m4)
m4_include(connection-opts.m4)
m4_include(protocol-errors.m4)
