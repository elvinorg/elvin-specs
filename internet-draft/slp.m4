dnl  slp
dnl
m4_include(macros.m4)
heading(2, Service Location)
.LP
Elvin 4 will use the Service Location Protocol (SLPv2) to enable
clients to locate suitable Elvin servers.  The advantages of this
scheme are:

.IP - 2
multicast location of multiple servers within an adminstrative domain, without *any* configuration by the client 
.IP - 2
ability to select servers using service attributes
.IP - 2
enables failover to other servers when current connection fails
.LP
The basis of the SLPv2 scheme is the server: URL notation -- a means
of specifying the type and location of services.

For Elvin4, the service: URL will look like
.QP
service:notification:elvin://elvin.dstc.edu.au:2917;version=4.0;transport=tcp;security=null;marshal=xdr
.LP
breaking this up

.IP "notification" 15
is the abstract service type, applicable to a domain of services.  other examples are "printer", "fileserver", etc 
.IP "elvin" 15
is the concrete service type.  other examples could be "zephyr" or "tib" or "keryx"
.IP FQDN 15
the hostname and port number  is per the standard URL conventions
.IP "marshal" 15
is an attribute which specifies the marshalling protocol offered by the server
.IP "security" 15
specifies what security mechanism is offered, and
.IP "transport" 15
specifies what transport protocol is offered.
.IP "version" 15
specifies the protocol version supported by the server.

.LP
other attributes are also possible -- some i'm keen on are the
performance rating of the server, and it's load average, for example.

during server initialisation, it will have to register the N x N set
of its capabilities with SLP.

the elvin client library uses SLP to select these, specifying what
values it will accept.  it can therefore filter the set of offers from
servers to those which match its abilities.

once it has received those, they are sorted by (optional) preferences
for security, transport, version, etc., and then it attempts to
connect to each server listed in preference order.

Service: URLs also require a template be registered (with the IANA)
describing the attributes which are allowed to be advertised by
services.

For Elvin 4, this template will look like

.ID 4
type=ELVIN
version=0.0
lang=en
description=Elvin is a notification service that delivers sets of
named attributes to consumers whose subscription predicate evaluates
true for the set in question.
.DE

according to section 8.6 of SLPv2, the service agent (elvind) should
support an attribute "service-type" having a list of string values for
all the service types supported by the service agent.  for elvin, this
query could be
.QP
service:service-agent://;(service-type=notification:elvin);
.LP
to which it should respond
.QP
service:service-agent://130.102.176.7

.LP
the specific elvin query (not limiting protocol) would look more like
.QP
URL     service:notification:elvin  (or optionally, service:, for example)


.LP
The Elvin client library must implement SrvRqst, SrvRply, SAAdvert and
DAAdvert (SAAdvert is optional, but we expect it to be common, so we'd
better support it!)

The Elvin server must implement SrvRqst, SrvRply, SAAdvert, DAAdvert,
SrvReg and SrvAck.


According to the spec, section 6, first step for a UA is to find their
DA configured via DHCP.  so i suppose that mandates a DHCP client in
the UA?

Note that according to Secton 2.1, strings are preceded by a two byte
length field in contrast to XDR encoded strings used in the rest of
Elvin4.  XDR strings are preceded by an four byte length field.

