m4_dnl sub-syntax
m4_dnl
.bp
m4_heading(1, APPENDIX A - ELVIN SUBSCRIPTION LANGUAGE)
.LP
The Elvin subscription language is used by clients to select
notifications for delivery.  This section documents the formal syntax
for the language.

Subscription expressions are normally represented as strings in the
programming language of the client application.  These strings SHOULD
allow the entry of the full Unicode character set, either directly or
through an escaping mechanism.  The subscription string MUST be
encoded as Unicode UTF-8 prior to transmission by the client library.

While full Unicode strings are required, they are only used within the
language for representing string literals.  Attribute names are
restricted to a subset of the ASCII character set.

The specification is written using ABNF [RFC2234].

.ID 2
;  Elvin subscription language
;
;  version: 4.0

;
;  expressions
;

sub-expr		= owsp truth-value owsp

truth-value		= simple-truth-value / 
			  simple-truth-value wsp boolean-operator wsp simple-truth-value /
			  unary-boolean-op owsp simple-truth-value /
			  "(" owsp truth-value owsp ")"

simple-truth-value	= general-truth-value / string-truth-expr / numeric-truth-value

general-truth-value	= general-predicate-func "(" owsp attribute owsp ")"

string-truth-value	= string-predicate-func "(" owsp string-expr owsp "," owsp string-expr owsp ")" /
			  string-expr wsp string-predicate-op wsp string-expr

numeric-truth-value	= arithmetic-expr wsp numeric-predicate-op wsp arithmetic-expr

string-expr		= string-literal /
			  attribute /
			  string-value-func

arithmetic-expr		= numeric-literal / 
			  attribute /
			  sizeof-function / 
			  ( arithmetic-expr wsp binary-numeric-op wsp arithmetic-expr )

;
;  predicates
;

general-predicate-func	= "exists" / "int32" / "int64" / "real64" /
			  "string" / "opaque"

string-predicate-func	= "equals" / "contains" / "begins_with" /
			  "ends_with" / "wildcard" / "regex"

numeric-predicate-op	= "==" / "!=" / "<=" / "<" / ">" / ">="

string-predicate-op	= "~~" / "!~"


;
;  functions
;

sizeof-function		= "sizeof" "(" owsp attribute owsp ")"

string-value-func	= string-func-name "(" owsp (attribute / string-literal) owsp ")"

string-func-name	= "icase" / "iaccent" / "iencoding"

;
;  literals
;

string-literal		= DQUOTE 0*(string-char / quote)  DQUOTE /
			  quote  0*(string-char / DQUOTE) quote

string-char		= safe-utf8-char / backslash safe-utf8-char / magic-char

magic-char		= backslash DQUOTE / backslash quote / backslash backslash

safe-utf8-char		= %x00-21 / %x23-26 / %x28-5b / %x5d-ff
			; not single quote, double quote or backslash


numeric-literal		= int32-literal / int64-literal / real64-literal


int64-literal		= int32-literal "l"
			; ABNF is case insensitive, so we get "L" too

int32-literal		= decimal-literal / hex-literal

decimal-literal		= [unary-numeric-op] owsp 1*DIGIT

hex-literal		= "0x" 1*HEXDIGIT


real64-literal		= [unary-numeric-op] owsp 1*DIGIT "." 1*DIGIT [exponent]

exponent		= "e" [unary-numeric-op] 1*DIGIT]
			; ABNF is case insensitive, so we get "E" too


;
;  operators
;

binary-boolean-op	= log-and / log-or / log-xor
unary-boolean-op	= log-not

log-and			= "&&"
log-or			= "||"
log-xor			= "^^"
log-not			= "!"


binary-numeric-op	= "+" / "-" / "*" / "/" / "%" / "<<" / ">>" / 
			  ">>>" / "&" / "|" / "^" / "~"
unary-numeric-op	= "-" / "+"

;
;  lexical elements
;

attribute		= 1*attr-char

attr-first		= ALPHA / "#" / "$" / "%" / "&" / "*" / "." / 
			  "/" / ":" / ";" / "<" / "=" / ">" / "?" / 
			  "@" / "[" / "]" / "^" / "_" / "{" / "|" / 
			  "}" / "~" / backslash / backquote

attr-rest		= attr-first / DIGIT / "-" / "+" / "!"

backslash		= %x5c
backquote		= %x60
quote			= %x27

owsp			= 0*swsp
wsp			= 1*swsp
swsp			=  SP / HTAB / CR / LF


.DE
