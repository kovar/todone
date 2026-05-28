#import "/lib.typ": *

#set page(width: 12cm, height: auto, margin: 1cm)
#show: todone.with(
  assignees: ("alice": red, "bob": blue),
  format: entry => box(
    fill: entry.color.lighten(80%),
    stroke: (left: 2pt + entry.color),
    inset: (x: 6pt, y: 3pt),
    radius: 2pt,
  )[
    *FIX:* #entry.body
  ],
)

Paragraph one.
#todo[Custom-formatted item @alice]

Paragraph two.
#todo[Second one @bob]
