dnl  slp-template.m4
dnl
dnl  this is the SLP service: URL template for Elvin4

include(macros.m4)
heading(1, APPENDIX B -- Service Scheme Template)
.LP
Elvin 4 will use the Service Location Protocol (SLPv2) to enable
clients to locate suitable Elvin servers.  Elvin service: URLs must
satisfy this template.

.ID 2
Name of submitter: "David Arnold" <davida@pobox.com>
Language of service template: en
Security considerations:
Template text:
----------------------template begins here-----------------------
template-type=notification:elvin

template-version=0.0

template-description=
  The notification:elvin service URL provides the location of an Elvin
  server, and details of a supported combination of transport,
  security and marshalling protocols.

template-url-syntax=
  url-path= ;

transport= string L O X
  tcp
  tcp, doors

security= string L O X
  none
  none, ssl3

marshal= string L O X
  xdr
  xdr, none

-----------------------template ends here------------------------
