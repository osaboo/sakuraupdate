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
Dim CurlExe
Dim UnzipExe
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

	CurlExe = """" & Plugin.GetPluginDir() & "\Curl.exe"""
	'UnzipExe = """" & Plugin.GetPluginDir() & "\Unzip.exe"""
	UnzipExe = """" & Plugin.GetPluginDir() & "\7za.exe"""
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

    Select Case Plugin.GetOption("サクラエディタ", "SITEPRIORITY")
    Case 0
        wurl = Plugin.GetOption("サクラエディタ", "GITHUBURL")
    Case 1
        wurl = Plugin.GetOption("サクラエディタ", "SFRSSURL")
    Case 2
        wurl = Plugin.GetOption("サクラエディタ", "CUSTOMURL")
    End Select

	If Instr(wurl,"sourceforge.net")>0 then
        wnewver = GetSFRSS(wurl, "sakura2")
	ElseIf Instr(wurl,"github.com")>0 then
        wnewver = GetGitHub(wurl)
    End If

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
function GetSFRSS(byref aurl, apath)
    Dim rCode
    Dim Itemtitle
    Dim i
    Dim wlink
    Dim wver
    Dim wcmd
    Dim wtmpfile

    wlink = aurl & "?path=/" & apath
    TraceOut "SourceForge確認中... " & wlink

    wtmpfile = WorkDir & "\_temp.htm"
    wcmd = CurlExe & " -L """ & wlink & """ -o " & wtmpfile
    If DebugLvl > 0 Then TraceOut ">" & wcmd
    'Tools.DoCmd wcmd, ""
    oSH.Run wcmd, 7, True '

    Dim XmlDoc 'As Object
    Set XmlDoc = CreateObject("Microsoft.XMLDOM")
    XmlDoc.async = False
    'RSSのURLからデータを取得
    'rCode = XmlDoc.Load("https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2")
	'rCode = XmlDoc.Load(aurl & "?path=/" & apath)
    rCode = XmlDoc.Load(wtmpfile)

    '取得確認
    'If rCode = False Then
        If (XmlDoc.parseError.ErrorCode <> 0) Then 'ロード失敗
            TraceOut "読み込めませんでした。"
            TraceOut XmlDoc.parseError.reason   'エラー内容を出力
            getSFRSS = -1
            Exit function
        End If
    'End If

    'ブログ記事のタイトルを取得
    Set Itemtitle = XmlDoc.SelectNodes("//item/link")

    wlink = ""
    'ブログ記事4つ出力
    For i = 0 To Itemtitle.Length - 1
        wlink = Itemtitle(i).Text
        If Instr(wlink, "sakura2-") > 0 And InStr(wlink, ".zip") > 0 Then
            'Editor.TraceOut(wlink)
            aurl = wlink
            Editor.TraceOut "見つかったファイル:" & wlink 
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
if false Then
'================== http://madia.world.coocan.jp/cgi-bin/VBBBS/wwwlng.cgi?print+200801/08010037.txt
Const WinHttpRequestOption_SslErrorIgnoreFlags = &H4& 
Const SslErrorFlag_UnknownCA = &H100& 

'SSLエラーを無視するかどうかを決めるフラグ。 
'初期値は0(エラーを無視しない)。 
Dim flag 'As Long 
flag = req.Option(WinHttpRequestOption_SslErrorIgnoreFlags) 

'「信頼されていないCA(認証局)」のSSLエラーを無視する。 
req.Option(WinHttpRequestOption_SslErrorIgnoreFlags) = flag Or SslErrorFlag_UnknownCA 
end if

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
                Editor.TraceOut "見つかったファイル:" & wlink
            Next
        End With
    End If

    GetGitHub = wver

End function

Call Main()
