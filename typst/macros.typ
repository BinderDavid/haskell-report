/// A box used in defining the meaning of syntactic entities by translation.
#let translation-box(x) = box(
  stroke: black,
  width: 1fr,
  inset: 10pt,
  [*Translation:* #x]
)