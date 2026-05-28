#import "/lib.typ": *

#set page(width: 16cm, height: 10cm, margin: (x: 3cm, y: 1cm))
#show: config

This is a paragraph in the main column.
#todo[Review numbers @bob]

A second paragraph with another margin annotation.
#todo[Tighten phrasing @carol]

A third paragraph far down the page so the two prior TODOs have room.
#todo[Stacked TODO that should sit below the others @alice]
