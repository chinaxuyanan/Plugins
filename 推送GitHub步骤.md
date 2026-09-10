# 把三个库推到 GitHub 并启用 CI

> 三个库各自是独立仓库：`SwiftUIProKit`、`LogKit`、`SystemInfoKit`。
> 各自的 CI 配置已经写好并提交（`.github/workflows/ci.yml`），推到 GitHub 后会自动开始跑。
> 下面的命令都在 **终端** 里执行；把 `你的GitHub用户名` 换成你的实际账号。

## 一、先在 GitHub 网页建三个空仓库

打开 <https://github.com/new>，建三次，名字分别填 `SwiftUIProKit`、`LogKit`、`SystemInfoKit`。

**重要：什么都不要勾** —— 不要勾 "Add a README file"、不要选 .gitignore、不要选 license。
建出来的必须是**完全空的**仓库，否则推送时会因为远端已有提交而冲突。

建议三个都设为 **Private**（还没想好要不要公开的话，之后随时能在 Settings 里改）。

## 二、确认能连上 GitHub

选一种方式，只做一次：

**方式 A：SSH（推荐，配好一次就不用再输密码）**

```bash
ssh -T git@github.com
```

看到 `Hi 你的用户名! You've successfully authenticated` 就成了。
如果报 `Permission denied`，先按 <https://docs.github.com/en/authentication/connecting-to-github-with-ssh> 生成并上传 SSH key。

**方式 B：HTTPS + 个人访问令牌（PAT）**

去 <https://github.com/settings/tokens> 生成一个 token（勾 `repo` 权限），密码处粘贴这个 token。
下面命令里的远端地址就用 `https://github.com/你的GitHub用户名/<库名>.git`。

## 三、逐个推送

三个库依次执行同一套命令（SSH 版）：

```bash
cd ~/Desktop/Xcode_Projects/Plugins

# ---- SwiftUIProKit ----
cd SwiftUIProKit
git remote add origin git@github.com:你的GitHub用户名/SwiftUIProKit.git
git push -u origin main
git push origin --tags
cd ..

# ---- LogKit ----
cd LogKit
git remote add origin git@github.com:你的GitHub用户名/LogKit.git
git push -u origin main
git push origin --tags
cd ..

# ---- SystemInfoKit ----
cd SystemInfoKit
git remote add origin git@github.com:你的GitHub用户名/SystemInfoKit.git
git push -u origin main
git push origin --tags
cd ..
```

`git push origin --tags` 会把历次版本标签（`0.1.0` ~ `0.15.0` 等）一起推上去，
这样别人才能用 `.package(url:..., from: "0.15.0")` 按版本依赖。

> 如果之前加过 origin（报 `remote origin already exists`），改成：
> `git remote set-url origin git@github.com:你的GitHub用户名/<库名>.git`

## 四、看 CI 跑得怎么样

推送后打开仓库页面 → 顶部 **Actions** 标签，会看到一次 `CI` 运行。
每次各跑两个 job：

| job | 做什么 |
| --- | --- |
| 构建与测试（macOS） | `swift build` + `swift test`，跑全部单元测试 |
| 编译检查（iOS） | `xcodebuild` 单独编一遍 iOS 目标，抓平台专有符号泄漏 |

以后再改代码，push 完等几分钟看 Actions 结果就行，不用每次在本机手动 `swift test`。

**如果 iOS 那个 job 红了**：把 Actions 里的报错日志贴给我，我来判断是库要改还是 CI 配置要调。
第一次跑有可能因为 runner 环境差异需要微调，属正常。

## 五、CI 徽章（可选）

知道用户名之后，我可以在每个 README 顶部加一个状态徽章，形如：

```markdown
[![CI](https://github.com/你的GitHub用户名/SwiftUIProKit/actions/workflows/ci.yml/badge.svg)](https://github.com/你的GitHub用户名/SwiftUIProKit/actions/workflows/ci.yml)
```

README 的「安装」小节里的 `.package(url: "https://github.com/<你的账号>/XXX", ...)`
也可以一并换成真实地址，顺手把 `<你的账号>` 这个占位符清掉。

## 关于 KitsDemo

`KitsDemo` 是演示可执行包，`Package.swift` 里依赖的是 **本地相对路径**
（`../SwiftUIProKit` 等），推上去在 CI 里找不到这三个同级目录，所以它暂时没配 CI。
如果以后也想让 KitsDemo 进 CI，有两条路：把依赖改成远端 URL，或者让 CI 同时 checkout 四个仓库。
想做的时候说一声，我来配。
