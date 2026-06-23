The Foreign Function Interface (FFI) has two purposes: it enables (1) to
describe in Haskell the interface to foreign language functionality and
(2) to use from foreign code Haskell routines.  More generally, its aim
is to support the implementation of programs in a mixture of Haskell and
other languages such that the source code is portable across different
implementations of Haskell and non-Haskell systems as well as
independent of the architecture and operating system.

=== Foreign Languages

The Haskell FFI currently only specifies the interaction between Haskell
code and foreign code that follows the C calling convention.  However,
the design of the FFI is such that it enables the modular extension of
the present definition to include the calling conventions of other
programming languages, such as C++ and Java.  A precise definition of
the support for those languages is expected to be included in later
versions of the language.  The second major omission is the definition
of the interaction with multithreading in the foreign language and, in
particular, the treatment of thread-local state, and so these details
are currently implementation-defined.

The core of the present specification is independent of the foreign language
that is used in conjunction with Haskell.  However, there are two areas where
FFI specifications must become language specific: (1) the specification of
external names and (2) the marshalling of the basic types of a foreign
language.  As an example of the former, consider that in C~@Kernighan1988 a simple
identifier is sufficient to identify an object, while
Java~@Gosling1997, in general, requires a qualified name in
conjunction with argument and result types to resolve possible overloading.
Regarding the second point, consider that many languages do not specify the
exact representation of some basic types.  For example the type `int` in
C may be 16, 32, or 64 bits wide.  Similarly, Haskell guarantees
only that `Int` covers at least the range $[-2^(29), 2^(29) - 1]$ (@sec:numbers[Section]).  As
a consequence, to reliably represent values of C's `int` in Haskell, we
have to introduce a new type `CInt`, which is guaranteed to match the
representation of `int`.

The specification of external names, dependent on a calling convention, is
described in @sec:extent[Section], whereas the marshalling of the basic
types in dependence on a foreign language is described in
@sec:marshalling[Section]

=== Contexts

For a given Haskell system, we define the _Haskell context_ to be the
execution context of the abstract machine on which the Haskell system is
based.  This includes the heap, stacks, and the registers of the abstract
machine and their mapping onto a concrete architecture.  We call any other
execution context an _external context._  Generally, we cannot assume any
compatibility between the data formats and calling conventions between the
Haskell context and a given external context, except where Haskell explicitly prescribes a specific data format.

The principal goal of a foreign function interface is to provide a
programmable interface between the Haskell context and external
contexts.  As a result Haskell threads can access data in external
contexts and invoke functions that are executed in an external context
as well as vice versa.  In the rest of this definition, external
contexts are usually identified by a calling convention.

==== Cross Language Type Consistency

Given that many external languages support static types, the question arises
whether the consistency of Haskell types with the types of the external
language can be enforced for foreign functions.  Unfortunately, this is, in
general, not possible without a significant investment on the part of the
implementor of the Haskell system (i.e., without implementing a dedicated type
checker).  For example, in the case of the C calling convention, the only
other approach would be to generate a C prototype from the Haskell type and
leave it to the C compiler to match this prototype with the prototype that is
specified in a C header file for the imported function.  However, the Haskell
type is lacking some information that would be required to pursue this route.
In particular, the Haskell type does not contain any information as to when
`const` modifiers have to be emitted.

As a consequence, this definition does not require the Haskell system to check
consistency with foreign types.  Nevertheless, Haskell systems are encouraged
to provide any cross language consistency checks that can be implemented with
reasonable effort.

=== Lexical Structure

The FFI reserves a single keyword `foreign`, and a set of special
identifiers.  The latter have a special meaning only within foreign
declarations, but may be used as ordinary identifiers elsewhere.

The special identifiers `ccall`, `cplusplus`, `dotnet`, `jvm`, and `stdcall` are defined to denote calling conventions.
However, a concrete implementation of the FFI is free to support additional,
system-specific calling conventions whose name is not explicitly listed here.

To refer to objects of an external C context, we introduce the following
phrases:
$
  italic("chname") &-> {italic("chchar")} mono(".h") &text("(C header filename)")\
  italic("cid") &-> italic("letter") {italic("letter") | italic("ascDigit")} &text("(C identifier)")\
  italic("chchar") &-> italic("letter") | italic("ascSymbol")_(chevron.l mono("&") chevron.r)\
  italic("letter") &-> italic("ascSmall") | italic("ascLarge") | mono("_")
$

The range of lexemes that are admissible for $italic("chname")$ is a subset of
those permitted as arguments to the `#include` directive in C.  In
particular, a file name $italic("chname")$ must end in the suffix `.h`.  The
lexemes produced by $italic("cid")$ coincide with those allowed as C identifiers,
as specified in~@Kernighan1988.

=== Foreign Declarations

The syntax of foreign declarations is as follows:
$
  italic("topdecl") &-> mono("foreign") italic("fdecl")\
  italic("fdecl") &-> mono("import") italic("callconv") [italic("safety")] italic("impent") italic("var") mono("::") italic("ftype") &text("(define variable)")\
  &| mono("export") italic("callconv") italic("expent") italic("var") mono("::") italic("ftype") &text("(expose variable)") \
  italic("callconv") &-> mono("ccall") | mono("stdcall") | mono("cplusplus") & text("(calling convention)")\
  &| mono("jvm") | mono("dotnet") \
  &| bold("system-specific calling conventions") \
  italic("impent") &-> [italic("string")]\
  italic("expent") &-> [italic("string")]\
  italic("safety") &-> mono("unsafe") | mono("safe")
$

There are two flavours of foreign declarations: import and export
declarations.  An import declaration makes an _external entity,_ i.e., a
function or memory location defined in an external context, available in the
Haskell context.  Conversely, an export declaration defines a function of the
Haskell context as an external entity in an external context.  Consequently,
the two types of declarations differ in that an import declaration defines a
new variable, whereas an export declaration uses a variable that is already
defined in the Haskell module.

The external context that contains the external entity is determined by the
calling convention given in the foreign declaration.  Consequently, the exact
form of the specification of the external entity is dependent on both the
calling convention and on whether it appears in an import declaration (as
$italic("impent")$) or in an export declaration (as $italic("expent")$).  To provide
syntactic uniformity in the presence of different calling conventions, it is
guaranteed that the description of an external entity lexically appears as a
Haskell string lexeme.  The only exception is where this string would be the
empty string (i.e., be of the form `""`); in this case, the string may be
omitted in its entirety.

==== Calling Conventions

The binary interface to an external entity on a given architecture is
determined by a calling convention.  It often depends on the programming
language in which the external entity is implemented, but usually is more
dependent on the system for which the external entity has been compiled.

As an example of how the calling convention is dominated by the system rather
than the programming language, consider that an entity compiled to byte code
for the Java Virtual Machine (JVM)~@Lindholm1996 needs to be
invoked by the rules of the JVM rather than that of the source language in
which it is implemented (the entity might be implemented in Oberon, for
example).

Any implementation of the Haskell FFI must at least implement the C calling
convention denoted by `ccall`.  All other calling conventions are
optional.  Generally, the set of calling conventions is open, i.e., individual
implementations may elect to support additional calling conventions.  In
addition to `ccall`, @tab:callconv specifies a range of
identifiers for common calling conventions.
#figure(
  caption: "Calling conventions",
  table(
    columns: 2,
    stroke: none,
    table.vline(x: 0),
    table.vline(x: 1),
    table.vline(x: 2),
    table.hline(),
    table.header([Identifier], [Represented calling
    convention]),
    table.hline(),
    [`ccall`],[Calling convention of the standard C compiler on a system],
    [`cplusplus`],[Calling convention of the standard C++ compiler on a system],
    [`dotnet`],[Calling convention of the `.NET` platform],
    [`jvm`],[Calling convention of the Java Virtual Machine],
    [`stdcall`],[Calling convention of the Win32 API (matches Pascal conventions)],
    table.hline(),
  )
)<tab:callconv>

Implementations need not implement all of these conventions, but if any is
implemented, it must use the listed name.  For any other calling convention,
implementations are free to choose a suitable name.

Only the semantics of the calling conventions `ccall` and `stdcall` are
defined herein; more calling conventions may be added in future versions
of Haskell.

It should be noted that the code generated by a Haskell system to implement a
particular calling convention may vary widely with the target code of that
system.  For example, the calling convention `jvm` will be trivial to
implement for a Haskell compiler generating Java code, whereas for a Haskell
compiler generating C code, the Java Native Interface (JNI)~@Liang1999
has to be targeted.

==== Foreign Types

The following types constitute the set of _basic foreign types_:

- `Char`, `Int`, `Double`, `Float`, and `Bool` as
  exported by the Haskell `Prelude` as well as
- `Int8`, `Int16`, `Int32`, `Int64`, `Word8`,
  `Word16`, `Word32`, `Word64`, `Ptr a`, `FunPtr a`,
  and `StablePtr a`, for any type `a`, as exported by `Foreign`
  (Section~\ref{module:Foreign}).


A Haskell system that implements the FFI needs to be able to pass these types
between the Haskell and the external context as function arguments and
results.

Foreign types are produced according to the following grammar:
$
  italic("ftype") &-> italic("frtype") \
  &| italic("fatype") mono("->") italic("ftype") \
  italic("frtype") &-> italic("fatype") \
  & | mono("()") \
  italic("fatype") &-> italic("qtycon") italic("atype")_1 dots italic("atype")_k & (k >= 0)
$

A foreign type is the Haskell type of an external entity.  Only a subset of
Haskell's types are permissible as foreign types, as only a restricted set of
types can be canonically transferred between the Haskell context and an
external context.  A foreign type has the form
$
  italic("at")_1 -> dots -> italic("at")_n -> italic("rt")
$

where $n >= 0$.  It implies that the arity of the external entity is $n$.

External functions are strict in all arguments.

*Marshallable foreign types.*
The argument types $italic("at")_i$ produced by $italic("fatype")$ must be
_marshallable foreign types;_ that is, either

- a basic foreign type,

- a type synonym that expands to a marshallable foreign type,

- a type $T med t'_1 dots t'_n$ where $T$ is defined by a `newtype` declaration
  $
    mono("newtype") T med a_1 dots a_n = N med t
  $
  and
  - the constructor $N$ is visible where $T$ is used,
  - $t[t'_1 italic("/") a_1 dots t'_n italic("/") a_n]$ is a marshallable foreign type

Consequently, in order for a type defined by `newtype` to be used in a
`foreign` declaration outside of the module that defines it, the type
must not be exported abstractly.  The module `Foreign.C.Types` that
defines the Haskell equivalents for C types follows this convention;
see Chapter~\ref{module:Foreign.C.Types}.

*Marshallable foreign result types.*
The result type $italic("rt")$ produced by $italic("frtype")$ must be a
_marshallable foreign result type;_ that is, either

- the type `()`,
- a type matching `Prelude.IO` $t$, where $t$ is a marshallable foreign type or `()`,
- a basic foreign type,
- a type synonym that expands to marshallable foreign result type,
- a type $T t'_1 dots t'_n$ where $T$ is defined by a `newtype` declaration
  $
    mono("newtype") T med a_1 dots a_n = N med t
  $
  and
  - the constructor $N$ is visible where $T$ is used,
  - $t[t'_1 italic("/") a_1 dots t'_n italic("/") a_n]$ is a marshallable foreign result type

==== Import Declarations

Generally, an import declaration has the form
$
  mono("foreign") mono("import") c med e med v mono("::") t
$

which declares the variable $v$ of type $t$ to be defined externally.
Moreover, it specifies that $v$ is evaluated by executing the external entity
identified by the string $e$ using calling convention $c$.  The precise form
of $e$ depends on the calling convention and is detailed in
@sec:extent[Section]
If a variable $v$ is defined by an import
declaration, no other top-level declaration for $v$ is allowed in the same
module.  For example, the declaration
```haskell
foreign import ccall "string.h strlen"
   cstrlen :: Ptr CChar -> IO CSize
```
introduces the function \mbox{\tt cstrlen}, which invokes the external function
`strlen` using the standard C calling convention.  Some external entities
can be imported as pure functions; for example,
```haskell
foreign import ccall "math.h sin"
   sin :: CDouble -> CDouble.
```
Such a declaration asserts that the external entity is a true function; i.e.,
when applied to the same argument values, it always produces the same result.

Whether a particular form of external entity places a constraint on the
Haskell type with which it can be imported is defined in
@sec:extent[Section]
Although, some forms of external entities restrict
the set of Haskell types that are permissible, the system can generally not
guarantee the consistency between the Haskell type given in an import
declaration and the argument and result types of the external entity.  It is
the responsibility of the programmer to ensure this consistency.

Optionally, an import declaration can specify, after the calling convention,
the safety level that should be used when invoking an external entity.  A
`safe` call is less efficient, but guarantees to leave the Haskell system
in a state that allows callbacks from the external code.  In contrast, an
`unsafe` call, while carrying less overhead, must not trigger a callback
into the Haskell system.  If it does, the system behaviour is undefined.  The
default for an invocation is to be `safe`.  Note that a callback into
the Haskell system implies that a garbage collection might be triggered after
an external entity was called, but before this call returns.  Consequently,
objects other than stable pointers (cf.\ Section~\ref{module:Foreign.StablePtr}) may be
moved or garbage collected by the storage manager.

==== Export Declarations

The general form of export declarations is
$
  mono("foreign") mono("export") c med e med v mono("::") t
$
Such a declaration enables external access to $v$, which may be a value, field
name, or class method that is declared on the top-level of the same module or
imported.  Moreover, the Haskell system defines the external entity described
by the string $e$, which may be used by external code using the calling
convention $c$; an external invocation of the external entity $e$ is
translated into evaluation of $v$.  The type $t$ must be an instance of the
type of $v$.  For example, we may have
```haskell
foreign export ccall "addInt"   (+) :: Int   -> Int   -> Int
foreign export ccall "addFloat" (+) :: Float -> Float -> Float
```
If an evaluation triggered by an external invocation of an exported Haskell
value returns with an exception, the system behaviour is undefined.  Thus,
Haskell exceptions have to be caught within Haskell and explicitly marshalled
to the foreign code.

=== Specification of External Entities <sec:extent>

Each foreign declaration has to specify the external entity that is accessed
or provided by that declaration.  The syntax and semantics of the notation
that is required to uniquely determine an external entity depends heavily on
the calling convention by which this entity is accessed.  For example, for the
calling convention `ccall`, a global label is sufficient.  However, to
uniquely identify a method in the calling convention `jvm`, type
information has to be provided.  For the latter, there is a choice between the
Java source-level syntax of types and the syntax expected by JNI---but,
clearly, the syntax of the specification of an external entity depends on the
calling convention and may be non-trivial.

Consequently, the FFI does not fix a general syntax for denoting external
entities, but requires both $italic("impent")$ and $italic("expent")$ to take the
form of a Haskell $italic("string")$ literal.  The formation rules for the values
of these strings depend on the calling convention and a Haskell system
implementing a particular calling convention will have to parse these strings
in accordance with the calling convention.

Defining $italic("impent")$ and $italic("expent")$ to take the form of a
$italic("string")$ implies that all information that is needed to statically
analyse the Haskell program is separated from the information needed to
generate the code interacting with the foreign language.  This is, in
particular, helpful for tools processing Haskell source code.  When ignoring
the entity information provided by $italic("impent")$ or $italic("expent")$, foreign
import and export declarations are still sufficient to infer identifier
definition and use information as well as type information.

For more complex calling conventions, there is a choice between the user-level
syntax for identifying entities (e.g., Java or C++) and the system-level
syntax (e.g., the type syntax of JNI or mangled C++, respectively).  If
such a choice exists, the user-level syntax is preferred.  Not only because it
is more user friendly, but also because the system-level syntax may not be
entirely independent of the particular implementation of the foreign language.

The following defines the syntax for specifying external entities and their
semantics for the calling conventions `ccall` and `stdcall`.  Other
calling conventions from @tab:callconv are expected to be defined
in future versions of Haskell.

==== Standard C Calls
==== Win32 API Calls
=== Marshalling <sec:marshalling>
=== The External C Interface