m4_dnl
m4_dnl macros for easier nroff editting
m4_dnl
m4_dnl $Id: macros.m4,v 1.5 2001/06/28 13:07:19 julian Exp $
m4_dnl
m4_dnl MACRO FOR THE DEFAULT INDENTATION
m4_dnl
m4_define(_default_in, 3)m4_dnl
m4_dnl
m4_dnl SECTION HEADING
m4_dnl
m4_define(m4_heading, `.in 0
.NH $1
$2
.ft
.in _default_in ')m4_dnl
m4_dnl
m4_dnl PREFORMATTING FOR TABLES, CODE, ETC
m4_dnl
m4_define(m4_pre, `m4_dnl
.in 3
.nf
.KS
$1
.KE
.in _default_in
.fi
')m4_dnl
m4_dnl
m4_dnl allows comments and remarks to be inserted for discussion, but
m4_dnl removed for publication of a cleaner document
m4_dnl
m4_define(m4_remark, `<FIXME>
.nf
$*
.fi
</FIXME>')m4_dnl
m4_dnl m4_define(m4_remark, `')m4_dnl

