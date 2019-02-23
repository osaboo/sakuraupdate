Param($fileupdate)
$ps = Start-Process -PassThru -Verb runas -File $fileupdate
$ps.WaitForExit()
