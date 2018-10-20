' サクラエディタ Ctags(タグ生成)ツールの更新処理
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub CtagsUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput

    Tools.log vbCrLf & "★★sakuraupdate " & Tools.Version & "★★", 0
    Tools.log "Ctags(タグ生成)ツールを配置します。", 0
    
    wchk = Tools.CtagsCheck(2, wnewver, wurl)
    If IsNull(wchk) Then Exit Sub

    If wchk = false Then
        If Tools.WSH.Popup("すでに配置済みですが、更新しますか?", 0, "ソフトウェアの更新", 4) = 7 Then
            Exit Sub
        End If
    End If
    
    If Tools.CtagsDownload(wurl) = False Then
        Exit Sub
    End If

    Call Tools.FileSetup(Array("","ctags.exe"))

End Sub

CtagsUpdate
