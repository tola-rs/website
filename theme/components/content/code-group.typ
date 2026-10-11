#let _code-group-counter = counter("code-group")

/// Each tab has a `label` and `body`. The group `label` is its accessible name.
#let code-group(tabs, label: "Code samples") = context {
  let group-name = "code-group-" + str(_code-group-counter.get().first())
  _code-group-counter.step()
  html.div(class: "code-group", role: "group", aria-label: label)[
    #for (index, tab) in tabs.enumerate() {
      let is-default = index == 0
      let preview-attrs = if is-default {
        ("data-search-preview-label": tab.label)
      } else {
        ("data-search-preview-ignore": "")
      }

      html.label(class: "code-tab", {
        html.input(type: "radio", name: group-name, checked: is-default)
        tab.label
      })
      html.elem("div", attrs: (class: "code-panel", ..preview-attrs))[#tab.body]
    }
  ]
}
