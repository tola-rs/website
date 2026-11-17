#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "编写 Nushell 脚本",
  description: "用内置 Nushell 运行带类型参数的站内脚本、在构建钩子中输出文件，以及调用内置图片与诊断工具。",
  order: 40,
))

#title()

Tola 内置了 Nushell 运行环境（无需本机额外安装 Nushell），且不会加载个人环境配置，确保脚本在不同机器上行为一致。

= 运行站内脚本

把需要参数解析的脚本存为 `tools/greet.nu`，`def main` 的类型签名会自动生成参数校验与 `--help` 文本：

```nu
# 按名称生成问候语
def main [name: string, --upper] {
  let message = $"你好，($name)"
  if $upper { $message | str upcase } else { $message }
}
```

```sh
tola nu tools/greet.nu Ada --upper
tola nu tools/greet.nu --help
```

使用时的几个习惯：

- *不要在脚本末尾手动调用 `main`*：Nu 会在顶层代码之后自动执行 `main`；保持顶层无副作用，这样用户查看 `--help` 时不会意外写文件。
- *保持结构化数据传递*：用 `open` 解析 JSON/TOML（纯文本读写用 `open --raw`），通过管道过滤或重组记录，需要写盘或传给外部进程时再用 `to json | save --raw ...`。
- *传递标准输入*：需要管道传参给脚本时，`--stdin` 等 Tola 选项写在脚本路径之前（如 `printf '%s' '{"name":"Tola"}' | tola nu --stdin upper.nu`）。
- *复用公共函数*：可把纯函数放在独立文件中用 `export def` 导出，再通过 `use` 导入；进度提示输出到 `print --stderr`，不要混入结构化返回值。

= 在构建钩子中写入站点文件

将脚本保存为 `tools/site-json.nu`。`get-context` 返回本次调用的上下文，`hook.outputDir` 是 `generate-outputs` 阶段为该钩子分配的输出目录。站点标题来自 `get-site`。

```nu
use tola [get-context get-site]

def main [] {
  let destination = (get-context | get hook.outputDir | path join "site.json")
  {title: (get-site).title} | to json | save --raw $destination
}
```

在 `tola.toml` 的 `[site]` 下设置 `title`，并注册 `generate-outputs` 钩子：

```toml
[[hooks.generate-outputs]]
name = "site-json"
nu = "tools/site-json.nu"
outputs = [{ file = "site.json" }]
```

运行 `tola build` 后，`public/site.json` 会包含站点标题。这个脚本需要在 `generate-outputs` 钩子中运行，因为只有该阶段会提供 `hook.outputDir`。各阶段提供的字段见 #link("/docs/reference/scripts/context/")[`@tola-scripts/context`]。

= 调用内置图片与诊断脚本

Tola 还自带 `@tola-scripts/*` 工具脚本，适合在命令行或构建流水线中直接调用：

```sh
tola nu @tola-scripts/image metadata photo.png
tola nu @tola-scripts/image resize photo.png --width 640 --op fit-width --format webp --output preview.webp
tola check --json > check.json
tola nu --stdin @tola-scripts/diagnostic render < check.json
```

- `@tola-scripts/image`：无需安装外部图像处理软件即可读取图片信息或缩放转码（`--output` 目标文件不能已存在，单边尺寸会保持比例）。
- `@tola-scripts/diagnostic`：把结构化诊断 JSON 渲染成终端高亮视图。如果在 Nu 钩子或模块命令中直接上报警告或错误，可用 `use tola diagnostic` 配合 `diagnostic submit` 提交到构建报告。

查看当前环境可用的内置库运行 `tola nu --help`，完整脚本参数见 #link("/docs/reference/scripts/")[内置脚本参考] 或 `tola help scripts`。
