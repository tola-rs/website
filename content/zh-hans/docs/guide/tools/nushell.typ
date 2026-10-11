#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "编写 Nushell 脚本",
  description: "用内置的 Nushell 操作结构化数据，并生成可发布的文件。",
  order: 30,
))

#title()

= 运行脚本

Tola 内置 Nushell。`tola nu` 可运行站点里的 `.nu` 文件。参数由脚本的 `def main` 声明。在站点根目录创建 `tools/`，再把下面的代码存为 `tools/greet.nu`。

```nu
def main [name: string, --upper] {
  let message = $"你好，($name)"
  if $upper { $message | str upcase } else { $message }
}
```

```sh
tola nu tools/greet.nu Ada --upper
tola nu tools/greet.nu --help
```

第一条命令输出 `你好，ADA`，第二条列出 `name` 和 `--upper`。Nu 的管道也能传递记录和列表，例如用 `open data.json | get title` 读取 JSON 数据里的字段。需要传给另一个进程或写文件时，再用 `to json` 转成文本。

= 生成发布文件

假设站点已经建好。将下面的脚本保存为 `tools/site-json.nu`。

```nu
use tola [get-hook get-site]

def main [] {
  let destination = ((get-hook).output-dir | path join "site.json")
  {title: (get-site).title} | to json | save --raw $destination
}
```

在 `tola.toml` 声明输出，并在 `[site]` 中设置 `title`。

```toml
[[hooks.generate-outputs]]
name = "site-json"
nu = "tools/site-json.nu"
outputs = [{ file = "site.json" }]
```

从站点根目录运行 `tola build`。如果 `[site]` 的 `title` 是 `"笔记"`，`public/site.json` 就会包含 `{"title":"笔记"}`。这里用构建提供的输出目录，直接执行脚本时没有钩子上下文。需要复用数据处理函数时，可以将计算部分放在单独的 `.nu` 文件，用 `export def` 导出、用 `use` 导入。

= 缩放图片和查看诊断

把 `photo.png` 放在站点根目录，从这里运行：

```sh
tola nu @tola-scripts/image metadata photo.png
tola nu @tola-scripts/image resize photo.png --width 640 --op fit-width --format webp --output preview.webp
tola check --json > check.json
tola nu --stdin @tola-scripts/diagnostic render < check.json
```

第一条输出图片宽高等 JSON 数据。第二条把宽 640 像素的 WebP 写到 `preview.webp`，该文件必须尚未存在。第三条保存检查报告，第四条读取报告里的诊断。`--stdin` 是 Tola 的选项，写在脚本名前。脚本的参数写在名称后。

查看 `tola nu --help` 可找到内置库。命令和参数见 `tola help scripts`。