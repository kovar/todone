#import "/lib.typ": *

#set page(width: 12cm, height: auto, margin: 1cm)
#show: config

#todo(inline: true)[Fix A @alice]
#todo(inline: true)[Fix B @bob]
#todo(inline: true)[Fix C @alice @bob]
#todo(done: true, inline: true)[Fix D @alice]

#pagebreak()

#todo-list(group-by: "assignee")

= Open
#todo-list(filter: e => not e.done)
