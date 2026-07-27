#import "../macros.typ" : *
In this chapter, we describe the syntax and informal semantics of Haskell _declarations_.

#table(
  columns: 4,
  stroke: none,
  align: (left, center, left, left),
  // module
  $italic("module")$, $->$, $terminal("module") nonterminal("modid") [ nonterminal("exports")] terminal("where") nonterminal("body")$,$$,
  $$, $|$, $nonterminal("body")$, $$,
  // body
  $italic("body")$, $->$, $terminal("{") nonterminal("impdecls") terminal(";") nonterminal("topdecls") terminal("}")$, $$,
  $$, $|$, $terminal("{") nonterminal("impdecls") terminal("}")$, $$,
  $$, $|$, $terminal("{") nonterminal("topdecls") terminal("}")$, $$,
  // topdecls
  $italic("topdecls")$, $->$, $nonterminal("topdecl")_1 terminal(";") dots terminal(";") nonterminal("topdecl")_n$, $(n >= 1)$,
  // topdecl
  $italic("topdecl")$, $->$, $terminal("type") nonterminal("simpletype") terminal("=") nonterminal("type")$, $$,
  $$, $|$, $terminal("data") [nonterminal("context") terminal("=>")] nonterminal("simpletype") [terminal("=") nonterminal("constrs")] [nonterminal("deriving")]$, $$,
  $$, $|$, $terminal("newtype") [nonterminal("context") terminal("=>")] nonterminal("simpletype") terminal("=") nonterminal("newconstr") [nonterminal("deriving")]$, $$,
  $$, $|$, $terminal("class") [nonterminal("scontext") terminal("=>")] nonterminal("tycls") nonterminal("tyvar") [terminal("where") nonterminal("cdecls")]$, $$,
  $$, $|$, $terminal("instance") [nonterminal("scontext") terminal("=>")] nonterminal("qtycls") nonterminal("inst") [terminal("where") nonterminal("idecls")]$, $$,
  $$, $|$, $terminal("default") terminal("(") nonterminal("type")_1 terminal(",") dots terminal(",") nonterminal("type")_n terminal(")")$, $(n >= 0)$,
  $$, $|$, $terminal("foreign") nonterminal("fdecl")$, $$,
  $$, $|$, $nonterminal("decl")$, $$,
  // decls
  $italic("decls")$, $->$, $terminal("{") nonterminal("decl")_1 terminal(";") dots terminal(";") nonterminal("decl")_n terminal("}")$, $(n >= 0)$,
  // decl
  $italic("decl")$, $->$, $nonterminal("gendecl")$, $$,
  $$,$|$, $(nonterminal("funlhs") | nonterminal("pat")) nonterminal("rhs")$,$$,
  // cdecls
  $italic("cdecls")$, $->$, $terminal("{") nonterminal("cdecl")_1 terminal(";") dots terminal(";") nonterminal("cdecl")_n terminal("}")$, $(n >= 0)$,
  // cdecl
  $italic("cdecl")$, $->$, $nonterminal("gendecl")$, $$,
  $$,$|$, $(nonterminal("funlhs") | nonterminal("var")) nonterminal("rhs")$,$$,
  // idecls
  $italic("idecls")$, $->$, $terminal("{") nonterminal("idecl")_1 terminal(";") dots terminal(";") nonterminal("idecl")_n terminal("}")$, $(n >= 0)$,
  // idecl
  $italic("idecl")$, $->$, $(nonterminal("funlhs") | nonterminal("var")) nonterminal("rhs")$, $$,
  $$, $|$, $$, [(empty)],
  // gendecl
  $italic("gendecl")$, $->$, $nonterminal("vars") terminal("::") [nonterminal("context") terminal("=>")] nonterminal("type")$, [(type signature)],
  $$, $|$, $nonterminal("fixity") [nonterminal("integer")] nonterminal("ops")$, [(fixity declaration)],
  $$, $|$, $$, [(empty declaration)],
  // ops
  $italic("ops")$, $->$, $nonterminal("op")_1 terminal(",") dots terminal(",") nonterminal("op")_n$, $(n >= 1)$,
  // vars
  $italic("vars")$, $->$, $nonterminal("var")_1 terminal(",") dots terminal(",") nonterminal("var")_n$, $(n >= 1)$,
  // fixity
  $italic("fixity")$, $->$, $terminal("infixl") | terminal("infixr") | terminal("infix")$, $$,

)

The declarations in the syntactic category $nonterminal("topdecls")$ are only allowed
at the top level of a Haskell module (see @chapter:modules), whereas $nonterminal("decls")$ may be used either at the top level or
in nested scopes (i.e. those within a `let` or `where` construct).

For exposition, we divide the declarations into
three groups: user-defined datatypes, consisting of `type`, `newtype`,
and `data` declarations (@sec:user-defined-datatypes); type classes and
overloading, consisting of `class`, `instance`, and `default` declarations (@sec:type-classes); and nested declarations,
consisting of value bindings, type signatures, and fixity declarations
(@sec:nested).

Haskell has several primitive datatypes that are "hard-wired"
(such as integers and floating-point numbers), but most "built-in"
datatypes are defined with normal Haskell code, using normal `type`
and `data` declarations.
These "built-in" datatypes are described in detail in @sec:standard-haskell-types.

== Overview of Types and Classes

Haskell uses a traditional
Hindley-Milner
polymorphic type system to provide a static type semantics
@hindley69 @damas-milner82, but the type system has been extended with
_type classes_ (or just _classes_) that provide 
a structured way to introduce _overloaded_ functions.

A `class` declaration (@sec:class-decl) introduces a new
_type class_ and the overloaded operations that must be
supported by any type that is an instance of that class.  An
`instance` declaration (@sec:instance-decl) declares that a
type is an _instance_ of a class and includes
the definitions of the overloaded operations---called _class methods_---instantiated on the named type.


For example, suppose we wish to overload the operations `(+)` and
`negate` on types `Int` and `Float`.  We introduce a new
type class called `Num`:
```haskell
  class Num a  where          -- simplified class declaration for Num
    (+)    :: a -> a -> a     -- (Num is defined in the Prelude)
    negate :: a -> a
```
This declaration may be read "a type `a` is an instance of the class
`Num` if there are class methods `(+)` and `negate`, of the
given types, defined on it.""

We may then declare `Int` and `Float` to be instances of this class:
```haskell
  instance Num Int  where     -- simplified instance of Num Int
    x + y       =  addInt x y
    negate x    =  negateInt x
  
  instance Num Float  where   -- simplified instance of Num Float
    x + y       =  addFloat x y
    negate x    =  negateFloat x
```
where `addInt`, `negateInt`, `addFloat`, and `negateFloat` are assumed
in this case to be primitive functions, but in general could be any
user-defined function.  The first declaration above may be read
"`Int` is an instance of the class `Num` as witnessed by these
definitions (i.e.~class methods) for `(+)` and `negate`."

More examples of type classes can be found in
the papers by Jones @jones:cclasses or Wadler and Blott
@wadler:classes. 
The term "type class" was used to describe the original Haskell 1.0
type system; "constructor class" was used to describe an extension to
the original type classes.  There is no longer any reason to use two
different terms: in this report, "type class" includes both the
original Haskell type classes and the constructor classes
introduced by Jones.

=== Kinds

To ensure that they are valid, type expressions are classified
into different _kinds_, which take one of two possible
forms:

- The symbol $ast$ represents the kind of all nullary type constructors.
- If $kappa_1$ and $kappa_2$ are kinds, then $kappa_1 -> kappa_2$
  is the kind of types that take a type of kind $kappa_1$ and return
  a type of kind $kappa_2$.

Kind inference checks the validity of type expressions 
in a similar way that type inference checks the validity of value expressions.  
However, unlike types, kinds are entirely
implicit and are not a visible part of the language.
Kind inference is discussed in @sec:kind-inference.

=== Syntax of Types <sec:type-syntax>

#table(
  columns: 4,
  stroke: none,
  align: (left, center, left, left),
  // type
  $italic("type")$, $->$, $nonterminal("btype") [terminal("->") nonterminal("type")]$, [(function type)],
  // btype
  $italic("btype")$, $->$, $[nonterminal("btype")] nonterminal("atype")$, [(type application)],
  // atype
  $italic("atype")$, $->$, $nonterminal("gtycon")$, $$,
  $$,$|$, $nonterminal("tyvar")$, $$,
  $$,$|$, $terminal("(") nonterminal("type")_1 terminal(",") dots terminal(",") nonterminal("type")_k terminal(")")$, [(tuple type, $k >= 2$)],
  $$,$|$, $terminal("[") nonterminal("type") terminal("]")$, [(list type)],
  $$,$|$, $terminal("(") nonterminal("type") terminal(")")$, [(parenthesized constructor)],
  // gtycon
  $italic("gtycon")$, $->$, $nonterminal("qtycon")$, $$,
  $$,$|$,$terminal("()")$, [(unit type)],
  $$,$|$,$terminal("[]")$, [(list constructor)],
  $$,$|$,$terminal("(->)")$, [(function constructor)],
  $$,$|$,$terminal("(,") {terminal(",")} terminal(")")$, [(tupling constructors)],
)

The syntax for Haskell type expressions is given above.  Just as data values are built using data constructors, type values are built from _type constructors_.
As with data constructors, the names of type constructors start with uppercase letters.
Unlike data constructors, infix type constructors are not allowed (other than `(->)`).

The main forms of type expression are as follows:

1. Type variables, written as identifiers beginning with
   a lowercase letter.  The kind of a variable is determined implicitly
   by the context in which it appears.

2. Type constructors.  Most type constructors are written as an identifier
   beginning with an uppercase letter.  For example:
   - `Char`, `Int`, `Integer`, `Float`, `Double` and `Bool` are
     type constants with kind $ast$.
   - `Maybe` and `IO` are unary type
     constructors, and treated as types with kind $ast -> ast$.
   - The declarations `data T ...` or `newtype T ...` add the type
     constructor `T` to the type vocabulary.  The kind of `T` is determined by
     kind inference.
   Special syntax is provided for certain built-in type constructors:
   - The _trivial type_ is written as `()` and
     has kind $ast$.
     It denotes the "nullary tuple" type, and has exactly one value,
     also written `()` (see @sec:unit-expression and @subsec:basic-trivial).
   - The _function type_ is written as `(->)` and has
     kind $ast -> ast -> ast$.
   - The _list type_  is written as `[]` and has kind $ast -> ast$.
   - The _tuple types_ are written as `(,)`,
     `(,,)`, and so on.
     Their kinds are $ast -> ast -> ast$,$ast -> ast -> ast -> ast$,  and
     so on.
   Use of the `(->)` and `[]` constants is described in more detail below.

3. Type application.  If $t_1$ is a type of kind
   $kappa_1 -> kappa_2$ and $t_2$ is a type of kind $kappa_1$,
   then $t_1 space t_2$ is a type expression of kind $kappa_2$.

4. A _parenthesized type_, having form $(t)$, is identical
      to the type $t$.

For example, the type expression `IO a` can be understood as the application
of a constant, `IO`, to the variable `a`.  Since the `IO` type
constructor has kind 
$ast -> ast$, it follows that both the variable `a` and the whole
expression, `IO a`, must have kind $ast$.
In general, a process of _kind inference_
(see @sec:kind-inference) is needed to determine appropriate kinds for user-defined datatypes, type
synonyms, and classes.

Special syntax is provided to allow certain type expressions to be written
in a more traditional style:

1. A _function type_ has the form $t_1 -> t_2$, which is equivalent to the type
$(->) t_1 t_2$.  Function arrows associate to the right.
For example, `Int -> Int -> Float` means `Int -> (Int -> Float)`.
2. A _tuple type_ has the form $(t_1, dots, t_k)$, where $k >= 2$, which is equivalent to
   the type $(,dots,) t_1 dots t_k$ where there are
   $k-1$ commas between the parenthesis.  It denotes the
   type of $k$-tuples with the first component of type $t_1$, the second
   component of type $t_2$, and so on (see @sec:tuple-expression
   and @subsec:basic-tuples).
3. A _list type_ has the form $[t]$, which is equivalent to the type $[] t$.
   It denotes the type of lists with elements of type $t$ (see @sec:lists and @subsec:basic-lists).


These special syntactic forms always denote the built-in type constructors
for functions, tuples, and lists, regardless of what is in scope.
In a similar way, the prefix type constructors `(->)`, `[]`, `()`, `(,)`, 
and so on, always denote the built-in type constructors; they 
cannot be qualified, nor mentioned in import or export lists (@chapter:modules).
(Hence the special production, "gtycon", above.)

Although the list and tuple types have special syntax, their semantics 
is the same as the equivalent user-defined algebraic data types.

Notice that expressions and types have a consistent syntax.
If $t_i$ is the type of
expression or pattern $e_i$, then the expressions `(\ e1 -> e2)`, `[e1]`, and  `(t1 -> t2)`, `[t1]`, and `(t1, t2)`, respectively.

With one exception (that of the distinguished type variable
in a class declaration (@sec:class-decl)), the
type variables in a Haskell type expression
are all assumed to be universally quantified; there is no explicit
syntax for universal quantification @damas-milner82.
For example, the type expression
`a -> a` denotes the type $forall a. a -> a$.
For clarity, however, we often write quantification explicitly
when discussing the types of Haskell programs.  When we write an
explicitly quantified type, the scope of the $forall$ extends as far
to the right as possible; for example, $forall a. a -> a$ means
$forall a. (a -> a)$.

=== Syntax of Class Assertions and Contexts <sec:classes-contexts>

#table(
  columns: 4,
  stroke: none,
  align: (left, center, left, left),
  // context
  $italic("context")$, $->$, $nonterminal("class")$, $$,
  $$,$|$,$terminal("(") nonterminal("class")_1 terminal(",") dots terminal(",") nonterminal("class")_n terminal(")")$,$(n >= 0)$,
  // class
  $italic("class")$, $->$, $nonterminal("qtycls") nonterminal("tyvar")$, $$,
  $$,$|$,$nonterminal("qtycls") terminal("(") nonterminal("tyvar") nonterminal("atype")_1 dots nonterminal("atype")_n terminal(")")$,$(n >= 1)$,
  // qtycls
  $italic("qtycls")$, $->$, $[nonterminal("modid") terminal(".")] nonterminal("tycls")$,$$,
  // tycls
  $italic("tycls")$, $->$, $nonterminal("conid")$,$$,
  // tyvar
  $italic("tyvar")$, $->$, $nonterminal("varid")$,$$,

)

A _class assertion_ has form $italic("qtycls") italic("tyvar")$, and
indicates the membership of the type $italic("tyvar")$ in the class
$italic("qtycls")$.
A class identifier begins with an uppercase letter.
A _context_ consists of zero or more class assertions,
and has the general form
$
  (C_1 u_1, dots, C_n u_n)
$
where $C_1, dots, C_n$ are class identifiers, and each of the $u_1, dots, u_n$ is
either a type variable, or the application of type variable to one or more types.
The outer parentheses may be omitted when $n=1$.
In general, we use $italic("cx")$ to denote a context and we write $italic("cx") mono("=>") t$ to
indicate the type $t$ restricted by the context $italic("cx")$.
The context $italic("cx")$ must only contain type variables referenced in $t$.
For convenience,
we write $italic("cx") mono("=>") t$ even if the context $italic("cx")$ is empty, although in this
case the concrete syntax contains no `=>`.

=== Semantics of Types and Classes

In this section, we provide informal details of the type system.
(Wadler and Blott @wadler:classes and Jones
@jones:cclasses discuss type
and constructor classes, respectively, in more detail.)

The Haskell type system attributes a _type_ to each
expression in the program.  In general, a type is of the form
$forall overline(u). italic("cx") => t$,
where $overline(u)$ is a set of type variables $u_1, dots, u_n$.
In any such type, any of the universally-quantified type variables $u_i$
that are free in $italic("cx")$ must also be free in $t$.
Furthermore, the context $italic("cx")$ must be of the form given above in
@sec:classes-contexts.  For example, here are some
valid types:
```haskell
  Eq a => a -> a
  (Eq a, Show a, Eq b) => [a] -> [b] -> String
  (Eq (f a), Functor f) => (a -> b) -> f a -> f b -> Bool
```
In the third type, the constraint `Eq (f a)` cannot be made
simpler because `f` is universally quantified.

The type of an expression $e$ depends 
on a _type environment_ that gives types 
for the free variables in $e$, and a
_class environment_ that 
declares which types are instances of which classes (a type becomes
an instance of a class only via the presence of an
`instance` declaration or a `deriving` clause).

Types are related by a generalization preorder
(specified below);
the most general type, up to the equivalence induced by the generalization preorder,
that can be assigned to a particular
expression (in a given environment) is called its _
principal type_.
Haskell's extended Hindley-Milner type system can infer the principal
type of all expressions, including the proper use of overloaded
class methods (although certain ambiguous overloadings could arise, as
described in @sec:default-decls).  Therefore, explicit typings (called
_type signatures_)
are usually optional (see @sec:expression-type-sigs and @sec:type-signatures).

The type $forall overline(u).italic("cx")_1 => t_1$ _more general than_ the 
type $forall overline(w). italic("cx")_2 => t_2$ if and only if there is 
a substitution $S$ whose domain is $overline(u)$ such that:

- $t_2$ is identical to $S(t_1)$.
- Whenever $italic("cx")_2$ holds in the class environment, $S(italic("cx")_1)$ also holds.

A value of type $forall overline(u).italic("cx") => t$,
may be instantiated at types $overline(s)$ if and only if
the context $italic("cx")[overline(s)/overline(u)]$ holds.
For example, consider the function `double`:
```haskell
double x = x + x
```
The most general type of `double` is $forall a. mono("Num") a => a -> a$.
`double` may be applied to values of type `Int` (instantiating $a$ to
`Int`), since `Num Int` holds, because `Int` is an instance of the class `Num`.
However, `double` may not normally be applied to values
of type `Char`, because `Char` is not normally an instance of class `Num`.
The user may choose to declare such an instance, in which case `double` may indeed be applied to a `Char`.

== User-Defined Datatypes <sec:user-defined-datatypes>

=== Algebraic Datatype Declarations <sec:datatype-decls>

=== Type Synonym Declarations

=== Datatype Renamings <sec:datatype-renamings>

== Type Classes and Overloading <sec:type-classes>

=== Class Declarations <sec:class-decl>

=== Instance Declarations <sec:instance-decl>

=== Derived Instances

=== Ambiguous Types, and Defaults for Overloaded Numeric Operations <sec:default-decls>

== Nested Declarations <sec:nested>

=== Type Signatures <sec:type-signatures>

=== Fixity Declarations <sec:fixity-declarations>

#figure(
  caption: "Precedences and fixities of prelude operators",
)[
  #table(
    columns: 4,
    table.header([Precedence],[Left associateive operators],[Non-associative operators],[Right associative operators])
  )
]<fig:prelude-fixities>


=== Function and Pattern Bindings <subsec:function-and-pattern-bindings>

==== Function bindings

==== Pattern bindings

== Static Semantics of Function and Pattern Bindings

The static semantics of the function and pattern bindings of a `let` expression or `where` clause are discussed in this section.

=== Dependency Analysis

In general the static semantics are given by applying the
normal Hindley-Milner inference
rules.  In order to increase polymorphism, these rules are applied to
groups of bindings identified by a _dependency analysis_.


A binding $b 1$ _depends_ on a binding $b 2$ in the same list of declarations if either

1. $b 1$ contains a free identifier that has no type signature and is bound by $b 2$, or
2. $b 1$ depends on a binding that depends on $b 2$.


A _declaration group_ is a minimal set of mutually dependent bindings.
Hindley-Milner type inference is applied to each declaration group in dependency order.
The order of declarations in `where`/`let`
constructs is irrelevant.

=== Generalization

The Hindley-Milner type system assigns types to a let-expression in two stages:


1. The declaration groups are considered in dependency order. For
   each group, a type with no universal quantification is inferred for
   each variable bound in the group. Then, all type variables that occur
   in these types are universally quantified unless they are associated
   with bound variables in the type environment; this is called
   generalization.
2. Finally, the body of the let-expression is typed.

For example, consider the declaration
```haskell
  f x = let g y = (y,y)
        in ...
```
The type of `g`'s definition is $a -> (a,a)$.
The generalization step
attributes to `g` the polymorphic type 
$forall a. a -> (a,a)$,
after which the typing of the "`...`" part can proceed.

When typing overloaded definitions, all the overloading 
constraints from a single declaration group are collected together, 
to form the context for the type of each variable declared in the group.
For example, in the definition:
```haskell
  f x = let g1 x y = if x>y then show x else g2 y x
            g2 p q = g1 q p
        in ...
```
The types of the definitions of `g1` and `g2` are both
$a -> a -> mono("String")$, and the accumulated constraints are
$mono("Ord") a$ (arising from the use of `>`), and $mono("Show") a$ (arising from the
use of `show`).
The type variables appearing in this collection of constraints are
called the _constrained type variables_.

The generalization step attributes to both `g1` and `g2` the type
$
  forall a. (mono("Ord") a, mono("Show") a) => a -> a -> mono("String")
$
Notice that `g2` is overloaded in the same way as `g1` even though the
occurrences of `>` and `show` are in the definition of `g1`.

If the programmer supplies explicit type signatures for more than one variable
in a declaration group, the contexts of these signatures must be 
identical up to renaming of the type variables.


=== Context Reduction Errors

As mentioned in Section~\ref{type-semantics}, the context of a type
may constrain only a type variable, or the application of a type variable
to one or more types.  Hence, types produced by
generalization must be expressed in a form in which all context
constraints have be reduced to this "head normal form".
Consider, for example, the
definition:
```haskell
  f xs y  =  xs == [y]
```
Its type is given by
```haskell
  f :: Eq a => [a] -> a -> Bool
```
and not
```haskell
  f :: Eq [a] => [a] -> a -> Bool
```
Even though the equality is taken at the list type, the context must
be simplified, using the instance declaration for `Eq` on lists, before generalization.  If no such instance is in scope, a static error occurs.

Here is an example that shows the need for a
constraint of the form $C (m space t)$ where m is one of the type
variables being generalized; that is, where the class $C$ applies to a type
expression that is not a type variable or a type constructor.
Consider:
```haskell
  f :: (Monad m, Eq (m a)) => a -> m a -> Bool
  f x y = return x == y
```
The type of `return` is  `Monad m => a -> m a`; the type of `(==)` is `Eq a => a -> a -> Bool`.
The type of `f` should be
therefore `(Monad m, Eq (m a)) => a -> m a -> Bool`, and the context
cannot be simplified further.

The instance declaration derived from a data type `deriving` clause
(see Section~\ref{derived-decls})
must, like any instance declaration, have a _simple_ context; that is,
all the constraints must be of the form $C space a$, where $a$ is a type variable.
For example, in the type
```haskell
  data Apply a b = App (a b)  deriving Show
```
the derived Show instance will produce a context `Show (a b)`, which
cannot be reduced and is not simple; thus a static error results.


=== Monomorphism <sec:monomorphism>

Sometimes it is not possible to generalize over all the type variables
used in the type of the definition.
For example, consider the declaration
```haskell
  f x = let g y z = ([x,y], z)
        in ...
```
In an environment where `x` has type $a$,
the type of `g`'s definition is $a -> b -> ([a],b)$.
The generalization step attributes to \mbox{\tt g} the type $forall b. a -> b -> ([a], b)$;
only $b$ can be universally quantified because $a$ occurs in the
type environment.
We say that the type of `g` is _monomorphic in the type variable $a$_.

The effect of such monomorphism is that the first argument of all 
applications of `g` must be of a single type.  
For example, it would be valid for
the "`...`" to be
```haskell
  (g True, g False)
```
(which would, incidentally, force `x` to have type `Bool`) but invalid
for it to be 
```haskell
  (g True, g 'c')
```
In general, a type $forall overline(u).italic("cx") => t$
is said to be _monomorphic_
in the type variable $a$ if $a$ is free in
$forall overline(u).italic("cx") => t$.

It is worth noting that the explicit type signatures provided by Haskell
are not powerful enough to express types that include monomorphic type
variables.  For example, we cannot write
```haskell
  f x = let 
          g :: a -> b -> ([a],b)
          g y z = ([x,y], z)
        in ...
```
because that would claim that `g` was polymorphic in both `a` and `b`
(Section~\ref{type-signatures}).  In this program, `g` can only be given
a type signature if its first argument is restricted to a type not involving
type variables; for example
```haskell
  g :: Int -> b -> ([Int],b)
```
This signature would also cause `x` to have type `Int`.

=== The Monomorphism Restriction

#monomorphism-box([
  / Rule 1.: todo
  / Rule 2.: todo
])
== Kind Inference <sec:kind-inference>

This section describes the rules that are used to perform _kind
inference_, i.e. to calculate a suitable kind for each type
constructor and class appearing in a given
program.

The first step in the kind inference process is to arrange the set of
datatype, synonym, and class definitions into dependency groups.  This can
be achieved in much the same way as the dependency analysis for value
declarations that was described in Section~\ref{dependencyanalysis}.
For example, the following program fragment includes the definition
of a datatype constructor `D`, a synonym `S` and a class `C`, all of
which would be included in the same dependency group:
```haskell

  data C a => D a = Foo (S a)
  type S a = [D a]
  class C a where
      bar :: a -> D a -> Bool
```
The kinds of variables, constructors, and classes within each group
are determined using standard techniques of type inference and
kind-preserving unification \cite{jones:cclasses}.  For example, in the
definitions above, the parameter `a` appears as an argument of the
function constructor `(->)` in the type of `bar` and hence must
have kind $ast$.  It follows that both `D` and `S` must have
kind $ast -> ast$ and that every instance of class `C` must
have kind $ast$.

It is possible that some parts of an inferred kind may not be fully
determined by the corresponding definitions; in such cases, a default
of $ast$ is assumed.  For example, we could assume an arbitrary kind
$kappa$ for the `a` parameter in each of the following examples:
```haskell
  data App f a = A (f a)
  data Tree a  = Leaf | Fork (Tree a) (Tree a)
```
This would give kinds
$(kappa -> ast) -> kappa -> ast$ and
$kappa -> ast$ for `App` and `Tree`, respectively, for any
kind $kappa$, and would require an extension to allow polymorphic
kinds.  Instead, using the default binding $kappa=ast$, the
actual kinds for these two constructors are
$(ast -> ast) -> ast -> ast$ and
$ast -> ast$, respectively.

Defaults are applied to each dependency group without consideration of
the ways in which particular type constructor constants or classes are
used in later dependency groups or elsewhere in the program.  For example,
adding the following definition to those above does not influence the
kind inferred for `Tree` (by changing it to
$(ast -> ast) -> ast$, for instance), and instead
generates a static error because the kind of `[]`, $ast -> ast$,
does not match the kind $ast$ that is expected for an argument of `Tree`:
```haskell
  type FunnyTree = Tree []     -- invalid
```
This is important because it ensures that each constructor and class are
used consistently with the same kind whenever they are in scope.


