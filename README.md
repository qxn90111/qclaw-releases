# GitHub Publish Instructions

1. Commit these files to the GitHub repo $Repo:
   - eleases/latest/manifest.json
   - eleases/0.86.0/manifest.json

2. Create GitHub Release $Tag and upload:
   - $zipName
   - checksums.txt
   - elease-notes.md

3. Existing installed Qclaw users only need to send this in WeChat:

   qclaw upgrade

The installed Qclaw command reads:

https://raw.githubusercontent.com/qxn90111/qclaw-releases/main/releases/latest/manifest.json

Then it downloads:

https://github.com/qxn90111/qclaw-releases/releases/download/v0.86.0/qclaw-upgrade-kit-0.86.0-c0fec3e9.zip
