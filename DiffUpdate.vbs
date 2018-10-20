' サクラエディタ Diff(差分)ツールの更新処理
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub DiffUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput

    Tools.log vbCrLf & "★★sakuraupdate " & Tools.Version & "★★", 0
    Tools.log "Diff(差分)ツールを配置します。", 0
    
    wchk = Tools.DiffCheck(2, wnewver, wurl)
    If IsNull(wchk) Then Exit Sub

    If wchk = False Then
        If Tools.WSH.Popup("すでに配置済みですが、更新しますか?", 0, "ソフトウェアの更新", 4) = 7 Then
            Exit Sub
        End If
    End If
    
    If Tools.DiffDownload(wurl) = False Then
        Exit Sub
    End If

    Call Tools.FileSetup(Array("","diff.exe"))

End Sub

DiffUpdate
