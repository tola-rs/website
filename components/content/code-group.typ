// Tabbed code samples using native radio inputs.

#let _code-group-counter = counter("code-group")

/// Tabs with `label` and `body`; `label` names the group.
#let code-group(tabs, label: "Code samples") = context {
  let name = "code-group-" + str(_code-group-counter.get().first())
  _code-group-counter.step()
  html.div(class: "code-group", role: "group", aria-label: label)[
    #for (index, tab) in tabs.enumerate() {
      let input-id = name + "-" + str(index)
      html.input(
        type: "radio",
        name: name,
        id: input-id,
        class: "code-tab-input",
        checked: index == 0,
      )
      html.label(class: "code-tab", ..("for": input-id))[#tab.label]
      let preview = if index == 0 {
        ("data-search-preview-label": tab.label)
      } else {
        ("data-search-preview-ignore": "")
      }
      html.elem("div", attrs: (class: "code-panel", ..preview))[#tab.body]
    }
  ]
}
