#import "src/util.typ": detect-assignees, extract-text, hash-str
#import "src/colors.typ": color-for-assignee, default-palette
#import "src/state.typ": config-state, counter-state, items-state, register
#import "src/render.typ": render-inline, render-margin
#import "src/list.typ": todo-list
#import "src/kinds.typ": kinds

#let todone(
  body,
  hidden: false,
  position: auto,
  palette: default-palette,
  assignees: (:),
  format: none,
  show-mentions: true,
) = {
  config-state.update(_ => (
    hidden: hidden,
    position: position,
    palette: palette,
    assignees: assignees,
    format: format,
    show-mentions: show-mentions,
  ))
  body
}

#let todo(
  body,
  kind: "todo",
  assignee: auto,
  color: auto,
  priority: none,
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
    detect-assignees(body)
  } else if type(assignee) == str {
    (assignee,)
  } else if type(assignee) == array {
    assignee
  } else {
    ()
  }

  let safe-body = {
    show ref: it => "@" + str(it.target)
    body
  }

  let entry = (
    body: safe-body,
    assignees: assignees,
    color: resolved-color,
    kind: kind,
    prefix: resolved-prefix,
    priority: priority,
    done: done,
    location: here(),
  )

  register(entry)

  figure(kind: "todo", supplement: [TODO], outlined: false, numbering: none, [])

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
    calc.max(resolve("left"), resolve("right")) >= 3cm
  }

  if cfg.format != none {
    (cfg.format)(entry)
  } else if inline or not margin-fits {
    render-inline(entry, cfg)
  } else {
    render-margin(entry, cfg, position: effective-position)
  }
}

#let todo-done = todo.with(done: true)
#let todo-wip = todo.with(priority: "wip")

#let fixme = todo.with(kind: "fixme")
#let ask = todo.with(kind: "ask")
