#import "util.typ": hash-str

#let default-palette = (
  rgb("#3b82f6"),
  rgb("#ef4444"),
  rgb("#10b981"),
  rgb("#f59e0b"),
  rgb("#8b5cf6"),
  rgb("#ec4899"),
  rgb("#14b8a6"),
  rgb("#f97316"),
  rgb("#6366f1"),
  rgb("#84cc16"),
  rgb("#06b6d4"),
  rgb("#a855f7"),
)

#let color-for-assignee(assignee, palette: default-palette, overrides: (:)) = {
  if assignee in overrides {
    overrides.at(assignee)
  } else {
    palette.at(calc.rem(hash-str(assignee), palette.len()))
  }
}
