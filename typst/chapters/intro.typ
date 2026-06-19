Haskell is a general purpose, purely functional
programming language incorporating many recent innovations in
programming language design.  Haskell provides
higher-order functions,
non-strict semantics, static polymorphic typing, user-defined
algebraic datatypes, pattern-matching, list comprehensions, a module
system, a monadic I/O system, and a rich set of primitive datatypes,
including lists,
arrays, arbitrary and fixed precision integers, and floating-point
numbers.  Haskell is both the culmination
and solidification of many years of research on non-strict functional
languages.

This report defines the syntax for Haskell programs and an
informal abstract semantics for the meaning of such
programs.
We leave as implementation dependent the ways in which Haskell programs are to be
manipulated, interpreted, compiled, etc.  This includes such issues as
the nature of programming environments and
the error messages returned for undefined programs
(i.e.~programs that formally evaluate to $bot$).

=== Program Structure

In this section, we describe the abstract syntactic and semantic structure of
Haskell, as well as how it relates to the organization of the
rest of the report.

+ At the topmost level a Haskell program is a set of _modules_, described in @chapter:modules[Chapter]
  Modules provide a way to control namespaces and to re-use software in large programs.
+ The top level of a module consists of a collection of
  _declarations_, of which there are several kinds, all described in @chapter:declarations[Chapter]Declarations define things such as ordinary values, datatypes, type classes, and fixity information.

+ At the next lower level are _expressions_, described
  in @chapter:expressions[Chapter]
  An expression denotes a _value_ and has a _static type_; expressions are at the heart of Haskell programming "in the small."

+ At the bottom level is Haskell's _lexical structure_, defined in @chapter:lexical-structure[Chapter]
  The lexical structure captures the concrete representation of Haskell programs in text files.

This report proceeds bottom-up with respect to Haskell's syntactic structure.

The chapters not mentioned above are @chapter:predefined-types[Chapter], which
describes the standard built-in datatypes and classes in Haskell, and @chapter:basic-input-output[Chapter], which discusses the I/O facility in Haskell
(i.e.~how Haskell programs communicate with the outside world).
Also, there are several chapters describing the Prelude,
the concrete syntax, literate programming, the specification of derived
instances, and pragmas supported by most Haskell compilers.

Examples of Haskell program fragments in running text are given in typewriter font:
```haskell
let x = 1
    z = x+y
in  z+1
```

"Holes" in program fragments representing arbitrary pieces of Haskell code are written in italics, as in
// \mbox{$\it \makebox{\tt if}\ e_1\ \makebox{\tt then}\ e_2\ \makebox{\tt else}\ e_3$}.
Generally the italicized names are mnemonic, such as $e$ for expressions, $d$ for declarations, $t$ for types, etc.

=== The Haskell Kernel

Haskell has adopted many of the convenient syntactic structures
that have become popular
in functional programming.  In this Report, the meaning of such
syntactic sugar is given by translation into simpler constructs.
If these translations are applied exhaustively, the result is a program
written in a small subset of Haskell that we call the Haskell _kernel_.

Although the kernel is not formally specified, it is essentially a
slightly sugared variant of the lambda calculus with a straightforward
denotational semantics.  The translation of each syntactic structure
into the kernel is given as the syntax is introduced.  This modular
design facilitates reasoning about Haskell programs and provides
useful guidelines for implementors of the language.

=== Values and Types

An expression evaluates to a _value_ and has a
static _type_.  Values and types are not mixed in
Haskell.
However, the type system
allows user-defined datatypes of various sorts, and permits not only
parametric polymorphism (using a
traditional Hindley-Milner type structure) but
also _ad hoc_ polymorphism, or _overloading_ (using
_type classes_).

Errors in Haskell are semantically equivalent to
$bot$ ("bottom").  Technically, they are indistinguishable
from nontermination, so the language includes no mechanism
for detecting or acting upon errors.  However, implementations
will probably try to provide useful information about
errors.  See Section~\ref{basic-errors}.

=== Namespaces

There are six kinds of names in Haskell: those for _variables_ and
_constructors_ denote values; those for _type variables_, _type constructors_, and _type classes_ refer to entities related
to the type system; and _module names_ refer to modules.
There are two constraints on naming:

+ Names for variables and type variables are identifiers beginning with lowercase letters or underscore;
  the other four kinds of names are identifiers beginning with uppercase letters.
+ An identifier must not be used as the name of a type constructor and a class in the same scope.

These are the only constraints; for example, Int may simultaneously be the name of a module, class, and constructor within a single scope.