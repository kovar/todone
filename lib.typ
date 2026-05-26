#import "src/util.typ": detect-assignees, extract-text, hash-str
#import "src/colors.typ": color-for-assignee, default-palette
#import "src/state.typ": config-state, counter-state, items-state, register
#import "src/render.typ": render-inline, render-margin
#import "src/list.typ": todo-list

#let todone(
  body,
  hidden: false,
  position: auto,
  palette: default-palette,
  assignees: (:),
  format: none,
  show-mentions: true,
  prefix: [TODO],
) = {
  config-state.update(_ => (
    hidden: hidden,
    position: position,
    palette: palette,
    assignees: assignees,
    format: format,
    show-mentions: show-mentions,
    prefix: prefix,
  ))
  body
}

#let todo(
  body,
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

  let resolved-color = if color != auto {
    color
  } else if assignees.len() > 0 {
    color-for-assignee(
      assignees.at(0),
      palette: cfg.palette,
      overrides: cfg.assignees,
    )
  } else {
    rgb("#888888")
  }

  let safe-body = {
    show ref: it => "@" + str(it.target)
    body
  }

  let entry = (
    body: safe-body,
    assignees: assignees,
    color: resolved-color,
    priority: priority,
    done: done,
    location: here(),
  )

  register(entry)

  figure(kind: "todo", supplement: [TODO], outlined: false, numbering: none, [])

  let effective-position = if position != auto { position } else {
    cfg.position
  }

  if cfg.format != none {
    (cfg.format)(entry)
  } else if inline {
    render-inline(entry, cfg)
  } else {
    render-margin(entry, cfg, position: effective-position)
  }
}

#let todo-done = todo.with(done: true)
#let todo-wip = todo.with(priority: "wip")
