Option Explicit

'	サクラエディタ本体の更新チェック
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
    Dim fs
    Dim fl
    Set fs = CreateObject("Scripting.FileSystemObject")

    WSC_PATH = Plugin.GetPluginDir() & "\Tools.wsc"
    Set Tools = GetObject("script:" & WSC_PATH)
    Set Tools.Editor = Editor
    Set Tools.Plugin = Plugin
    Tools.Init

	'Editor.ActivateWinOutput
	Dim lastcheck
	Dim checkfreq
	lastcheck = Plugin.GetOption("サクラエディタ", "LASTCHECK")
	checkfreq = Plugin.GetOption("サクラエディタ", "CHECKFREQ")
	
	if not isnumeric(checkfreq) Then
		Exit Sub
	End If
	
	if isdate(lastcheck) Then
		If DateAdd("d", checkfreq, lastcheck) > Date Then
			exit Sub
		End If
	end if
	lastcheck = Date
	Plugin.SetOption "サクラエディタ", "LASTCHECK", lastcheck
	
    Tools.log "リリース済みバージョンを確認します。", 0

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
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        Tools.log "最新版を確認できませんでした。", 0
        Exit Sub
    End If
    
    Tools.log "現在のサクラエディタのバージョン:" & wcurver, 0
    Tools.log "最新のサクラエディタのバージョン:" & wnewver, 0

    if wnewver <= wcurver Then
        Exit Sub
    End If
	'Editor.ActivateWinOutput

    MessageBox("サクラエディタの新バージョンがリリースされています。更新はツール→ソフトウェアの更新から実行してください。")
    
End Sub

Call Main()
