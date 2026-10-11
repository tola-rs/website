#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "构建钩子",
  description: "在构建的不同阶段准备输入、生成输出或处理完成的发布目录。",
  order: 60,
))

#title()

= 钩子阶段

#table(
  columns: (auto, 1fr),
  table.header([阶段], [适用情况]),
  [`before-build`], [先生成 Typst 或资产声明要读取的文件，例如 JSON 数据和编译后的 CSS。],
  [`generate-outputs`], [读取已经编译的页面，生成应随站点发布的文件，例如搜索索引。],
  [`after-publish`], [读取已发布的目录并做后续处理，例如同步到服务器。],
)

`build` 运行三个阶段。`check` 和 `preview` 运行前两个。`dev` 默认也运行前两个，每次钩子结束即退出，由 Tola 负责监听。钩子读取额外输入时，使用 `rerun-on` 声明，例如数据文件或导入的脚本。

= 启用条件

`enabled-by = "images.enable"` 读取布尔选项 `images.enable`。项目钩子从站点选项取值，模块钩子从模块实例选项取值。若键名本身含点号，用 `enabled-by = '"images.enable"'`。找不到键或值不是布尔值时会报错。设为 `enable = false` 会跳过查找。模块的资源声明也支持同样的语法。

= 生成构建输入

在站点根目录下创建 `tools/`，把下面的代码保存为 `tools/menu.nu`。

```nu
def main [] {
  mkdir generated
  {title: "我的站点"} | to json | save --force generated/menu.json
}
```

在 `tola.toml` 添加：

```toml
[[hooks.before-build]]
name = "menu-data"
nu = "tools/menu.nu"
generates = ["generated/menu.json"]
```

钩子从站点根目录运行。`generates` 列出的文件必须在脚本退出时存在。在默认入口使用的 `content/index.typ` 里加入以下代码。

```typst
#let menu = json("/generated/menu.json")
#menu.title
```

从站点根目录运行 `tola build`，打开 `public/index.html`，页面会显示「我的站点」。浏览器也需要原始 JSON 文件时，可以用 `[assets]` 发布它。要单独生成 JSON，可运行 `tola nu tools/menu.nu`。

= 生成发布文件

`generate-outputs` 的输入目录包含本次已生成的站点，输出目录每次运行前都是空的。用 `outputs` 声明一个文件 `{ file = "search.json" }`，或一棵目录 `{ tree = "search" }`。路径从发布目录根算起。生成器只能在自己的输出目录提交文件，不能覆盖页面或其他生成器的产物。

把下面的脚本保存为站点的 `tools/build-info.nu`。脚本用 `get-hook` 读取本次构建的输出目录。

```nu
use tola get-hook

def main [] {
  let output = (get-hook | get output-dir)
  "Built with Tola" | save ($output | path join build.txt)
}
```

在 `tola.toml` 加入这条声明。

```toml
[[hooks.generate-outputs]]
name = "build-info"
nu = "tools/build-info.nu"
outputs = [{ file = "build.txt" }]
```

从站点根目录运行 `tola build`。默认输出目录下会出现 `public/build.txt`，内容是 `Built with Tola`。如果脚本还要读取已编译的页面，用 `(get-hook).input-dir` 取得它们所在的目录。

= 调用外部工具

每个钩子选用 `nu` 或 `argv`。`argv` 的第一项是程序，后面各项逐个传入。需要 shell 变量、管道等语法时，放进脚本，让对应的解释器执行。使用外部程序的机器要安装它，并让 Tola 能在 `PATH` 中找到它。

生成前端 CSS 和 JavaScript 时，通常先把编译后的文件准备为输入。需要直接分析最终 HTML 时，用 `generate-outputs`。上传使用 `after-publish`，该阶段失败时会报告错误，已经生成的发布目录仍在。

外部钩子也可运行 `"$TOLA_EXECUTABLE" nu @tola-scripts/context --json`，读取这次调用的配置和目录。示例见 #link("/docs/reference/scripts/context/")[context]。字段见 `tola help --lang zh "[hooks]"`。
