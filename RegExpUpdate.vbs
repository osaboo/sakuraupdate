' サクラエディタ 正規表現ライブラリの更新処理
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub RegExpUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput

    Tools.log vbCrLf & "★★sakuraupdate " & Tools.Version & "★★", 0
    Tools.log "正規表現ライブラリを最新バージョンに更新します。", 0
    
    'WorkDirを空にする。
    Tools.WorkCleanup(true)

    wchk = Tools.RegExpCheck(2, wnewver, wurl) 
    If IsNull(wchk) Then Exit Sub

    If wchk = False Then
        If Tools.WSH.Popup("すでに最新版ですが、更新しますか?", 0, "ソフトウェアの更新", 4) = 7 Then
            Exit Sub
        End If
    End If

    If Tools.RegExpDownload(wurl) = False Then
        Exit Sub
    End If

    Call Tools.FileSetup(Array("","bregonig.dll"))

End Sub

RegExpUpdate