# QClaw Releases

This repository hosts the public update manifest and release assets for QClaw rules upgrades.

## Current Stable Release

- Version: `0.86.0`
- Manifest: `https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/releases/latest/manifest.json`
- Asset: `https://github.com/qxn90111/qclaw-releases/releases/download/v0.86.0/qclaw-upgrade-kit-0.86.0-702c9cac.zip`
- SHA256: `702C9CACD5ECCB066967EEA691496BF1B650F0E18B93506184E3F5C353915F94`

## User Upgrade Path

Chinese field SOP: [UPGRADE.zh-CN.md](UPGRADE.zh-CN.md)

Users whose QClaw already has the WeChat command interception layer can upgrade by sending this in the connected QClaw WeChat chat:

```text
qclaw upgrade
```

or:

```text
升级到 0.86
```

Important: older `0.85` installs that do not already have the WeChat command interception layer cannot be upgraded by a WeChat message alone. If `qclaw upgrade` reaches the normal model reply, run the one-time bootstrap command below on that machine first. After bootstrap, future upgrades can use the WeChat command.

```powershell
powershell -ExecutionPolicy Bypass -Command "$repo='qxn90111/qclaw-releases'; $manifest=Invoke-RestMethod ('https://raw.githubusercontent.com/'+$repo+'/main/releases/latest/manifest.json'); $zip=Join-Path $env:TEMP 'qclaw-upgrade.zip'; $dir=Join-Path $env:TEMP 'qclaw-upgrade-kit'; Invoke-WebRequest -UseBasicParsing $manifest.rules.artifactUrl -OutFile $zip; if(Test-Path $dir){Remove-Item -LiteralPath $dir -Recurse -Force}; Expand-Archive -LiteralPath $zip -DestinationPath $dir -Force; powershell -ExecutionPolicy Bypass -File (Join-Path $dir 'install-qclaw.ps1') -Repo $repo"
```

## What The Upgrade Does

- Backs up the previous rules before replacing them.
- Installs the `0.86.0` rules package.
- Sets QClaw runtime thinking defaults to `high`.
- Raises QClaw model `maxTokens` to at least `8192`.
- Syncs `agentTurn` cron jobs to `thinking: high`.
- Makes the daily reminder read `records/user-progress.md` before long-term memory.
- Does not upload raw chat logs.
