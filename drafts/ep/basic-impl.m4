m4_dnl  -*- nroff -*-
m4_dnl
m4_dnl  this is the basic implementation details
m4_dnl
.KS
m4_heading(1, SUBSCRIPTION LANGUAGE)

Consumer clients register subscription expressions with a server to
request delivery of messages.  The language used for these expressions
is defined in this section.  The subscription language syntax and
semantics are considered part of the protocol: all servers supporting
a particular protocol version will understand the same subscription
language.  There is no provision for alternative languages.

A consumer client registers a subscription expression that the server
evaluates on its behalf for each message delivered to the server. If
the expression evaluates to true then the notification is delivered,
otherwise, it it not delivered.
m4_dnl
m4_heading(2, Subscription Expressions)

The subscription language uses a ternary logic when evaluating
expressions; this is then resolves to a binary result.  During
evaluation, the value `bottom' is added to represent undefined values.
For example, a comparison involving an attribute which is not present
in a notification evaluates to bottom.

With respect to boolean operations, the behaviour of bottom is quite
similar to that of false with the notable exception that the negation
of bottom (! bottom) is still bottom.

It should be emphasized that:
.IP - 2
There is neither an explicit boolean type nor are there boolean
constants for true or false.
.IP - 2
Whereas some programming languages, such as C and C++, provide an
implicit conversion from numeric values to truth values (zero means
false, nonzero means true), the Elvin subscription language requires
such a conversion to be made explicit, for example 
.QP
(i-have-been-notified != 0)
m4_dnl
m4_heading(3, Grouping)

Clauses in an expression may be grouped to override precedence of
evaluation using parentheses.  Unlike the logical or arithmetic
operators, parentheses need not be separated from attribute
identifiers or literal values by whitespace.

An implementation MAY limit the depth of nesting able to be evaluated
in subscription expressions; an expression which exceeds this limit
MUST generate a NESTING_TOO_DEEP error in response to registration
with the server.
m4_dnl
m4_heading(3, Logical Operators)

A subscription expression may be a single predicate, or it may consist
of multiple predicates composed by logical operators. The logical
operators are
.ID 2
&&   Logical AND
||   Logical OR
^^   Logical Exclusive-OR
!    Logical NOT (unary)
.DE
Logical NOT has highest precedence, followed by AND, XOR and then OR.
.KS
m4_heading(3, Literal Syntax)
.LP
A subscription expression may include literal values for most of the
message data types.  These types are

Integer Numbers
m4_dnl ***FIXME*** we lose our indent here  ***
.IP int32 10
A 32 bit, signed, 2's complement integer.
.IP int64 10
A 64 bit, signed, 2's complement integer.
.LP
Integer literals can be expressed in decimal (the default) or
hexadecimal, using a 0x prefix.  In either case, an optional leading
minus sign negates the value, and a trailing "l" or "L" indicates that
the value should be of type int64.
.KE
.LP
Literal values too large to be converted to an int32, but without the
suffix specifying an int64 type, are illegal.  Similarly, values with
the suffix, too large to be converted to an int64, are illegal.

.KS
Real Numbers
.IP real64 10
An IEEE 754 double precision floating point number.
.LP
Real literals can be expressed only in decimal, and must include a
decimal point and both whole and fractional parts.  An optional
integer exponent may be added following an "e" or "E" after the
fractional part.
.KE

.KS
Character Strings
.IP string 10
A UTF-8 encoded Unicode string of known length, with no NUL (0x00)
bytes.
.LP
String literals must be quoted using either the UTF-8 single or double
quote characters.  Within the (un-escaped) quotes, a backslash
character functions as an escape for the following character.  All
escaped characters except the quotes represent themselves.
.KE
There is no mechanism for including special characters in string
literals; each language mapping is expected to use its own mechanism
to achieve this.

.KS
Opaque Octet Data
.IP opaque 10
An opaque octet string of known length.
.LP
The subscription language does not support opaque literals; reference
to opaque attributes in a subscription expression is limited to use of
the sizeof() function.
.KE

There are no structured data types (C struct, enum or union), nor is
there a boolean data type.  All of these can be implemented simply
using the existing types and structured naming.

String and opaque data values have known sizes (ie. they don't use a
termination character).  An implementation MAY enforce limits on these
sizes; see section X on Server Features.
m4_dnl
m4_heading(3, Reference Syntax)

Predicates and function may also use values obtained from the message
under evaluation.  Values are referred to using the name of the
message attribute.

Names must be separated from operators by whitespace.  What other
rules here?
m4_dnl
m4_heading(3, General predicates)
.LP
The subscription language defines a number of predicates that return
boolean values.
.KE
Any predicate may be applied to any attribute name. If the named attribute
does not exist in the current notification, or exists but has an
inappropriate type for the predicate, the predicate returns bottom.
.IP require(attribute) 4
Returns true if the notification contains an attribute whose name
exactly matches that specified (even if the attribute's value is, say,
an empty string or a zero-length opaque value).
.IP int32(attribute) 4
Returns true if the type of the attribute is 
.B int32.
.KS
.IP int64(attribute) 4
Returns true if the type of the attribute is 
.B int64.
.KE
.KS
.IP real64(attribute) 4
Returns true if the type of the attribute is 
.B real64.
.KE
.KS
.IP nan(attribute) 4
Returns true if the type of the specified attribute is
.B real64
and its value is the IEEE 754-defined constant NaN (not a number).
There is no literal constant value for NaN because comparing the value
of an attribute against such a numeric expression is equivalent to
using this predicate.
.KE
.KS
.IP string(attribute) 4
Returns true if the type of the attribute is 
.B string.
.KE
.KS
.IP opaque(attribute) 4
Returns true if the type of the attribute is 
.B opaque.
.KE
m4_dnl
m4_heading(3, String predicates)

Some of the most used features of the subscription language are its
string predicates.  The most general provides regular-expression
("regex") matching, but simpler predicates are also provided, ranging
from wildcarding (or "globbing") down to straight-forward string
equality.  While these could all be replaced by regular-expression
operations, it is generally clearer to use and more efficient to
implement the simpler forms when they suit.
.LP
The string predicates are:
.IP "equals(attr, stringconst+)" 4
Returns true if any stringconst equals the value of attr.
.IP "contains(attr, stringconst+)" 4
Returns true if any stringconst is a substring of the value of attr.
.IP "begins_with(attr, stringconst+)" 4
Returns true if any stringconst is an initial substring (prefix) of
the value of attr.
.IP "ends_with(attr, stringconst+)" 4
Returns true if any stringconst is a final substring (suffix) of the
value of attr.
.IP "wildcard(attr, stringconst+)" 4
Returns true if the value of attr matches a wildcard ("glob")
expression specified by any stringconst value. Need pointer to glob
semantics.
.IP "regex(attr, stringconst)" 4
Returns true if the value of attr matches the regular expression
specified by the stringconst. Need pointer to (E?)RE semantics.
.LP
In the definitions above, the empty (zero-length) substring is
defined to be a substring of every string, and any string is a
substring of itself. Thus
.B begins_with 
and
.B ends_with 
imply
.B contains, 
and 
.B equals 
implies all three of them.
.LP
For many subscriptions, string (in)equality is the most used
predicate.  For simplicity, the following shorthand notations may also
be used:
.QP 
string-expr-1 == string-expr-2
.LP
is equivalent to 
.QP 
equals(string-expr-1, string-expr-2)
.LP
and
.QP 
string-expr-1 != string-expr-2
.LP
is equivalent to 
.QP
!equals(string-expr-1, string-expr-2)
.LP
There are no predicates for string comparison, i.e. testing whether one
string "is less than" another string.
m4_dnl
m4_heading(3, Implications of International Characters)

Unicode characters introduce some complexity to the string
predicates.  Comparison of Unicode characters must consider two
aspects: character decomposition, and strength of the comparison.
m4_dnl
m4_heading(4, Decomposition)

A single Unicode "character" might consist of a base character
together with a number of combining characters (such as accents),
represented as either a single, pre-composed character, or as a
sequence of characters which are combined for presentation.  In
addition, because the Unicode standard attempts to encompass existing
character sets, there can be multiple representations of the same
basic character.

In order to compare two Unicode strings, you might want to ensure that
two different representations of the same character compare as equal.
In order to do this, pre-composed characters (consisting of a base
character and some combining characters, can be decomposed to a
canonical representation.

For example,
.QP
LATIN SMALL LETTER A WITH GRAVE (\\u00e0)
.LP
decomposes to the two characters
.QP
LATIN SMALL LETTER A + COMBINING GRAVE ACCENT (\\u0061 + \\u0300)
.LP
As an additional complication, there exist Unicode characters that
have multiple pre-composed representations, and in performing
decomposition, the information about which original character was used
is lost.  The process of performing decomposition of these characters
(in addition to those for which the process is straight-forward) is
called compatibility decomposition.

Two string functions are provided to perform decomposition of Unicode
strings prior to comparison:
.IP "decompose(string)" 4
Perform canonical decomposition of the supplied string and return the
resulting string value.
.IP "decompose_compat(string)" 4
Perform compatible (and canonical) decomposition of the supplied string
and return the resulting string value.
m4_dnl
m4_heading(4, Comparison Strength)
.LP
There are four "strengths" of comparison defined for Unicode
characters: identical, primary, secondary and tertiary.  Three string
functions are defined to perform conversions to the non-default
strengths prior to comparison (the default strength is identical):
.IP "primary(string)" 4
Return a string value containing the primary characteristics of the
supplied string.  The primary characteristic of a Unicode character
is its base character, stripped of case and accents.
.IP "secondary(string)" 4
Return a string value containing the secondary characteristics of the
supplied string.  Secondary characteristics retain accents, but strip
case.
.IP "tertiary(string)" 4
Return a string value containing the tertiary characteristics of the
supplied string.  Strings which differ only in tertiary
characteristics, are identical save for their bitwise representation:
they have the same base character, case and accents.  Importantly,
embedded control characters are stripped during tertiary conversion.
m4_dnl
m4_heading(3, Numeric predicates)

The numeric predicates are the usual arithmetic comparison operators:
.IP "==" 4
Equal to
.IP "<" 4
Less than
.IP "<=" 4
Less than or equal to
.IP ">" 4
Greater than
.IP ">=" 4
Greater than or equal to
.LP
These predicates can be applied to numeric literals, attributes and
expressions.  When applied to attributes, or expressions containing an
attribute, it is important to understand the effect of using an
undefined attribute name.
.QP
A reference to an undefined attribute sets the closest enclosing
boolean expression to false.
.LP
This will normally mean that the numeric predicate will return false,
leading to apparently anomalous cases:
.KS
.RS 2

Consider an expression referring to two int32 attributes
.QP
A <= B || A > B
.LP
While it could be expected that this expression would always return
true, in fact it will return false if neither A nor B is defined.

.RE
.KE
.LP
The application of the equality predicate to values of type real64 can
also appear anomalous due to rounding errors.  Two real64 values are
defined to be equal if their sign, mantissa and exponent are all
equal.  More useful comparison of real64 numbers can be achieved using
the less-than and greater-than predicates.

In addition to these predicate, the following syntactic sugar is
defined for convenience
.IP "!=" 4
Not equal to. 
.LP
While superficially similar to the predicates above, it is in fact
implemented using other predicates, like
.QP
!(A == B)
.LP
which can again cause confusion when the attributes are not defined.
m4_dnl
m4_heading(3, Numeric functions)

The following functions are defined on all three numeric types:
.IP "+" 4
Addition
.IP "-" 4
Subtraction (also unary negation)
.IP "*" 4
Multiplication
.IP "/" 4
Division
.LP
The following operators are defined only on the two integer types, int32 and
int64: 
.QP
m4_remark(Need to pin down 5- and 6-bit shifts (and different promotion
rules?), as Java does.  Also modulus could be done for real64 too
(Java does), but why?)
.IP "%" 4
Remainder (modulus)
.IP "<<" 4
Left `shift'
.IP ">>" 4
Right `shift', signed/arithmetic (`shift' in the value of the sign bit)
.IP ">>>" 4
Right `shift', unsigned/logical (`shift' in 0)
.IP "&" 4
Bitwise AND
.IP "|" 4
Bitwise OR
.IP "^" 4
Bitwise XOR
.IP "~" 4
Bitwise inversion (unary)
m4_dnl
m4_heading(2, Numeric type promotion)

The three numeric types (int32, int64 and real64) may be mixed freely
in numeric expressions, and Elvin performs automatic type promotions
when necessary.

If the arguments to a numeric predicate or the components of an
expression have different numeric types, their values are promoted to
a common numeric type before the predicate or expression is
evaluated. For an expression, the type of the result value is always
the promoted type, even if the result would fit in a smaller type.

The promotion rule is "real64 > int64 > int32", or in other words:

.IP "1." 3
If either operand is real64, the promoted type is also real64.
.IP "2." 3
Otherwise, if either operand is int64, the promoted type is also int64.
.IP "3." 3
Otherwise, both operands must be int32, and no promotion is required.
m4_dnl
m4_heading(2, Subscription Errors)

Elvin subscriptions are compiled by the server after submission at runtime.
Various errors are possible; this section documents the error conditions.

m4_remark(I don't think we should have ANY lang specific stuff
here.  better to refer to a section on abstract errors independent of
any particular naming conventions.  ie like the different packet types
are current defined. Is this the Failures section in
abstract-protocol.m4? jb)

Errors are reported as numbers so that language-specific error
messages may be used by the client. This section shows symbols from
the C language binding; for the corresponding error numbers, please
see <elvin4/errors.h> or documentation for your language binding.

.IP SYNTAX_ERROR 4
Non-specific syntactic problem.
.IP IDENTIFIER_TOO_LONG 4
the supplied element identifier exceeds the maximum allowed length.
.IP BAD_IDENTIFIER 4
the supplied element identifier contains illegal characters. Remember
that the first character must be only a letter or underscore.
m4_dnl
m4_heading(3, Runtime evaluation errors in numeric expressions)

During the evaluation of a numeric predicate (including the evaluation of
any expressions that are the arguments to the predicate), the following
classes of errors may occur:

.IP 1. 3
Errors that cause the predicate to return false:
.IP
o Use of an attribute that does not exist in the notification,
.IP
o Use of an attribute, constant or expression that has an
  inappropriate type (for example, real64, string or opaque in a
  function that expects int32 or int64)
.IP
o int32 or int64 division by zero.
.IP 2. 3
Integer overflow. This is silently ignored and the result is undefined,
or do we define it to be wrapped to 32 or 64 bits?
.IP 3. 3
Floating-point errors, including underflow, overflow and division by
zero, are silently mapped to the appropriate IEEE 754 values.

.QP
m4_remark(Do we want predicates for 754 values, e.g. isNan()?

Need to check whether 754 defines all relationals to return FALSE if
either argument is NaN. (What about other magic numbers, e.g.
underflow?) Does 754 specify behaviour of != with NaN, and how does
that compare to Elvin semantics?)
