Option Explicit

'	サクラエディタ本体の更新チェック(オンデマンド)
'
'	現バージョンを取得
'	最新バージョンをインターネットから取得
'	更新されている場合、メッセージを表示し、更新する場合は更新する。
'	更新されていない場合は、終了
'	チェックはエディタ起動3分後に実施

Dim vbCrLf '= Chr(13) & Chr(10)
Dim vbLf '= Chr(10)

vbCrLf = Chr(13) & Chr(10)
vbLf = Chr(10)

Dim Tools

Sub Main()

    Dim WSC_PATH

    WSC_PATH = Plugin.GetPluginDir() & "\Tools.wsc"
    Set Tools = GetObject("script:" & WSC_PATH)
    Set Tools.Editor = Editor
    Set Tools.Plugin = Plugin
    Tools.Init

	Editor.ActivateWinOutput

	Dim lastcheck
	Dim checkfreq
	lastcheck = Plugin.GetOption("サクラエディタ", "LASTCHECK")
	checkfreq = Plugin.GetOption("サクラエディタ", "CHECKFREQ")
	
	lastcheck = Date
	Plugin.SetOption "サクラエディタ", "LASTCHECK", lastcheck
	
    Tools.log "サクラエディタ本体の最新バージョンを確認します。", 0

    Dim wurl
    Dim wlink
    Dim wcurver
    Dim wnewver
    wcurver = Editor.ExpandParameter("$V")
    
    Select Case Plugin.GetOption("サクラエディタ", "SITEPRIORITY")
    Case "0"
        wurl = Plugin.GetOption("サクラエディタ", "GITHUBURL")
    Case "1"
        wurl = Plugin.GetOption("サクラエディタ", "SFRSSURL")
    Case "2"
        wurl = Plugin.GetOption("サクラエディタ", "CUSTOMURL")
    End Select

	If Instr(wurl,"sourceforge.net")>0 then
        wnewver = Tools.GetSFRSS(wurl, "sakura2")
	ElseIf Instr(wurl,"github.com")>0 then
        wnewver = Tools.GetGitHub(wurl)
    End If

    If wnewver = "" then
        TraceOut "最新版を確認できませんでした。"
        Exit Sub
    End If
    
    Tools.log "現在のサクラエディタのバージョン:" & wcurver, 0
    Tools.log "最新のサクラエディタのバージョン:" & wnewver, 0

    if wnewver <= wcurver Then
        Tools.log "このサクラエディタは最新バージョンです。", 0
        Exit Sub
    End If
	'Editor.ActivateWinOutput

    Tools.log "サクラエディタの新バージョンがリリースされています。更新はツール→ソフトウェアの更新から実行してください。", 0
    
End Sub

Call Main()
