#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Typst 语法",
  description: "正文、内容值、样式规则和 HTML 导出示例。",
  order: 0,
))

#title()

沿用 #link("/docs/getting-started/first-site/")[第一个站点]。把下面的正文片段分别放进 `content/index.typ`，运行 `tola dev`，打开终端打印的地址看结果。HTML 示例使用单独的 `site.typ`。

= 基本语法

一个 Typst 文件默认从正文模式开始。以下几行会生成标题、强调文字、公式、子标题和列表。

```typst
= 研究笔记

*结论*写在前面，_待讨论_的内容留到下次。

行内公式是 $x^2 + y^2$。在公式两侧各留一个空格，就能独占一行。

$ sum_(i=1)^n i = frac(n(n + 1), 2) $

== 相关资料

- #link("https://typst.app/")[Typst]
- #link("https://tola.build/")[Tola]
```

空行分段，`=` 和 `==` 分别开启一级、二级标题，`-` 开启无序列表，`+` 开启有序列表。用 `*文字*` 加粗、`_文字_` 加强调、反引号标记代码。数学模式有自己的语法，例如 `_` 和 `^` 分别引入下标和上标，`frac` 生成分数。

`#` 从正文进入代码，表达式完结后回到正文。计算 `1 + 2` 时写 `#(1 + 2)`，把整个表达式括起来。在代码中，方括号 `[...]` 又进入正文。因此代码块里的 `[你好，#name]` 可以在正文中插入变量。#link("https://typst.app/docs/reference/syntax/")[官方语法参考]

= 内容与数据

== 内容函数

`"文字"` 是字符串，常用于文件名、URL 和属性值。`[文字]` 是 `content` 值，可以包含公式、链接或其他元素。传给组件的正文通常用方括号。

```typst
#let name = "Tola"
#let note(body, kind: "note") = html.aside(class: kind, body)

#note(kind: "tip")[用 *#name* 写第一篇笔记。]
```

`kind: "note"` 定义了有默认值的命名参数。调用末尾的方括号是传给 `body` 的位置参数。这次调用会得到 `<aside class="tip">`，里面的强调仍是一个独立的正文元素。

== 数组与字典

`(a, b)` 是数组，单项数组要写成 `(a,)`。`(title: "首页", draft: false)` 是字典，`title` 和 `draft` 是键。入口程序常用数组存页面，用字典存每页的属性。

```typst
#let notes = (
  (title: "第一篇", draft: false),
  (title: "还在写", draft: true),
)

#{
  let published = notes.filter(note => not note.draft)
  list(..published.map(note => [#note.title]))
}
```

代码块 `{...}` 内直接写表达式。块会依次合并表达式产生的值，`let` 绑定本身没有输出。这里 `filter` 选出公开条目，`map` 把每项变成正文，`..` 把数组展开成 `list` 的各个参数。同样的筛选可以写成 `for` 循环，循环也会合并每轮返回的内容。

给多行的 `.filter(...)`、`.map(...)` 链加代码块或括号。直接在正文中换行续写，下一行可能被当成文字。#link("https://typst.app/docs/reference/scripting/")[官方脚本参考]

= import 与 include

用 `import` 从组件文件引入定义，用 `include` 插入另一个文件的正文。

在站点根目录创建 `components/`，把上面的 `#let note(...)` 定义存入 `components/note.typ`，在 `components/intro.typ` 写一行「本站维护 Typst 笔记。」。把下面的代码放进 `content/index.typ`。

```typst
#import "/components/note.typ": note
#note[这段正文传给组件。]

#include "/components/intro.typ"
```

首页会先显示组件生成的提示，再显示 `intro.typ` 的正文。组件文件有自己的作用域，调用者可通过函数参数传标题和数据。相对路径从写下调用的文件算起。以 `/` 开头时，项目文件从项目根算，包里的代码从包根算。

= 规则与上下文

== set 与 show

`set` 为元素补默认参数，例如给之后的原生标题编号。`show` 可以选中一种元素，再用函数处理它。省略选择器的 `#show: 函数` 会把后续正文整体传给函数，适合套用页面模板。

```typst
#let article(body) = html.article(class: "note", body)
#show: article
#set heading(numbering: "1.")

= 研究笔记

== 结论

这两个标题仍是 Typst 原生标题。
```

可以用 `#show heading: it => ...` 逐个处理标题，函数会收到标题元素，`it.body` 是标题正文。需要目录和引用的地方，优先保留原生标题的结构。网页间距、断点、分栏等样式用 CSS 控制。#link("https://typst.app/docs/reference/styling/")[官方样式规则参考]

== context 查询

同一个 `content` 值可以放进不同的 HTML 文档。`context` 将查询推迟到内容放入文档时求值。下面的 `current-document()` 每次读取当前文档的信息，`output` 是该文档的输出路径。

```typst
#import "@tola/document:0.0.0": current-document

#context {
  let page = current-document()
  [这份文档输出到 #raw(page.output)。]
}

= 研究笔记 <research-notes>

#link(<research-notes>)[跳到标题]
```

尖括号给标题添加标签，原生 `link` 可以用它定位；同一个 Bundle 中应使用唯一标签。手写 HTML ID 适合固定的网页片段。需要生成目录时，用 `headings()` 读取当前文档的原生标题。#link("https://typst.app/docs/reference/context/")[官方上下文参考]

= HTML 导出

Typst 能把原生标题、段落、列表和链接导出为 HTML，也能通过 `html.*` 函数创建网页元素。`html.aside` 等构造函数会检查参数类型。想加 `data-*` 属性时，可以用 `html.elem("aside", attrs: ("data-kind": "tip"))[正文]`。如果把 HTML 写在引号里面，导出结果会把它作为普通文本显示。

== 页面示例

把下面存为临时站点的 `site.typ`。`document` 指定输出格式为 HTML。页面用了自定义 `html.html`，因此标题、viewport 和样式都在自己的 `head` 里写明。

```typst
#document("index.html", format: "html", title: "研究笔记")[
  #html.html(lang: "zh-Hans")[
    #html.head[
      #html.meta(charset: "utf-8")
      #html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
      #html.title[研究笔记]
      #html.style("main { max-width: 42rem; margin: 2rem auto; padding: 1rem; }")
    ]
    #html.body[
      #html.main[
        = 研究笔记
        #html.elem("aside", attrs: ("data-kind": "tip"))[
          平方和可以写成 $x^2 + y^2$。
        ]
      ]
    ]
  ]
]

#document("404.html", format: "html")[找不到页面。]
```

运行 `tola build`，检查 `public/index.html`。可以找到 `<main>`、带 `data-kind` 的 `<aside>` 和原生公式输出的 `<math>`。如果采用默认页面外壳，`document` 的标题会由导出器填入 `head`。正式主题可以把上面的内联样式移到 #link("/docs/concepts/assets/")[静态资源]，用样式表统一维护。

#link("https://typst.app/docs/reference/html/")[HTML 导出] · #link("https://typst.app/docs/reference/html/typed/")[Typed HTML] · #link("https://typst.app/docs/reference/bundle/")[Bundle 导出]

= MathML

Typst 将公式导出为 `<math>`。下面两条分别嵌在段落中和单独成行。

```typst
行内公式 $x^2 + y^2$。

$ sum_(i=1)^n i = frac(n(n + 1), 2) $
```

行内公式 $x^2 + y^2$。

$ sum_(i=1)^n i = frac(n(n + 1), 2) $

查看网页源码，行内公式的上标用 `<msup>` 表示。第二条公式的 `<math>` 带有 `display="block"`，分数对应 `<mfrac>`。浏览器根据这些元素排版。#link("https://typst.app/blog/2026/typst-0.15#mathml")[Typst 0.15 的 MathML 说明]
