#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "概览",
  description: "了解 Tola 如何用一个 Typst 入口程序生成整座静态站点。",
  order: 0,
))

#title()

Tola 是基于 #link("https://typst.app/")[Typst] 的静态站点生成器。与「Markdown 正文 + 独立模板引擎」的传统方式不同，Tola 把整个站点组织成一个 Typst 程序：布局组件、页面筛选、导航结构与正文内容都用同一种语言编写。

= 站点入口长什么样

在 Tola 里，站点入口（默认是根目录的 `site.typ`）负责声明要生成哪些输出文件。下面这段代码直接定义了一个首页和一个关于页：

```typst
#let page(body) = html.main(body)

#document("index.html", format: "html", title: "首页")[
  #page[
    = 首页

    #link("/about/")[关于本站]
  ]
]

#document("about/index.html", format: "html", title: "关于本站")[
  #page[
    = 关于本站

    $ integral_0^infinity e^(-x^2) dif x = sqrt(pi)/2 $
  ]
]
```

构建后，`index.html` 与 `about/index.html` 会写入输出目录（默认 `public/`），分别对应 `/` 和 `/about/` 两个路由。实际站点通常把正文拆进 `content/` 目录，再由入口程序遍历并 `include` 进来，具体做法见 #link("/docs/concepts/build-model/")[站点如何构建]。

= 原生 HTML 与公式导出

Typst 直接把文档元素导出为语义化 HTML：

- `= 首页` 导出为标题元素，`#link(...)` 导出为 `<a>`，`#html.main(...)` 生成 `<main>` 容器。
- 行间或行内数学公式直接导出为浏览器原生的 MathML，不需要额外引入前端脚本：

$ integral_0^infinity e^(-x^2) dif x = sqrt(pi)/2 $

= 内置链接与输出检查

Tola 在写入发布目录之前，会整站检查输出路径与内部引用。如果把上面首页里的 `/about/` 改成一个不存在的路径 `/about-us/`，运行 `tola check` 就会立即报错；多个页面指向同一输出路径时也会触发冲突诊断。

= 关于 Typst 版本

Typst 的 HTML 与 Bundle 导出目前仍处于实验阶段。每个 Tola 发行版都内置了固定版本的 Typst，运行 `tola --version` 可以查看当前版本。

准备好后，前往 #link("/docs/getting-started/installation/")[安装] 获取 Tola，再通过 #link("/docs/getting-started/first-site/")[创建第一个站点] 动手跑通完整流程。
