' サクラエディタ ヘルプファイルの更新処理
'
' サクラエディタのバージョンと同じバージョンのヘルプファイルを探す
' すでにあるヘルプファイルのバージョンを取得するには？
'   タイムスタンプで判断。テーブル作っておく
' URLとバージョンの関係を収集
'   すべてのヘルプファイルをダウンロードして、展開しタイムスタンプとバージョンのリストを作る。
'   リストはdefファイルに保管する。(JSON形式?)
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub HelpUpdate
    Editor.ActivateWinOutput

    Tools.log vbCrLf & "★★sakuraupdate " & Tools.Version & "★★", 0
    Tools.log "ヘルプファイルを最新バージョンに更新します。", 0

    Dim wtargets
    wtargets = Array("")

    If HelpCheck("sakura.chm") Then
        redim preserve wtargets(ubound(wtargets)+1)
        wtargets(ubound(wtargets)) = "sakura.chm"
    End If
    If HelpCheck("macro.chm") Then
        redim preserve wtargets(ubound(wtargets)+1)
        wtargets(ubound(wtargets)) = "macro.chm"
    End If
    If HelpCheck("plugin.chm") Then
        redim preserve wtargets(ubound(wtargets)+1)
        wtargets(ubound(wtargets)) = "plugin.chm"
    End If

    if ubound(wtargets) > 0 Then
        Call Tools.FileSetup(wtargets)
    End If

End Sub

Function HelpCheck(atarget)
    Dim wchk
    Dim wurl
    Dim wnewver

    HelpCheck = false

    wchk = Tools.HelpCheck(2, atarget, wnewver, wurl)
    If IsNull(wchk) Then Exit Function

    If wchk = False Then
        If Tools.WSH.Popup("すでに最新版ですが、更新しますか?", 0, "ソフトウェアの更新", 4) = 7 Then
            Exit Function
        End If
    End If

    If Tools.HelpDownload(atarget, wurl) = False Then
        Exit Function
    End If

    HelpCheck = true

End Function

HelpUpdate
