#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "构建钩子",
  description: "在构建前后或发布后运行 Nushell 脚本与外部工具，扩展站点构建流程。",
  order: 60,
))

#title()

当需要编译前端样式、准备外部数据、生成搜索索引或自动部署时，可以通过 `tola.toml` 或 `tola-module.toml` 中的 `[[hooks.<阶段>]]` 把任务接入构建流程。每个钩子在一次运行完成后即退出，文件监听由 Tola 统一调度。

= 三个运行时阶段

#table(
  columns: (auto, 1fr),
  table.header([阶段], [适用情况]),
  [`before-build`], [在 Typst 编译前准备输入文件，如生成 JSON 数据、编译 CSS 或脚本资源。],
  [`generate-outputs`], [读取本次已编译的页面，生成随站点一同发布的文件（如搜索索引、`build.txt`）。],
  [`after-publish`], [在站点写入发布目录后读取产物并执行上传、同步或通知等后续操作。],
)

不同命令触发的阶段和默认开发行为如下：

- `tola build` 按顺序运行全部三个阶段。
- `tola check` 与 `tola preview` 只运行前两个阶段，不触发 `after-publish`。
- `tola dev` 默认运行 `before-build` 与 `generate-outputs`，默认跳过 `after-publish`（可设 `dev = "run"` 启用；`generate-outputs` 还支持 `dev = "reuse"`，在输入未变时复用上次产物与诊断）。
- 同一阶段内可通过 `order`（默认 `0`）控制顺序，值越小越先执行；`order` 相同的钩子默认并行执行（可通过 `[build] par-hooks = false` 改为串行）。

= 启用与条件开关

钩子默认启用，可用 `enable = false` 显式关闭，或通过 `enabled-by` 绑定到布尔配置项（站点钩子读取 `[options]`，模块钩子读取该模块实例的 options）：

```toml
enabled-by = "search.enable"
# 若键名本身包含点号，可用引号包裹路径段：
# enabled-by = '"search.enable"'
```

路径必须指向一个布尔值；缺少对应键或父级不是表会直接报错（`enable = false` 会跳过查找）。

= `before-build`：准备构建输入

在项目下编写 `tools/menu.nu`，在站点根目录生成数据文件：

```nu
def main [] {
  mkdir generated
  {title: "我的站点"} | to json | save --force generated/menu.json
}
```

在 `tola.toml` 中声明钩子与产出路径：

```toml
[[hooks.before-build]]
name = "menu-data"
nu = "tools/menu.nu"
rerun-on = { include = ["data/**/*.json"] }
generates = ["generated/menu.json"]
```

- `generates` 列出相对于站点根目录的产出路径（不要写进 `publish-dir`），钩子退出时这些文件必须已存在。
- `rerun-on` 声明除入口脚本之外影响结果的输入文件（模块钩子还支持 `{ project = "content/**/*.typ" }` 监听站点输入）。
- 生成的文件既可在 Typst 中用 `json("/generated/menu.json")` 读取，也可以在需要时配置到 `[assets]` 中一并发布。仅生成输入本身不会自动发布它。

= `generate-outputs`：写出发布产物

在内置 Nushell 脚本里，用 `get-context` 读取本次调用的上下文。这个阶段可从 `hook.inputDir` 读取已编译的页面和资源，并把新产物写入 `hook.outputDir`。每次调用开始时，输出目录都是空的。

将以下脚本保存为 `tools/build-info.nu`：

```nu
use tola get-context

def main [] {
  let output = (get-context | get hook.outputDir)
  "Built with Tola" | save ($output | path join "build.txt")
}
```

在 `tola.toml` 中注册钩子：

```toml
[[hooks.generate-outputs]]
name = "build-info"
nu = "tools/build-info.nu"
outputs = [{ file = "build.txt" }]
```

- `outputs` 用 `{ file = "..." }` 或 `{ tree = "..." }` 声明相对于发布根目录的输出，生成器只能写入自身声明的路径，且不能覆盖站点页面或其他钩子的产物。
- 在 Typst 中引用这类输出时，使用 `output-url("build.txt")`（它不需要也不应写进 `[assets]`）。
- 跨次构建复用的数据可放在 `hook.cacheDir`。只在本次调用使用的临时文件可放在 `hook.tempDir`。

= 调用外部工具与 `after-publish`

除内置的 `nu` 脚本外，每个钩子也可以用 `argv = ["tool", "arg1", ...]` 调用外部可执行文件（不经过 shell 展开通配符或环境变量；目标机器须在 `PATH` 中安装对应工具）。外部工具可通过以下命令读取本次钩子的 JSON 上下文：

```sh
"$TOLA_EXECUTABLE" nu @tola-scripts/context --json
```

外部工具解析 JSON 后可按同样的字段名取值。在 `after-publish` 阶段，`hook.inputDir` 指向已写出的发布目录。如果该阶段执行失败，命令会返回错误码，已写出的文件会保留。内置 Nu 脚本可通过 `use tola diagnostic` 和 `diagnostic submit` 提交诊断。外部工具可把 JSON 诊断报告写到上下文中的 `reportPath`。

详细字段见 #link("/docs/reference/config/hooks/")[`[hooks]` 配置参考] 与 #link("/docs/reference/scripts/context/")[`@tola-scripts/context` 参考]。
