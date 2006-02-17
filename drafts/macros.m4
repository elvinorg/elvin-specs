m4_dnl
m4_dnl macros for easier nroff editting
m4_dnl
m4_dnl $Id: macros.m4,v 1.9 2006/02/17 03:13:00 d Exp $
m4_dnl
m4_dnl MACRO FOR THE DEFAULT INDENTATION
m4_dnl
m4_define(_default_in, 3)m4_dnl
m4_dnl
m4_dnl SECTION HEADING
m4_dnl
m4_define(m4_heading, `.RE
.NH $1
$2
.RS')m4_dnl
m4_dnl
m4_dnl UNNUMBERED HEADING
m4_dnl
m4_define(em4_unnumbered, `.ID 0
\fB$1\fP
.ID _default_in ')m4_dnl
m4_dnl
m4_dnl PREFORMATTING FOR TABLES, CODE, ETC
m4_dnl
m4_define(m4_pre, `.RS
.nf
$1
.fi
.RE
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
