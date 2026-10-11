// 文档入口。

#import "@tola/source:0.0.0": tola-meta
#import "@tola/address:0.0.0": output-url
#import "@tola-modules/docs:0.0.0": current-page
#import "@tola-modules/docs:0.0.0": sections

#tola-meta((
  title: "文档",
  description: "从创建第一个 Tola 站点到组织内容和部署。",
  order: 0,
))

#title()

#context {
  let page = current-page()
  for group in sections(page.locale.tag, omit: page.key) [
    = #group.title

    #for target in group.pages [
      - #link(output-url(target.output))[#target.meta.title]：#target.meta.description
    ]
  ]
}
