m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  protocol-errors

m4_heading(2, Protocol Errors)

The different things that generate Nacks. 

Errors are reported as numbers so that language-specific error
messages may be used by the client.

.KS
  -----------------------------------------------------------------
  Error Description                    Abbreviation       Error ID 
  -----------------------------------------------------------------
  Reserved                                                   0
  Protocol Error                       ProtErr               1
  Syntax Error in Subscription         SynErr                2
  Identifier Too Long in Subscription  LongIdent             3
  Bad Identifier in Subscription       BadIdent              4
  No such subscription for client      BadSub                5
  ---------------------------------------------------------------
.KE

m4_remark(can 1,2,3 happen in a notif as well as sub?)

.IP "Protocol Error"
Non-specific error related to client-server communications.  This
will generally be sent to the client if the server recieves unexpected
data.  The server SHOULD close the socket after sending a ProtErr
Nack.

.IP "Syntax Error" 4
Non-specific syntactic problem.

.IP "Identifier Too Long" 4
the supplied element identifier exceeds the maximum allowed length.

.IP "Bad Identifier" 4
the supplied element identifier contains illegal characters. Remember
that the first character must be only a letter or underscore.


m4_heading(2, Protocol Errors)

