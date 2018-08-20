Param($srcfolder, $targetfolder, $targetfile)

$srcfile = $srcfolder + "/" + $targetfile
$newfile = $targetfolder + "/" + $targetfile
$oldfile = $targetfolder + "/" + $targetfile + ".old"

echo sleep 3sec.
start-sleep 3

Write-Host "pause..."
[Console]::ReadKey($true) | Out-Null

echo ("srcfile = " + $srcfile)
echo ("newfile = " + $newfile)
echo ("oldfile = " + $oldfile)

if ($targetfile -eq "sakura.exe") {
    echo タスク'sakura.exe'の終了
    Stop-Process -Name "sakura"
    # Wait-Process -Name "sakura.exe"
}

# 古いファイルの削除
# Remove-Item $oldfile
# リネーム
echo Move-Item $newfile $oldfile -Force
Move-Item $newfile $oldfile -Force
# コピー
echo Copy-Item $srcfile $newfile
Copy-Item $srcfile $newfile

Write-Host "pause..."
[Console]::ReadKey($true) | Out-Null
