#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "命令行用法",
  description: "init、dev、check、build 等命令的用法。",
  order: 20,
))

#title()

= 项目与配置

```sh
tola --version
tola init my-site --dry-run
tola init my-site
cd my-site
tola inspect config
```

`--version` 显示 Tola、内置 Typst 和 Nushell 的版本。`init` 默认接受不存在或为空的目录，生成 `tola.toml`、`site.typ` 和空的 `content/`。`--dry-run` 预览将创建的文件。`--force` 允许使用非空目录，保留已有文件。主题提供初始化器时，可以用 `tola init my-site --from <来源>`。

站点命令从当前目录向上找最近的 `tola.toml`。要从另一个路径操作站点，可以用 `-C` 指向配置文件。解析后的入口、输入目录和发布路径可在 `inspect config` 的结果中找到。

```sh
tola inspect -C path/to/tola.toml config
```

= 开发与构建

== 本地开发

```sh
tola dev
tola dev --port 0
```

两条命令任选一条。`dev` 启动本地服务器，保存文件后会重建并尝试更新浏览器。`--port 0` 让系统选空闲端口。打开命令实际打印的地址，特别是端口已被占用或站点配置了部署前缀时。按 Ctrl+C 结束。

如果修改后页面仍显示旧内容，先看终端是否有失败诊断。重建失败时，开发服务器可以继续提供上一次成功的页面。程序要读取重建状态时可用 `tola dev --json`，每行输出一个事件，`server-ready` 给出地址，`build-finished` 给出本次结果。

== 检查与预览

```sh
tola check
tola preview
```

`check` 构建并验证输出及站内引用，保留已有发布目录。只想解析 Typst 源文件的语法时，可以用 `tola check --no-build`。语法检查通过以后，仍要完整检查才能确认导入、求值、路由和链接。

`preview` 使用生产设置构建一次，在内存中提供结果。适合验证部署前缀、压缩后的脚本与样式，以及缺失页面的行为。改动文件后重新启动预览。`check` 和 `preview` 都会运行构建前与输出生成钩子。已有生成输入时，可用 `tola check --no-hooks` 跳过这两个阶段。

== 构建输出

```sh
tola build
```

`tola build` 默认写到 `public/`。用 `tola build -o public-review` 可以另存一份构建结果。目标目录需在项目内，且为空或已有同站点的 Tola 发布记录。要试另一个部署前缀，运行 `tola preview --base-path /notes/`。

= 故障排查

== 页面打不开

```sh
tola inspect sources
tola check --json --pretty
```

先用 `inspect sources` 查源文件。找不到时，检查内容目录、扩展名、隐藏目录和符号链接。能找到时，查报告的 `pages` 和 `routes`，核对生成的页面、输出路径和站内路由。若源文件没有对应的输出，检查入口或主题的筛选条件。若路由正确，再核对浏览器地址里的部署前缀。

== 字体、图标与入口

```sh
tola doctor
tola inspect config
tola inspect fonts
tola inspect icons
```

`doctor` 展示配置、路径和本地工具方面的问题。`inspect fonts` 列的是 Typst 编译器能看到的字体。网页字体要到浏览器里检查网络请求和 CSS。`inspect icons` 列出当前配置的图标集合，追加集合名可看其中的图标。

构建失败时，先读诊断里的源位置和建议。需要更多细节时，用 `tola check -v`。要将机器可读的构建报告保存下来，可以运行 `tola build --json --pretty > build-report.json`。有发布后钩子时，也要看 `published`：钩子失败会让命令报错，已经写出的站点仍在。

= 格式化与编辑器

```sh
tola fmt --check
tola editor setup --list
tola editor template vscode
```

`fmt --check` 只报告格式问题。运行 `tola fmt` 才会改写站点 Typst 源。`editor template` 打印配置示例。支持自动配置的编辑器可以用 `tola editor setup vscode` 等命令合并工作区配置。升级 Tola 后，用 `tola editor packages` 刷新编辑器使用的包文件。其他支持 LSP 的编辑器也可以调用 `tola lsp`。

`tola editor setup helix --nu` 会配置内置 Nushell 的语言服务。在 macOS 和 Linux 上，`tola editor setup vscode --nu` 会为 VS Code 的 Nushell 扩展生成启动脚本。手动配置时，用 `tola nu --lsp` 启动服务。

= 依赖与离线构建

`tola.lock` 记录选中的依赖输入。更新某个远程主题时，先用 `tola update <模块别名> --dry-run` 查看变化，再运行 `tola update <模块别名>`。无名称时会刷新所有远程输入。

`--dry-run` 会列出检查过的模块和图标集合，以及将修改的锁定记录。

#table(
  columns: (auto, 1fr),
  table.header([构建选项], [用途]),
  [`--locked`], [要求当前输入与锁文件匹配，并保持锁文件原样。可以下载锁中已有记录的输入。],
  [`--offline`], [Tola 从本地可用的输入加载，缺少时直接报错。],
  [`--pure`], [使用项目与 vendor 中的锁定输入，排除主机缓存、包和系统字体。],
)

需要把依赖文件也带到另一台机器时，在 `tola.toml` 中设置 vendor 目录。

```toml
[vendor]
path = "vendor"
```

```sh
tola vendor --dry-run
tola vendor
tola build --pure
```

`vendor` 保存本次选择的包、模块和远程图标。字体应通过项目或模块中配置的路径提供。钩子启动的外部工具按各自的环境工作。

= 脚本、模块与查询

- `tola nu tools/report.nu --help` 查看 Nushell 脚本的参数。`tola nu --help` 列出可用的库与内置脚本。
- `tola module check ./theme` 检查模块清单与声明的文件。`tola module pack` 用于准备模块发布目录。
- `tola <模块别名> --help` 查看该站点里由模块添加的命令。例如官网项目的 `tola docs guide` 会打开主题的写作说明。
- `tola completions --help` 和 `tola manpage --help` 用于生成 shell 补全和手册页。

== 查询站点数据

沿用 #link("/docs/getting-started/first-site/")[第一个站点]，在根目录新建 `tools/model.typ`。下面用 `metadata` 把源文件路径交给 `tola query`。

```typst
#import "@tola/source:0.0.0": all-sources
#metadata(all-sources().map(source => source.path)) <model>
```

```sh
tola query ./tools/model.typ --label model --json --pretty
```

示例返回 `guide/install.typ` 和 `index.typ`。查询不会运行构建钩子，也不会写入发布目录。主题若已声明查询，可以用 `tola query <别名>.<查询名>`。

任意命令的完整参数见 `tola <command> --help`。配置和 API 的查法见 #link("/zh-hans/docs/reference/overview/#li-xian-wen-dang")[离线文档]。下一步可以 #link("/docs/getting-started/first-site/")[创建第一个站点]。
