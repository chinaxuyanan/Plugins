# 把 Plugins 推到 GitHub 并启用 CI

> 整个 `Plugins` 目录是**一个仓库**，里面并排放着三个包和一个演示工程：
> `SwiftUIProKit/`、`LogKit/`、`SystemInfoKit/`、`KitsDemo/`。
> CI 配置已经写好并提交（`.github/workflows/ci.yml`），推上去后自动开始跑。
> 下面的命令都在 **终端** 里执行；把 `你的GitHub用户名` 换成你的实际账号。

## 一、先在 GitHub 网页建一个空仓库

打开 <https://github.com/new>，仓库名填 `Plugins`。

**重要：什么都不要勾** —— 不要勾 "Add a README file"、不要选 .gitignore、不要选 license。
建出来的必须是**完全空的**仓库，否则推送时会因为远端已有提交而冲突。

建议设为 **Private**（还没想好要不要公开的话，之后随时能在 Settings 里改）。

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
下面命令里的远端地址就用 `https://github.com/你的GitHub用户名/Plugins.git`。

## 三、推送

```bash
cd ~/Desktop/Xcode_Projects/Plugins
git remote add origin git@github.com:你的GitHub用户名/Plugins.git
git push -u origin main
git push origin --tags
```

`git push origin --tags` 会把 53 个历史版本标签一起推上去。它们是 `库名-版本` 的形式，例如：

```
SwiftUIProKit-1.8.0
LogKit-1.5.0
SystemInfoKit-1.5.0
```

> 注意：这些 tag 只是**版本标记**，不是给 SwiftPM 用的。因为三个包在同一个仓库的子目录里，
> SwiftPM 没法按版本从远端解析它们（要 `Package.swift` 在仓库根目录才行），详见仓库根 README。

> 如果之前加过 origin（报 `remote origin already exists`），改成：
> `git remote set-url origin git@github.com:你的GitHub用户名/Plugins.git`

## 四、看 CI 跑得怎么样

推送后打开仓库页面 → 顶部 **Actions** 标签，会看到一次 `CI` 运行。共三个 job：

| job | 做什么 |
| --- | --- |
| 构建与测试（SwiftUIProKit / LogKit / SystemInfoKit） | 三个库各跑一遍 `swift build` + `swift test` |
| 编译检查（… · iOS） | 三个库各用 `xcodebuild` 编一遍 iOS 目标，抓平台专有符号泄漏 |
| 构建演示工程（KitsDemo · macOS） | 编一遍演示工程（它用相对路径依赖同仓库的三个库） |

以后再改代码，push 完等几分钟看 Actions 结果就行，不用每次在本机手动 `swift test`。

**如果某个 job 红了**：把 Actions 里的报错日志贴给我，我来判断是库要改还是 CI 配置要调。
第一次跑有可能因为 runner 环境差异需要微调，属正常。

## 五、CI 徽章

四个 README（仓库根 + 三个库）的标题下面都已经放好状态徽章：

```markdown
[![CI](https://github.com/chinaxuyanan/Plugins/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/chinaxuyanan/Plugins/actions/workflows/ci.yml)
```

三个库的 README 里额外带了 `&label=Plugins%20CI`，把徽章文字显示成「Plugins CI」。
仓库是 Private 的话，徽章只对登录且有权限的人可见，匿名访客看到的是灰图，属正常。

## 关于 `.old-repos-backup`

合并历史时，原来四个独立仓库各自的 `.git` 曾挪到 `.old-repos-backup/`（3.8 MB，且已在 `.gitignore` 里，从未推上去）。
2026-09-11 确认新仓库一切正常后，已连同 `.gitignore` 里那条注释一起删除。

## 关于 KitsDemo

它以前也是独立仓库，现在并进来了。因为它用 `../SwiftUIProKit` 这样的**相对路径**依赖三个库，
在同一个仓库里路径依然成立，所以本地照常能跑，CI 里也能顺带编一遍。
