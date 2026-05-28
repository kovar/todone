#import "src/util.typ": detect-assignees, extract-text, hash-str
#import "src/colors.typ": color-for-assignee, default-palette
#import "src/state.typ": config-state, counter-state, items-state, register
#import "src/render.typ": render-inline, render-margin
#import "src/list.typ": todo-list
#import "src/kinds.typ": kinds

#let config(
  body,
  hidden: false,
  position: auto,
  palette: default-palette,
  assignees: (:),
  format: none,
  show-mentions: true,
  passthrough-refs: false,
  min-margin: 2.5cm,
) = {
  config-state.update(_ => (
    hidden: hidden,
    position: position,
    palette: palette,
    assignees: assignees,
    format: format,
    show-mentions: show-mentions,
    passthrough-refs: passthrough-refs,
    min-margin: min-margin,
  ))
  body
}

#let todo(
  body,
  kind: "todo",
  assignee: auto,
  color: auto,
  position: auto,
  inline: false,
  done: false,
) = context {
  let cfg = config-state.get()
  if cfg.hidden {
    return
  }

  let kind-spec = kinds.at(kind, default: kinds.todo)
  let resolved-color = if color != auto { color } else { kind-spec.color }
  let resolved-prefix = kind-spec.prefix

  let assignees = if assignee == none {
    ()
  } else if assignee == auto {
    let detected = detect-assignees(body)
    if cfg.passthrough-refs {
      detected.filter(a => query(label(a)).len() == 0)
    } else { detected }
  } else if type(assignee) == str {
    (assignee,)
  } else if type(assignee) == array {
    assignee
  } else {
    ()
  }

  let safe-body = if cfg.passthrough-refs {
    show ref: it => context {
      if query(it.target).len() > 0 { it } else { "@" + str(it.target) }
    }
    body
  } else {
    show ref: it => "@" + str(it.target)
    body
  }

  let styled-body = if cfg.show-mentions {
    show regex("@[\w-]+"): name => {
      let handle = name.text.slice(1)
      let c = color-for-assignee(
        handle,
        palette: cfg.palette,
        overrides: cfg.assignees,
      )
      text(fill: c, weight: "bold", name)
    }
    safe-body
  } else { safe-body }

  let entry = (
    body: styled-body,
    assignees: assignees,
    color: resolved-color,
    kind: kind,
    prefix: resolved-prefix,
    done: done,
    location: here(),
  )

  register(entry)

  let effective-position = if position != auto { position } else {
    cfg.position
  }

  let margin-fits = {
    let m = page.margin
    let resolve = side => {
      if type(m) == dictionary and side in m {
        m.at(side)
      } else if type(m) == length {
        m
      } else {
        calc.min(page.width * 2.5 / 21, 3cm)
      }
    }
    calc.max(resolve("left"), resolve("right")) >= cfg.min-margin
  }

  let rendered = if cfg.format != none {
    (cfg.format)(entry)
  } else if inline or not margin-fits {
    render-inline(entry, cfg)
  } else {
    render-margin(entry, cfg, position: effective-position)
  }

  // Margin TODOs are placed absolutely and take no flow space, so they
  // don't need a block wrapper. Inline and custom formats do — without
  // it, a short TODO can flow onto the same visual line as surrounding
  // prose and visually hide.
  if margin-fits and not inline and cfg.format == none {
    rendered
  } else {
    block(above: 0.4em, below: 0.4em, rendered)
  }
}

#let todo-done = todo.with(done: true)

#let fixme = todo.with(kind: "fixme")
#let ask = todo.with(kind: "ask")
