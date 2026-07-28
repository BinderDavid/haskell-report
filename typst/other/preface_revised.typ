Over 16 years have passed since the publication of the Haskell 2010 language report, and the Haskell that we write today has evolved in many ways, some of which are incompatible with the language specified in the Haskell 2010 language report.
In order to account for this change we saw the need to compile a _revised version_ of the Haskell 2010 language report which does not add any novel language features but brings the report in line with the version of Haskell 2010 implemented by compilers and maintainers of the standard libraries.
This revised report is the result of that effort.

#heading(level: 2, numbering: none)[Organization of the Revised Report]

In distinction to the previous version of the Haskell 2010 language report, this revision separates out documentation of the standard libraries.
These standard libraries are now available in the form of a zero-dependency Haskell package which makes the API specification machine readable and allows to generate documentation using standard Haskell tools like Haddock.


#heading(level: 2, numbering: none)[Changes to the  Report]

The (planned) changes to the report are:
- "Functor-Applicative-Monad" proposal
- "MonadFail" proposal
- "Monad of no return" proposal
- "Burning Bridges" proposal --- Generalization of list functions
- Syntax of numeric literals
- (Unicode) Syntax of identifiers
- Changes to the Num typeclass
- Changes to Bits typeclass
- Changes to specification of recursive modules (maybe?)
- "forall" is now a keyword
- Treatment of whitespace around operators
- Move section about deriving of `Ix` instances into report
