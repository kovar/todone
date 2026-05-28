# CLAUDE.md

Guidance for Claude when working in this repo.

## What this is

`todone` is a Typst package for inline and margin TODO annotations with auto-colored `@mention` assignees. Entry point is `lib.typ`; modules live under `src/`. Public API: `todone` (show-rule entry), `todo`, `fixme`, `ask`, `todo-done`, `todo-list`, `default-palette`.

## Commands

```bash
# Snapshot tests
tt run

# Formatter (CI gate)
typstyle --check lib.typ src/*.typ examples/*.typ

# Compile examples
typst compile examples/basic.typ
typst compile examples/advanced.typ

# Version bump (edits typst.toml + syncs README/examples)
./scripts/bump-version.sh patch|minor|major|X.Y.Z

# Verify @preview/todone:<ver> references match typst.toml
./scripts/check-version-refs.sh "$(awk -F'"' '/^version *=/ {print $2; exit}' typst.toml)"
```

## Dev / release workflow

1. Feature branches for each change; no direct commits to `main`.
2. CI gates the merge (runs on PR and push to `main`).
3. Release: `git switch -c release/v<X.Y.Z>` → `./scripts/bump-version.sh ...` → review → commit → PR → merge.
4. Tag on `main`: `git tag v<X.Y.Z> && git push --tags`.
5. Publish to the **Typst Pro private team** via typst.app web UI. Not submitting to Universe at this stage — don't assume the `typst/packages` PR flow applies.

`typst.toml` is the single source of truth for the version. The CI step "Verify version references are in sync" fails if README or examples drift.

## Conventions

- **Out-of-box defaults must work.** Bare `#show: todone` on default A4 must render correctly without user configuration. If a layout requires custom margins, fix the package (auto-detect, fall back), don't ask the user to configure.
- **Scope is intentionally narrow.** No priorities, due dates, statuses, tags, or other task-tracker metadata. Only three TODO types: `todo`, `fixme`, `ask`. Adding more pushes against the design goal of keeping the call-site one short line. See the "Why no priorities, due dates, or status workflows" section in README.md before adding scope.
- **Verify rendering visually before reporting a UI change done.** Type-check passing or `tt run` passing is not enough — compile the relevant example PDF and inspect it. Typst's `state` + `measure` + `place` machinery can render incorrectly without producing compile errors.
- **Default to no comments.** Only document the *why* of non-obvious decisions, never the *what*. Examples in `lib.typ`, `src/render.typ` already follow this.

## Known quirks

- **`layout did not converge within 5 attempts`** is benign. Standard side effect of `state` + `measure` + `place(float: false)` for margin notes; output is correct. Same as `dashy-todo` issue #15.
- **Tytanic tests must be created persistent.** `tt new --persistent <name>` first, *then* overwrite `tests/<name>/test.typ`. Empty `ref/` directories register as compile-only and silently skip snapshot comparison.
- **CI stages the working tree** into `~/.local/share/typst/packages/preview/todone/<version>/` so `examples/*.typ` (which import `@preview/todone:<version>`) resolve.
- **Refs inside TODO bodies** (`#todo[See @sec-a]`) would otherwise explode with "Label `<sec-a>` does not exist". `lib.typ` neutralizes them with `show ref: it => "@" + str(it.target)`. Opt in to real refs with `passthrough-refs: true`.
- **`extract-text`** must return `" "` for space/linebreak/parbreak and for unknown content, otherwise mention detection mangles handles (`@bob's` → `bobs`).
