#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Typst 语法与 HTML",
  description: "掌握编写页面和模板所需的 Typst 语法、标题层级、样式规则、context 与 HTML/MathML 导出。",
  order: 10,
))

#title()

Typst 既不是 Markdown，也不是 LaTeX：正文直接书写，用 `=` 写章节标题，用 `$` 写数学公式，用 `#` 进入代码模式。编写网页时，用原生 Typst 内容表达文字、标题、公式和链接，用 `html.*` 函数和 CSS 负责网页结构与布局。

= 基本语法

Typst 文件默认处于正文模式（markup mode）：

```typst
#title[研究笔记]

*结论*写在前面，_待讨论_的内容留到下次。

行内公式是 $x^2 + y^2$。在公式两侧各留一个空格，就能独占一行：

$ sum_(i=1)^n i = frac(n(n + 1), 2) $

= 相关资料

- #link("https://typst.app/")[Typst]
- #link("https://tola.build/")[Tola]
```

常用标记速览：

- 空行分段，`*文字*` 加粗，`_文字_` 强调，反引号标记行内代码或代码块。
- `-` 开启无序列表，`+` 开启有序列表。
- `#` 从正文进入代码模式，表达式结束后自动回到正文；需要计算表达式时可写 `#(1 + 2)`。

更多语法细节见 #link("https://typst.app/docs/reference/syntax/")[Typst 官方语法参考]。

== 页面标题与章节层级

在默认导出规则下，`#title[...]` 对应 HTML 的 `<h1>`，`=` 对应 `<h2>`，`==` 对应 `<h3>`，依此类推。因此，页面主标题使用 `#title()`，正文第一节从 `=` 开始，不要跳级使用标题来调整字号——外观尺寸应由 CSS 控制。

= 内容值、函数与数据

== 字符串与 `content`

`"文字"` 是纯字符串（`str`），常用于路径、URL 和属性；`[文字]` 是内容值（`content`），可以包含加粗、公式、链接等排版元素，在代码模式中用 `[...]` 重新切回正文。传给组件的正文通常使用方括号，而写成字符串的 HTML 只会被当作普通文本转义输出。

```typst
#let name = "Tola"
#let note(body, kind: "note") = html.aside(class: kind, body)

#note(kind: "tip")[用 *#name* 写第一篇笔记。]
```

`kind: "note"` 是带默认值的命名参数，末尾的 `[...]` 作为位置参数传给 `body`，最终导出为 `<aside class="tip">`。

== 数组与字典

`(a, b)` 是数组（单项数组须带尾逗号 `(a,)`），`(title: "首页", draft: false)` 是字典。入口程序常把页面列表存成字典数组：

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

花括号 `{...}` 内为代码块，`let` 绑定不会产生输出，其余表达式的值会自动拼接。上面通过 `..` 把数组展开为 `list` 的参数，用 `for` 循环也能起到同样的合并效果。

#callout[
  多行的 `.filter(...)`、`.map(...)` 方法链必须放在 `{...}` 代码块或 `(...)` 括号里；直接在正文中换行写 `.map(...)`，新行会被当成普通文字。详见 #link("https://typst.app/docs/reference/scripting/")[Typst 官方脚本参考]。
]

= `import` 与 `include`

- `import`：导入另一个文件导出的变量与函数定义。
- `include`：把另一个文件的正文内容直接插入当前位置。

两个文件各自拥有独立的作用域，被导入文件不会继承调用方的局部变量，需要的数据请通过函数参数传入。路径规则：相对路径从当前文件算起；以 `/` 开头的路径在站点项目中从项目根目录算起，在模块包中则从包根目录算起。

```typst
#import "/components/note.typ": note
#note[这段正文传给组件。]

#include "/components/intro.typ"
```

= 样式规则与 `context`

== `set` 与 `show`

`set` 为后续元素设置默认参数（如 `#set heading(numbering: "1.")`），`show` 用于拦截并改写指定元素。不带选择器的 `#show: fn` 会把后续整篇正文传给 `fn`，常用于套用文章或页面模板：

```typst
#let article(body) = html.article(class: "note", body)
#show: article
#set heading(numbering: "1.")

= 研究笔记
== 结论
```

如果需要针对单个标题定制外观，可写 `#show heading: it => ...`（`it.body` 为标题正文），同时尽量保留原生 `heading` 结构，以便目录和引用查询正常工作。见 #link("https://typst.app/docs/reference/styling/")[Typst 官方样式参考]。

== `context` 与标题锚点

同一份 `content` 值可能被放进不同的输出文档，`context` 将查询延迟到内容真正落入文档时再求值：

```typst
#import "@tola/document:0.0.0": current-document

#context {
  let page = current-document()
  [这份文档输出到 #raw(page.output)。]
}

= 研究笔记 <research-notes>

#link(<research-notes>)[跳到标题]
```

给原生标题加 `<research-notes>` 标签后，即可用 `#link(<research-notes>)[...]` 跳转（标签须在整个 Bundle 内唯一）。注意：只有被链接到的原生标题才会导出锚点 ID；如果需要一个固定不变的外部锚点，且不依赖站内链接触发，可以写 `#html.h2(id: "research-notes")[研究笔记]`（但手写 HTML 标题不会进入 `headings()` 查询结果）。详情见 #link("https://typst.app/docs/reference/context/")[Typst 官方上下文参考]。

= HTML 导出与自定义外壳

Typst 会将原生段落、标题、列表与链接转为 HTML，也提供 `html.aside`、`html.main` 等带类型检查的标签函数；需要自定义 `data-*` 等非标准属性时，使用 `html.elem`：

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
        #title[研究笔记]
        #html.elem("aside", attrs: ("data-kind": "tip"))[
          平方和可以写成 $x^2 + y^2$。
        ]
      ]
    ]
  ]
]
```

当文档自行构造 `#html.html` 外壳时，须保留 `#html.head`（Typst 导出器会向其中注入公式样式）并自行提供标题、viewport 与样式表；页面布局与响应式样式建议抽成独立 CSS 文件，通过 #link("/docs/concepts/assets/")[静态资源] 引入。此外，自定义外壳不会自动放置脚注，若文档使用脚注或参考文献，需在模板中显式检查或提供对应的 `show` 规则。

相关参考：#link("https://typst.app/docs/reference/html/")[HTML 导出] · #link("https://typst.app/docs/reference/html/typed/")[Typed HTML] · #link("https://typst.app/docs/reference/bundle/")[Bundle 导出]。

= 公式与 MathML

Typst 默认将数学公式导出为标准 `<math>`（MathML）：

```typst
行内公式 $x^2 + y^2$。

$ sum_(i=1)^n i = frac(n(n + 1), 2) $
```

行内公式 $x^2 + y^2$，以及独占一行的块级公式：

$ sum_(i=1)^n i = frac(n(n + 1), 2) $

MathML 使用浏览器端字体渲染（与 Typst 编译字体无关），在窄屏下的换行和明暗主题对比度应在浏览器中实测确认。如果个别复杂公式必须由 Typst 编译器按特定字体渲染为矢量图，可通过 `html.frame` 转为 SVG（注意 SVG 会失去 MathML 的可选中文本与无障碍数学语义）：

```typst
#show math.equation: eq => if eq.at("block", default: false) {
  block(html.frame(eq))
} else {
  box(html.frame(eq))
}
```
