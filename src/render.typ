#import "util.typ": detect-assignees
#import "colors.typ": color-for-assignee

#let render-inline(entry, cfg) = {
  let inner = entry.body
  let label = text(
    size: 0.7em,
    weight: "bold",
    fill: entry.color,
    smallcaps(entry.prefix),
  )
  let in-body = detect-assignees(entry.body)
  let extra = entry.assignees.filter(a => a not in in-body)
  let extra-line = if extra.len() > 0 {
    (
      h(4pt)
        + extra
          .map(a => {
            let c = color-for-assignee(
              a,
              palette: cfg.palette,
              overrides: cfg.assignees,
            )
            text(fill: c, weight: "bold", "@" + a)
          })
          .join(" ")
    )
  } else { none }
  let content = box(
    inset: (x: 4pt, y: 2pt),
    radius: 2pt,
    fill: entry.color.transparentize(80%),
    stroke: 0.5pt + entry.color,
  )[#label #h(3pt) #inner#extra-line]
  if entry.done { strike(content) } else { content }
}

#let _descent(page-num, side-name) = state(
  "todone:descent:" + str(page-num) + ":" + side-name,
  0pt,
)

#let render-margin(
  entry,
  cfg,
  position: auto,
  width: auto,
  gap: 4pt,
  page-padding: 2mm,
) = {
  context {
    let pos = here().position()
    let pw = page.width

    let m-left = if type(page.margin) == dictionary and "left" in page.margin {
      page.margin.left
    } else if type(page.margin) == length {
      page.margin
    } else {
      calc.min(pw * 2.5 / 21, 3cm)
    }
    let m-right = if (
      type(page.margin) == dictionary and "right" in page.margin
    ) {
      page.margin.right
    } else if type(page.margin) == length {
      page.margin
    } else {
      calc.min(pw * 2.5 / 21, 3cm)
    }

    let side = if position == left or position == right {
      position
    } else if m-left != m-right {
      if m-left > m-right { left } else { right }
    } else if pos.x < pw / 2 { left } else { right }
    let side-name = if side == left { "L" } else { "R" }

    let margin-w = if side == left { m-left } else { m-right }
    let box-w = if width == auto {
      calc.max(margin-w - page-padding * 2, 1cm)
    } else { width }

    let label = text(
      size: 0.7em,
      weight: "bold",
      fill: entry.color,
      smallcaps(entry.prefix),
    )

    let body-rendered = entry.body

    let in-body = detect-assignees(entry.body)
    let extra = entry.assignees.filter(a => a not in in-body)
    let assignees-line = if extra.len() > 0 {
      text(size: 0.7em, fill: entry.color.darken(20%))[
        #extra
        .map(a => {
        let c = color-for-assignee(
        a,
        palette: cfg.palette,
        overrides: cfg.assignees,
        )
        text(fill: c, weight: "bold", "@" + a)
        })
        .join(", ")
      ]
    } else { none }

    let stroke-side = if side == left {
      (right: 1.5pt + entry.color)
    } else {
      (left: 1.5pt + entry.color)
    }

    let inner = box(
      width: box-w,
      inset: (x: 3pt, y: 2pt),
      stroke: stroke-side,
    )[
      #set align(left)
      #label #h(4pt) #text(size: 0.8em, body-rendered)
      #if assignees-line != none [
        \
        #assignees-line
      ]
    ]

    let placed = if entry.done { strike(inner) } else { inner }

    let m = measure(placed)
    let descent = _descent(pos.page, side-name)
    let prev = descent.get()
    let placed-y = calc.max(pos.y, prev + gap)
    let dy = placed-y - pos.y
    descent.update(p => calc.max(pos.y, p + gap) + m.height)

    // Anchor in a zero-size box so the note is an inline element in
    // the surrounding paragraph — without it, `place` is block content
    // and a `#todo[...]` mid-paragraph would split the paragraph in
    // two. The box becomes the parent of `place`, so dx is computed
    // from the cursor position (pos.x) rather than the column edges.
    let dx = if side == left {
      page-padding - pos.x
    } else {
      pw - page-padding - pos.x
    }

    box(place(
      side,
      dx: dx,
      dy: dy,
      float: false,
      placed,
    ))
  }
}
