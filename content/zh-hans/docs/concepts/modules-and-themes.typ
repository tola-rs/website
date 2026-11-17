#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "模块与主题",
  description: "了解模块清单、来源声明、选项合并以及如何在不拆改主题源码的前提下定制站点。",
  order: 70,
))

#title()

模块是包含 `tola-module.toml` 的目录。一个模块可以只提供一套可复用的 Typst 组件或 Nu 工具库，也可以同时声明 `[build] entry` 作为完整主题，接管站点的页面筛选、路由生成与页面渲染。

= 模块能力声明

`tola-module.toml` 按需声明模块提供的能力：

#table(
  columns: (auto, 1fr),
  table.header([清单字段], [作用]),
  [`[typst] entry`], [导出公开的 Typst 函数与组件，站点通过 `@tola-modules/<别名>:0.0.0` 导入。],
  [`[build] entry`], [提供可作为主题使用的站点入口程序。],
  [`[nu] entry`], [导出公开的 Nu 定义，供脚本通过 `use tola-modules <别名>` 导入。],
  [`[queries]`], [注册具名 Typst 查询，支持 `tola query <别名>.<查询名>` 及编辑器补全跳转。],
  [`[commands]`], [注册模块子命令（例如本站 `docs` 模块提供的 `tola docs guide`）。],
  [`[init]`], [注册站点初始化器，支持 `tola init <目录> --from <来源>`。],
  [`[pack]`], [声明打包发布模块时要包含与排除的文件，配合 `tola module pack` 使用。],
)

= 注册与来源

在站点的 `tola.toml` 中用 `[modules.<别名>]` 注册模块，模块别名由使用方站点决定。每个模块从 `path`、`git`、`tarball` 中三选一作为来源：

```toml
[build]
entry = { module = "blog" }

[modules.blog]
path = "theme"

[modules.blog.options]
show-title = true
```

- *本地路径（`path`）*：相对于 `tola.toml` 的目录路径。
- *Git 仓库（`git`）*：可指定 `url`、`subdir` 以及 `tag` / `branch` / 完整 `rev`（三者选一，省略则取默认分支）。
- *压缩包（`tarball`）*：支持 `tar.gz`、`tar.zst`、`zip`（本地 `path` 或远程 `url`，可选 `sha256` 校验），包内须有一层包含 `tola-module.toml` 的外层目录。

远程仓库与压缩包的具体版本摘要会锁定在 `tola.lock` 中；后续需要拉取更新时运行 `tola update <别名>`。只使用组件库而保留站点自有 `site.typ` 时，只需配置 `[modules.<别名>]`，不必改动 `[build] entry`。

= 选项合并与定制主题

主题默认值写在模块清单的 `[options]` 中，站点通过 `[modules.<别名>.options]` 覆盖。字典表会递归合并，而数组和标量值会整体替换。模块内部用 `get-module()` 读取当前实例的选项与资产，站点代码或外部模板则用 `get-module("<别名>")` 读取指定实例。

想在不修改主题源码的前提下定制站点时，一般依次采用以下方式：

1. *调整选项*：先查看主题文档公开的 `[modules.<别名>.options]` 与可选样式配置。
2. *替换静态资源*：通过 `[modules.<别名>.assets.replace]` 用站点本地文件替换主题内已声明的特定资源（保留原模块 URL）。
3. *包装入口函数*：如果主题导出了可定制的渲染函数（如 `render-site`），把 `tola.toml` 的 `[build] entry` 改回站点根目录的 `"site.typ"`，在里面导入主题渲染函数并传入自定义的布局回调。

模块内部在读取包文件、静态资产和站点项目文件时各自有不同的根目录约定，可参见 #link("/docs/concepts/routes-and-urls/")[路由与 URL]。动手编写自己的第一个模块与主题，请前往 #link("/docs/guide/local-module/")[创建本地模块]。

完整清单字段见 #link("/docs/reference/config/modules/")[`[modules]` 配置参考]。
