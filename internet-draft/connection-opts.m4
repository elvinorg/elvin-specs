m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  connection-opts

m4_heading(2, Connection Options)

Connection options control the behaviour of the server for the
specified connection.  Set during connection, they may also be
modified during the life of the connection using QosRqst.

A server implementation MUST support the following options.  It MAY
support additional, implementation-specific options.

.KS
  -----------------------------------------------------------------
  Name                                   Type     Min  Default Max
  -----------------------------------------------------------------
   sub_max                               int32
   sub_len_max                           int32
   attribute_max                         int32
   attribute_name_len_max                int32
   byte_size_max                         int32
   string_len_max                        int32
   opaque_len_max                        int32
   notif_buffer_min                      int32
   notif_buffer_drop_policy              int32    (see below)
  -----------------------------------------------------------------
.KE
