#import "@preview/todone:0.1.0": *

// A small custom format that draws TODOs as soft callout boxes.
#let callout-format(entry) = {
  let label = if entry.priority == none [FIX] else [FIX (#entry.priority)]
  let who = if entry.assignees.len() == 0 [] else {
    text(size: 0.85em, fill: entry.color.darken(20%))[
      — #entry.assignees.map(a => "@" + a).join(", ")
    ]
  }
  box(
    fill: entry.color.lighten(85%),
    stroke: (left: 2pt + entry.color),
    inset: (x: 6pt, y: 4pt),
    radius: 2pt,
  )[
    #text(weight: "bold", fill: entry.color.darken(30%))[#label]
    #h(0.4em)
    #entry.body
    #h(0.4em)
    #who
  ]
}

#show: todone.with(
  assignees: (
    "alice": red,
    "bob": blue,
  ),
  prefix: [FIX],
  format: callout-format,
)

= On the convergence of distributed gradient methods

== Introduction

The literature on distributed stochastic gradient descent has converged
on a handful of canonical assumptions, but the bounded-variance regime
remains poorly understood in the asynchronous setting.
#todo(priority: "high")[
  Cite Lian et al. 2017 and the more recent Karimireddy survey @alice
]

A complete characterization of the asynchronous case is beyond the scope
of this paper; we restrict attention to the bounded-delay model.
#todo[
  Reviewer asked whether unbounded delay is tractable. Add a one-line
  footnote saying we leave it as future work. @bob
]

== Main result

#lorem(35)

Our central contribution is Theorem 1, which sharpens the constant in
the leading-order term by a factor of two.
#todo(done: true)[
  Double-check the factor-of-two improvement against the proof in
  Appendix B @alice
]

== Experiments

We evaluate on three benchmark tasks. The wall-clock numbers reported in
Table 3 were collected on a shared cluster and may be noisy.
#todo(priority: 2)[
  Re-run experiments on the dedicated nodes once allocation is approved
  @bob @carol
]

The ablation in Figure 4 is missing the no-momentum baseline.
#todo[Add no-momentum row to the ablation @carol]

== Discussion

#lorem(28)

#todo(inline: true)[Tighten the connection to the variance-reduction
  literature in the related-work section @alice]

= Outstanding work

By assignee:

#todo-list(group-by: "assignee")

Open items only:

#todo-list(title: [Open], filter: e => not e.done)
