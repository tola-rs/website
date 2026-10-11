#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "总览",
  description: "查阅 Tola 的配置、内置包和内置脚本，以及按任务阅读或导出写作指南。",
  order: 0,
))

#title()

= 在线参考

在线参考根据 Tola 随附的离线内置文档自动生成，可浏览 #link("/docs/reference/config/")[配置]、#link("/docs/reference/packages/")[内置包]和 #link("/docs/reference/scripts/")[内置脚本]。

= 离线文档

终端帮助随本机的 Tola 版本提供。用它查询命令参数、配置字段、函数签名和脚本选项。

#table(
  columns: (auto, 1fr),
  table.header([查什么], [命令]),
  [命令参数], [`tola build --help`],
  [配置目录], [`tola help config`],
  [内置包目录], [`tola help package`],
  [内置脚本目录], [`tola help scripts`],
  [构建配置], [`tola help --lang zh "[build]"`],
  [指定函数], [`tola help --lang zh "@tola/address" output-of output-url`],
  [脚本参数], [`tola help "@tola-scripts/image" resize`],
)

`tola help -i` 可交互浏览，右方向键展开，`/` 搜索标题和正文，Enter 打开。加 `--lang zh` 使用简体中文。需要复制整页时，可加 `--no-pager` 或 `--format markdown`。

用 `tola help --format json --pretty "@tola/image"` 导出结构化参考，其中包含签名、参数、示例和相关条目。

= Agent Skill

`tola skill` 提供从写正文到编写主题的操作指南。可以在终端按任务查阅，也可以把有关章节交给协助修改站点的工具。

== 终端用法

```sh
tola skill --list
tola skill writing math --all
tola skill site assets files
tola skill modules theme customization
```

`--list` 列出可选主题。主题名按层级依次写在命令后，例如 `writing math`。加 `--all` 会包含所选主题的子章节。遇到特定场景时直接读对应章节，例如 `tola skill writing math rendering svg`。

== 导出指南

```sh
tola skill --output tola-authoring.md
tola skill modules --all --output module-authoring.md
```

第一条导出整份指南，第二条只导出模块相关章节。文件以 Markdown 保存。命令会创建缺失的父目录，已有的目标文件会保留，另选文件名即可重新导出。导出无需站点配置。
