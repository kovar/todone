#import "state.typ": config-state, items-state

#let _render-entry(entry, cfg) = {
  let swatch = box(
    width: 0.7em,
    height: 0.7em,
    fill: entry.color,
    radius: 1.5pt,
    baseline: 0.1em,
  )
  let body-cell = link(entry.location)[#swatch #h(4pt) #entry.body]
  let page-num = entry.location.page()
  let row = box(width: 100%)[
    #body-cell
    #box(width: 1fr, repeat[.])
    #page-num
  ]
  if entry.done { strike(row) } else { row }
}

#let todo-list(title: [TODOs], filter: none, group-by: none) = context {
  let cfg = config-state.get()
  let items = items-state.final()
  if filter != none {
    items = items.filter(filter)
  }

  if title != none {
    heading(level: 1, title)
  }

  if group-by == none {
    for entry in items {
      _render-entry(entry, cfg)
      linebreak()
    }
  } else if group-by == "assignee" {
    let groups = (:)
    let order = ()
    for entry in items {
      let keys = if entry.assignees.len() == 0 {
        ("unassigned",)
      } else {
        entry.assignees
      }
      for key in keys {
        if key not in groups {
          groups.insert(key, ())
          order.push(key)
        }
        let arr = groups.at(key)
        arr.push(entry)
        groups.insert(key, arr)
      }
    }
    for key in order {
      heading(level: 2, if key == "unassigned" [unassigned] else { "@" + key })
      for entry in groups.at(key) {
        _render-entry(entry, cfg)
        linebreak()
      }
    }
  }
}
