// Post lists and bylines.

/// Calendar date or timestamp as a `<time>` element.
#let time(value) = {
  let date = if type(value) == datetime { value.display("[year]-[month]-[day]") } else { value.rfc3339 }
  html.elem("time", attrs: (datetime: date), date.slice(0, 10))
}

/// Publication/update dates and author names.
#let post-byline(meta, messages) = html.div(class: "post-meta")[
  #messages.published #time(meta.published)
  #if meta.updated != none [
    · #messages.updated #time(meta.updated)
  ]
  #if meta.authors != none and meta.authors.len() > 0 {
    html.p(meta.authors.map(author => author.name).join(", "))
  }
]

/// Ordered post list, or `empty` when there are no posts.
#let post-list(posts, empty) = {
  if posts.len() == 0 { return html.p(class: "empty-state", empty) }
  html.ol(class: "post-list")[
    #for post in posts {
      html.li[
        #html.p(class: "post-meta")[
          #time(post.meta.published)
        ]
        #html.h2(link(post.label, post.meta.title))
        #html.p(post.meta.description)
      ]
    }
  ]
}
