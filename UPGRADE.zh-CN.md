# QClaw 0.87.1 安装、升级与分流说明

当前稳定版：

- rules：`0.87.1`
- training：`qinsheng-training-pack-v0.87.1`
- latest manifest：`https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/releases/latest/manifest.json`
- release asset：`qclaw-upgrade-kit-0.87.1-149826d8.zip`
- SHA256：`149826D8F06D7CDCE3EC2A207389526098AF19CB9A86AC44A108EC0CDAA84B7F`

## 新用户怎么安装

普通 Windows 新用户，一条 PowerShell 命令够：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/install.ps1 | iex"
```

这条命令会：

1. 读取 GitHub `releases/latest/manifest.json`。
2. 确认 latest 是 `0.87.1` 且是 `rules+training` 包。
3. 下载 `qclaw-upgrade-kit-0.87.1-149826d8.zip`。
4. 校验 SHA256。
5. 解压并运行包内 `install-qclaw.ps1`。
6. 安装 `qclaw` 命令层。
7. 立即安装 bundled `0.87.1` rules。
8. 同步 `qinsheng-training-pack-v0.87.1`、`SOUL.md`、`AGENTS.md`、workspace、skill、installer。
9. 同步 `thinkingDefault: xhigh`。

安装后验证：

```powershell
qclaw status
qclaw doctor
```

必须看到：

- `Current ver: 0.87.1` 或 JSON 里的 `currentRulesVersion = 0.87.1`
- `Training ver: qinsheng-training-pack-v0.87.1`
- `Workspace SOUL: ok`
- `Workspace AGENTS: ok`
- `defaultsThinking = xhigh`

## 用户是不是只发微信命令就够

分情况：

- 新用户第一次安装：不要只让用户发微信。先跑上面那条 PowerShell 一键安装命令。
- 已经装过 `0.87.1` 命令层和微信命令路由的用户：以后在微信里发 `qclaw upgrade` 就够。
- 旧 `0.85/0.86` 或 rules-only `0.87.0` 用户：如果微信把 `qclaw upgrade` 当普通聊天回答，说明命令路由还没接上，必须先跑一键安装命令。

给用户的话术：

```text
第一次安装请在 Windows PowerShell 里运行这条命令。装好以后，后续升级只需要在 QClaw 微信会话里发 qclaw upgrade。
```

## 服务器 / 非默认状态目录

如果 QClaw 跑在 Windows 服务器上，必须登录“实际运行 QClaw 的 Windows 用户”再执行。不要用另一个管理员账号乱跑，否则会改到另一个用户目录。

默认状态目录是：

```powershell
%USERPROFILE%\.qclaw
```

如果服务器使用默认目录，可以直接用新用户一键命令。

如果服务器状态目录不是默认目录，用下面方式：

```powershell
$script = Join-Path $env:TEMP "qclaw-install.ps1"
irm https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/install.ps1 -OutFile $script
powershell -NoProfile -ExecutionPolicy Bypass -File $script -StateRoot "C:\path\to\.qclaw"
```

验证：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\QClaw\Tool\qclaw.ps1" status -StateRoot "C:\path\to\.qclaw"
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\QClaw\Tool\qclaw.ps1" doctor -StateRoot "C:\path\to\.qclaw"
```

## 换微信 / 换机器 / 重装服务器

先在旧机器导出用户状态：

```powershell
qclaw export-user-state
```

新机器先跑一键安装，再导入：

```powershell
qclaw import-user-state -ArchivePath "C:\path\qclaw-user-state-xxxx.zip"
qclaw doctor
```

不要把 API Key、模型 token、微信密码、中转站密钥放进迁移包。新机器重新配置这些凭据。

## 不允许的说法

- 不要说“所有旧用户都能只靠微信一句话安装”。
- 不要说“GitHub 发了就等于用户机器升级了”。
- 不要继续发旧 `0.86` README 里的安装命令。
- 不要在没有 `status/doctor` 证据时说“后台已经装好”。
- 不要静默上传聊天原文、密钥或用户隐私记录做升级分析。

