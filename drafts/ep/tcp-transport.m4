m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  tcp-transport
m4_heading(3, Transport)

tcp

TCP/IP is the standard transport protocol for Elvin4 Standard
Protocol.  Each client maintains a TCP connection to the server
daemon.  Either side (client or server) may close this connection at
any time, triggering reconnection handling by the client library.

The connection is established to a port advertised by the server.
Once the connection is open, the server must determine the security
protocol required for the connection.  how?
