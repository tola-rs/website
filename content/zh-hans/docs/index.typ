// 文档入口。

#import "@tola/source:0.0.0": tola-meta
#import "@tola/address:0.0.0": output-url
#import "@tola-modules/docs:0.0.0": current-page, sections

#tola-meta((
  title: "文档",
  description: "从创建第一个 Tola 站点到组织内容、编写模块与部署上线。",
  order: 0,
))

#title()

Tola 用 Typst 编写整座站点——正文、模板、路由和构建输出都由同一个程序控制。初次接触可以从 #link("/docs/getting-started/overview/")[概览]与 #link("/docs/getting-started/first-site/")[创建第一个站点] 开始；需要查具体字段或函数签名时，可以直接翻阅 #link("/docs/reference/overview/")[参考]。

#let _reference-roots = (
  "/docs/reference/overview/",
  "/docs/reference/config/",
  "/docs/reference/packages/",
  "/docs/reference/scripts/",
)

#context {
  let page = current-page()
  for group in sections(page.locale.tag, omit: page.key) [
    #let targets = if group.pages.any(item => item.key.starts-with("/docs/reference/")) {
      group.pages.filter(item => item.key in _reference-roots)
    } else {
      group.pages
    }
    = #group.title

    #for target in targets [
      - #link(output-url(target.output))[#target.meta.title]：#target.meta.description
    ]
  ]
}
