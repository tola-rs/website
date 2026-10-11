#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "概览",
  description: "看一份 site.typ 怎样生成首页和关于页。",
  order: 0,
))

#title()

Tola 是基于 #link("https://typst.app/")[Typst] 的静态站点生成器。

= 首页与关于页

运行 `tola init my-site`，用下面的代码替换 `site.typ` 中的页面循环，保留原来的 `404.html`。

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

运行 `tola build` 后，关于页写到 `public/about/index.html`。预览时可通过 `/about/` 打开它。要把正文拆到 `content/` 下，可以用 `include` 读入文件。#link("/docs/concepts/build-model/")[站点如何构建]演示了怎样遍历这个目录。

= HTML 导出

Typst 把 `= 首页` 导出为标题元素，把 `link` 导出为 `<a>`。`page` 函数用 `<main>` 包裹正文。

关于页的公式会导出为 MathML。

$ integral_0^infinity e^(-x^2) dif x = sqrt(pi)/2 $

= 检查链接

把首页的 `/about/` 改成 `/about-us/`，再运行 `tola check`，就会看到断链提示。要改页面地址，也要改相应的 `document` 输出路径。

= Typst 版本

Typst 的 HTML 和 Bundle 导出目前仍是实验功能。运行 `tola --version` 可以查看 Tola 内置的 Typst 版本。

#link("/docs/getting-started/installation/")[安装 Tola] · #link("/docs/getting-started/first-site/")[创建第一个站点]
