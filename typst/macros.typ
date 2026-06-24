/// Typesetting terminal symbols in the grammar
#let terminal(x) = {
  text(fill: eastern, $mono(#x)$)
}

/// A box used in defining the meaning of syntactic entities by translation.
#let translation-box(x) = box(
  stroke: black,
  width: 1fr,
  inset: 10pt,
  [*Translation:* #x]
)