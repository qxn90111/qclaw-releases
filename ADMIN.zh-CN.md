# QClaw 发布后台检查清单

这个仓库就是 QClaw 公共发布后台的源头。每次对外说“新用户一键安装”之前，必须检查下面这些项目。

## 当前稳定版

- version：`0.87.1`
- kind：`rules+training`
- training：`qinsheng-training-pack-v0.87.1`
- asset：`qclaw-upgrade-kit-0.87.1-149826d8.zip`
- SHA256：`149826D8F06D7CDCE3EC2A207389526098AF19CB9A86AC44A108EC0CDAA84B7F`

## 对外一键安装命令

普通 Windows 新用户只需要这一条：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/install.ps1 | iex"
```

这条命令必须始终读取：

```text
https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/releases/latest/manifest.json
```

不要再给新用户发旧 `0.86` zip 或旧 README 里的命令。

## 发布后必须验收

```powershell
$manifest = Invoke-RestMethod "https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/releases/latest/manifest.json"
$manifest.version
$manifest.rules.artifactUrl
$manifest.rules.sha256
```

必须看到：

- version 是 `0.87.1`
- artifact 包名包含 `qclaw-upgrade-kit-0.87.1-149826d8.zip`
- SHA 是 `149826D8F06D7CDCE3EC2A207389526098AF19CB9A86AC44A108EC0CDAA84B7F`

新用户一键安装验收必须用临时目录跑：

```powershell
$script = Join-Path $env:TEMP "qclaw-install.ps1"
irm https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/install.ps1 -OutFile $script
$root = Join-Path $env:TEMP ("qclaw-admin-check-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
powershell -NoProfile -ExecutionPolicy Bypass -File $script -AppRoot (Join-Path $root "app") -ToolRoot (Join-Path $root "tool") -StateRoot (Join-Path $root "state") -NoPath
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tool\qclaw.ps1") status -Root (Join-Path $root "app") -StateRoot (Join-Path $root "state") -Json
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tool\qclaw.ps1") doctor -Root (Join-Path $root "app") -StateRoot (Join-Path $root "state")
```

完整生命周期验收：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\source\training\qinsheng-training\installer\test-qclaw-end-to-end-lifecycle.ps1
```

## 后台不能出现的旧入口

根目录 README、UPGRADE、一键脚本、管理说明里不能再出现：

- “Current Stable Release: 0.86.0”
- `qclaw-upgrade-kit-0.86.0-*.zip`
- “Thinking default: high”
- “升级到 0.86”

历史目录 `releases/0.86.0/` 和 `releases/0.87.0/` 可以保留，因为那是版本归档；但 `releases/latest/manifest.json` 必须指向当前稳定版。

## 隐私边界

验收输出只能包含版本、路径、哈希、计数和 PASS/FAIL。不要把 API Key、模型 token、微信密码、中转站密钥、用户原始聊天或家庭真实聊天记录写进仓库、release note 或验收报告。
