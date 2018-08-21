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

	TraceOut "ヘルプファイルを最新バージョンに更新します。"

    Dim wos, wosver, wosbit
    Tools.GetOSInfo wos, wosver, wosbit
    Tools.log "wos=" & wos, 2
    Tools.log "wosver=" & wosver, 2
    Tools.log "wosbit=" & wosbit, 2

    Dim wurl
    Dim wlink
    Dim wsakurapath
    Dim whelppath
    Dim wcurdate
    Dim wsakuraver
    Dim wnewver
    Dim wnewdate
    
    wsakurapath = Editor.ExpandParameter("$S")
    whelppath = Tools.FS.GetParentFolderName(wsakurapath) & "\sakura.chm"
    wcurdate = DateValue(Tools.FS.GetFile(whelppath).DateLastModified)

    wsakuraver = Editor.ExpandParameter("$V")
	wurl = Plugin.GetOption("サクラエディタ", "HELPURL")

	If Instr(wurl,"sourceforge.net")>0 then
        wnewver = GetSFRSS(wurl, "", wnewdate)
    ElseIf wurl = "" Then '指定なしの場合は、SourceForgeから検索
    	wurl = Plugin.GetOption("サクラエディタ", "SFRSSURL")
        wnewver = GetSFRSS(wurl, "help2", wnewdate)
    End If
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        TraceOut "リリースされたヘルプファイルを確認できませんでした。"
        Exit Sub
    End If
    
    TraceOut "現在のサクラエディタのバージョン:" & wsakuraver
    TraceOut "現在のヘルプファイル更新日付:" & wcurdate
    TraceOut "最新のヘルプファイルバージョン:" & wnewver
    TraceOut "最新のヘルプファイル発行日付:" & wnewdate

    if wnewdate <= wcurdate Then
        If Tools.WSH.Popup("すでに最新版ですが、更新しますか?", 0, "ソフトウェアの更新", 4) = 7 Then
	        Exit Sub
	    End if
    End If

    
    ' ヘルプファイルのzipダウンロード
    Dim wcmd
    Dim wzipfile
    
    wzipfile = Tools.WorkDir & "help.zip"
    
	If Instr(wurl,"sourceforge.net")>0 then
	    wlink = wurl
    End If
    
    Tools.log "ヘルプファイルをダウンロードします.. " & wlink, 0

    'wcmd = "bitsadmin.exe /TRANSFER sakura2 " & wurl & " " & wzipfile
    wcmd = Tools.CurlExe & " -L """ & wlink & """ -o " & wzipfile
    Tools.log ">" & wcmd, 1
    'Tools.DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, True '

	If Not Tools.IsExistFile(wzipfile) then
	    Tools.log "ダウンロードできませんでした。", 0
		Exit Sub
	End If
	
	TraceOut "ダウンロードファイルを展開します。"

    'zip展開
    wcmd = Tools.UnzipExe & " e -aoa " & wzipfile & " sakura.chm -o" & Tools.WorkDir
    Tools.log ">" & wcmd, 1
    Tools.WSH.Run wcmd, 7, False

	Sleep 500

	If Not Tools.IsExistFile(Tools.WorkDir & "\sakura.chm") then
	    TraceOut "sakura.chmがダウンロードファイルにありませんでした。"
		Exit Sub
	End If

	TraceOut "sakura.chmを更新します。"
	If Tools.WSH.Popup("sakura.chmを更新します。",0,"ソフトウェアの更新",1) = 2 Then
        Exit sub
    End If
	
    ' exe上書き処理
    '    更新スクリプトを作成し、他プロセスで実行
    '    実行後サクラエディタを終了する。
    '    スクリプトは、サクラエディタ上書きが出来るまで待機する。
    '    program files\sakuraの場合はセキュリティ警告がでる。
    Dim wcmdfile
    Dim wcmdparam
    Dim programfiles
    programfiles = "C:\Program Files"
    
    wcmd     = "set srcfolder=" & Tools.WorkDir & vbCrLf & _
	           "set targetfolder=" & Tools.SakuraDir & vbCrLf & _
	           "set targetfile=sakura.chm" & vbCrLf

	If (left(wosver,2) = "6." or left(wosver,3) = "10.") and left(Tools.SakuraDir, Len(programfiles)) = programfiles Then
        wcmd = wcmd & "set _runas=-Verb runas"
    End If
    
    wcmdfile = Tools.WorkDir & "\_setenv.bat"
	Tools.SaveText wcmd, wcmdfile, "Shift_JIS"

    wcmd = """" & Tools.PluginDir & "\mainupdate.bat"""

    Tools.log ">" & wcmd, 1
    'Tools.DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, False

    'Editor.ExitAll

End Sub

' Get SourceForge RSS 
function GetSFRSS(byref aurl, apath, byref aupdate)
    Dim rCode
    Dim items
    Dim ItemLink
    Dim ItemDate
    Dim i, j
    Dim wlink
    Dim wver
    Dim wcmd
    Dim wtmpfile
    
    wlink = aurl
    If apath<>"" then wlink = aurl & "?path=/" & apath
    
    Tools.log "SourceForge確認中... " & wlink, 0
    
    wtmpfile = Tools.WorkDir & "\_temp.htm"
    wcmd = Tools.CurlExe & " -L """ & wlink & """ -o " & wtmpfile
    Tools.log ">" & wcmd, 1
    'DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, True '
    
    Dim XmlDoc 'As Object
    Set XmlDoc = CreateObject("Microsoft.XMLDOM")
    XmlDoc.async = False
    'RSSのURLからデータを取得
    'rCode = XmlDoc.Load("https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2")
	'rCode = XmlDoc.Load(aurl)
    rCode = XmlDoc.Load(wtmpfile)

    '取得確認
    If (XmlDoc.parseError.ErrorCode <> 0) Then 'ロード失敗
        Tools.log "読み込めませんでした。", 0
        Tools.log XmlDoc.parseError.reason, 0   'エラー内容を出力
        GetSFRSS = -1
        Exit Function
    End If

    'item取得
    Set items = XmlDoc.SelectNodes("//item")

    Dim re, match, matchs
    Set re = CreateObject("VBScript.RegExp")
    re.pattern = "([0-9]\.[0-9]\.[0-9]\.[0-9])/sakura_help[0-9\-]+\.zip"

    wlink = ""
    'ブログ記事4つ出力
    For i = 0 To items.Length - 1
        set ItemLink = items(i).SelectNodes("./link")
        set ItemDate = items(i).SelectNodes("./pubDate")
        wlink = ItemLink(0).Text
        'If re.Test(wlink) Then
        Set matchs = re.Execute(wlink)
        If matchs.Count > 0 Then
            Editor.TraceOut "見つかったファイル:" & wlink 
            aurl = wlink
            
            Tools.log "pubDate: " & ItemDate(0).Text , 2
            aupdate = ItemDate(0).Text
            aupdate = replace(aupdate, " UT","")
            j = instr(aupdate, ",")
            if j > 0 then aupdate =mid(aupdate, j+1)
            If IsDate(aupdate) then aupdate = DateValue(aupdate)
            Tools.log "aupdate: " & aupdate , 2
            
            If matchs(0).SubMatches.Count > 0 Then
                wver = matchs(0).SubMatches(0)
                'if wver = atargetver then
                'End If
            End If
            Exit For
        End If
        wlink = ""
    Next
    
    GetSFRSS = wver

End function



Call Main()
