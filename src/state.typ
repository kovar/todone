#import "colors.typ": default-palette

#let config-state = state("todone:config", (
  hidden: false,
  position: auto,
  palette: default-palette,
  assignees: (:),
  format: none,
  show-mentions: true,
  prefix: [TODO],
))

#let items-state = state("todone:items", ())

#let counter-state = state("todone:counter", 0)

#let register(entry) = {
  counter-state.update(n => n + 1)
  context {
    let id = counter-state.get()
    let with-id = entry
    with-id.insert("id", id)
    items-state.update(items => {
      let updated = items
      updated.push(with-id)
      updated
    })
  }
}
