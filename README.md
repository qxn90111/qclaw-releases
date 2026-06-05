# QClaw Releases

This repository is the public release and install source for QClaw upgrade kits.

## Current Stable Release

- Version: `0.87.1`
- Kind: `rules+training`
- Training: `qinsheng-training-pack-v0.87.1`
- Manifest: `https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/releases/latest/manifest.json`
- Asset: `https://github.com/qxn90111/qclaw-releases/releases/download/v0.87.1/qclaw-upgrade-kit-0.87.1-149826d8.zip`
- SHA256: `149826D8F06D7CDCE3EC2A207389526098AF19CB9A86AC44A108EC0CDAA84B7F`

## New Windows User Install

For a normal new Windows user, one PowerShell command is enough:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/install.ps1 | iex"
```

The bootstrap script reads `releases/latest/manifest.json`, downloads the current release asset, verifies SHA256, extracts the kit, and runs `install-qclaw.ps1`. The installer immediately installs the bundled `0.87.1` rules, syncs `qinsheng-training-pack-v0.87.1`, creates the `qclaw` command layer, stores the GitHub latest manifest source, and syncs runtime `thinkingDefault: xhigh` where supported.

Verify after install:

```powershell
qclaw status
qclaw doctor
```

or:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\QClaw\Tool\qclaw.ps1" status
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\QClaw\Tool\qclaw.ps1" doctor
```

## Existing Users

Users who already have the `0.87.1` command layer and WeChat command router can upgrade later by sending this inside the connected QClaw WeChat chat:

```text
qclaw upgrade
```

Old `0.85`, `0.86`, or rules-only `0.87.0` installs may not have the command layer that can sync the training pack. Those machines need the one-time PowerShell install command above first. After that bootstrap, future upgrades can use WeChat.

## Server / Custom StateRoot

When QClaw runs on a Windows server or a non-default state directory, run the bootstrap on the actual Windows account that runs QClaw:

```powershell
$script = Join-Path $env:TEMP "qclaw-install.ps1"
irm https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/install.ps1 -OutFile $script
powershell -NoProfile -ExecutionPolicy Bypass -File $script -StateRoot "C:\path\to\.qclaw"
```

Never use the user-state archive or release package as a credential backup. Re-enter API keys, model relay tokens, WeChat credentials, and relay settings on the destination machine/server.

## Admin Release Checklist

Chinese admin checklist: [ADMIN.zh-CN.md](ADMIN.zh-CN.md)

Chinese upgrade SOP: [UPGRADE.zh-CN.md](UPGRADE.zh-CN.md)

