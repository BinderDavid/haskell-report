A _derived instance_ is an instance declaration that is generated
automatically in conjunction with a `data` or `newtype` declaration.
The body of a derived instance declaration is derived syntactically from
the definition of the associated type.  Derived instances are
possible only for classes known to the compiler: those defined in
either the Prelude or a standard library.  In this chapter, we
describe the derivation of classes defined by the Prelude.

If $T$ is an algebraic datatype declared by:

$
  mono("data") italic("cx") mono("=>") T med u_1 dots u_k = K_1 med t_(1,1) dots t_(1,k_1) | dots | K_n med t_(n,1) dots t_(n,k_n) \
  mono("deriving") (C_1, dots, C_m)
$

(where $m >= 0$ and the parentheses may be omitted if $m=1$) then
a derived instance declaration is possible for a class $C$
if these conditions hold:
+ $C$ is one of `Eq`, `Ord`, `Enum`, `Bounded`, `Show` or `Read`.
+ There is a context $c x'$ such that $c x' => C t_(i j)$ holds for each of the constituent types $t_(i j)$.
+ If $C$ is `Bounded`, the type must be either an enumeration (all constructors must be nullary) or have only one constructor.
+ If $C$ is `Enum`, the type must be an enumeration.
+ There must be no explicit instance declaration elsewhere in the program that
  makes $T u_1 dots u_k$ an instance of $C$.
+ If the data declaration has no constructors (i.e. when $n=0$),
  then no classes are derivable (i.e. $m=0$)

For the purposes of derived instances, a `newtype` declaration is
treated as a `data` declaration with a single constructor.

If the `deriving` form is present,
an instance declaration is automatically generated for $T u_1 dots u_k$
over each class $C_i$.
If the derived instance declaration is impossible for any of the $C_i$
then a static error results.
If no derived instances are required, the `deriving` form may be
omitted or the form `deriving ()` may be used.

Each derived instance declaration will have the form:

$
  mono("instance") (italic("cx"), italic("cx")') mono("=>") C_i med (T med u_1 dots u_k) mono("where") { med d med }
$

where $d$ is derived automatically depending on $C_i$ and the data
type declaration for $T$ (as will be described in the remainder of this section).

The context $c x'$ is the smallest context satisfying point (2) above.
For mutually recusive data types, the compiler may need to perform a
fixpoint calculation to compute it.

The remaining details of the derived
instances for each of the derivable Prelude classes are now given.
Free variables and constructors used in these translations
always refer to entities defined by the `Prelude`.

=== Derived instances of Eq and Ord

The class methods automatically introduced by derived instances
of `Eq` and `Ord` are `(==)`, `(/=)`, `compare`
`(<)`,
`(<=)`,
`(>)`,
`(>=)`,
`max`, and
`min`.
The latter seven operators are defined so
as to compare their arguments lexicographically with respect to
the constructor set given, with earlier constructors in the datatype
declaration counting as smaller than later ones.  For example, for the
`Bool` datatype, we have that `(True > False) == True`.

Derived comparisons always traverse constructors from left to right.
These examples illustrate this property:
$
  mono("(1,undefined) == (2,undefined)") &=> mono("False") \
  mono("(undefined,1) == (undefined,2)") &=> bot
$

All derived operations of class `Eq` and `Ord` are strict in both arguments.
For example, `False <= `$bot$ is $bot$, even though `False` is the first constructor
of the `Bool` type.


=== Derived instances of Enum

Derived instance declarations for the class `Enum` are only
possible for enumerations (data types with only nullary constructors).

The nullary constructors are assumed to be
numbered left-to-right with the indices 0 through $n-1$.
The `succ` and `pred` operators give the successor and predecessor
respectively of a value, under this numbering scheme.  It is
an error to apply `succ` to the maximum element, or `pred` to the minimum
element.

The `toEnum` and `fromEnum` operators map enumerated values to and
from the `Int` type; `toEnum` raises a runtime error if the `Int` argument
is not the index of one of the constructors.

The definitions of the remaining methods are
```haskell
  enumFrom x           = enumFromTo x lastCon
  enumFromThen x y     = enumFromThenTo x y bound
                       where
                         bound | fromEnum y >= fromEnum x = lastCon
                               | otherwise                = firstCon
  enumFromTo x y       = map toEnum [fromEnum x .. fromEnum y]
  enumFromThenTo x y z = map toEnum [fromEnum x, fromEnum y .. fromEnum z]
```
where `firstCon` and `lastCon` are respectively the first and last
constructors listed in the `data` declaration.
For example,
given the datatype:
```haskell
  data  Color = Red | Orange | Yellow | Green  deriving (Enum)
```
we would have:
```haskell
  [Orange ..]         ==  [Orange, Yellow, Green]
  fromEnum Yellow     ==  2
```

=== Derived instances of Bounded

The `Bounded` class introduces the class
methods `minBound` and `maxBound`,
which define the minimal and maximal elements of the type.
For an enumeration, the first and last constructors listed in the
`data` declaration are the bounds.  For a type with a single
constructor, the constructor is applied to the bounds for the
constituent types.  For example, the following datatype:
```haskell
  data  Pair a b = Pair a b deriving Bounded
```
would generate the following `Bounded` instance:
```haskell
  instance (Bounded a,Bounded b) => Bounded (Pair a b) where
    minBound = Pair minBound minBound
    maxBound = Pair maxBound maxBound
```

=== Derived instances of Read and Show
=== An Example
