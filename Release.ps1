$Name = "RS2RotS-Era-Progress-Display"
$Archive = "${Name}.7z"
$Tag = "v" + (Get-Date -Format "yyyyMMdd-HHmm")

$trackedChanges = git status --porcelain | Where-Object { $_ -notmatch '^\?\?' }
if ($trackedChanges) {
  Write-Error "fatal: working tree contains uncommitted changes in tracked files. Please commit or stash them before releasing."
}

if (Test-Path $Archive) { Remove-Item -Force $Archive }
& 7z.exe a -t7z -mx7 $Archive "src"
& 7z.exe rn $Archive src $Name

gh release create $Tag $Archive --generate-notes
