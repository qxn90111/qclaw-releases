#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Repo = "qxn90111/qclaw-releases",
    [string]$ManifestSource = "",
    [string]$AppRoot = (Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) "QClaw\App"),
    [string]$ToolRoot = (Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) "QClaw\Tool"),
    [string]$StateRoot = "",
    [switch]$NoPath,
    [switch]$SkipInitialUpgrade,
    [switch]$KeepTemp
)

$ErrorActionPreference = "Stop"

if (-not $ManifestSource) {
    $ManifestSource = "https://raw.githubusercontent.com/$Repo/main/releases/latest/manifest.json"
}

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.ServicePointManager]::SecurityProtocol
} catch {
}

function Assert-True {
    param($Condition, [string]$Message)
    if (-not [bool]$Condition) { throw $Message }
}

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("qclaw-bootstrap-" + [guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tempRoot "qclaw-upgrade-kit.zip"
$extractRoot = Join-Path $tempRoot "extract"

New-Item -ItemType Directory -Force -Path $tempRoot, $extractRoot | Out-Null

try {
    Write-Host "Reading QClaw manifest:"
    Write-Host $ManifestSource
    $manifestText = (Invoke-WebRequest -Uri $ManifestSource -UseBasicParsing -TimeoutSec 60).Content
    $manifest = $manifestText.TrimStart([char]0xFEFF) | ConvertFrom-Json

    Assert-True ($manifest.version -eq "0.87.1") "Refusing to install unexpected QClaw version: $($manifest.version). Expected 0.87.1."
    Assert-True ($manifest.kind -eq "rules+training") "Refusing to install non rules+training package: $($manifest.kind)."
    Assert-True ($manifest.rules.artifactUrl) "Manifest is missing rules.artifactUrl."
    Assert-True ($manifest.rules.sha256) "Manifest is missing rules.sha256."
    Assert-True ($manifest.training.version -eq "qinsheng-training-pack-v0.87.1") "Unexpected training version: $($manifest.training.version)."

    $required = @($manifest.training.requiredFiles)
    Assert-True ($required -contains "installer\test-qclaw-end-to-end-lifecycle.ps1") "Manifest is missing lifecycle harness."
    Assert-True ($required -contains "installer\user-lifecycle-acceptance-runbook.md") "Manifest is missing lifecycle runbook."

    Write-Host "Downloading QClaw $($manifest.version):"
    Write-Host $manifest.rules.artifactUrl
    Invoke-WebRequest -Uri $manifest.rules.artifactUrl -OutFile $zipPath -UseBasicParsing -TimeoutSec 180

    $actualHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
    Assert-True ($actualHash -eq $manifest.rules.sha256) "SHA256 mismatch. Expected $($manifest.rules.sha256), got $actualHash."
    Write-Host "SHA256 ok: $actualHash"

    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force
    $installer = Join-Path $extractRoot "install-qclaw.ps1"
    Assert-True (Test-Path -LiteralPath $installer) "Downloaded package is missing install-qclaw.ps1."

    $installArgs = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $installer,
        "-AppRoot", $AppRoot,
        "-ToolRoot", $ToolRoot,
        "-ManifestSource", $ManifestSource,
        "-Repo", $Repo
    )
    if ($StateRoot) { $installArgs += @("-StateRoot", $StateRoot) }
    if ($NoPath) { $installArgs += "-NoPath" }
    if ($SkipInitialUpgrade) { $installArgs += "-SkipInitialUpgrade" }

    & powershell.exe @installArgs
    if ($LASTEXITCODE -ne 0) {
        throw "install-qclaw.ps1 failed with exit code $LASTEXITCODE"
    }

    Write-Host ""
    Write-Host "QClaw 0.87.1 install complete."
    Write-Host "Tool root: $ToolRoot"
    Write-Host "App root:  $AppRoot"
    if ($StateRoot) { Write-Host "State root: $StateRoot" }
    Write-Host "Verify with:"
    Write-Host ("powershell -NoProfile -ExecutionPolicy Bypass -File ""{0}"" status" -f (Join-Path $ToolRoot "qclaw.ps1"))
    Write-Host ("powershell -NoProfile -ExecutionPolicy Bypass -File ""{0}"" doctor" -f (Join-Path $ToolRoot "qclaw.ps1"))
} finally {
    if ($KeepTemp) {
        Write-Host "Kept temp root: $tempRoot"
    } elseif (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
