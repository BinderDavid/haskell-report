#let chapter-count = counter("chapter counter")
#show heading.where(level: 2): it => chapter-count.step() + it
#set heading(numbering: (..nums) => {
  if nums.pos().len() == 1 {
    numbering("I.", ..nums) // Part
  } else if nums.pos().len() == 2 {
    numbering("1.", chapter-count.get().first() + 1) // Chapter
  } else {
    numbering("1.", ..chapter-count.get(), ..nums.pos().slice(2))
  }
})

#show heading.where(level: 1): it => if it.body == [Contents] { it } else {
  set align(center + horizon)
  set text(36pt)
  pagebreak(weak: true) + it
}

#show heading.where(level: 2): set text(22pt)
#show heading.where(level: 2): it => pagebreak(weak: true) + it

#set par(
  justify: true,
)

#outline(target: selector.or(heading.where(level: 1), heading.where(level: 2)))




= The Haskell 2010 Language

== Introduction <chapter:intro>


#include "sections/intro.typ"

== Lexical Structure <chapter:lexical-structure>

== Expressions <chapter:expressions>

== Declarations and Bindings <chapter:declarations>

== Modules <chapter:modules>

== Predefined Types and Classes <chapter:predefined-types>

== Basic Input/Output <chapter:basic-input-output>

== Foreign Function Interface <chapter:ffi>

== Standard Prelude <chapter:standard-prelude>

== Syntax Reference <chapter:syntax-reference>

== Specification of Derived Instances <chapter:derived-instances>

== Compiler Pragmas <chapter:compiler-pragmas>

= The Haskell 2010 Libraries

