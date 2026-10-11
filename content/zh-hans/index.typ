#import "@tola/source:0.0.0": tola-meta
#import "/components/content/lib.typ": home-features, home-hero, home-typst, logo-url
#import "/site/info.typ": license, repository, version

#let title = "你的整个站点就是一个 Typst 程序"

#tola-meta((
  title: title,
  description: "基于 Typst Bundles 的可编程静态站点生成器。一个 Typst 程序选择所有页面、订阅与资源。",
))

#home-hero(
  [你的整个站点 \ #html.span(class: "home-title-accent")[就是一个 Typst 程序]],
  "基于 Typst 的静态站点生成器",
  (href: "/docs/getting-started/overview/", label: "开始构建"),
  (href: repository, label: "在 GitHub 查看"),
  [v#version.tola · Typst #version.typst · #link(license.url)[#license.name 许可]],
  logo-url(),
)

#home-typst("Typst 的表达能力", (
  (
    icon: "file-pen-line",
    title: "正文与模板",
    body: [正文、模板和组件共用一种语言。用函数、数据和样式规则复用内容。],
  ),
  (
    icon: "square-function",
    title: "数学与图表",
    body: [在正文里直接写公式，通过 Typst 绘图包制作图表与交换图。],
  ),
  (
    icon: "split",
    title: "一份内容，多种输出",
    body: [同一份内容可以用于多个页面。用根程序决定页面的组合与输出位置。],
  ),
  (
    icon: "blocks",
    title: "Typst 包生态",
    body: [复用已有的函数与包，按需组合绘图、数据处理和内容组件。],
  ),
))


#home-features(
  "面向静态站点的扩展",
  (
    (
      icon: "monitor-play",
      title: "预览与热重载",
      body: [改动即时可见：自动重建，优先局部更新，不打断编辑体验],
      link: "本地预览",
    ),
    (
      icon: "square-code",
      title: "编辑器支持",
      body: [补全、悬浮文档、跳转定义，即时诊断，源代码高亮，站点预览。],
      link: "配置编辑器",
    ),
    (
      icon: "notebook-tabs",
      title: "内容与导航",
      body: [编写模板，组件，路由层级，前后篇导航，目录，反向链接。],
      link: "组织站点",
    ),
    (
      icon: "images",
      title: "图片与图标",
      body: [构建时缩放、裁剪，转换图片，响应式尺寸；美观的图标集],
      link: "处理图片与图标",
    ),
    (
      icon: "plug",
      title: "钩子系统",
      body: [多阶段钩子系统，将外部工具接入构建链，扩展站点能力],
      link: "构建钩子",
    ),
    (
      icon: "list-checks",
      title: "断链与冲突",
      body: [检查站内链接、资源和页面锚点，检测缺失目标与输出路径冲突。],
      link: "检查与构建",
    ),
    (
      icon: "rss",
      title: "分享与订阅",
      body: [配置页面的社交分享信息，自定义生成 RSS、Atom 和站点地图。],
      link: "订阅与站点信息",
    ),
    (
      icon: "file-check",
      title: "元数据检验",
      body: [解析文章声明的元数据，避免字段缺失，类型错误，繁琐转换],
      link: "元数据校验",
    ),
  ),
  (),
)
