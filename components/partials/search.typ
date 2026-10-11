// Search trigger, dialog, and image preview.

#import "@tola/address:0.0.0": output-url
#import "../icon.typ": icon
#import "../assets.typ" as assets

/// Search trigger.
#let search-button(messages) = html.elem(
  "button",
  attrs: (
    type: "button",
    class: "ui-control search-trigger",
    "aria-label": messages.title,
    "data-open-search": "",
    disabled: "",
    "aria-haspopup": "dialog",
    "aria-controls": "site-search",
  ),
  icon("search")
    + html.span(class: "control-label", messages.button)
    + html.kbd(aria-hidden: true),
)

// Status text consumed by search.js.
#let _message-attrs(messages) = (
  "data-empty": messages.empty,
  "data-searching": messages.searching,
  "data-count": messages.count,
  "data-none": messages.none,
  "data-error": messages.error,
)

/// Search dialog.
#let search-popup(messages) = {
  html.elem("dialog", attrs: (
    id: "site-search",
    class: "search-popup",
    "aria-labelledby": "search-title",
    "aria-describedby": "search-hint",
    "data-pagefind-ignore": "all",
    "data-index": assets.pagefind-url(),
    "data-base-url": output-url("index.html"),
    .._message-attrs(messages),
  ))[
    #html.h2(id: "search-title", class: "sr-only", messages.title)
    #html.p(id: "search-hint", class: "sr-only", messages.hint)
    #html.label(..("for": "search-input"), class: "sr-only", messages.label)
    #html.div(class: "search-field")[
      #icon("search")
      // Raw input: typed autocomplete rejects "off".
      #html.elem("input", attrs: (
        id: "search-input",
        type: "search",
        placeholder: messages.placeholder,
        autocomplete: "off",
        enterkeyhint: "search",
        "aria-describedby": "search-status",
      ))
      #html.div(class: "search-actions")[
        #html.elem("button", attrs: (
          type: "button",
          class: "ui-control search-tool",
          id: "search-details",
          "aria-label": messages.details,
          title: messages.details,
          "aria-pressed": "false",
          "aria-controls": "search-results",
        ))[#icon("list") #html.span(class: "search-view-label", messages.details)]
        #html.elem("button", attrs: (
          type: "button",
          class: "ui-control search-tool",
          id: "search-clear",
          disabled: "",
          "aria-label": messages.clear,
          title: messages.clear,
        ))[#icon("x")]
      ]
    ]
    #html.elem(
      "p",
      attrs: (
        id: "search-status",
        class: "muted",
        role: "status",
        "aria-live": "polite",
        "aria-atomic": "true",
        "data-state": "empty",
      ),
      messages.empty,
    )
    #html.div(id: "search-results-region")[
      #html.ol(id: "search-results")
    ]
    #html.div(class: "search-footer")[
      #html.span(class: "search-key-hint")[#html.kbd()[↑] #html.kbd()[↓] #messages.navigate]
      #html.span(class: "search-key-hint")[#html.kbd()[↵] #messages.select]
      #html.elem("button", attrs: (
        type: "button",
        class: "search-close",
        "data-close-search": "",
        "aria-label": messages.close,
      ))[#html.kbd()[Esc] #messages.close]
    ]
  ]
}
