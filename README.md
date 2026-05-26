# todone

Ergonomic TODO annotations for Typst, with auto-colored assignees and inline @mentions.

## Why

- Drop TODOs inline or in the margin from a single function call.
- Each assignee gets a stable, deterministic color from a built-in palette — no manual bookkeeping.
- Write `@alice` directly in the TODO body and it becomes a tracked assignee, highlighted in the output.
- Custom formatting hooks let you restyle every TODO without forking the package.
- A single `#todo-list()` call collects every TODO in the document, with optional filtering and grouping.

## Install

```typst
#import "@preview/todone:0.1.0": *
```

## Quick start

```typst
#import "@preview/todone:0.1.0": *
#show: todone

= My document

This is a paragraph #todo[Fix the typo here @alice].

Another paragraph #todo[Review numbers @bob @carol].

#todo-list()
```

Apply the `todone` show rule once at the top of your document. After that, every `#todo[...]` call is annotated, the `@handles` inside the body are tracked, and `#todo-list()` renders a summary wherever you place it.

## The @mention magic

Anywhere inside a TODO body, write `@handle` to attach an assignee. The handle is stripped from the displayed text (or highlighted, depending on configuration), recorded as an assignee, and hashed to a stable color from the active palette.

Before, with a traditional TODO macro you would write:

```typst
#todo(assignee: "alice", color: rgb("#d33"))[Fix the typo here]
```

With `todone`:

```typst
#todo[Fix the typo here @alice]
```

Multiple mentions are supported and produce a multi-color marker:

```typst
#todo[Reconcile section 3 with the appendix @alice @bob]
```

Colors stay consistent across the document: every occurrence of `@alice` is the same color, every occurrence of `@bob` is a different stable color, and `@carol` gets a third — all without any configuration. Override colors explicitly via the `assignees:` option when needed.

## Types

Three built-in types, each with its own color and label:

| Function | Label | Color | When to use |
| --- | --- | --- | --- |
| `#todo[...]` | TODO | blue | generic task |
| `#fixme[...]` | FIX | red | known broken thing |
| `#ask[...]` | ? | purple | open question awaiting an answer |

The type owns the box color; `@mentions` inside the body keep their own per-assignee colors. So `#fixme[Broken @alice]` renders as a red FIX box with `@alice` highlighted in alice's color.

## API reference

### `todo(body, kind: "todo", assignee: auto, color: auto, position: auto, inline: false, done: false)`

Render a single annotation. `#fixme` and `#ask` are shorthand for `todo.with(kind: ...)`.

| Argument | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | content | — | The annotation text. `@handle` tokens are detected automatically. |
| `kind` | `str` | `"todo"` | One of `"todo"`, `"fixme"`, `"ask"`. Determines the prefix label and box color. |
| `assignee` | `auto`, `str`, or `array` | `auto` | When `auto`, assignees are read from `@mentions` in the body. Pass a string or array to override. |
| `color` | `auto` or `color` | `auto` | When `auto`, the box color comes from the kind. Pass a color to override. |
| `position` | `auto`, `left`, or `right` | `auto` | Which margin side to render on. `auto` prefers the wider margin. Ignored when `inline` is `true`. |
| `inline` | `bool` | `false` | Force inline rendering even when margins are wide. Inline is also the automatic fallback when no margin reaches 3cm. |
| `done` | `bool` | `false` | Mark this annotation as completed. Renders with a strikethrough. |

### `todo-list(title: [TODOs], filter: none, group-by: none)`

Render a collected list of every TODO in the document.

| Argument | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | content | `[TODOs]` | Heading for the list. Pass `none` to omit. |
| `filter` | `none` or function | `none` | Predicate `entry => bool`. Each entry exposes `body`, `assignees`, `color`, `kind`, `done`. |
| `group-by` | `none` or `"assignee"` | `none` | When set, groups entries under sub-headings. |

### `todone(body, hidden: false, position: auto, palette: default-palette, assignees: (:), format: none, show-mentions: true, passthrough-refs: false)`

The show-rule entry point. Apply with `#show: todone` or `#show: todone.with(...)`.

| Argument | Type | Default | Description |
| --- | --- | --- | --- |
| `hidden` | `bool` | `false` | Hide every annotation in the output. Useful for final print runs. |
| `position` | `auto`, `left`, or `right` | `auto` | Default margin side. `auto` prefers the wider margin. |
| `palette` | array of colors | `default-palette` | Colors used to highlight `@mentions` per assignee. |
| `assignees` | dictionary | `(:)` | Explicit `handle -> color` overrides for mention highlighting. Bypasses the palette hash. |
| `format` | `none` or function | `none` | Custom renderer. Receives an `entry` dict (with `body`, `assignees`, `color`, `kind`, `prefix`, `done`, `location`, `id`) and returns content. |
| `show-mentions` | `bool` | `true` | When `true`, `@handles` are highlighted in the rendered body. When `false`, they are rendered as plain text. |
| `passthrough-refs` | `bool` | `false` | When `true`, `@foo` inside a TODO body resolves as a normal Typst ref if `<foo>` exists in the document; only unresolved `@foo` are treated as mentions. When `false` (default), every `@foo` inside a TODO body is treated as a mention. |

### `default-palette`

The built-in palette used for auto-coloring. Exported so you can extend or reorder it:

```typst
#show: todone.with(palette: default-palette + (purple, teal))
```

## Configuration recipes

### Margin TODOs vs inline TODOs

With Typst's default page margins (~2.5cm on A4) a margin TODO would wrap every word, so by default `#todo[...]` renders inline. Widen either margin past 3cm and the same call automatically renders in that margin instead — no other code change required:

```typst
#set page(margin: (left: 4.5cm, right: 2cm, y: 2cm))
#show: todone
```

Force a particular mode per call with `inline: true` (always inline) or a `format:` callback (always custom).

### Real Typst refs inside TODOs

`@foo` inside a TODO body normally clashes with Typst's reference syntax. By default `todone` neutralizes every `@foo` inside a TODO body to literal mention text, which means you cannot reference labeled elements (figures, sections, theorems) from a TODO body.

Enable `passthrough-refs` to opt in to real refs inside TODOs:

```typst
#show: todone.with(passthrough-refs: true)

= Section A <sec-a>

#todo[See @sec-a — assign cleanup to @alice]
```

With this flag, `@foo` is resolved as a normal Typst ref when `<foo>` exists in the document, and treated as a mention only when the label is missing. Trade-off: each `@foo` triggers a `query()`, so heavily TODO-laden documents may render slightly slower.

### Hide all TODOs for final print

```typst
#show: todone.with(hidden: true)
```

All `#todo[...]` calls become invisible; the document layout is otherwise unchanged. `#todo-list()` is also suppressed.

### Override colors for specific people

```typst
#show: todone.with(assignees: (
  "alice": red,
  "bob": blue,
))
```

Handles not listed in the dictionary still receive their hashed color from the palette.

### Custom format

```typst
#show: todone.with(format: entry => {
  box(
    fill: entry.color.lighten(80%),
    stroke: entry.color + 0.5pt,
    inset: 4pt,
    radius: 3pt,
  )[
    *#entry.prefix* #entry.body
  ]
})
```

The callback receives a single `entry` dict with these fields:

- `body` — body content with `@mentions` already highlighted in their assignee colors
- `assignees` — array of handle strings
- `color` — the resolved color for this annotation (kind color by default)
- `kind` — `"todo"`, `"fixme"`, or `"ask"`
- `prefix` — the label content (`[TODO]`, `[FIX]`, `[?]`)
- `done` — `true` if marked completed
- `location` — the source location, useful for cross-references
- `id` — a unique integer id assigned in document order

### Filter the list

```typst
#todo-list(filter: e => "alice" in e.assignees)
```

Only show TODOs assigned to Alice. Filters compose naturally with `group-by`.

### Group by assignee

```typst
#todo-list(group-by: "assignee")
```

Produces one sub-section per assignee. A TODO with multiple assignees appears under each.

## Why no priorities, due dates, or status workflows

`todone` deliberately does not model priorities, due dates, statuses (`in-progress`, `blocked`, …), tags, or any other task-tracker metadata. Anything richer than "who, what kind, done?" belongs outside the document — in an issue tracker, a kanban board, or a checklist file — where it can be queried, sorted, and updated independently of the prose. Keeping `todone` small protects the call-site (`#todo[Fix this @alice]` stays a single short line) and avoids competing with tools that already do task tracking well.

## Comparison with prior art

`todone` builds on ideas from [`dashy-todo`](https://typst.app/universe/package/dashy-todo), [`todonotes`](https://typst.app/universe/package/todonotes), and [`tally`](https://typst.app/universe/package/tally). The differences:

- Assignees are detected from `@mentions` in the body, not passed as a separate argument.
- Colors are hashed from the handle, so they stay consistent across the document without manual configuration.
- Inline and margin styles share one API; switch with a single `position:` argument.
- `todo-list` supports filters and grouping out of the box.

If you need richer LaTeX-style margin notes with arrows and connectors, prefer `todonotes`. If you only want a simple inline TODO macro, `dashy-todo` is lighter.

## License

MIT. See [`LICENSE`](./LICENSE).
