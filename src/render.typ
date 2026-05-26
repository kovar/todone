#let _styled-body(body, color, show-mentions: true) = {
  if show-mentions {
    show regex("@\w+"): name => text(fill: color, weight: "bold", name)
    body
  } else {
    body
  }
}

#let render-inline(entry, cfg) = {
  let body = entry.body
  let inner = _styled-body(body, entry.color, show-mentions: cfg.show-mentions)
  let label = text(
    size: 0.7em,
    weight: "bold",
    fill: entry.color,
    smallcaps(cfg.prefix),
  )
  let content = box(
    inset: (x: 4pt, y: 2pt),
    radius: 2pt,
    fill: entry.color.transparentize(80%),
    stroke: 0.5pt + entry.color,
  )[#label #h(3pt) #inner]
  if entry.done {
    strike(content)
  } else {
    content
  }
}

#let _descent(page-num, side-name) = state(
  "todone:descent:" + str(page-num) + ":" + side-name,
  0pt,
)

#let render-margin(
  entry,
  cfg,
  position: auto,
  width: 2.5cm,
  left-dx: -2.8cm,
  right-dx: 1cm,
  gap: 4pt,
) = {
  context {
    let pos = here().position()
    let page-size = page.width
    let side = if position == left or position == right {
      position
    } else {
      let middle = page-size / 2
      if pos.x < middle { left } else { right }
    }
    let side-name = if side == left { "L" } else { "R" }

    let dx = if side == left { left-dx } else { right-dx }

    let label = text(
      size: 0.7em,
      weight: "bold",
      fill: entry.color,
      smallcaps(cfg.prefix),
    )

    let body-rendered = _styled-body(
      entry.body,
      entry.color,
      show-mentions: cfg.show-mentions,
    )

    let assignees-line = if entry.assignees.len() > 0 {
      text(size: 0.7em, fill: entry.color.darken(20%))[
        #entry.assignees.map(a => "@" + a).join(", ")
      ]
    } else { none }

    let stroke-side = if side == left {
      (right: 1.5pt + entry.color)
    } else {
      (left: 1.5pt + entry.color)
    }

    let inner = box(
      width: width,
      inset: (x: 5pt, y: 3pt),
      stroke: stroke-side,
    )[
      #label \
      #text(size: 0.8em, body-rendered)
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
    descent.update(_ => placed-y + m.height)

    place(
      side,
      dx: dx,
      dy: dy,
      float: false,
      placed,
    )
  }
}
