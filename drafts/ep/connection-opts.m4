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
.nf
  Name                        |  Type    |  Min   Default      Max
  ----------------------------+----------+-------------------------
  attribute_max               |  int32   |    64     256     2**31
  attribute_name_len_max      |  int32   |    64    2048     2**31
  byte_size_max               |  int32   |    1K      1M     2**31  
  lang                        |  string  |   (server defined)
  notif_buffer_drop_policy    |  string  | { "oldest", "newest",
                                             "largest", "fail" }
  notif_buffer_min            |  int32   |    1       1K     2**31
  opaque_len_max              |  int32   |    1K      1M     2**31
  string_len_max              |  int32   |    1K      1M     2**31
  sub_len_max                 |  int32   |    1K      2K     2**31
  sub_max                     |  int32   |    1K      8K     2**31
.fi
.KE
