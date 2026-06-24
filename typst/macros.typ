/// Typesetting terminal symbols in the grammar
#let terminal(x) = {
  text(fill: eastern, $mono(#x)$)
}

/// Typesetting nonterminal symbols in the gramma
#let nonterminal(x) = {
  text(fill: maroon, $italic(#x)$)
}

#let nonterminaldef(x) = {
  text(fill: maroon, $italic(#x)$)
}

/// A box used in defining the meaning of syntactic entities by translation.
#let translation-box(x) = box(
  stroke: black,
  width: 1fr,
  inset: 10pt,
  [*Translation:* #x]
)