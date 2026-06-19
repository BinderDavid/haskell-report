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

=== Operator Applications

=== Sections

=== Conditionals

=== Lists

=== Tuples

=== Unit Expressions and Parenthesized Expressions

=== Arithmetic Sequences

=== List Comprehensions

=== Let Expressions

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

==== Formal Semantics of Pattern Matching