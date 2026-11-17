#import "@tola/source:0.0.0": tola-meta
#import "@tola/module:0.0.0": get-module
#import "@tola/site:0.0.0": site
#import "@tola-modules/docs:0.0.0": home-capabilities, home-features, home-hero, logo-url

#let (repository, versions) = get-module("docs").options
#let license = site.options.license
#let title = "你的整个站点就是一个 Typst 程序"

#tola-meta((
  title: title,
  layout: "landing",
  description: "基于 Typst Bundles 的可编程静态站点生成器。用一个 Typst 程序组织页面、订阅与资源。",
))

#home-hero(
  [你的整个站点 \ #html.span(class: "home-title-accent")[就是一个 Typst 程序]],
  "基于 Typst 的静态站点生成器",
  (href: "/docs/getting-started/overview/", label: "开始使用"),
  (href: repository, label: "在 GitHub 查看"),
  [v#versions.tola · Typst #versions.typst · #link(license.url)[#license.name 许可]],
  logo-url(),
)

#home-capabilities("Typst 的表达能力", (
  (
    icon: "file-pen-line",
    title: "正文与模板",
    body: [正文、模板和组件共用一种语言，通过函数、数据和样式规则复用结构。],
  ),
  (
    icon: "square-function",
    title: "数学与图表",
    body: [在正文里直接写公式，用 Typst 绘图包制作图表与交换图。],
  ),
  (
    icon: "split",
    title: "一份内容，多种输出",
    body: [同一份源文件可以编排进多个页面，由根程序决定组合方式与输出路径。],
  ),
  (
    icon: "blocks",
    title: "Typst 包生态",
    body: [直接复用社区包与内置函数，按需组合绘图、数据处理和内容组件。],
  ),
))


#home-features(
  "面向静态站点的扩展",
  (
    (
      icon: "monitor-play",
      title: "预览与热重载",
      body: [修改保存后自动重建，优先局部刷新浏览器，不打断写作节奏。],
      link: "本地预览",
      href: "/docs/getting-started/first-site/",
    ),
    (
      icon: "square-code",
      title: "编辑器支持",
      body: [提供补全、悬停文档、跳转定义、实时诊断、语法高亮与站点预览。],
      link: "配置编辑器",
      href: "/docs/getting-started/cli-usage/",
    ),
    (
      icon: "notebook-tabs",
      title: "内容与导航",
      body: [编写模板与组件，生成路由层级、上下篇导航、页面目录与反向链接。],
      link: "组织站点",
      href: "/docs/guide/metadata-and-navigation/",
    ),
    (
      icon: "images",
      title: "图片与图标",
      body: [构建时缩放、裁剪和转换图片并生成响应式尺寸，内置可定制的图标集。],
      link: "处理图片与图标",
      href: "/docs/guide/page-presentation/",
    ),
    (
      icon: "plug",
      title: "钩子系统",
      body: [通过多阶段构建钩子接入外部工具，在编译前后或发布后扩展站点流程。],
      link: "构建钩子",
      href: "/docs/concepts/hooks/",
    ),
    (
      icon: "list-checks",
      title: "断链与冲突检查",
      body: [校验站内链接、静态资源和页面锚点，提前拦截缺失目标与路径冲突。],
      link: "检查与构建",
      href: "/docs/getting-started/cli-usage/",
    ),
    (
      icon: "rss",
      title: "分享与订阅",
      body: [生成社交分享元标签，以及符合标准的 RSS、Atom 订阅和站点地图。],
      link: "订阅与站点信息",
      href: "/docs/guide/publication/",
    ),
    (
      icon: "file-check",
      title: "元数据校验",
      body: [用 schema 解析并校验页面声明的元数据，尽早发现缺失字段与类型错误。],
      link: "元数据校验",
      href: "/docs/concepts/metadata/",
    ),
  ),
  (),
)
