// Theme toggle; CSS selects the icon and label from the root theme.

#import "../icon.typ": ui-icon

/// Theme toggle with localized next-action labels.
#let theme-button(messages) = html.elem(
  "button",
  attrs: (
    type: "button",
    class: "ui-control icon-control theme-toggle",
    disabled: "",
    "data-theme-toggle": "",
  ),
  html.span(
    class: "theme-sun",
    title: messages.switch-to-light,
    ui-icon("sun") + html.span(class: "sr-only", messages.switch-to-light),
  )
    + html.span(
      class: "theme-moon",
      title: messages.switch-to-dark,
      ui-icon("moon") + html.span(class: "sr-only", messages.switch-to-dark),
    ),
)
