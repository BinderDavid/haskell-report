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
  $italic("exp")$, $->$, $nonterminal("infixexp") terminal("::") [nonterminal("context") terminal("=>")] nonterminal("type")$, [(expression type signature)],
  [],$|$, $nonterminal("infixexp")$,[],
  // infixexp
  $italic("infixexp")$, $->$, $nonterminal("lexp") nonterminal("qop") nonterminal("infixexp")$, [],
  [], $|$, $terminal("-") nonterminal("infixexp")$, [(prefix negation)],
  [], $|$, $nonterminal("lexp")$, [],
  // lexp
  $italic("lexp")$, $->$, $terminal("\\") nonterminal("apat")_1 dots nonterminal("apat")_n terminal("->") nonterminal("exp")$, [(lambda abstraction, $n >= 1$)],
  [], $|$, $terminal("let") nonterminal("decls") terminal("in") nonterminal("exp")$, [(let expression)],
  [], $|$, $terminal("if") nonterminal("exp") [terminal(";")] terminal("then") nonterminal("exp") [terminal(";")] terminal("else") nonterminal("exp")$, [(conditional)],
  [], $|$, $terminal("case") nonterminal("exp") terminal("of") terminal("{") nonterminal("alts") terminal("}")$, [(case expression)],
  [], $|$, $terminal("do") terminal("{") nonterminal("stmts") terminal("}")$, [(do expression)],
  [], $|$, $nonterminal("fexp")$, [],
  // fexp
  $italic("fexp")$, $->$, $[nonterminal("fexp")] nonterminal("aexp")$, [(function application)],
  // aexp
  $italic("aexp")$, $->$, $nonterminal("qvar")$, [(variable)],
  [], $|$, $nonterminal("gcon")$, [(general constructor)],
  [], $|$, $nonterminal("literal")$, [],
  [], $|$, $terminal("(") nonterminal("exp") terminal(")")$, [(parenthesized expression)],
  [], $|$, $terminal("(") nonterminal("exp")_1 terminal(",") dots terminal(",") nonterminal("exp")_k terminal(")")$, [(tuple, $k>=2$)],
  [], $|$, $terminal("[") nonterminal("exp")_1 terminal(",") dots terminal(",") nonterminal("exp")_k terminal("]")$, [(list, $k>=1$)],
  [], $|$, $terminal("[") nonterminal("exp")_1 [terminal(",") nonterminal("exp")_2] terminal("..") [nonterminal("exp")_3] terminal("]")$, [(arithmetic sequence)],
  [], $|$, $terminal("[") nonterminal("exp") terminal("|") nonterminal("qual")_1 terminal(",") dots terminal(",") nonterminal("qual")_n terminal("]")$, [(list comprehension, $n>=1$)],
  [], $|$, $terminal("(") nonterminal("infixexp") nonterminal("qop") terminal(")")$, [(left section)],
  [], $|$, $terminal("(") nonterminal("qop")_(chevron.l terminal("-") chevron.r) nonterminal("infixexp") terminal(")")$, [(right section)],
  [], $|$, $nonterminal("qcon") terminal("{") nonterminal("fbind")_1 terminal(",") dots terminal(",") nonterminal("fbind")_n terminal("}")$, [(labeled construction, $n>=0$)],
  [], $|$, $nonterminal("aexp")_(chevron.l nonterminal("qcon") chevron.r) terminal("{") nonterminal("fbind")_1 terminal(",") dots terminal(",") nonterminal("fbind")_n terminal("}")$, [(labeled update, $n>=1$)],
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

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  // aexp
  $italic("aexp")$, $->$, $nonterminal("qvar")$, [(variable)],
  $$,$|$,$nonterminal("gcon")$,[(general constructor)],
  $$,$|$,$nonterminal("literal")$,[],
  // gcon
  $italic("gcon")$, $->$, $terminal("()")$, [],
  $$,$|$,$terminal("[]")$,[],
  $$,$|$,$terminal("(,") {terminal(",")} terminal(")")$,[],
  $$,$|$,$nonterminal("qcon")$,[],
  // var
  $italic("var")$, $->$, $nonterminal("varid") | terminal("(") nonterminal("varsym") terminal(")")$, [(variable)],
  // qvar
  $italic("qvar")$, $->$, $nonterminal("qvarid") | terminal("(") nonterminal("qvarsym") terminal(")")$, [(qualified variable)],
  // con
  $italic("con")$, $->$, $nonterminal("conid") | terminal("(") nonterminal("consym") terminal(")")$, [(constructor)],
  // qcon
  $italic("qcon")$, $->$, $nonterminal("qconid") | terminal("(") nonterminal("gconsym") terminal(")")$, [(qualified constructor)],
  // varop
  $italic("varop")$, $->$, $nonterminal("varsym") | terminal("`") nonterminal("varid") terminal("`")$, [(variable operator)],
  // qvarop
  $italic("qvarop")$, $->$, $nonterminal("qvarsym") | terminal("`") nonterminal("qvarid") terminal("`")$, [(qualified variable operator)],
  // conop
  $italic("conop")$, $->$, $nonterminal("consym") | terminal("`") nonterminal("conid") terminal("`")$, [(constructor operator)],
  // qconop
  $italic("qconop")$, $->$, $nonterminal("gconsym") | terminal("`") nonterminal("qconid") terminal("`")$, [(qualified constructor operator)],
  // op
  $italic("op")$, $->$, $nonterminal("varop") | nonterminal("conop")$, [(operator)],
  // qop
  $italic("qop")$, $->$, $nonterminal("qvarop") | nonterminal("qconop")$, [(qualified operator)],
  // gconsym
  $italic("gconsym")$, $->$, $terminal(":") | nonterminal("qconsym")$, [],
)

Haskell provides special syntax to support infix notation.
An _operator_ is a function that can be applied using infix 
syntax (Section~\ref{operators}), or partially applied using a
_section_ (Section~\ref{sections}).

An _operator_ is either an _operator symbol_, such as `+` or `$$`,
or is an ordinary identifier enclosed in grave accents (backquotes), such
as #raw("`op`").  For example, instead of writing the prefix application
`op x y`, one can write the infix application #raw("x `op` y").
If no fixity declaration is given for `op` then it defaults
to highest precedence and left associativity
(see Section~\ref{fixity}).

Dually, an operator symbol can be converted to an ordinary identifier
by enclosing it in parentheses.  For example, `(+) x y` is equivalent
to `x + y`, and `foldr (*) 1 xs` is equivalent to `foldr (\x y -> x*y) xs`.

Special syntax is used to name some constructors for some of the
built-in types, as found
in the production for $italic("gcon")$ and $italic("literal")$.  These are described
in Section~\ref{basic-types}.

An integer literal represents the
application of the function `fromInteger` to the
appropriate value of type `Integer`.
Similarly, a floating point literal stands for an application of `fromRational` to a value of type `Rational` (that is, `Ratio Integer`).

#translation-box([
  The integer literal $i$ is equivalent to $mono("fromInteger") i$,
  where `fromInteger` is a method in class `Num` (see Section \ref{numeric-literals}).

  The floating point literal $f$ is equivalent to $mono("fromRational") (n mono("Ratio.%") d)$, where `fromRational` is a method in class `Fractional` `Ratio.%` constructs a rational from two integers, as defined in
the `Ratio` library.
The integers $n$ and $d$ are chosen so that $n \/ d = f$.
])


=== Curried Applications and Lambda Abstractions

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  $italic("fexp")$, $->$, $[nonterminal("fexp")] nonterminal("aexp")$, [(function application)],
  $italic("lexp")$, $->$, $terminal("\\") nonterminal("apat")_1 med dots med nonterminal("apat")_n terminal("->") nonterminal("exp")$, [(lambda abstraction $n>=1$)]
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
  $italic("qop")$, $->$, $nonterminal("qvarop") | nonterminal("qconop")$, [(qualified operator)],
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
  $italic("infixexp")$, $->$, $nonterminal("exp")_1 nonterminal("qop") nonterminal("exp")_2$, [],
  // aexp
  $italic("aexp")$, $->$, $terminal("[") nonterminal("exp")_1 terminal(",") dots terminal(",") nonterminal("exp")_k terminal("]")$, $(k >= 1)$,
  $$, $|$, $nonterminal("gcon")$, [],
  // gcon
  $italic("gcon")$, $->$, $terminal("[]")$, [],
  [], $|$, $nonterminal("qcon")$, [],
  // qcon
  $italic("qcon")$, $->$, $terminal("(") nonterminal("gconsym") terminal(")")$, [],
  // qop
  $italic("qop")$, $->$, $nonterminal("qconop")$, [],
  // qconop
  $italic("qconop")$, $->$, $nonterminal("gconsym")$,[],
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
  [], $|$, $nonterminal("qcon")$, [],
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
  $italic("aexp")$, $->$, $nonterminal("gcon")$,
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
  $italic("aexp")$, $->$, $terminal("[") nonterminal("exp") terminal("|") nonterminal("qual")_1 terminal(",") dots terminal(",") nonterminal("qual")_n terminal("]")$, [(list comprehension, $n >= 1$)],
  $italic("qual")$, $->$, $nonterminal("pat") terminal("<-") nonterminal("exp")$, [(generator)],
  $$, $|$, $terminal("let") nonterminal("decls")$, [(local declaration)],
  $$, $|$, $nonterminal("exp")$, [(boolean guard)],
)

A _list comprehension_ has the form $[e | q_1, dots, q_n]$, $n >= 1$,
where the $q_i$ qualifiers are either

- _generators_ of the form $p mono("<-") e$, where $p$ is a
  pattern (see Section~\ref{pattern-matching}) of type $t$ and $e$ is an
  expression of type $[t]$
- _local bindings_ that provide new definitions for use in
  the generated expression $e$ or subsequent boolean guards and generators
- _boolean guards_, which are arbitrary expressions of
  type `Bool`.


Such a list comprehension returns the list of elements
produced by evaluating $e$ in the successive environments
created by the nested, depth-first evaluation of the generators in the
qualifier list.  Binding of variables occurs according to the normal
pattern matching rules (see Section~\ref{pattern-matching}), and if a
match fails then that element of the list is simply skipped over.  Thus:
```haskell
[ x |  xs   <- [ [(1,2),(3,4)], [(5,4),(3,2)] ], 
      (3,x) <- xs ]
```
yields the list `[4,2]`.  If a qualifier is a boolean guard, it must evaluate
to `True` for the previous pattern match to succeed.  
As usual, bindings in list comprehensions can shadow those in outer scopes; for example:
$
  [x | x mono("<-") x, x mono("<-") x] = [z | y mono("<-") x, z mono("<-") y]
$
#translation-box([
  List comprehensions satisfy these identities, which may be used as a translation into the kernel:
  #align(center)[
    #table(
      columns: 3,
      align: (left, center, left),
      stroke: none,
      $[e | mono("True")]$,$=$, $[e]$,
      $[e | q]$,$=$,$[e | q, mono("True")]$,
      $[e | b, Q]$, $=$, $mono("if") b mono("then") [e, Q] mono("else") []$,
      $[e | p mono("<-") l, Q]$, $=$, $mono("let ok") = [e | Q]$,
      $$, $$, $mono("      ok") \_ = []$,
      $$, $$, $mono("in concatMap ok") l$,
      $[e | mono("let") italic("decls"), Q]$, $=$, $mono("let") italic("decls") mono("in") [e | Q]$
    )
  ]
  where $e$ ranges over expressions, $p$ over
  patterns, $l$ over list-valued expressions, $b$ over
  boolean expressions, $italic("decls")$ over declaration lists, $q$ over qualifiers, and $Q$ over sequences of qualifiers.  `ok` is a fresh variable.
  The function `concatMap`, and boolean value `True`, are defined in the Prelude.
])

As indicated by the translation of list comprehensions, variables
bound by `let` have fully polymorphic types while those defined by
`<-` are lambda bound and are thus monomorphic (see Section \ref{monomorphism}).

=== Let Expressions

#table(
  columns: 3,
  align: (left, center, left),
  stroke: none,
  $italic("lexp")$, $->$, $terminal("let") nonterminal("decls") terminal("in") nonterminal("exp")$
)


_Let expressions_ have the general form $mono("let") { d_1; dots ; d_n} mono("in") e$,
and introduce a
nested, lexically-scoped, 
mutually-recursive list of declarations (`let` is often called `letrec`).  The scope of the declarations is the expression $e$ and the right hand side of the declarations.  Declarations are
described in Chapter~\ref{declarations}.  Pattern bindings are matched
lazily; an implicit `~` makes these patterns
irrefutable.
For example, 
$
  mono("let") (x,y) = mono("undefined in") e
$

does not cause an execution-time error until `x` or `y` is evaluated.

#translation-box([
  The dynamic semantics of the expression 
  $mono("let") { d_1; dots ; d_n} mono("in") e_0$
  are captured by this translation: After removing all type signatures, each declaration $d_i$ is translated into an equation of the form $p_i = e_i$, where $p_i$ and $e_i$ are patterns and expressions
  respectively, using the translation in
  Section~\ref{function-bindings}.  Once done, these identities
  hold, which may be used as a translation into the kernel:
  #align(center)[
    #table(
      columns: 3,
      align: (left, center, left),
      stroke: none,
      $mono("let") { p_1 = e_1 ; dots ; p_n = e_n} mono("in") e_0$, $=$, $mono("let")(~p_1, dots,~p_n) = (e_1, dots, e_n) mono("in") e_0$,
      $mono("let") p = e_1 mono("in") e_0$, $=$, $mono("case") e_1 mono("of") ~p mono("->") e_0$,
      $$, $$, [where no variable in $p$ appears free in $e_1$],
      $mono("let") p = e_1 mono("in") e_0$, $=$, $mono("let") p = mono("fix") (\\ ~p mono("->") e_1) mono("in") e_0$
    )
  ]
  where `fix` is the least fixpoint operator.  Note the use of the irrefutable patterns `~p`.
  This translation
  does not preserve the static semantics because the use of `case` precludes a fully polymorphic typing of the bound variables.
  The static semantics of the bindings in a `let` expression are described in 
  Section~\ref{pattern-bindings}.
])

=== Case Expressions

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  $italic("lexp")$, $->$, $terminal("case") nonterminal("exp") terminal("of {") nonterminal("alts") terminal("}")$,$$,
  $italic("alts")$, $->$, $nonterminal("alt")_1 terminal(";") dots terminal(";") nonterminal("alt")_n$, $(n >= 1)$,
  $italic("alt")$, $->$,$nonterminal("pat") terminal("->") nonterminal("exp") [terminal("where") nonterminal("decls")]$,$$,
  $$,$|$,$nonterminal("pat") nonterminal("gdpat") [terminal("where") nonterminal("decls")]$,[],
  $$,$|$,$$,[(empty alternative)],
  $italic("gdpat")$, $->$,$nonterminal("guards") terminal("->") nonterminal("exp") [ nonterminal("gdpat")]$,$$,
  $italic("guards")$, $->$,$terminal("|") nonterminal("guard")_1 terminal(",") dots terminal(",") nonterminal("guard")_n$,$(n >= 1)$,
  $italic("guard")$, $->$,$nonterminal("pat") terminal("<-") nonterminal("infixexp")$,[(pattern guard)],
  $$,$|$,$terminal("let") nonterminal("decls")$,[(local declaration)],
  $$,$|$,$nonterminal("infixexp")$, [(boolean guard)]
)

A _case expression_ has the general form
$
  mono("case") e mono("of") { p_1 italic("match")_1 ; dots ; p_n italic("match")_n}
$
where each $italic("match")_i$ is of the general form
$
  &| italic("gs")_(i 1) mono("->") e_(i 1) \
  & dots \
  &| italic("gs")_(i m_i) mono("->") e_(i m_i) \
  &mono("where") italic("decls")_i
$
(Notice that in the syntax rule for $italic("guards")$, the "`|`" is a terminal symbol, not the syntactic metasymbol for alternation.)
Each alternative $p_i italic("match")_i$ consists of a 
pattern $p_i$ and its matches, $italic("match")_i$.
Each match in turn
consists of a sequence of pairs of guards $italic("gs")_(italic("ij"))$ and bodies $e_(italic("ij"))$ (expressions), followed by
optional bindings ($italic("decls")_i$) that scope over all of the guards and expressions of the alternative.

A _guard_ has one of the following forms:

- _pattern guards_ are of the form $p mono("<-") e$, where
  $p$ is a 
  pattern (see Section~\ref{pattern-matching}) of type $t$ and $e$ is an
  expression type $t$#footnote[Note that the syntax of a pattern guard is the same as that of a generator in a list comprehension. 
  The contextual difference is that, in a list comprehension, a pattern of type $t$ goes with an expression of type $[t]$.].
  They succeed if the expression $e$ matches the pattern $p$, and introduce the bindings of the pattern to the environment.
- _local bindings_ are of the form $mono("let") italic("decls")$.
  They always succeed, and they introduce the names defined in $italic("decls")$ to the environment.
- _boolean guards_ are arbitrary expressions of
  type `Bool`.  They succeed if the expression evaluates to `True`, and they do not introduce new names to the environment.  A boolean guard, $g$, is semantically equivalent to the pattern guard $mono("True <-") g$.

An alternative of the form
$
  italic("pat") mono("->") italic("exp") mono("where") italic("decls")
$
is treated as shorthand for:
$
  &italic("pat") | mono("True ->") italic("exp") \
  &mono("where") italic("decls")
$

A case expression must have at least one alternative and each alternative must
have at least one body.  Each body must have the same type, and the
type of the whole expression is that type.

A case expression is evaluated by pattern matching the expression $e$
against the individual alternatives.  The alternatives are tried
sequentially, from top to bottom.  If $e$ matches the pattern of an
alternative, then the guarded expressions for that alternative are
tried sequentially from top to bottom in the environment of the case
expression extended first by the bindings created during the matching
of the pattern, and then by the $italic("decls")_i$ in the `where` clause associated with that alternative.

For each guarded expression, the comma-separated guards are tried
sequentially from left to right.  If all of them succeed, then the
corresponding expression is evaluated in the environment extended with
the bindings introduced by the guards.  That is, the bindings that are
introduced by a guard (either by using a let clause or a pattern
guard) are in scope in the following guards and the corresponding
expression.  If any of the guards fail, then this guarded expression
fails and the next guarded expression is tried.

If none of the guarded expressions for a given alternative succeed,
then matching continues with the next alternative.  If no alternative
succeeds, then the result is $bot$.  Pattern matching is described in
Section~\ref{pattern-matching}, with the formal semantics of case
expressions in Section~\ref{case-semantics}.

_A note about parsing._
The expression
```haskell
  case x of { (a,_) | let b = not a in b :: Bool -> a }
```
is tricky to parse correctly.  It has a single unambiguous parse, namely
```haskell
  case x of { (a,_) | (let b = not a in b :: Bool) -> a }
```
However, the phrase `Bool -> a` is syntactically valid as a type, and parsers with limited lookahead may incorrectly commit to this choice, and hence reject the program.
Programmers are advised, therefore, to avoid guards that
end with a type signature --- indeed that is why a $italic("guard")$ contains an $italic("infixexp")$ not an $italic("exp")$.

=== Do Expressions

#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  $italic("lexp")$, $->$, $terminal("do {") nonterminal("stmts") terminal("}")$, [(do expression)],
  $italic("stmts")$, $->$, $nonterminal("stmt")_1 dots nonterminal("stmt")_n nonterminal("exp") [terminal(";")]$, $(n >= 0)$,
  $italic("stmt")$, $->$, $nonterminal("exp") terminal(";")$, [],
  $$,$|$,$nonterminal("pat") terminal("<-") nonterminal("exp") terminal(";")$,[],
  $$,$|$,$terminal("let") nonterminal("decls") terminal(";")$,[],
  $$,$|$,$terminal(";")$,[(empty statement)],
)

A _do expression_ provides a more conventional syntax for monadic programming.
It allows an expression such as 
```haskell
  putStr "x: "    >> 
  getLine         >>= \l ->
  return (words l)
```
to be written in a more traditional way as:
```haskell
  do putStr "x: "
     l <- getLine
     return (words l)
```

#translation-box([
  Do expressions satisfy these identities, which may be
  used as a translation into the kernel, after eliminating empty $italic("stmts")$:
  #align(center)[
    #table(
      columns: 3,
      align: (left, center, left),
      stroke: none,
      $mono("do") {e}$, $=$, $e$,
      $mono("do") {e ; italic("stmts")}$, $=$, $e mono(">>") mono("do") {italic("stmts")}$,
      $mono("do") {p mono("<-") e; italic("stmts")}$, $=$,$mono("let ok") p = mono("do") { italic("stmts")}$,
      $$,$$,$mono("      ok") \_ = mono("fail \"...\"")$,
      $$,$$,$mono("in") e mono(">>=") mono("ok")$,
      $mono("do") {mono("let") italic("decls"); italic("stmts")}$, $=$,$mono("let") italic("decls") mono("in do") { italic("stmts")}$
    )
  ]
  The ellipsis "`...`" stands for a compiler-generated error message,
  passed to `fail`, preferably giving some indication of the location
  of the pattern-match failure;
  the functions `>>`, `>>=`, and `fail` are operations in the class `Monad`,
  as defined in the Prelude; and `ok` is a fresh identifier. 
])

As indicated by the translation of `do`, variables bound by `let` have fully polymorphic types while those defined by `<-` are lambda bound and are thus monomorphic.

=== Datatypes with Field Labels

A datatype declaration may optionally define field labels
(see Section~\ref{datatype-decls}).
These field labels can be used to 
construct, select from, and update fields in a manner
that is independent of the overall structure of the datatype.

Different datatypes cannot share common field labels in the same scope.
A field label can be used at most once in a constructor.
Within a datatype, however, a field label can be used in more
than one constructor provided the field has the same typing in all
constructors. To illustrate the last point, consider:
```haskell
  data S = S1 { x :: Int } | S2 { x :: Int }   -- OK
  data T = T1 { y :: Int } | T2 { y :: Bool }  -- BAD
```
Here `S` is legal but `T` is not, because `y` is given 
inconsistent typings in the latter.

==== Field Selection

#table(
  columns: 3,
  align: (left, center, left),
  stroke: none,
  $italic("aexp")$, $->$, $nonterminal("qvar")$
)

Field labels are used as selector functions.
When used as a variable, a field label serves as a function that extracts the field from an object.
Selectors are top level bindings and so they
may be shadowed by local variables but cannot conflict with 
other top level bindings of the same name.  This shadowing only
affects selector functions; in record construction (Section~\ref{record-construction}) 
and update (Section~\ref{record-update}), field labels
cannot be confused with ordinary variables. 

#translation-box([
  A field label $f$ introduces a selector function defined as:
  $
    f x = mono("case") x mono("of") { C_1 p_(11) dots p_(1k) mono("->") e_1 ; dots ; C_n p_(n 1) dots p_(n k) mono("->") e_n}
  $
  where $C_1 dots C_n$ are all the constructors of the datatype containing a
  field labeled with $f$, $p_(i j)$ is $y$ when $f$ labels the $j$th
  component of $C_i$ or $\_$ otherwise, and $e_i$ is $y$ when some field in $C_i$ has a label of $f$ or `undefined` otherwise.
])

==== Construction Using Field Labels

==== Updates Using Field Labels

=== Expression Type-Signatures


_Expression type-signatures_ have the form $e mono("::") t$, where $e$ is an expression and $t$ is a type (Section~\ref{type-syntax}); they
are used to type an expression explicitly
and may be used to resolve ambiguous typings due to overloading (see
Section~\ref{default-decls}).  The value of the expression is just that of
$italic("exp")$.  As with normal type signatures (see
Section~\ref{type-signatures}), the declared type may be more specific than 
the principal type derivable from $italic("exp")$, but it is an error to give a type that is more general than, or not comparable to, the principal type.

#translation-box([
  #align(center)[
    #table(
      columns: 3,
      align: (left, center, left),
      stroke: none,
      $e mono("::") t$, $=$, $mono("let") { v mono("::") t; v = e} mono("in") v$
    )
  ]
])



=== Pattern Matching

_Patterns_ appear in lambda abstractions, function definitions, pattern
bindings, list comprehensions, do expressions, and case expressions.
However, the 
first five of these ultimately translate into case expressions, so
defining the semantics of pattern matching for case expressions is sufficient.

==== Patterns

Patterns have this syntax:
#table(
  columns: 4,
  align: (left, center, left, left),
  stroke: none,
  // pat
  $italic("pat")$,$->$,$nonterminal("lpat") nonterminal("qconop") nonterminal("pat")$,[(infix constructor)],
  $$,$|$,$nonterminal("lpat")$,$$,
  // lpat
  $italic("lpat")$,$->$,$nonterminal("apat")$,$$,
  $$,$|$,$terminal("-") (nonterminal("integer") | nonterminal("float"))$,[(negative literal)],
  $$,$|$,$nonterminal("gcon") nonterminal("apat")_1 dots nonterminal("apat")_k $,[(arity $italic("gcon") = k$, $k >= 1$)],
  // apat
  $italic("apat")$,$->$,$nonterminal("var") [terminal("@") nonterminal("apat")]$,[(as pattern)],
  $$,$|$,$nonterminal("gcon")$,[(arity $italic("gcon") = 0$)],
  $$,$|$,$nonterminal("qcon") terminal("{") nonterminal("fpat")_1 terminal(",") dots terminal(",") nonterminal("fpat")_k terminal("}")$,[(labeled pattern, $k >= 0$)],
  $$,$|$,$nonterminal("literal")$,[],
  $$,$|$,$terminal("_")$,[(wildcard)],
  $$,$|$,$terminal("(") nonterminal("pat") terminal(")")$,[(parenthesized pattern)],
  $$,$|$,$terminal("(") nonterminal("pat")_1 terminal(",") dots terminal(",") nonterminal("pat") terminal(")")$, [(tuple pattern, $k >= 2$)],
  $$,$|$,$terminal("[") nonterminal("pat")_1 terminal(",") dots terminal(",") nonterminal("pat") terminal("]")$, [(list pattern, $k >= 1$)],
  $$,$|$,$terminal("~") nonterminal("apat")$,[(irrefutable pattern)],
  // fpat
  $italic("fpat")$,$->$,$nonterminal("qvar") terminal("=") nonterminal("pat")$,$$,
)

All patterns must be _linear_---no variable may appear more than once.
For example, this definition is illegal:
```haskell
f (x,x) = x     -- ILLEGAL; x used twice in pattern
```
Patterns of the form $italic("var")mono("@")italic("pat")$ are called _as-patterns_,
and allow one to use $italic("var")$
as a name for the value being matched by $italic("pat")$.  For example,
```haskell
case e of { xs@(x:rest) -> if x==0 then rest else xs }
```
is equivalent to:
```haskell
let { xs = e } in
  case xs of { (x:rest) -> if x==0 then rest else xs }
```

Patterns of the form `_` are _wildcards_ and are useful when some part of a pattern
is not referenced on the right-hand-side.  It is as if an
identifier not used elsewhere were put in its place.  For example,
```haskell
case e of { [x,_,_]  ->  if x==0 then True else False }
```
is equivalent to:
```haskell
case e of { [x,y,z]  ->  if x==0 then True else False }
```

==== Informal Semantics of Pattern Matching

==== Formal Semantics of Pattern Matching <subsec:formal-semantics-pattern-matching>