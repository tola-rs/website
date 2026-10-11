#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "模块与主题",
  description: "使用可复用的站点入口、Typst 组件、资产与命令。",
  order: 70,
))

#title()

= 模块清单

模块目录由 `tola-module.toml` 描述。模块可以只提供一套 Typst 组件，也可以提供 Nu 脚本、静态资源、查询或命令。提供 `[build] entry` 的模块可以作为主题接管站点入口，决定页面选择、路由与渲染。

#table(
  columns: (auto, 1fr),
  table.header([模块清单中的声明], [用处]),
  [`[typst] entry`], [导出 Typst 定义，通过 `@tola-modules/别名:0.0.0` 导入。],
  [`[build] entry`], [供站点选择的入口程序。],
  [`[nu] entry`], [供 Nu 脚本复用的公开定义。],
  [`[commands]`], [命令行入口，例如 `tola blog check`。],
)

= 启用主题

假设本地有 `theme/`，其中的 `tola-module.toml` 声明了 Typst 和构建入口。在站点根目录的 `tola.toml` 中注册 `blog`，并将它设为入口。若已有 `[build]` 表，只替换其中的 `entry`。

```toml
[build]
entry = { module = "blog" }

[modules.blog]
path = "theme"

[modules.blog.options]
show-title = true
```

从站点根目录运行 `tola inspect config`，确认入口指向 `blog`，再运行 `tola build`。页面和输出路径由主题入口决定。

如果主题提供 `note`，可以在正文中这样调用。

```typst
#import "@tola-modules/blog:0.0.0": note
#note[本周更新]
```

只需要组件时，添加 `[modules.blog]` 即可，站点可以继续用自己的 `site.typ`。

主题来源也可以是 Git 或压缩包。使用 Git 时，可选择 `tag`、`branch` 或 `rev`，并用 `subdir` 指定仓库中的模块目录。使用压缩包时可记录 `sha256`。保留 `tola.lock` 可以让其他机器选择相同输入。

= 定制与排错

主题默认值来自清单的 `[options]`，站点在 `[modules.blog.options]` 中覆盖。表逐层合并，数组和标量整体替换。主题里用 `get-module()` 读取当前实例的选项和资产；项目可以用 `get-module("blog")` 读取指定实例。

修改主题前，先查主题公开的选项和组件。主题导出了渲染函数时，也可以在自己的 `site.typ` 中调用它，按函数接受的参数传入组件。用 `tola blog --help` 查看模块命令。

模块内部读取资源与项目文件时有不同的根目录，见 #link("/docs/concepts/routes-and-urls/")[站点路径]。想写一个能用于多个站点的组件，可以从 #link("/docs/guide/local-module/")[创建本地模块] 开始。
