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


sub-exp			= sub-exp bool-op sub-exp /
			  bool-exp

bool-exp		= value "==" value /
			  value "!=" value /
			  value "<" value /
			  value "<=" value /
			  value ">" value /
			  value ">=" value /
			  bool-function-exp /
			  "!" bool-exp /
			  "(" sub-exp ")"

value			= string-literal /
			  math-exp

math-exp		= math-exp math-op math-exp /
			  num-value

num-value		= num-literal /
			  name /
			  function-exp /
			  unary-math-op num-value /
			  "(" value ")"

name			= id-literal

bool-function-exp	= bool-pred "(" args ")"

function-exp		= function-pred "(" args ")"


;
; predicates
;

bool-pred		= "exists" / "int32" / "int64" /
			  "real64" / "string" / "opaque" /
			  "nan"

function-pred		= "begins-with" / "ends-with" / 
			  "contains" / "wildcard" / "regex" /
			  "equals" / "size" /
			  "fold-case" /
			  "decompose" / "decompose-compat"

;
; operators
;

bool-op			= "&&" / "^^" / "||"

math-op			= "&" / "^" / "|" /
			  "<<" / ">>" / ">>>" /
			  "+" / "-" / "*" / "/" / "%"

unary-math-op		= "+" | "-" | "~"


;
; literals
;

string-literal		= DQUOTE 0*(string-char / quote) DQUOTE /
			  quote 0*(string-char / DQUOTE) quote

string-char		= safe-utf8-char /
			  backslash safe-utf8-char /
			  magic-char

magic-char		= backslash DQUOTE /
			  backslash quote /
			  backslash backslash

safe-utf8-char		= %x01-21 / %x23-26 / %x28-5b / %x5d-fd
			; not single quote, double quote or backslash


num-literal		= int32-literal / int64-literal / real64-literal

int32-literal		= decimal-literal / octal-literal / hex-literal

int64-literal		= int32-literal "l"
			; ABNF is case insensitive so this includes "L"

real64-literal		= 1*DIGIT "." 1*DIGIT [exponent]

exponent		= "e" [ "+" | "-" ] 1*DIGIT
			; ABNF is case insensitive so this includes "E"

backslash		= %x5c

quote			= %x27

id-literal		= id-first 0*id-char

id-first		= ALPHA / "_" / backslash safe-utf8-char

id-char			= %x21 / %x23-26 / %x28 / %x2a-2b /
			  %x2d-5a / %5e-ff / backslash safe-utf8-char

owsp			= 0*swsp
wsp			= 1*swsp
swsp			=  SP / HTAB / CR / LF


.DE
