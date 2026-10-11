#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": code-group

#tola-meta((
  title: "创建本地模块",
  description: "把常用组件移到模块中，通过别名供站点使用。",
  order: 20,
))

#title()

= 写一个 Typst 组件

沿用 #link("/docs/getting-started/first-site/")[第一个站点]，创建 `theme/`，按标签上的路径保存模块清单和组件。

#code-group((
  (label: "theme/tola-module.toml", body: [```toml
[typst]
entry = "lib.typ"
```]),
  (label: "theme/lib.typ", body: [```typst
#let note(body) = html.aside(class: "note", body)
```]),
), label: "模块文件")

= 在站点中导入组件

在项目的 `tola.toml` 里添加：

```toml
[modules.notes]
path = "theme"
```

在 `content/index.typ` 末尾加入：

```typst
#import "@tola-modules/notes:0.0.0": note
#note[安装前请先检查版本。]
```

从站点根目录运行 `tola module check ./theme` 检查模块清单，再运行 `tola build`。打开 `public/index.html`，能看到提示文字。页面源码里会有 `<aside class="note">`。

= 让模块提供布局

目前站点仍由项目的 `site.typ` 构建。要把布局也交给模块，保存下面的代码为 `theme/site.typ`。

```typst
#import "@tola/address:0.0.0": join-route, output-of
#import "@tola/module:0.0.0": get-module
#import "@tola/source:0.0.0": all-sources

#let theme = get-module()

#for source in all-sources() {
  document(output-of(join-route(source.route-segments)), format: "html")[
    #html.html[
      #html.head[
        #html.meta(charset: "utf-8")
        #html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
        #html.title(theme.options.title)
        #html.link(rel: "stylesheet", href: theme.assets.urls.at("note.css"))
      ]
      #html.body[
        #html.main(class: "reading")[#include source.file]
      ]
    ]
  ]
}

#document("404.html", format: "html")[找不到页面。]
```

模块中的 `source.file` 仍指向站点的源文件。这个原生路径可以直接交给 `include`。样式表则通过模块的 `assets.urls` 提供给浏览器。

在 `theme/tola-module.toml` 末尾追加：

```toml
[build]
entry = "site.typ"

[options]
title = "笔记"

[assets]
files = [{ source = "assets/note.css", url = "/note.css" }]
```

将样式存为 `theme/assets/note.css`：

```css
.reading { max-width: 42rem; margin: 2rem auto; padding: 0 1rem; }
.note { padding: 0.75rem 1rem; border-inline-start: 0.25rem solid currentColor; }
```

将项目 `tola.toml` 中已有的 `[build]` 入口改成 `entry = { module = "notes" }`。在文件末尾追加选项覆盖：

```toml
[modules.notes.options]
title = "我的站点"
```

运行 `tola build`。首页和安装指南都应套用新布局，浏览器标签页使用「我的站点」。样式表发布到 `public/_tola-modules/notes/note.css`。改动站点的 `base-path` 后，生成的样式链接也会带上新的部署前缀。

更多模块入口、来源与定制方式见 #link("/docs/concepts/modules-and-themes/")[模块与主题]。
