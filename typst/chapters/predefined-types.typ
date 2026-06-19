=== Standard Haskell Types
==== Booleans
==== Characters and Strings
==== Lists
==== Tuples
==== The Unit Datatype
==== Function Types
==== The IO and IOError Types
==== Other Types
=== Strict Evaluation
=== Standard Haskell Classes

@fig:standard-classes shows the hierarchy of 
Haskell classes defined in the Prelude and the Prelude types that
are instances of these classes.

#figure(
  caption: "Standard Haskell Classes",
  image(width: 50%, "../assets/classes.pdf")
)<fig:standard-classes>

Default class method declarations (@sec:type-classes) are provided
for many of the methods in standard classes.  A comment with each
`class` declaration in @chapter:standard-prelude specifies the
smallest collection of method definitions that, together with the
default declarations, provide a reasonable definition for all the
class methods.  If there is no such comment, then all class methods
must be given to fully specify an instance.



==== The Eq Class

```haskell
class  Eq a  where
      (==), (/=)  ::  a -> a -> Bool

      x /= y  = not (x == y)
      x == y  = not (x /= y)
```

The `Eq` class provides equality (`==`) and inequality (`/=`) methods.
All basic datatypes except for functions and `IO` are instances of this class.
Instances of `Eq` can be derived for any user-defined datatype whose
constituents are also instances of `Eq`.

This declaration gives default method declarations for both `/=` and `==`,
each being defined in terms of the other.  If an instance declaration
for `Eq` defines neither `==` nor `/=`, then both will loop.
If one is defined, the default method for the other will make use of
the one that is defined.  If both are defined, neither default method is used.


==== The Ord Class

```haskell
class  (Eq a) => Ord a  where
  compare              :: a -> a -> Ordering
  (<), (<=), (>=), (>) :: a -> a -> Bool
  max, min             :: a -> a -> a

  compare x y | x == y    = EQ
              | x <= y    = LT
              | otherwise = GT

  x <= y  = compare x y /= GT
  x <  y  = compare x y == LT
  x >= y  = compare x y /= LT
  x >  y  = compare x y == GT

  -- Note that (min x y, max x y) = (x,y) or (y,x)
  max x y | x <= y    =  y
          | otherwise =  x
  min x y | x <= y    =  x
          | otherwise =  y
```

The `Ord` class is used for totally ordered datatypes.  All basic
datatypes
except for functions, `IO`, and `IOError`, are instances of this class.  Instances
of `Ord`
can be derived for any user-defined datatype whose constituent types
are in `Ord`.  The declared order
of the constructors in the data declaration determines the ordering in
derived `Ord` instances.
The `Ordering` datatype
allows a single comparison to determine the precise ordering of two
objects.

The default declarations allow a user to create an `Ord` instance
either with a type-specific `compare` function or with type-specific
`==` and `<=` functions.

==== The Read and Show Classes

```haskell
type  ReadS a = String -> [(a,String)]
type  ShowS   = String -> String

class  Read a  where
    readsPrec :: Int -> ReadS a
    readList  :: ReadS [a]
    -- ... default decl for readList given in Prelude

class  Show a  where
    showsPrec :: Int -> a -> ShowS
    show      :: a -> String 
    showList  :: [a] -> ShowS

    showsPrec _ x s   = show x ++ s
    show x            = showsPrec 0 x ""
    -- ... default decl for showList given in Prelude
```
The `Read` and `Show` classes are used to convert values to
or from strings. 
The `Int` argument to `showsPrec` and `readsPrec` gives the operator
precedence of the enclosing context (see Section~\ref{derived-text}).

`showsPrec` and `showList` return a `String`-to-`String`
function, to allow constant-time concatenation of its results using function
composition.
A specialised variant, `show`, is also provided, which
uses precedence context zero, and returns an ordinary `String`.
The method  `showList` is provided to allow the programmer to
give a specialised way of showing lists of values.  This is particularly
useful for the `Char` type, where values of type `String` should be
shown in double quotes, rather than between square brackets.

Derived instances of `Read` and `Show` replicate the style in which a
constructor is declared: infix constructors and field names are used
on input and output.  Strings produced by `showsPrec` are usually
readable by `readsPrec`.  

All `Prelude` types, except function types and `IO` types,
are instances of `Show` and `Read`.
(If desired, a programmer can easily make functions and `IO` types 
into (vacuous) instances of `Show`, by providing an instance declaration.)

For convenience, the Prelude provides the following auxiliary
functions:
```haskell
reads   :: (Read a) => ReadS a
reads   =  readsPrec 0

shows   :: (Show a) => a -> ShowS
shows   =  showsPrec 0

read    :: (Read a) => String -> a
read s  =  case [x | (x,t) <- reads s, ("","") <- lex t] of
              [x] -> x
              []  -> error "PreludeText.read: no parse"
              _   -> error "PreludeText.read: ambiguous parse"
```
`shows` and `reads` use a default precedence of 0.  The `read` function reads
input from a string, which must be completely consumed by the input
process.  

The function `lex :: ReadS String`, used by `read`, is also part of the Prelude.
It reads a single lexeme from the input, discarding initial white space, and
returning the characters that constitute the lexeme.  If the input string contains
only white space, `lex` returns a single successful "lexeme" consisting of the
empty string.  (Thus `lex ""` = `[("","")]`.)  If there is no legal lexeme at the
beginning of the input string, `lex` fails (i.e. returns `[]`).


==== The Enum Class
```haskell
class  Enum a  where
    succ, pred     :: a -> a
    toEnum         :: Int -> a
    fromEnum       :: a -> Int
    enumFrom       :: a -> [a]            -- [n..]
    enumFromThen   :: a -> a -> [a]       -- [n,n'..]
    enumFromTo     :: a -> a -> [a]       -- [n..m]
    enumFromThenTo :: a -> a -> a -> [a]  -- [n,n'..m]

    -- Default declarations given in Prelude
```
Class `Enum` defines operations on sequentially ordered types.
The functions `succ` and `pred` return the successor and predecessor,
respectively, of a value.
The functions `fromEnum` and `toEnum` map values from a type in
`Enum` to and from `Int`.  
The `enumFrom`... methods are used when translating arithmetic
sequences (Section~\ref{arithmetic-sequences}).

Instances of `Enum` may be derived for any enumeration type (types
whose constructors have no fields); see Chapter~\ref{derived-appendix}.

For any type that is an instance of class `Bounded` as well as `Enum`, the following should hold:

- The calls `succ maxBound` and `pred minBound` should result in a runtime error.
- `fromEnum` and `toEnum` should give a runtime error if the 
  result value is not representable in the result type.  For example, `toEnum 7 :: Bool` is an error.
- `enumFrom` and `enumFromThen` should be defined with 
  an implicit bound, thus:
  ```haskell
  enumFrom     x   = enumFromTo     x maxBound
  enumFromThen x y = enumFromThenTo x y bound
    where
      bound | fromEnum y >= fromEnum x = maxBound
            | otherwise                = minBound
  ```

The following `Prelude` types are instances of `Enum`: 
- Enumeration types: `()`, `Bool`, and `Ordering`. The
  semantics of these instances is given by Chapter~\ref{derived-appendix}.
  For example, `[LT ..]` is the list `[LT,EQ,GT]`.
- `Char`: the instance is given in Chapter~\ref{stdprelude},   based
  on the primitive functions that convert between a `Char` and an `Int`.
  For example, `enumFromTo 'a' 'z'` denotes
  the list of lowercase letters in alphabetical order.
- Numeric types: `Int`, `Integer`, `Float`, `Double`.  The semantics of these instances is given next.

For all four numeric types, `succ` adds 1, and `pred` subtracts 1.
The conversions `fromEnum` and `toEnum` convert between the type and `Int`.
In the case of `Float` and `Double`, the digits after the decimal point may be lost.
It is implementation-dependent what `fromEnum` returns when applied to 
a value that is too large to fit in an `Int`.

For the types `Int` and `Integer`, the enumeration functions 
have the following meaning:


- The sequence $mono("enumFrom") e_1$ is the list $[e_1, e_1 + 1, e_1 + 2, dots]$.
- The sequence $mono("enumFromThen") e_1 e_2$ is the list $[e_1, e_1 + i, e_1 + 2i, dots]$,
  where the increment, $i$, is $e_2 - e_1$.  The increment may be zero or negative.
  If the increment is zero, all the list elements are the same.
- The sequence $mono("enumFromTo") e_1 e_3$ is 
  the list $[e_1, e_1 + 1, e_1 + 2, dots, e_3]$.
  The list is empty if $e_1 > e_3$.
- The sequence $mono("enumFromThenTo") e_1 e_2 e_3$ 
  is the list $[e_1, e_1 + i, e_1 + 2i, dots, e_3]$,
  where the increment, $i$, is $e_2 - e_1$.  If the increment 
  is positive or zero, the list terminates when the next element would
  be greater than $e_3$; the list is empty if $e_1 > e_3$.
  If the increment is negative, the list terminates when the next element would be less than $e_3$; the list is empty if $e_1 < e_3$.


For `Float` and `Double`, the semantics of the `enumFrom` family is
given by the rules for `Int` above, except that the list terminates
when the elements become greater than $e_3 + i mono("/") 2$ for positive increment
$i$, or when they become less than $e_3 + i mono("/") 2$ for negative $i$.

For all four of these Prelude numeric types, all of the `enumFrom` family of functions are strict in all their arguments.

==== The Functor Class

```haskell
class  Functor f  where
    fmap    :: (a -> b) -> f a -> f b
```
The `Functor` class is used for types that can be mapped over.  Lists, `IO`, and `Maybe` are in this class.

Instances of `Functor` should satisfy the following laws:
$
  mono("fmap id") &= mono("id") \
  mono("fmap (f . g)") &= mono("fmap f . fmap g")
$

All instances of `Functor` defined in the Prelude satisfy these laws.

==== The Monad Class

```haskell
class  Monad m  where
    (>>=)   :: m a -> (a -> m b) -> m b
    (>>)    :: m a -> m b -> m b
    return  :: a -> m a
    fail    :: String -> m a

    m >> k  =  m >>= \_ -> k
    fail s  = error s
```

The `Monad` class defines the basic operations over a _monad_.
See @chapter:basic-input-output[Chapter] for more information about monads.

"`do`" expressions provide a convenient syntax for writing
monadic expressions (see Section~\ref{do-expressions}).
The `fail` method is invoked on pattern-match failure in a `do`
expression.

In the Prelude, lists, 
`Maybe`, and `IO` are all instances of `Monad`.
The `fail` method for lists returns the empty list `[]`,
for `Maybe` returns `Nothing`, and for `IO` raises a user
exception in the IO monad (see Section~\ref{io-exceptions}).

Instances of `Monad` should satisfy the following laws:

$
  mono("return a >>= k") &= mono("k a") \
  mono("m >> return") &= mono("m") \
  mono("m >>= (\x -> k x >>= h)") &= mono("(m >>= k) >>= h")
$

Instances of both `Monad` and `Functor` should additionally satisfy the law:
$
  mono("fmap f xs") &= mono("xs >>= return . f")
$

All instances of `Monad` defined in the Prelude satisfy these laws.

The Prelude provides the following auxiliary functions: 
```haskell
sequence  :: Monad m => [m a] -> m [a] 
sequence_ :: Monad m => [m a] -> m () 
mapM      :: Monad m => (a -> m b) -> [a] -> m [b]
mapM_     :: Monad m => (a -> m b) -> [a] -> m ()
(=<<)     :: Monad m => (a -> m b) -> m a -> m b
```

==== The Bounded Class

```haskell
class  Bounded a  where
    minBound, maxBound :: a
```

The `Bounded` class is used to name the upper and lower limits of a
type.  `Ord` is not a superclass of `Bounded` since types that are not
totally ordered may also have upper and lower bounds.
The types `Int`, `Char`, `Bool`,
`()`, `Ordering`, and all tuples are instances of `Bounded`.  
The `Bounded` class may be derived
for any enumeration type; `minBound` is the first constructor listed
in the `data` declaration and `maxBound` is the last. `Bounded` may
also be derived for single-constructor datatypes whose constituent
types are in `Bounded`.

=== Numbers
==== Numeric Literals <sec:numeric-literals>
==== Arithmetic and Number-Theoretic Operations
==== Exponentiation and Logarithms
==== Magnitude and Sign
==== Trigonometric Functions
==== Coercions and Component Extraction
