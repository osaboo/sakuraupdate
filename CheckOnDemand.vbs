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

Dim oSH
Dim oEX
Dim WSC_PATH
Dim Tools
Dim WorkDir
Dim DebugLvl

Sub Main()

    Dim fs
    Dim fl
    Set fs = CreateObject("Scripting.FileSystemObject")

    WSC_PATH = Plugin.GetPluginDir() & "\Tools.wsc"
    'TraceOut(WSC_PATH)
    Set Tools = GetObject("script:" & WSC_PATH)
    Set Tools.Editor = Editor
    Set Tools.Plugin = Plugin

	DebugLvl = Plugin.GetOption("サクラエディタ", "DEBUGLVL")
    Tools.DebugLvl = DebugLvl

	'Editor.ActivateWinOutput
	Dim lastcheck
	Dim checkfreq
	lastcheck = Plugin.GetOption("サクラエディタ", "LASTCHECK")
	checkfreq = Plugin.GetOption("サクラエディタ", "CHECKFREQ")
	
	lastcheck = Date
	Plugin.SetOption "サクラエディタ", "LASTCHECK", lastcheck
	
    Set oSH = CreateObject("Wscript.Shell")
    WorkDir = oSH.ExpandEnvironmentStrings("%TEMP%") & "\sakuraupdate"
'	TraceOut "更新作業用フォルダ " & WorkDir
'    If not Tools.IsExistDir(WorkDir) Then
'    	TraceOut "更新作業用フォルダを作成します"
'        Tools.CreateDir fs, workdir
'    End If

    vbCrLf = Chr(13) & Chr(10)
    vbLf = Chr(10)


	TraceOut "リリース済みバージョンを確認します。"

    Dim wurl
    Dim wlink
    Dim wcurver
    Dim wnewver
    wcurver = Editor.ExpandParameter("$V")

    Select Case Plugin.GetOption("サクラエディタ", "DOWNLOADSITE")
        Case "0" 'GitHub
        	wurl = Plugin.GetOption("サクラエディタ", "GITHUBURL")
            wnewver = GetGitHub(wurl)
        Case "1" 'SourceForge
        	wurl = Plugin.GetOption("サクラエディタ", "SFRSSURL")
            wnewver = GetSFRSS(wurl)
    End Select
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        TraceOut "最新版を確認できませんでした。"
        Exit Sub
    End If
    
    TraceOut "現在のサクラエディタのバージョン:" & wcurver
    TraceOut "最新のサクラエディタのバージョン:" & wnewver

    if wnewver <= wcurver Then
        TraceOut "このサクラエディタは最新バージョンです。"
        Exit Sub
    End If
	'Editor.ActivateWinOutput

    TraceOut "サクラエディタの新バージョンがリリースされています。更新はツール→ソフトウェアの更新から実行してください。"
    
End Sub

' Get SourceForge RSS 
function GetSFRSS(byref aurl)
    Dim rCode
    Dim Itemtitle
    Dim i
    Dim wlink
    Dim wver
    
    TraceOut "SourceForge確認中... " & aurl
    
    Dim XmlDoc 'As Object
    Set XmlDoc = CreateObject("Microsoft.XMLDOM")
    XmlDoc.async = False
    'RSSのURLからデータを取得
    'rCode = XmlDoc.Load("https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2")
	rCode = XmlDoc.Load(aurl)

    '取得確認
    If rCode = False Then
        TraceOut "読み込めませんでした。"
        getSFRSS = -1
        Exit function
    End If

    'ブログ記事のタイトルを取得
    Set Itemtitle = XmlDoc.SelectNodes("//item/link")

    wlink = ""
    'ブログ記事4つ出力
    For i = 0 To Itemtitle.Length - 1
        wlink = Itemtitle(i).Text
        If InStr(wlink, ".zip") > 0 Then
            'Editor.TraceOut(wlink)
            aurl = wlink
            Exit For
        End If
    Next
    
    if wlink <> "" Then
        Dim re, match, matchs
        Set re = CreateObject("VBScript.RegExp")
        With re
            .pattern = "[0-9]\.[0-9]\.[0-9]\.[0-9]"
            .Global = True
            Set matchs = .Execute(wlink)
            'Debug.Print matchs.Count
            For Each match In matchs
                'Debug.Print match.Value
                wver = match.Value
            Next
    End With

    End If

    GetSFRSS = wver

End function

' Get GitHub Release API 
function GetGitHub(byref aurl)
    Dim req
    Dim wjson
    Dim wlink
    Dim wver
    Dim wpage
    Dim mesg
    Dim i, j

	TraceOut "GitHub確認中.. " & aurl

    Set req = Nothing '初期化
    Set req = Tools.CreateHttpRequest()
    If req Is Nothing Then Exit function
    req.Open "GET", aurl, False
  
    'XMLHTTPRequestを考慮してキャッシュ対策
    'http://vird2002.s8.xrea.com/javascript/XMLHttpRequest.html#XMLHttpRequest_Cache-Control
    'http://www.atmarkit.co.jp/ait/articles/0305/10/news002.html 参考
    req.setRequestHeader "Pragma", "no-cache"
    req.setRequestHeader "Cache-Control", "no-cache"
    req.setRequestHeader "If-Modified-Since", "Thu, 01 Jun 1970 00:00:00 GMT"

'https://support.microsoft.com/en-us/help/3140245/update-to-enable-tls-1-1-and-tls-1-2-as-a-default-secure-protocols-in
'    If (A_OSVersion = "WIN_7") {
'        Win7FixPatch_URL = http://download.microsoft.com/download/0/6/5/0658B1A7-6D2E-474F-BC2C-D69E5B9E9A68/MicrosoftEasyFix51044.msi
'        Log("MicrosoftEasyFix51044をダウンロード"
'        Download(Win7FixPatch_URL, "actor_download\" . "MicrosoftEasyFix51044.msi")
'        Log("MicrosoftEasyFix51044をインストール")
'        RunWait, actor_download\MicrosoftEasyFix51044.exe /passive /promptrestart
'    }
'    
    req.Send
    If req.Status <> 200 Then
        If DebugLvl > 1 Then TraceOut "Status Error: " & req.Status
        Exit Function
    End If
      
    'set wjson = Tools.ParseJson(req.responseText)
    'wlink = wjson.assets(0).browser_download_url
    wpage = req.responseText
    If DebugLvl > 1 Then TraceOut "Status : " & req.Status
    
    mesg = "browser_download_url"":"""
    i = InStr(wpage, mesg)
    If i > 0 Then
        wlink = Mid(wpage, i + Len(mesg))
        j = InStr(wlink, """")
        If j > 0 Then
            wlink = Mid(wlink, 1, j - 1)
            aurl = wlink
        Else
            wlink = ""
        End If
    End If
     
    If wlink <> "" Then
        Dim re, match, matchs
        Set re = CreateObject("VBScript.RegExp")
        With re
            .Pattern = "[0-9]\.[0-9]\.[0-9]\.[0-9]"
            .Global = True
            Set matchs = .Execute(wlink)
            'Debug.Print matchs.Count
            For Each match In matchs
                'Debug.Print match.Value
                wver = match.Value
            Next
        End With
    End If

    GetGitHub = wver

End function

Call Main()
