' サクラエディタ本体の更新処理
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub SakuraUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput
    
    Tools.log vbCrLf & "★★sakuraupdate " & Tools.Version & "★★", 0
    Tools.log "サクラエディタ本体を最新バージョンに更新します。", 0

    'WorkDirを空にする。
    Tools.WorkCleanup(true)

    wchk = Tools.SakuraCheck(2, wnewver, wurl)
    If IsNull(wchk) Then Exit Sub

    If wchk = False Then
        If Tools.WSH.Popup("すでに最新版ですが、更新しますか?", 0, "ソフトウェアの更新", 4) = 7 Then
            Exit Sub
        End If
    ElseIf wchk > 0 Then
        If Tools.WSH.Popup("新しいプレリリース版(" & wnewver & ")があります。更新しますか?", 0, "ソフトウェアの更新", 4) = 7 Then
            Exit Sub
        End If
    End If
    
    If Tools.SakuraDownload(wurl) = False Then
        Exit Sub
    End If

    If Tools.FS.FileExists(Tools.WorkDir & "\sakura.chm") Then
        Call Tools.FileSetup(Array("","sakura.exe","sakura.chm"))
    Else
        Call Tools.FileSetup(Array("","sakura.exe"))
    End If

End Sub

SakuraUpdate
