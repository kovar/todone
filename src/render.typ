#import "util.typ": detect-assignees
#import "colors.typ": color-for-assignee

#let _styled-body(body, cfg, show-mentions: true) = {
  if show-mentions {
    show regex("@[\w-]+"): name => {
      let handle = name.text.slice(1)
      let c = color-for-assignee(
        handle,
        palette: cfg.palette,
        overrides: cfg.assignees,
      )
      text(fill: c, weight: "bold", name)
    }
    body
  } else {
    body
  }
}

#let render-inline(entry, cfg) = {
  let body = entry.body
  let inner = _styled-body(body, cfg, show-mentions: cfg.show-mentions)
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
  width: auto,
  gap: 4pt,
  page-padding: 4mm,
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

    let body-rendered = _styled-body(
      entry.body,
      cfg,
      show-mentions: cfg.show-mentions,
    )

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

    let dx = if side == left {
      page-padding - m-left
    } else {
      m-right - page-padding - box-w
    }

    place(
      side,
      dx: dx,
      dy: dy,
      float: false,
      placed,
    )
  }
}
