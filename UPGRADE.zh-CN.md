# QClaw 0.85 到 0.86 升级分流说明

这次升级不能用一句 `qclaw upgrade` 覆盖所有旧用户。先判断用户机器有没有“微信命令拦截层”。

## 先判断

让用户在 QClaw 微信会话里发：

```text
qclaw upgrade
```

如果 QClaw 回复“开始检查 0.86 更新”或类似升级状态，说明已经接入命令拦截层，继续等它完成即可。

如果 QClaw 正常聊天回复“不知道这个命令”“这是命令行命令”“需要在终端运行”，说明这台机器还是纯旧版入口，微信命令没有被拦截。必须先在那台机器上跑一次 bootstrap。

## 场景 A：用户自己电脑安装的 QClaw

适用：普通 Windows 用户、自己装的桌面版 QClaw、微信已经在本机连着 QClaw。

先让用户关闭正在生成的回复，然后在 Windows PowerShell 里运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$repo='qxn90111/qclaw-releases'; $manifest=Invoke-RestMethod ('https://raw.githubusercontent.com/'+$repo+'/main/releases/latest/manifest.json'); $zip=Join-Path $env:TEMP 'qclaw-upgrade.zip'; $dir=Join-Path $env:TEMP 'qclaw-upgrade-kit'; Invoke-WebRequest -UseBasicParsing -Uri $manifest.rules.artifactUrl -OutFile $zip; if(Test-Path $dir){Remove-Item -LiteralPath $dir -Recurse -Force}; Expand-Archive -LiteralPath $zip -DestinationPath $dir -Force; powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $dir 'install-qclaw.ps1') -Repo $repo"
```

完成后重启 QClaw。以后同一台机器升级，用户只需要在微信里发：

```text
qclaw upgrade
```

本机验证：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\QClaw\Tool\qclaw.ps1" status -ManifestSource "https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/releases/latest/manifest.json"
```

应看到：

- `Current rules version: 0.86.0`
- `Thinking default: high`
- `Model output ceiling: >= 8192`

## 场景 B：我们帮用户装在 Windows 服务器上的纯 0.85

适用：QClaw/OpenClaw 跑在 Windows 服务器，用户只是在微信里聊天。

必须远程登录服务器，在“实际运行 QClaw 的 Windows 用户”下面运行命令。不要用另一个管理员账号乱跑，否则会改到另一个用户目录的 `%USERPROFILE%\.qclaw`。

默认状态目录是当前用户：

```powershell
%USERPROFILE%\.qclaw
```

如果服务器就是默认目录，运行场景 A 的 bootstrap 命令即可。

如果服务器的状态目录不是默认目录，先只安装工具，不立刻改配置：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$repo='qxn90111/qclaw-releases'; $manifest=Invoke-RestMethod ('https://raw.githubusercontent.com/'+$repo+'/main/releases/latest/manifest.json'); $zip=Join-Path $env:TEMP 'qclaw-upgrade.zip'; $dir=Join-Path $env:TEMP 'qclaw-upgrade-kit'; Invoke-WebRequest -UseBasicParsing -Uri $manifest.rules.artifactUrl -OutFile $zip; if(Test-Path $dir){Remove-Item -LiteralPath $dir -Recurse -Force}; Expand-Archive -LiteralPath $zip -DestinationPath $dir -Force; powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $dir 'install-qclaw.ps1') -Repo $repo -SkipInitialUpgrade"
```

然后明确指定状态目录升级：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\QClaw\Tool\qclaw.ps1" upgrade -Repo "qxn90111/qclaw-releases" -StateRoot "C:\path\to\.qclaw"
```

服务器验证：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\QClaw\Tool\qclaw.ps1" status -Repo "qxn90111/qclaw-releases" -StateRoot "C:\path\to\.qclaw"
```

升级后重启 QClaw/OpenClaw 服务或桌面进程。重启期间微信连接会短暂断开，通常恢复后继续使用原会话。

## 场景 C：我们这台机器这种手动装/改过路径的 QClaw

适用：开发机、手动替换过 openclaw 目录、手动改过 `.qclaw` 配置、同时存在多个 QClaw 版本目录。

不要直接说“已经升级”。必须检查三件事：

```powershell
Test-Path "$env:LOCALAPPDATA\QClaw\Tool\qclaw.ps1"
Test-Path "$env:LOCALAPPDATA\QClaw\Tool\wechat\qclaw-wechat-command-router.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\QClaw\Tool\qclaw.ps1" status -Repo "qxn90111/qclaw-releases"
```

还要确认当前正在运行的微信扩展代码能识别命令。Windows 示例：

```powershell
rg -n "qclaw upgrade|qclaw-wechat-command-router|isWeixinCommandCandidate" "D:\qclaw\v0.2.23.532\resources\openclaw\config\extensions\weixin" --glob "!**/*.map"
```

如果运行中的 QClaw 进程没有重启，微信里可能还是旧行为。必须退出并重新打开 QClaw。

## 场景 D：Linux/macOS 服务器

当前 0.86 升级包使用 PowerShell 脚本。Linux/macOS 服务器必须先有 `pwsh`，否则不要承诺一条命令完成。

有 `pwsh` 时，可以用：

```powershell
pwsh -NoProfile -Command '$repo="qxn90111/qclaw-releases"; $manifest=Invoke-RestMethod ("https://raw.githubusercontent.com/"+$repo+"/main/releases/latest/manifest.json"); $zip=Join-Path ([IO.Path]::GetTempPath()) "qclaw-upgrade.zip"; $dir=Join-Path ([IO.Path]::GetTempPath()) "qclaw-upgrade-kit"; Invoke-WebRequest -Uri $manifest.rules.artifactUrl -OutFile $zip; if(Test-Path $dir){Remove-Item -LiteralPath $dir -Recurse -Force}; Expand-Archive -LiteralPath $zip -DestinationPath $dir -Force; pwsh -NoProfile -File (Join-Path $dir "install-qclaw.ps1") -Repo $repo -SkipInitialUpgrade; pwsh -NoProfile -File (Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) "QClaw/Tool/qclaw.ps1") upgrade -Repo $repo -StateRoot "$HOME/.qclaw"'
```

验证：

```powershell
pwsh -NoProfile -File "$HOME/.local/share/QClaw/Tool/qclaw.ps1" status -Repo "qxn90111/qclaw-releases" -StateRoot "$HOME/.qclaw"
```

如果服务器不是 `~/.qclaw`，把 `-StateRoot "$HOME/.qclaw"` 换成真实目录。

## 给用户的话术

不要直接说“发 qclaw upgrade 就行”。先按用户类型说清楚：

```text
如果你的 QClaw 已经支持微信命令，在微信里发 qclaw upgrade 就能升级。
如果它把这句话当普通聊天回复，说明你的旧版还没有命令拦截层，需要先在电脑/服务器上跑一次 bootstrap 命令。跑完并重启 QClaw 后，以后再升级就可以直接在微信里发 qclaw upgrade。
```

## 不允许的说法

- 不要说“所有 0.85 用户都能微信一条命令升级”。
- 不要说“GitHub 发了就等于用户机器升级了”。
- 不要在没重启运行进程的情况下说“微信命令已经生效”。
- 不要静默上传聊天原文做升级分析。
