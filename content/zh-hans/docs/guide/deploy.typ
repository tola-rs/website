#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "检查、离线构建与部署",
  description: "上线前校验页面与链接、锁定并离线构建依赖，最后预览并部署发布目录。",
  order: 70,
))

#title()

= 部署前检查

发布之前，先用以下命令确认所有页面都已按预期纳入输出、且没有断链或资源缺失：

```sh
tola inspect sources
tola check --json --pretty
```

- 如果某篇源文件没有出现在页面列表里，先看 `tola inspect sources` 是否扫描到它（核对 `content-dir`、小写 `.typ` 扩展名、隐藏目录或符号链接）；若源文件存在但未输出，再检查入口或主题的筛选条件（例如 `draft: true`）。
- `tola check` 会运行构建前钩子与输出生成钩子并校验全部路由和站内链接，同时保留现有发布目录不被改动。

= 验证正式域名与路径前缀

若站点部署在子路径（例如 `https://example.com/notes/`），在 `tola.toml` 中设置 `origin` 和 `base-path`（部署在域名根目录时 `base-path = "/"`）：

```toml
[site]
origin = "https://example.com"
base-path = "/notes/"
```

确认模板与正文中的内部链接均使用 #link("/docs/concepts/routes-and-urls/")[`output-url`、`route-url` 或 `asset-url`] 生成（而不是写死没有前缀的绝对路径），然后启动生产预览：

```sh
tola preview
```

打开终端打印的预览地址，逐项点开导航链接、图片、样式和 404 页面，确认资源都能正常加载。如果只是临时试跑另一个前缀，也可以直接运行 `tola preview --base-path /notes/`。

= 依赖锁定与离线纯构建

站点引用的远程模块与图标集合会记录在 `tola.lock` 中，提交该锁文件可让协作者与 CI 拿到完全一致的输入。需要更新远程模块时，先预览变更再刷新锁记录：

```sh
tola update <模块别名> --dry-run
tola update <模块别名>
```

构建时可通过以下选项限制输入来源：

#table(
  columns: (auto, 1fr),
  table.header([构建选项], [适用场景]),
  [`--locked`], [要求输入与 `tola.lock` 严格一致且不改写锁文件；仍可下载锁中已记录的远程输入。],
  [`--offline`], [禁止网络访问，仅使用本地和缓存中已有的输入；缺少时直接报错。],
  [`--pure`], [只使用项目文件与 `vendor` 中的锁定输入，排除主机缓存、全局包与系统字体。],
)

要在离线环境或 CI 中做完全自包含的 `--pure` 构建，可在 `tola.toml` 配置 `[vendor]` 并打包依赖：

```toml
[vendor]
path = "vendor"
```

```sh
tola vendor --dry-run
tola vendor
tola build --pure
```

#callout[
  `vendor` 会复制选中的 Typst 包、远程模块和图标集合，但不包含编译器字体；纯构建环境须把字体放到项目配置路径或模块字体目录中。钩子调起的外部工具仍按各自环境运行。
]

= 构建与上传

按 `Ctrl+C` 退出预览后执行生产构建：

```sh
tola build
```

将 `public/`（或 `[build].publish-dir` 指定的目录）内的全部内容上传到托管服务或 Web 服务器，并按以下规则配置站点托管：

- 将目录路径（如 `/notes/guide/install/`）映射到对应的 `index.html`。
- 将未匹配到的路径指向站点根目录的 `404.html`。
- 如果使用 `[[hooks.after-publish]]` 自动上传，注意构建本身已成功写出发布目录；若上传钩子失败，命令行会报错提示，磁盘上的成片不会回滚。
