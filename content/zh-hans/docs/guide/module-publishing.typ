#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "模块查询、命令与打包发布",
  description: "为模块注册 Typst 查询与编辑器跳转、暴露 CLI 命令与初始化器，并打包发布供其他站点使用。",
  order: 60,
))

#title()

除了提供组件与布局，模块还可以把查询、命令行工具和站点脚手架打包在一起交付给使用者。以下能力均在 `tola-module.toml` 中按需声明。

= 注册查询与编辑器跳转

模块可以通过 `[queries.<名称>]` 导出一个带 `<label>` 的 Typst 文件，供外部读取站点结构化数据：

```toml
[queries.pages]
entry = "queries/pages.typ"
label = "page-list"
```

在 `queries/pages.typ` 中复用主题自身的页面列表函数，保证查询结果与实际构建一致：

```typst
#import "../lib.typ": pages
#import "@tola/address:0.0.0": output-url

#metadata(pages().map(page => (
  title: page.source.meta.title,
  output: page.output,
  url: output-url(page.output),
))) <page-list>
```

在消费方站点运行 `tola query notes.pages --json` 即可取得 JSON 数据（查询不会运行构建钩子）。

如果需要让编辑器为模块公开函数的特定参数提供自动补全、悬停文档、跳转定义与重命名支持，可以为该查询声明 `references` 与 `definitions`（此时每条查询记录须包含 `id`、`name`，以及可选的 `description`、`source`、`url` 字段）：

```toml
[[queries.index.references]]
export = "page-link"
parameter = { positional = 0 }

[[queries.index.definitions]]
export = "page"
parameter = { named = "id" }
```

= 注册模块命令与编写指南

在 `[commands.<名称>]` 下可以注册模块专属的子命令，运行形式为 `tola <模块别名> <命令名>`：

```toml
[commands.greet]
nu = "tools/greet.nu"

[commands.pages]
query = "pages"
projection = ["title", "url"]

[commands.guide]
skill = "GUIDE.md"
```

- `nu`：执行模块内的 Nushell 脚本。导入 `use tola get-context` 后，用 `get-context | get module.name` 读取当前模块别名，用 `get-context | get module.options` 读取站点覆盖后的模块选项。用 `use tola diagnostic` 和 `diagnostic submit` 提交诊断。
- `argv`：运行外部命令，用 `"$TOLA_EXECUTABLE" nu @tola-scripts/context --json` 读取调用上下文。
- `query`：直接暴露已声明的具名查询，无需额外包装脚本，可用 `projection` 筛选展示列。
- `skill`：绑定一份模块写作说明文档，消费方运行 `tola <别名> guide` 即可在终端分节阅读。

= 提供站点初始化器

声明 `[init]` 后，用户可以用 `tola init my-site --from <模块来源> --alias <别名>` 一键生成配套站点：

```toml
[init]
nu = "tools/init.nu"
```

初始化脚本导入 `use tola get-context` 后，可从上下文读取以下字段：

- `init.outputDir` 是临时输出目录。生成的文件都写到这里，Tola 校验通过后会写入目标目录。
- `init.targetDir` 是最终站点目录。生成配置中的相对路径以它为基准。
- `module.name` 和 `module.root` 分别是这次初始化选用的模块别名和根目录。Tola 会在新站点配置中保留模块的原始来源。

其他字段及外部脚本的用法见 #link("/docs/reference/scripts/context/")[`@tola-scripts/context`]。

= 打包与分发

如果模块包含需要预先编译的文件（例如编译好的前端 CSS 或 JS），用 `[pack]` 指定要放进发布目录的运行时文件，并通过 `[[hooks.before-pack]]` 在打包前自动生成它们：

```toml
[pack]
include = ["lib.typ", "site.typ", "assets", "queries", "tools"]
exclude = ["assets/**/*.map"]

[[hooks.before-pack]]
name = "compile-assets"
nu = "author/assets.nu"
```

打包并验证发布产物：

```sh
mkdir -p dist
tola module pack ./theme --output ./dist/theme
tola module check ./dist/theme
```

`tola module pack` 会先运行 `before-pack`（脚本内通过 `get-context | get hook.inputDir` 读取模块源码目录），再将 `[pack]` 选中的文件复制到目标目录，并在交付的 `tola-module.toml` 中剔除 `pack` 与 `hooks.before-pack`——消费方直接使用预处理好的产物，无需安装作者的构建工具。

#callout[
  如果通过压缩包（`.tar.gz` / `.tar.zst` / `.zip`）发布模块，打包时需保留一层包含 `tola-module.toml` 的外层目录（例如 `tar -czf dist/theme-v1.0.0.tar.gz -C dist theme`）。GitHub 自动生成的源码归档不会运行 `before-pack`，若主题依赖预处理资源，请上传打包后的压缩包到 Release，或把打包产物提交到 Git 子目录配合 `git.subdir` 使用。
]

发布前建议新建一个测试站点引用 `./dist/theme`，更换模块别名、覆盖选项并设置非根 `base-path`，跑通 `tola check`、`tola build` 与浏览器预览后再正式发布。更多细节见 `tola skill modules --all`。
