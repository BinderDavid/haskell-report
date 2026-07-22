#import "../macros.typ" : *

In this chapter, we describe the syntax and informal semantics of
Haskell _expressions_, including their translations into the
Haskell kernel, where appropriate.  Except in the case of `let`
expressions, these translations preserve both the static and dynamic
semantics.  Free variables and constructors used in these translations
always refer to entities defined by the `Prelude`.  For example,
"`concatMap`" used in the translation of list comprehensions
(@sec:list-comprehensions[Section]) means the `concatMap` defined by
the `Prelude`, regardless of whether or not the identifier "`concatMap`" is in
scope where the list comprehension is used, and (if it is in scope)
what it is bound to.

#table(
  columns: 4,
  stroke: none,
  align: (left, center, left, left),
  // exp
  $italic("exp")$, $->$, $nonterminal("infixexp") terminal("::") [italic("context") terminal("=>")] italic("type")$, [(expression type signature)],
  [],$|$, $nonterminal("infixexp")$,[],
  // infixexp
  $italic("infixexp")$, $->$, $nonterminal("lexp") italic("qop") nonterminal("infixexp")$, [],
  [], $|$, $terminal("-") nonterminal("infixexp")$, [(prefix negation)],
  [], $|$, $nonterminal("lexp")$, [],
  // lexp
  $italic("lexp")$, $->$, $terminal("\\") italic("apat")_1 dots italic("apat")_n terminal("->") nonterminal("exp")$, [(lambda abstraction, $n >= 1$)],
  [], $|$, $terminal("let") italic("decls") terminal("in") nonterminal("exp")$, [(let expression)],
  [], $|$, $terminal("if") nonterminal("exp") [terminal(";")] terminal("then") nonterminal("exp") [terminal(";")] terminal("else") nonterminal("exp")$, [(conditional)],
  [], $|$, $terminal("case") nonterminal("exp") terminal("of") terminal("{") italic("alts") terminal("}")$, [(case expression)],
  [], $|$, $terminal("do") terminal("{") italic("stmts") terminal("}")$, [(do expression)],
  [], $|$, $nonterminal("fexp")$, [],
  // fexp
  $italic("fexp")$, $->$, $[nonterminal("fexp")] nonterminal("aexp")$, [(function application)],
  // aexp
  $italic("aexp")$, $->$, $italic("qvar")$, [(variable)],
  [], $|$, $italic("gcon")$, [(general constructor)],
  [], $|$, $nonterminal("literal")$, [],
  [], $|$, $terminal("(") nonterminal("exp") terminal(")")$, [(parenthesized expression)],
  [], $|$, $terminal("(") nonterminal("exp")_1 terminal(",") dots terminal(",") nonterminal("exp")_k terminal(")")$, [(tuple, $k>=2$)],
  [], $|$, $terminal("[") nonterminal("exp")_1 terminal(",") dots terminal(",") nonterminal("exp")_k terminal("]")$, [(list, $k>=1$)],
  [], $|$, $terminal("[") nonterminal("exp")_1 [terminal(",") nonterminal("exp")_2] terminal("..") [nonterminal("exp")_3] terminal("]")$, [(arithmetic sequence)],
  [], $|$, $terminal("[") nonterminal("exp") terminal("|") italic("qual")_1 terminal(",") dots terminal(",") italic("qual")_n terminal("]")$, [(list comprehension, $n>=1$)],
  [], $|$, $terminal("(") nonterminal("infixexp") nonterminal("qop") terminal(")")$, [(left section)],
  [], $|$, $terminal("(") nonterminal("qop")_(chevron.l terminal("-") chevron.r) nonterminal("infixexp") terminal(")")$, [(right section)],
  [], $|$, $italic("qcon") terminal("{") italic("fbind")_1 terminal(",") dots terminal(",") italic("fbind")_n terminal("}")$, [(labeled construction, $n>=0$)],
  [], $|$, $nonterminal("aexp")_(chevron.l italic("qcon") chevron.r) terminal("{") italic("fbind")_1 terminal(",") dots terminal(",") italic("fbind")_n terminal("}")$, [(labeled update, $n>=1$)],
)


Expressions involving infix operators are disambiguated by the operator's fixity (see Section~\ref{fixity}).  Consecutive unparenthesized operators with the same precedence must both be either
left or right associative to avoid a syntax error.
Given an unparenthesized expression "$x med italic("qop")^((a,i)) med y med italic("qop")^((b,j)) med z$"
(where $italic("qop")^((a,i))$ means an operator with associativity $a$ and
precedence $i$), parentheses must be added around either $x med italic("qop")^((a,i)) med y$ or $y med italic("qop")^((b,j)) med z$ when $i = j$ unless $a = b = text("l")$ or $a = b = text("r")$.

An example algorithm for resolving expressions involving infix operators is given in @sec:fixity-resolution[Section]

Negation is the only prefix operator in
Haskell; it has the same precedence as the infix `-` operator defined in the Prelude (see Section~\ref{fixity}, Figure~\ref{prelude-fixities}).

The grammar is ambiguous regarding the extent of lambda abstractions, let expressions, and conditionals.
The ambiguity is resolved by the meta-rule that each of these constructs extends as far to the right as possible.


Sample parses are shown below.

#align(center,
  table(
    columns: 2,
    align: (left, left),
    stroke: none,
    table.vline(x: 0),
    table.vline(x: 1),
    table.vline(x: 2),
    table.hline(),
    table.header([This], [Parses as]),
    table.hline(),
    [`f x + g y`],[`(f x) + (g y)`],
    [`- f x + y`],[`(- (f x)) + y`],
    [`let {...} in x + y`],[`let {...} in (x + y)`],
    [`z + let {...} in x + y`],[`z + (let {...} in (x + y))`],
    [`f x y :: Int`],[`(f x y) :: Int`],
    [`\ x -> a+b :: Int`],[`\x -> ((a+b) :: Int)`],
    table.hline(),
  )

)

For the sake of clarity, the rest of this section will assume that expressions involving infix operators have been resolved according to the fixities of the operators.

=== Errors <sec:expressions:errors>

Errors during expression evaluation, denoted by $bot$ ("bottom"),
are indistinguishable by a Haskell program from non-termination.  Since Haskell is a
non-strict language, all Haskell types include $bot$.  That is, a value
of any type may be bound to a computation that, when demanded, results
in an error.  When evaluated, errors cause immediate program
termination and cannot be caught by the user.  The Prelude provides
two functions to directly
cause such errors:

```haskell
error     :: String -> a
undefined :: a
```
A call to `error` terminates execution of
the program and returns an appropriate error indication to the
operating system.  It should also display the string in some
system-dependent manner.  When `undefined` is used, the error message
is created by the compiler.

Translations of Haskell expressions use `error` and `undefined` to
explicitly indicate where execution time errors may occur.  The actual
program behavior when an error occurs is up to the implementation.
The messages passed to the `error` function in these translations are
only suggestions; implementations may choose to display more or less
information when an error occurs.

=== Variables, Constructors, Operators, and Literals

=== Curried Applications and Lambda Abstractions

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  $italic("fexp")$, $->$, $[nonterminal("fexp")] nonterminal("aexp")$, [(function application)],
  $italic("lexp")$, $->$, $terminal("\\") italic("apat")_1 med dots med italic("apat")_n terminal("->") nonterminal("exp")$, [(lambda abstraction $n>=1$)]
)

_Function application_ is written $e_1 med e_2$.
Application associates to the left, so the
parentheses may be omitted in `(f x) y`.
Because $e_1$ could be a data constructor, partial applications of data constructors are allowed.

_Lambda abstractions_ are written
$dots$, where the $p_i$ are _patterns_.
An expression such as `\x:xs->x` is syntactically incorrect;
it may legally be written as `\(x:xs)->x`.

The set of patterns must be _linear_---no variable may appear more than once in the set.

#translation-box(
  [The following identity holds:
    $
      mono("\\") p_1 med dots med p_n mono("->") e = mono("\\") x_1 med dots med x_n mono("->") mono("case") (x_1, dots, x_n) mono("of") (p_1, dots, p_n) mono("->") e
    $
    where the $x_i$ are new identifiers.]
)

Given this translation combined with the semantics of case
expressions and pattern matching described in @subsec:formal-semantics-pattern-matching, if the
pattern fails to match, then the result is $bot$.

=== Operator Applications <sec:operator-applications>

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  $italic("infixexp")$, $->$, $nonterminal("lexp") med nonterminal("qop") med nonterminal("infixexp")$, [],
  [], $|$, $terminal("-") nonterminal("infixexp")$, [(prefix negation)],
  [], $|$, nonterminal("lexp"), [],
  $nonterminaldef("qop")$, $->$, $italic("qvarop") | italic("qconop")$, [(qualified operator)],
)

The form $e_1 italic("qop") e_2$ is the infix application of binary operator $italic("qop")$ to expressions $e_1$ and $e_2$.

The special
form $-e$ denotes prefix negation, the only
prefix operator in Haskell, and is
syntax for $mono("negate") (e)$.
The binary `-` operator does not necessarily refer
to the definition of `-` in the Prelude; it may be rebound by the module system.
However, unary `-` will always refer to the
`negate` function defined in the Prelude.  There is no link between the local meaning of the `-` operator and unary negation.

Prefix negation has the same precedence as the infix operator `-` defined in the Prelude (see
Table~\ref{prelude-fixities}).
Because `e1-e2` parses as an
infix application of the binary operator `-`, one must write `e1(-e2)` for the alternative parsing.
Similarly, `(-)` is syntax for `\x y -> x-y`, as with any infix operator, and does not denote
`\x -> -x`---one must use `negate` for that.

#translation-box([
  The following identities hold:
  $
    e_1 italic("op") e_2 &= (italic("op")) med e_1 med e_2 \
    -e &= mono("negate") (e)
  $
  ]
)

=== Sections

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  $italic("aexp")$, $->$, $terminal("(") nonterminal("infixexp") med nonterminal("qop") terminal(")")$, [(left section)],
  [], $|$, $terminal("(") nonterminal("qop")_(chevron.l terminal("-") chevron.r) nonterminal("infixexp") terminal(")")$, [(right section)]
)
$
  &|  && text("")
$

_Sections_ are written as $(italic("op") e)$ or $(e italic("op"))$, where
$italic("op")$ is a binary operator and $e$ is an expression.
Sections are a convenient syntax for partial application of binary operators.

Syntactic precedence rules apply to sections as follows.
$(italic("op") e)$ is legal if and only if $(x italic("op") e)$ parses in the same way as $(x italic("op") (e))$;
and similarly for $(e italic("op")$.
For example, `(*a+b)` is syntactically invalid, but `(+a*b)` and `(*(a+b))` are valid.
Because `(+)` is left associative, `(a+b+)` is syntactically correct,
but `(+a+b)` is not; the latter may legally be written as `(+(a+b))`.
As another example, the expression
```haskell
  (let n = 10 in n +)
```
is invalid because, by the let/lambda meta-rule (Section~\ref{expressions}),
the expression
```haskell
  (let n = 10 in n + x)
```
parses as
```haskell
  (let n = 10 in (n + x))
```
rather than
```haskell
  ((let n = 10 in n) + x)
```

Because `-` is treated specially in the grammar,
$(- italic("exp"))$ is not a section, but an application of prefix negation, as described in the preceding section.
However, there is a `subtract` function defined in the Prelude such that $(mono("subtract") italic("exp"))$
is equivalent to the disallowed section.
The expression $(+ (- italic("exp")))$ can serve the same purpose.

#translation-box([
  The following identities hold:
  $
    (italic("op") e) &= mono("\\") x mono("->") x italic("op") e\
    (e italic("op")) &= mono("\\") x mono("->") e italic("op") x
  $
  where $italic("op")$ is a binary operator, $e$ is an expression, and $x$ is a variable that does not occur free in $e$.
])

=== Conditionals

#table(
  columns: 3,
  align: (left, center, left),
  stroke: none,
  $italic("lexp")$, $->$, $terminal("if") nonterminal("exp") [terminal(";")] terminal("then") nonterminal("exp") [terminal(";")] terminal("else") nonterminal("exp")$

)

A _conditional expression_ has the form $mono("if") e_1 mono("then") e_2 mono("else") e_3$ and returns the value of $e_2$ if the
value of $e_1$ is `True`, $e_3$ if $e_1$ is `False`, and $bot$ otherwise.

#translation-box([
  The following identity holds:
  $
    mono("if") e_1 mono("then") e_2 mono("else") e_3 = mono("case") e_1 mono("of") { mono("True") mono("->") e_2 mono(";") mono("False") mono("->") e_3}
  $
  where `True` and `False` are the two nullary constructors from the type `Bool`, as defined in the Prelude.
  The type of $e_1$ must be `Bool`;
  $e_2$ and $e_3$ must have the same type, which is also the type of the entire conditional expression.
])


=== Lists

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  // infixexp
  $italic("infixexp")$, $->$, $nonterminal("exp")_1 italic("qop") nonterminal("exp")_2$, [],
  // aexp
  $italic("aexp")$, $->$, $terminal("[") nonterminal("exp")_1 terminal(",") dots terminal(",") nonterminal("exp")_k terminal("]")$, $(k >= 1)$,
  $$, $|$, $italic("gcon")$, [],
  // gcon
  $italic("gcon")$, $->$, $terminal("[]")$, [],
  [], $|$, $italic("qcon")$, [],
  // qcon
  $italic("qcon")$, $->$, $terminal("(") italic("gconsym") terminal(")")$, [],
  // qop
  $italic("qop")$, $->$, $italic("qconop")$, [],
  // qconop
  $italic("qconop")$, $->$, $italic("gconsym")$,[],
  // gconsym
  $italic("gconsym")$, $->$, $terminal(":")$, [],
)

_Lists_ are written $[e_1, dots, e_k]$, where $k >= 1$.
The list constructor is `:`, and the empty list is denoted `[]`.
Standard operations on lists are given in the Prelude (see Section~\ref{basic-lists}, and
@chapter:standard-prelude[Chapter] notably Section~\ref{preludelist}).

#translation-box([
  The following identity holds:
  $
    [e_1, dots, e_k] = e_1 : (e_2 : ( dots ( e_k : [ thin ])))
  $
  where `:` and `[]` are constructors for lists, as defined in the Prelude (see Section~\ref{basic-lists}).
  The types of $e_1$ through $e_k$ must all be the same (call it $t$), and the
  type of the overall expression is `[t]` (see Section~\ref{type-syntax}).
])

The constructor "`:`" is reserved solely for list construction; like `[]`, it is considered part of the language syntax, and cannot be hidden or redefined.
It is a right-associative operator, with precedence level 5 (Section~\ref{fixity}).

=== Tuples

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  $italic("aexp")$, $->$, $terminal("(") nonterminal("exp")_1 terminal(",") dots terminal(",") nonterminal("exp")_k terminal(")")$, $(k >= 2)$,
  [], $|$, $italic("qcon")$, [],
  $italic("qcon")$, $->$, $terminal("(") terminal(","){ terminal(",")}terminal(")")$, []
)

_Tuples_ are written $(e_1, dots, e_k)$, and may be
of arbitrary length $k >= 2$.
The constructor for an $n$-tuple is denoted by $(, dots ,)$, where there are $n-1$ commas.
Thus `(a,b,c)` and `(,,) a b c` denote the same value.
Standard operations on tuples are given
in the Prelude (see Section~\ref{basic-tuples} and @chapter:standard-prelude[Chapter].

#translation-box([
  $(e_1, dots, e_k)$ for $k >= 2$ is an instance of a $k$-tuple as defined in the Prelude, and requires no translation.
  If $t_1$ through $t_k$ are the types of $e_1$ through $e_k$, respectively, then the type of the resulting tuple is $(t_1, dots, t_k)$ (see Section~\ref{type-syntax}).
])



=== Unit Expressions and Parenthesized Expressions

#table(
  columns: 3,
  align: (left, center, left),
  stroke: none,
  $italic("aexp")$, $->$, $italic("gcon")$,
  [], $|$, $terminal("(") nonterminal("exp") terminal(")")$,
  $italic("gcon")$, $->$, $terminal("()")$
)

The form $(e$) is simply a _parenthesized expression_, and is equivalent to $e$.
The _unit expression_ `()` has type `()` (see
Section~\ref{type-syntax}).
It is the only member of that type apart from $bot$, and can be thought of as the "nullary tuple" (see Section~\ref{basic-trivial}).

#translation-box([
  $(e)$ is equivalent to $e$.
])

=== Arithmetic Sequences <sec:arithmetic-sequences>

#table(
  columns: 3,
  align: (left, center, left),
  stroke: none,
  $italic("aexp")$, $->$, $terminal("[") nonterminal("exp")_1 [terminal(",") nonterminal("exp")_2] terminal("..") [nonterminal("exp")_3] terminal("]")$,
)

The _arithmetic sequence_ $[e_1, e_2 .. e_3]$ denotes a list of values of type $t$, where each of the $e_i$ has type $t$, and $t$ is an instance of class `Enum`.

#translation-box([
  Arithmetic sequences satisfy these identities:
  $
    X &= Y\
    X &= Y\
    X &= Y\
    X &= Y\
  $
  where `enumFrom`, `enumFromThen`, `enumFromTo`, and `enumFromThenTo` are class methods in the class `Enum` as defined in the Prelude (see Figure~\ref{standard-classes}).
])

The semantics of arithmetic sequences therefore depends entirely on the instance declaration for the type `t`.  
See Section~\ref{enum-class} for more details of which `Prelude` types are in `Enum` and their semantics.

=== List Comprehensions <sec:list-comprehensions>

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  $italic("aexp")$, $->$, $terminal("[") nonterminal("exp") terminal("|") italic("qual")_1 terminal(",") dots terminal(",") italic("qual")_n terminal("]")$, [(list comprehension, $n >= 1$)],
  $italic("qual")$, $->$, $italic("pat") terminal("<-") nonterminal("exp")$, [(generator)],
  $$, $|$, $terminal("let") italic("decls")$, [(local declaration)],
  $$, $|$, $nonterminal("exp")$, [(boolean guard)],
)
=== Let Expressions

#table(
  columns: 3,
  align: (left, center, left),
  stroke: none,
  $italic("lexp")$, $->$, $terminal("let") italic("decls") terminal("in") nonterminal("exp")$
)

=== Case Expressions

=== Do Expressions

=== Datatypes with Field Labels

==== Field Selection

==== Construction Using Field Labels

==== Updates Using Field Labels

=== Expression Type-Signatures

=== Pattern Matching

==== Patterns

==== Informal Semantics of Pattern Matching

==== Formal Semantics of Pattern Matching <subsec:formal-semantics-pattern-matching>