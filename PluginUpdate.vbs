'   プラグインの更新処理
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub PluginUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput
    
    Tools.log vbCrLf & "★★sakuraupdate " & Tools.Version & "★★", 0
    Tools.log "sakuraupdateプラグインを最新バージョンに更新します。", 0

    'WorkDirを空にする。
    Tools.WorkCleanup(true)

    wchk = Tools.PluginCheck(2, wnewver, wurl)
    If IsNull(wchk) Then Exit Sub

    If wchk = False Then
        If Tools.WSH.Popup("すでに最新版ですが、更新しますか?", 0, "ソフトウェアの更新", 4) = 7 Then
            Exit Sub
        End If
    End If

    If Tools.PluginDownload(wurl) = False Then
        Exit Sub
    End If
    
    Call Tools.PluginSetup("plugin")

End Sub

PluginUpdate
