#import "../macros.typ" : *
In this chapter, we describe the syntax and informal semantics of Haskell _declarations_.

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

=== Syntax of Class Assertions and Contexts

=== Semantics of Types and Classes

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


