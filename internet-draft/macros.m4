m4_dnl
m4_dnl macros for easier nroff editting
m4_dnl
m4_dnl $Id: macros.m4,v 1.4 1999/09/30 08:03:50 julian Exp $
m4_dnl
m4_define(_default_in, 3)m4_dnl
m4_dnl
m4_dnl
m4_define(m4_heading, `.ti 0
.NH $1
$2
.ft
.in _default_in')m4_dnl
m4_dnl
m4_dnl
m4_define(m4_pre, `
.in 5
.KS
.nf
$1
.fi
.KE
.in _default_in
')m4_dnl





