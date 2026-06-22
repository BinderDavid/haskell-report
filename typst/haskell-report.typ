#set document(
  title: [Haskell 2010 \ Language Report]
)

#let chapter-count = counter("chapter counter")
#show heading.where(level: 2): it => {
  if it.body == [Preface] {it}
  else {chapter-count.step() + it}
}
#set heading(numbering: (..nums) => {
  if nums.pos().len() == 1 {
    numbering("I.", ..nums) // Part
  } else if nums.pos().len() == 2 {
    numbering("1.", chapter-count.get().first() + 1) // Chapter
  } else {
    numbering("1.", ..chapter-count.get(), ..nums.pos().slice(2))
  }
})

#show heading.where(level: 1): it => {
  if it.body == [Contents] or it.body == [Bibliography] { it }
  else {
    set align(center + horizon)
    set text(36pt)
    pagebreak(weak: true) + [Part #it]
  }
}
#show heading.where(level: 2): set text(22pt)
#show heading.where(level: 2): it => pagebreak(weak: true) + [Chapter #it]

#show heading.where(level: 3): set text(18pt)

#set par(
  justify: true,
)

#show title: set align(center)


//
// CONTENT
//

#include "other/titlepage.typ"

#outline()

#pagebreak()

#counter(page).update(1)
#set page(numbering: "1")

#heading(level: 2, numbering: none)[Preface]

#include "other/preface.typ"

= The Haskell 2010 Language

== Introduction <chapter:intro>


#include "chapters/intro.typ"

== Lexical Structure <chapter:lexical-structure>

#include "chapters/lexical-structure.typ"

== Expressions <chapter:expressions>

#include "chapters/expressions.typ"

== Declarations and Bindings <chapter:declarations>

#include "chapters/declarations.typ"

== Modules <chapter:modules>

#include "chapters/modules.typ"

== Predefined Types and Classes <chapter:predefined-types>

#include "chapters/predefined-types.typ"

== Basic Input/Output <chapter:basic-input-output>

#include "chapters/basic-input-output.typ"

== Foreign Function Interface <chapter:ffi>

#include "chapters/ffi.typ"

== Standard Prelude <chapter:standard-prelude>

#include "chapters/standard-prelude.typ"

== Syntax Reference <chapter:syntax-reference>

#include "chapters/syntax-reference.typ"

== Specification of Derived Instances <chapter:derived-instances>

#include "chapters/derived-instances.typ"

== Compiler Pragmas <chapter:compiler-pragmas>

#include "chapters/compiler-pragmas.typ"

= The Haskell 2010 Libraries <part:libraries>

== Control.Monad <chapter:control.monad>

== Data.Array

== Data.Bits

== Data.Char

== Data.Complex

== Data.Int

== Data.Ix

== Data.List

== Data.Maybe

== Data.Ratio

== Data.Word

== Foreign

== Foreign.C

== Foreign.C.Error

== Foreign.C.String

== Foreign.C.Types

== Foreign.ForeignPtr

== Foreign.Marshal

== Foreign.Marshal.Alloc

== Foreign.Marshal.Array

== Foreign.Marshal.Utils

== Foreign.Ptr

== Foreign.StablePtr

== Foreign.Storable

== Numeric

== System.Environment

== System.Exit

== System.IO

== System.IO.Error

#pagebreak()

#bibliography("bibliography.bib")