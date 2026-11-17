#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "命令行用法",
  description: "掌握 dev、check、preview、build 以及配置检查、格式化和编辑器配置命令。",
  order: 30,
))

#title()

站点命令会从当前目录向上查找最近的 `tola.toml`。需要在其他目录操作站点时，用 `-C` 指定配置文件路径：

```sh
tola inspect -C path/to/tola.toml config
```

= 日常开发工作流

#table(
  columns: (auto, 1fr),
  table.header([命令], [作用]),
  [`tola dev`], [启动本地服务器，监听修改并自动重建与局部更新。],
  [`tola check`], [构建并检查输出路径与站内引用，不改写发布目录。],
  [`tola preview`], [按生产设置构建一次，并在内存中启动本地预览服务器。],
  [`tola build`], [校验通过后将完整站点写入发布目录（默认 `public/`）。],
)

== 初始化与版本

```sh
tola --version
tola init my-site --dry-run
tola init my-site
```

- `--version`：显示 Tola 以及内置 Typst、Nushell 的版本。
- `init`：默认接受不存在或为空的目录，生成 `tola.toml`、`site.typ`、`.gitignore`、`.ignore` 和空的 `content/`。加 `--dry-run` 可预览将生成的文件；加 `--force` 允许在非空目录中初始化而不覆盖已有文件。若主题提供了初始化器，可用 `tola init my-site --from <来源>`。

== 本地开发 <local-dev>

```sh
tola dev
tola dev --port 0
```

`--port 0` 由系统分配空闲端口。浏览器请打开终端实际打印的地址（尤其在端口被占用或配置了 `base-path` 时），按 `Ctrl+C` 停止服务。

如果修改后页面仍显示旧内容，先查看终端的诊断输出：当重建失败时，开发服务器会继续保留上一次成功的页面。若外部脚本需要读取构建事件，运行 `tola dev --json`，每行输出一条 JSON 事件（包含 `server-ready`、`build-finished` 等）。

== 检查与预览 <check-and-preview>

```sh
tola check
tola preview --base-path /notes/
```

`tola check` 执行构建前钩子、编译站点并验证输出与引用，但不会替换发布目录。附加选项：

- `--no-build`：只检查站点自有的 Typst 源文件语法，不执行完整编译，因此无法验证导入、求值、路由和链接。
- `--no-hooks`：跳过 `before-build` 与 `generate-outputs` 钩子，直接使用磁盘上已有的生成输入。

`tola preview` 使用生产设置（如资源压缩、`base-path`）构建一次并在内存中提供服务，适合在部署前验证路径前缀、压缩后的脚本样式和 404 页面。可以用 `--base-path` 临时测试不同的部署路径。修改文件后需重新运行命令。

== 构建发布目录

```sh
tola build
tola build -o public-review
```

默认输出到 `public/`。使用 `-o` 可指定项目内另一个输出目录，目标目录须为空或已有同站点的 Tola 发布记录。

= 配置检查与排错

当页面未出现或构建报错时，可以按下面顺序定位：

```sh
tola doctor
tola inspect config
tola inspect sources
tola inspect fonts
tola inspect icons
tola check --json --pretty
```

- `doctor`：检查站点配置、路径及外部工具环境。
- `inspect config`：查看合并后的生效配置（包括解析后的入口、输入目录和发布路径）。
- `inspect sources`：列出 Tola 扫描到的源文件。若列表缺少预期文件，检查 `content-dir` 配置、小写 `.typ` 扩展名、隐藏目录或符号链接。
- `check --json --pretty`：输出结构化检查报告，核对 `pages`、`routes` 与引用错误；加 `-v` 可输出更多细节。
- `inspect fonts` / `inspect icons`：分别列出 Typst 编译器可见的字体以及当前配置的图标集合（后接集合名可查看具体图标）。网页端使用的字体需在浏览器网络面板和 CSS 中核对。

如需保存完整构建报告，可运行 `tola build --json --pretty > build-report.json`。如果配置了发布后钩子，即使钩子失败报错，已经写出的发布目录仍会保留，可检查报告中的 `published` 字段确认状态。

= 格式化与编辑器 <editor-setup>

```sh
tola fmt --check
tola editor setup --list
tola editor template vscode
```

- `tola fmt --check` 只检查格式差异；去掉 `--check` 才会改写站点 Typst 源文件。格式化规则在 `tola.toml` 的 `[formatter]` 中配置，CLI 与语言服务共用同一套设置。
- `tola editor setup <编辑器>` 可将工作区配置合并到支持的编辑器（如 `vscode`、`helix`）；`editor template` 用于打印配置模板。升级 Tola 后运行 `tola editor packages` 刷新编辑器使用的内置包声明。其他支持 LSP 的编辑器可直接接入 `tola lsp`。
- 传入 `--nu`（如 `tola editor setup helix --nu` 或 macOS/Linux 下的 `tola editor setup vscode --nu`）可同时配置内置 Nushell 的语言服务；手动配置时启动命令为 `tola nu --lsp`。

= 更多工具命令

- `tola nu --help`：列出内置 Nu 库与内置脚本；`tola nu tools/report.nu --help` 查看站内脚本参数。
- `tola query`：执行站点或模块的 Typst 数据查询（用法见 #link("/docs/guide/site-data/")[站点数据与内容查询]）。
- `tola update` / `tola vendor`：刷新 `tola.lock` 与打包离线构建依赖（用法见 #link("/docs/guide/deploy/")[检查、离线构建与部署]）。
- `tola module check` / `tola module pack`：校验或打包模块发布目录。
- `tola <模块别名> --help`：查看当前站点中由模块注册的子命令（例如本站的 `tola docs guide`）。
- `tola completions --help` / `tola manpage --help`：生成 shell 自动补全脚本与 man 手册。

完整命令参数可随时用 `tola <command> --help` 查看，配置与内置包文档见 #link("/docs/reference/overview/")[参考总览]。接下来可以阅读 #link("/docs/concepts/build-model/")[站点如何构建]，深入理解构建模型。
