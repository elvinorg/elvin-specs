m4_dnl
m4_dnl macros for easier nroff editing
m4_dnl
m4_dnl $Id: macros.m4,v 1.1 2000/05/11 23:21:23 arnold Exp $
m4_dnl
m4_dnl MACRO FOR THE DEFAULT INDENTATION
m4_dnl
m4_define(_default_in, 3)m4_dnl
m4_dnl
m4_dnl SECTION HEADING
m4_dnl
m4_define(m4_heading, `.ti 0
.NH $1
$2
.ft
.in _default_in')m4_dnl
m4_dnl
m4_dnl PREFORMATTING FOR TABLES, CODE, ETC
m4_dnl
m4_define(m4_pre, `m4_dnl
.in 5
.KS
.nf
$1
.fi
.KE
.in _default_in
')m4_dnl
m4_dnl
m4_dnl DATES
m4_dnl
m4_define(_yr_, `2000')m4_dnl
m4_define(_date_, `dd mmmm _yr_')
