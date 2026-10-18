$ErrorActionPreference = "Stop"

$SrcDir = "src"
$DistDir = "dist"
$Archive = "dist\RS2RotS-Era-Progress-Display.7z"
$Tag = "v" + (Get-Date -Format "yyyyMMdd")

if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
New-Item -ItemType Directory -Force -Path $DistDir | Out-Null

if (Test-Path $Archive) { Remove-Item -Force $Archive }
& 7z.exe a -t7z -mx7 $Archive ".\$SrcDir\*"

gh release create $Tag $Archive --generate-notes
