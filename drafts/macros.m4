m4_dnl
m4_dnl macros for easier nroff editing
m4_dnl
m4_dnl $Id: macros.m4,v 1.10 2006/10/12 10:16:13 d Exp $
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
m4_dnl UNNUMBERED HEADING
m4_dnl
m4_default(em4_unnumbered, `.ti 0
\fB$1\fP
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
m4_dnl allows comments and remarks to be inserted for discussion, but
m4_dnl removed for publication of a cleaner document
m4_dnl
m4_define(m4_remark, `<FIXME>
.nf
$*
.fi
</FIXME>')m4_dnl
m4_dnl m4_define(m4_remark, `')m4_dnl
