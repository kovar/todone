#let extract-text(c) = {
  if c == none {
    ""
  } else if type(c) == str {
    c
  } else if type(c) == array {
    c.map(extract-text).join("")
  } else if type(c) == content {
    let f = repr(c.func())
    if c.has("target") and f == "ref" {
      "@" + str(c.target)
    } else if f == "space" or f == "linebreak" or f == "parbreak" {
      " "
    } else if c.has("text") {
      c.text
    } else if c.has("children") {
      c.children.map(extract-text).join("")
    } else if c.has("body") {
      extract-text(c.body)
    } else if c.has("child") {
      extract-text(c.child)
    } else {
      " "
    }
  } else {
    ""
  }
}

#let detect-assignees(body) = {
  let text = extract-text(body)
  let matches = text.matches(regex("@([\w-]+)"))
  let seen = (:)
  let result = ()
  for m in matches {
    let handle = m.captures.at(0)
    if handle not in seen {
      seen.insert(handle, true)
      result.push(handle)
    }
  }
  result
}

#let hash-str(s) = {
  let h = 0
  for ch in s {
    let code = str.to-unicode(ch)
    h = calc.rem(h * 31 + code, 2147483647)
  }
  h
}
