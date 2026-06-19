In September of 1987 a meeting was held at the conference on Functional Programming Languages and Computer Architecture (FPCA ’87) in Portland, Oregon, to discuss an unfortunate situation in the functional programming community: there had come into being more than a dozen non-strict, purely functional programming languages, all similar in expressive power and semantic underpinnings. There was a strong consensus at this meeting that more widespread use of this class of functional languages was being hampered by the lack of a common language. It was decided that a committee should be formed to design such a language, providing faster communication of new ideas, a stable foundation for real applications development, and a vehicle through which others would be encouraged to use functional languages. This document describes the result of that (and subsequent) committee’s efforts: a purely functional programming language called Haskell, named after the logician Haskell B. Curry whose work provides the logical basis for much of ours.

#heading(level: 3, numbering: none)[Goals]

The committee's primary goal was to design a language that satisfied these constraints:

+ It should be suitable for teaching, research, and applications, including building large systems.
+ It should be completely described via the publication of a formal syntax and semantics.
+ It should be freely available. Anyone should be permitted to implement the language and distribute it to whomever they please.
+ It should be based on ideas that enjoy a wide consensus.
+ It should reduce unnecessary diversity in functional programming languages.

#heading(level: 3, numbering: none)[Haskell 2010: language and libraries]

The committee intended that Haskell would serve as a basis for future research in language design, and hoped that extensions or variants of the language would appear, incorporating experimental features.

Haskell has indeed evolved continuously since its original publication. By the middle of 1997, there had been five versions of the language design (from Haskell 1.0 - 1.4). At the 1997 Haskell Workshop in Amsterdam, it was decided that a stable variant of Haskell was needed; this became "Haskell 98" and was published in February 1999. The fixing of minor bugs led to the _Revised_ Haskell 98 Report in 2002.

At the 2005 Haskell Workshop, the consensus was that so many extensions to the official language were widely used (and supported by multiple implementations), that it was worthwhile to define another iteration of the language standard, essentially to codify (and legitimise) the status quo.

The Haskell Prime effort was thus conceived as a relatively conservative extension of Haskell 98, taking on board new features only where they were well understood and widely agreed upon. It too was intended to be a "stable" language, yet reflecting the considerable progress in research on language design in recent years.

After several years exploring the design space, it was decided that a single monolithic revision of the language was too large a task, and the best way to make progress was to evolve the language in small incremental steps, each revision integrating only a small number of well-understood extensions and changes. Haskell 2010 is the first revision to be created in this way, and new revisions are expected once per year.

#heading(level: 3, numbering: none)[Extensions to Haskell 98]

The most significant language changes in Haskell 2010 relative to Haskell 98 are listed here.

New language features:

- A Foreign Function Interface (FFI).
- Hierarchical module names, e.g. Data.Bool.
- Pattern guards.

Removed language features:

- The (n + k) pattern syntax.

#heading(level: 3, numbering: none)[Haskell Resources]

#heading(level: 3, numbering: none)[Building the language]