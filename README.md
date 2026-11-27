# 无线设备电量监视器 CN · Wireless-Device-Battery-Monitor-CN
[![ci](https://github.com/fuyue521/Wireless-Device-Battery-Monitor-CN/actions/workflows/ci.yml/badge.svg)](https://github.com/fuyue521/Wireless-Device-Battery-Monitor-CN/actions/workflows/ci.yml)

把无线鼠标、耳机、键盘和手柄的电量直接显示在 Windows 任务栏上，不装厂商软件、不要管理员权限、没有后台服务。

> **要提交 PR？** 新建 PR 时 GitHub 会自动带出模板，请按四段填写：**这个 PR 做了什么**（含复现方式与根因）、**协议来源**、**实机验证**（`--list` 原始输出）、**自查清单**。完整指引见 [CONTRIBUTING.md](CONTRIBUTING.md)。

![任务栏效果](docs/screenshot.png)

<sub>上图是上游原版的并排显示截图；本分支默认改为「一次只显示一个设备」（可在右键菜单关闭），详见下方改动清单。</sub>

这是 **Wireless Battery** 的简体中文本地化分支：界面默认中文、词条经过逐条校订、安装包与项目名改为 `Wireless-Device-Battery-Monitor-CN`，其余程序逻辑与上游保持一致。

---

## 维护状态

**随缘维护（best-effort）。**

这是一个个人利用业余时间维护的汉化分支，我不承诺响应时间，也不保证每个需求都能实现：

- **会做**：构建失败、崩溃、汉化或打包错误这类明显问题；以及合并能通过 CI 构建、写明协议来源、只读不写设备的外部 PR。
- **多半做不了新设备**：我手上只有少数几台设备，没有硬件就无法验证协议，盲写只会给出错误的读数——这类 issue 通常只能停在"需要抓包"这一步。
- **代码能力有限**：本仓库的不少改动是在 AI 辅助下完成的，所以我更依赖 CI 构建、静默安装/卸载和真实设备上的 `--list` 来验证，也因此不敢合并未经验证的改动。

如果你想要更大的改动、更快的节奏，**欢迎直接 fork 自行维护**：GPLv3 明确允许修改与再分发，构建脚本（`build.bat`、`Makefile`）、CI、NSIS 打包脚本和各驱动的协议注释都在仓库里，`upstream-final` 标签还保留着上游最后一份完整历史，可以从任意起点开始。改好的成果也欢迎以 PR 形式提回来，我会尽量合。

> 简言之：这是"能修就修"的项目，不是"有求必应"的项目；需要稳定支持的话，fork 是最实际的路。

<sub>English: this is a best-effort, single-person branch maintained with heavy AI assistance. Bug fixes and well-tested PRs are welcome; new device support usually needs a hardware trace I don't have. Forking is explicitly encouraged.</sub>

## 与上游项目的关系

| 项目 | 说明 |
| --- | --- |
| 原项目 | **Wireless Battery** |
| 原作者 | **krisgfx**（GitHub：[@krisgfx9](https://github.com/krisgfx9)） |
| 原仓库 | <https://github.com/krisgfx9/Wireless-Device-Battery-Monitor> |
| 原项目协议 | GNU GPLv3 或更高版本 |
| 本分支 | 简体中文本地化 + 中文安装包，同样以 GPLv3 发布 |

本仓库**不是**原作者维护的官方版本。中文界面、翻译措辞、打包方式相关的问题请提到本仓库。

### 上游状态

截至 **2026-11-25**，原作者的 GitHub 账号 `@krisgfx9` 与原仓库 <https://github.com/krisgfx9/Wireless-Device-Battery-Monitor> 都已无法访问（返回 404），原作者暂时联系不上；原项目主页 `krisgfx.com` 已跳转到作者的另一站点 `craftsdb.krisgfx.com`。

因此本仓库同时承担上游存档的职责：

- 完整保留上游 Git 历史（379 个提交，最后一版 `958a60a`），各位作者的原始署名与其提交原样未改；
- 标签 `upstream-final` 指向 `958a60a`，可用于核对上游最后一版；
- 上游最后一版的源码包 `Wireless-Device-Battery-Monitor-958a60a-upstream.zip` 作为存档附件挂在 [v1.0.1 Release](https://github.com/fuyue521/Wireless-Device-Battery-Monitor-CN/releases/tag/v1.0.1) 里。

GPLv3 的授权是永久且不可撤销的，上游仓库下线不影响本分支继续分发；若原作者日后希望调整署名或说明，请开 issue 联系，本仓库会配合处理。本分支**不提供、也不再链接任何赞助渠道**（原「支持本项目」菜单项已移除）。

### 修改声明（GPLv3 第 5 条）

本仓库是 <https://github.com/krisgfx9/Wireless-Device-Battery-Monitor> 的**修改版本**，按 GNU GPLv3 第 5 条在此显著声明：

- **修改人**：fuyue521（<https://github.com/fuyue521>），修改日期 2026-11-18。
- **修改内容**：简体中文本地化、默认语言与版本资源中文化、任务栏挂件的单设备显示与滚轮切换、打包方式（NSIS）、移除「支持本项目」赞助链接（原作者失联，见上「上游状态」）。逐条清单见下方「本分支相对上游的改动」。
- **修改性质**：仅修改与新增，未删除上游功能；上游源码文件头部的版权声明、`LICENSE` 文件均保持原样。
- **历史记录**：上游的完整 Git 提交历史（含每位作者的原始提交）原样保留在本仓库中，`git log` 即可查看；本分支的改动以上游最后一次提交（`958a60a`）为基线，其后的改动提交作者为本仓库修改人。
- **许可**：本项目整体仍以 GNU GPLv3（或更高版本）发布，完整对应源码即本仓库；原作者与上游贡献者名单见 [CONTRIBUTORS.md](CONTRIBUTORS.md)。

### 本分支相对上游的改动

- **界面默认简体中文**：未保存过语言选择时回退到 `zh-CN`（中文 Windows 本来就是中文，现在英文系统上也是中文）。
- **词条校订**：`lang/zh-CN.txt` 全部 97 条逐条校对，统一标点（中文省略号/引号）、术语（"接收器""挂件""开机启动"）和语气。
- **残留硬编码汉化**：托盘提示前缀、报告窗口标题改为中文产品名。
- **版本资源中文化**：文件描述、产品名改为中文/CN 版名称。
- **安装包重做**：Inno Setup 脚本换成 NSIS 脚本，中文安装向导、免管理员、按用户安装，产物为 `Wireless-Device-Battery-Monitor-CN-Setup-1.0.6.exe`。
- **挂件只显示一个设备**：设备多于一个时，任务栏挂件默认只显示当前设备（不再向右挤占任务按钮），鼠标悬停时滚轮上下切换，切换带左右滑动淡入淡出动画；右键菜单可关掉这项，恢复上游的并排显示。
- **文档中文化**：本 README 与安装目录内的 `README.txt`。
- **移除赞助入口**：原作者失联、`github.com/sponsors/krisgfx9` 已 404，右键菜单不再显示「支持本项目…」。
- **检查更新**：右键菜单新增「检查更新…」，点击后请求 GitHub Releases 的最新 tag 与本地版本比较，有新版本时询问是否打开下载页（只检查、不自动下载安装）。

> 驱动、协议解析、命令行行为均未改动；界面层只改了语言默认值、挂件显示方式与文案。

---

## 功能

- **任务栏挂件**：图标 + 百分比紧贴时钟左侧；电量 ≤15% 变红，充电显示蓝色闪电，设备休眠时变暗并保留上次电量。
- **单设备显示 + 滚轮切换**：连接多个设备时默认只显示一个，鼠标指向挂件滚动滚轮即可上下切换，切换时左右滑动淡入淡出（约 0.19 秒）；右键菜单"一次只显示一个设备（滚轮切换）"可关闭，恢复全部并排。
- **固定尺寸、统一图标**：单设备挂件宽度恒定（不随电量数字位数、设备类型或是否充电变化），电量按等宽数字位左对齐、"%" 单独占位，图标与数字间距固定为 3 像素；图标仍按设备类型区分（沿用原项目图标），但图标格宽度取全设备最大宽度后固定，切换设备不会改变整体宽度；充电闪电只在有设备正在充电时才占位，其余情况挂件更紧凑。
- **托盘模式**：每个设备一个带数字的图标，低电量时弹通知；任务栏竖直摆放或找不到时自动回退。
- **同类设备区分**：两只鼠标/两个手柄会在角上标最多 3 个字母（`MX`、`PRO`，实在分不清就用数字）。
- **显示选项**：15 套品牌配色（Razer 绿、Logitech 蓝、SteelSeries 橙……）、多显示器分别显示、图标压在百分比上方、透明任务栏底色板。
- **刷新策略**：每 60 秒轮询一次，插拔设备或系统唤醒时立即刷新。
- **右键菜单**：逐设备显示/隐藏/左右移动、立即刷新、开机启动、语言切换、选择显示器、检查更新、退出。
- **多语言**：内置 13 种语言（简繁中文、英、德、西、法、日、俄、波兰、巴西葡语、土耳其、阿拉伯、希伯来），也可放入自定义词条文件即时生效。

## 支持设备

| 类别 | 覆盖范围 |
| --- | --- |
| 罗技 | HID++ 1.0/2.0 鼠标与键盘、G435 等耳机 |
| 雷蛇 | 鼠标、键盘、耳机（含 Barracuda） |
| 赛睿 / 海盗船 / HyperX / Astro / NZXT / 美商海盗船 | 鼠标、耳机、底座 |
| 游戏手柄 | Xbox、PlayStation DualSense/DualShock、Switch Pro、Steam Controller、八位堂、飞智（Vader 4 Pro 需切 DInput 模式）、北通、盖世小鸡 |
| 真无线耳机 | Galaxy Buds、AirPods、Jabra、JBL、漫步者（部分）、水月雨 |
| 蓝牙设备 | 任何 Windows 能报电量的蓝牙外设 |
| 手机 | 通过 Phone Link 连接的手机电量 |
| 国产键鼠 | ATK/VXE、MCHOSE、Rapoo、Kysona、Pulsar、G-Wolves、Endgame、VAXEE、WLmouse、Finalmouse、AULA、SONiX、Redragon/Areson、Delux/Ajazz、Attack Shark、达尔优、雷柏、PMOKEY WAVE 75（WOBKEY）等 |

完整型号清单见源码 `src/drivers/` 下各驱动的注释（每个文件头部都标注了协议出处）。

## 安装

### 方式一：安装包（推荐）

1. 下载 `Wireless-Device-Battery-Monitor-CN-Setup-1.0.6.exe`（见 Releases）。
2. 双击运行，按中文向导下一步即可；**不需要管理员权限**，默认安装到
   `%LOCALAPPDATA%\Programs\Wireless-Device-Battery-Monitor-CN`。
3. 安装器可选择"开机自动启动"，装完可直接启动；卸载在"设置 → 应用"里。

安装包内附带 `headsetcontrol.exe`（HeadsetControl 4.3.0，用于部分耳机），请与主程序保持同目录。

### 方式二：便携版

把 `WirelessBattery.exe`、`headsetcontrol.exe`、`LICENSE.txt`、`THIRD_PARTY_NOTICES.txt` 放到任意目录直接运行即可，不写系统目录。

> `headsetcontrol.exe` 不是可选项：走 `[HeadsetControl]` 通道的耳机（例如 MCHOSE V9 Pro、Arctis Nova、部分 HyperX/Jabra/Astro）依赖主程序**同目录**下的它来读电量。缺了这个文件，这些设备会直接在列表里消失，其它鼠标/蓝牙设备不受影响。

## 使用

- 首次启动后任务栏出现挂件；右键托盘图标可切换"任务栏挂件"与"托盘图标"两种模式。
- 想单独隐藏某个设备：右键 → 指向该设备 → "在任务栏显示/在托盘中显示"。
- 语言：右键 → "语言" → 简体中文 / 自动（跟随 Windows 语言）/ 其他。
- 显示器：右键 → "挂件显示在" → 所有显示器 / 仅主显示器 / 指定某块屏。
- 多个设备时挂件只显示一个：把鼠标移到挂件上，**滚轮向上 = 上一个设备，向下 = 下一个设备**；
  不想这样可在右键菜单里取消勾选"一次只显示一个设备（滚轮切换）"，改回全部并排显示。

## 命令行

| 命令 | 作用 |
| --- | --- |
| `WirelessBattery.exe --list` | 列出检测到的设备与电量（控制台输出，英文） |
| `WirelessBattery.exe --dump` | 导出 HID 调查信息，反馈兼容性问题时附上 |
| `WirelessBattery.exe --report` | 打开"申请支持某个设备"窗口 |
| `WirelessBattery.exe --demo` | 用演示数据预览挂件外观 |
| `WirelessBattery.exe --quit` | 退出正在运行的实例 |

## 构建

需要 MSYS2 的 MinGW-w64 工具链（支持 C++17 的 g++、`windres`、`make`），无第三方库。
PATH 上还可能有别的旧版 g++（例如 6.3.0，会拒绝 C++17），而且 `make` 默认不在 PATH 上，
所以每条构建命令前先切到 MSYS2：

```powershell
$env:PATH='C:\msys64\mingw64\bin;C:\msys64\usr\bin;'+$env:PATH
```

```bat
:: 产出 WirelessBattery.exe（需要上面 PATH 里的 g++ 与 windres）
build.bat
```

或使用 Makefile（`make` 也在上面 PATH 的 `C:\msys64\usr\bin` 里）：

```bash
make          # 编译
make test     # 编译并运行 24 个单元测试（协议字节解析等）
make clean
```

资源（图标、清单、13 种语言）由 `windres` 编译进 exe，编译参数与上游一致：`-std=c++17 -Os -static -s`。

## 打包安装程序

```bat
:: 1) 先构建出 WirelessBattery.exe
build.bat
:: 2) 生成 dist\Wireless-Device-Battery-Monitor-CN-Setup-1.0.6.exe
installer\build-installer.cmd
```

脚本会校验 `third_party\headsetcontrol\headsetcontrol.exe` 的 SHA-256（`e371da04…`），不符则中止；首次运行会自动下载 HeadsetControl 4.3.0。

安装脚本 `installer/Wireless-Device-Battery-Monitor-CN.nsi` 使用 NSIS 3.x（`winget install NSIS.NSIS`），中文界面、`RequestExecutionLevel user`、LZMA 压缩。

## 持续集成与发布

GitHub Actions 承担全部构建与打包，本地只需要工具链用来验证改动：

| 工作流 | 触发 | 做什么 |
| --- | --- | --- |
| `ci.yml` | push 到 main、PR、手动 | 秒级静态检查 + Windows 上编译、跑 24 个单元测试、`--list` 冒烟 |
| `release.yml` | 推送 `v*` 标签、手动试跑 | 校验 tag 与版本号 → 编译 → 测试 → NSIS 安装包 + 便携 zip + 对应源码 → `SHA256SUMS.txt` → 发布 Release |
| `pr-safety.yml` | 外部 PR | 扫描网络访问、启动程序、写文件等危险改动，结果只作提示，不阻断合并 |

`ci.yml` 里那组静态检查也能在本地跑，改动词条或版本号前建议先执行：

```bash
bash scripts/check-version.sh        # 安装脚本、res/app.rc 与资源字符串里的版本号是否一致
python3 scripts/check-lang.py        # 13 份 lang/*.txt 的键、占位符是否与 _template.txt 对齐
```

`make test` 以 `tests/*_test.cpp` 为准：新增测试文件却忘了写进 `Makefile` 的 `test` 目标时，它会直接失败而不是悄悄跳过。

发布新版本（版本号共四处，`scripts/check-version.sh` 会一起校验）：

```bash
# 1) installer/*.nsi 的 APP_VERSION、res/app.rc 的 FILEVERSION/PRODUCTVERSION 与下面两个字符串
# 2) 提交后打标签并推送，release.yml 自动打包发布
git tag v1.0.7 && git push origin v1.0.7
```

被打上标签的提交如果版本号还是旧的，`release.yml` 会在编译前就停下；打包完成后 `dist/` 里还会多一份 `SHA256SUMS.txt`，可用于核对下载到的安装包。

## 目录结构

```
Wireless-Device-Battery-Monitor-CN/
├─ src/                 Win32 主体：任务栏挂件、托盘、菜单、i18n
│  └─ drivers/          72 个厂商驱动（只读电量协议）
├─ lang/                13 种语言词条（zh-CN.txt 为中文）
├─ res/                 图标、清单、版本资源
├─ tests/               24 个单元测试
├─ installer/           NSIS 安装脚本 + 构建脚本 + 第三方声明
├─ docs/                截图与协议笔记
├─ linux/              实验性 Linux 版（GTK4 托盘）
├─ Makefile / build.bat
└─ README.md
```

## 翻译

界面词条是纯文本的 `lang/*.txt`，格式为 `英文原文 = 译文`，支持 `{name}`、`{percent}` 具名占位符。
想改中文措辞直接编辑 `lang/zh-CN.txt`；想加语言复制 `lang/_template.txt` 改名即可。
把文件放进 `%APPDATA%\WirelessBattery\lang` 可以覆盖内置词条，无需重新编译。

## 已知限制

- 只读查询：驱动不会向设备写入任何数据（HeadsetControl 外）。
- 某些设备在休眠/关机后只能读到上次缓存电量。
- 2.4 GHz 私有协议设备依赖厂商 dongle 提供的 HID 接口，部分型号会随固件变化。
- 程序只在你主动点击时联网：右键菜单的「检查更新…」发一次 HEAD 请求到 GitHub 读最新版本号（不发送任何设备或个人信息），「申请支持某个设备…」会打开浏览器跳转到本仓库的 GitHub 新建 issue 页面。其余时间完全离线。

## 许可与致谢

- 本分支与上游一致，以 **GNU GPLv3 或更高版本** 发布，见 [LICENSE](LICENSE)。
- 原作者 **krisgfx**（bimbikri）与所有上游贡献者：<https://github.com/krisgfx9/Wireless-Device-Battery-Monitor>
- 上游贡献者完整名单（共 96 人）与各自角色：[CONTRIBUTORS.md](CONTRIBUTORS.md)
- 随附 [HeadsetControl](https://github.com/Sapd/HeadsetControl) 4.3.0（GPLv3），版权归其贡献者，见 [THIRD_PARTY_NOTICES.txt](installer/THIRD_PARTY_NOTICES.txt)。
- 图标作者 nik-txt；各品牌协议细节来源于 HeadsetControl、OpenRazer、Solaar、rivalcfg 等开源项目的公开逆向成果（详见各驱动文件头注释）。

## 上传到 GitHub

这个目录已经是 git 仓库（`git log` 里有提交），**不要再 `git init`**——那会在里面嵌套一个空仓库，
`git add .` 收不到任何历史。只需要补上远端并推送：

```bash
git remote add origin https://github.com/<你的用户名>/Wireless-Device-Battery-Monitor-CN.git
git push -u origin main
```

远端已经存在就改用 `git remote set-url origin <地址>`。只有在一个空目录里重新开始时才用
`git clone <地址> .` 取回仓库，而不是在已有仓库里 init。

`.gitignore` 已排除 `*.exe`、`dist/`、`build/`、`third_party/`，因此仓库里只有源码；安装包请作为 Release 附件上传。
建议在仓库描述里写清："Simplified Chinese fork of krisgfx/Wireless-Device-Battery-Monitor"。
