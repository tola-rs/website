#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout, code-group

#tola-meta((
  title: "创建本地模块",
  description: "从零编写可复用的 Typst 组件库，并将其升级为带样式和可配置选项的本地主题。",
  order: 50,
))

#title()

沿用 #link("/docs/getting-started/first-site/")[第一个站点]，下面分两步把可复用的组件和页面布局拆进本地 `theme/` 目录。

= 第一步：编写 Typst 组件模块

在站点下新建 `theme/` 目录，放入模块清单和组件定义：

#code-group((
  (label: "theme/tola-module.toml", body: [```toml
[typst]
entry = "lib.typ"
```]),
  (label: "theme/lib.typ", body: [```typst
#let note(body) = html.aside(class: "note", body)
```]),
), label: "最小模块")

在站点的 `tola.toml` 中以 `notes` 作为别名注册该模块：

```toml
[modules.notes]
path = "theme"
```

在 `content/index.typ` 末尾导入并调用：

```typst
#import "@tola-modules/notes:0.0.0": note

#note[安装前请先检查版本。]
```

运行 `tola module check ./theme` 验证模块清单与文件声明，再运行 `tola build`。打开 `public/index.html` 可以看到渲染出的 `<aside class="note">`。

= 第二步：升级为完整主题

要把页面布局、默认选项和样式表也交给模块统一管理，补全以下文件。

1. 在 `theme/assets/note.css` 写入样式：

```css
.reading { max-width: 42rem; margin: 2rem auto; padding: 0 1rem; }
.note { padding: 0.75rem 1rem; border-inline-start: 0.25rem solid currentColor; }
```

2. 创建主题入口 `theme/site.typ`，通过 `get-module()` 读取实例配置与模块资源 URL：

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

#callout[
  不要在模块代码里写死示例别名 `"notes"`。模块内部统一使用 `get-module()` 获取当前实例，这样消费方无论把别名改成 `docs` 还是 `blog` 都能正常生效；导入站点文章正文则始终使用 `source.file`。
]

3. 在 `theme/tola-module.toml` 末尾补充构建入口、默认选项与模块资源声明：

```toml
[build]
entry = "site.typ"

[options]
title = "笔记"

[assets]
files = [{ source = "assets/note.css", url = "/note.css" }]
```

4. 最后更新站点的 `tola.toml`：把 `[build]` 的 `entry` 改为 `{ module = "notes" }`，并按需覆盖选项：

```toml
[build]
entry = { module = "notes" }

[modules.notes.options]
title = "我的站点"
```

运行 `tola build`。所有内容页都会应用新布局，浏览器标题显示为「我的站点」，样式表会输出到 `public/_tola-modules/notes/note.css`。如果调整了站点的 `base-path`，`theme.assets.urls` 也会自动带上新的前缀。

= 进一步定制与分发

当模块需要对外分享或供其他项目长期复用时，通常还会做两件事：

- 在 `lib.typ` 导出可选的 `render-site(...)` 函数并让 `site.typ` 直接调用它，让使用方可以通过项目 `site.typ` 覆写局部布局，而不用修改主题源码。
- 为模块补全具名查询、CLI 子命令、站点初始化器与打包配置，具体步骤见 #link("/docs/guide/module-publishing/")[模块查询、命令与打包发布]。

关于模块来源、选项合并与加载边界，见 #link("/docs/concepts/modules-and-themes/")[模块与主题]。
