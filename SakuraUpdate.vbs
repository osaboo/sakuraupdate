' �T�N���G�f�B�^�{�̂̍X�V����
'
Option Explicit

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
    Set Tools = GetObject("script:" & WSC_PATH)
    Set Tools.Editor = Editor
    Set Tools.Plugin = Plugin

	DebugLvl = Plugin.GetOption("�T�N���G�f�B�^", "DEBUGLVL")
    Tools.DebugLvl = DebugLvl

	CurlExe = """" & Plugin.GetPluginDir() & "\Curl.exe"""
	'UnzipExe = """" & Plugin.GetPluginDir() & "\Unzip.exe"""
	UnzipExe = """" & Plugin.GetPluginDir() & "\7za.exe"""
	'Editor.ActivateWinOutput
	
    Set oSH = CreateObject("Wscript.Shell")
    WorkDir = oSH.ExpandEnvironmentStrings("%TEMP%") & "\sakuraupdate"
	If DebugLvl > 1 Then TraceOut "�X�V��Ɨp�t�H���_ " & WorkDir
    If not Tools.IsExistDir(WorkDir) Then
    	If DebugLvl > 1 Then TraceOut "�X�V��Ɨp�t�H���_���쐬���܂�"
        Tools.CreateDir fs, workdir
    End If

    vbCrLf = Chr(13) & Chr(10)
    vbLf = Chr(10)

	TraceOut "�����[�X�ς݃o�[�W�������m�F���܂��B"

    Dim wurl
    Dim wlink
    Dim wcurver
    Dim wnewver
    wcurver = Editor.ExpandParameter("$V")
	wurl = Plugin.GetOption("�T�N���G�f�B�^", "SAKURAURL")

	If Instr(wurl,"sourceforge.net")>0 then
        wnewver = GetSFRSS(wurl, "sakura2")
	ElseIf Instr(wurl,"github.com")>0 then
        wnewver = GetGitHub(wurl)
    End If
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        TraceOut "�ŐV�ł��m�F�ł��܂���ł����B"
        Exit Sub
    End If
    
    TraceOut "���݂̃T�N���G�f�B�^�̃o�[�W����:" & wcurver
    TraceOut "�ŐV�̃T�N���G�f�B�^�̃o�[�W����:" & wnewver

    if wnewver <= wcurver Then
        If  MessageBox("���łɍŐV�łł����A�X�V���܂���?",4) = 7 then 
	        Exit Sub
	    End if
    End If
	Editor.ActivateWinOutput

    'Dim TS
    
    'Set TS = FS.OpenTextFile(wfile, 8, True)  '�ǋL�I�[�v���B�t�@�C���������ꍇ�͍쐬
    'If Err.Number <> 0 Then
        'stderr.WriteLine "[logopen] open error " & wfile & ":" & Err.Description
    
    'Set TS = Nothing
    
    ' �T�N���G�f�B�^��zip�_�E�����[�h
    Dim wcmd
    Dim wzipfile
    
    wzipfile = WorkDir & "\sakura.zip"
    
	If Instr(wurl,"sourceforge.net")>0 then
	    wlink = wurl
        'If DebugLvl > 0 Then TraceOut "�_�E�����[�h�����N���m�F���܂��B"
        'wlink = GetSFLink(wurl)
        'if wlink = "" then
        '    If DebugLvl > 0 Then TraceOut "�_�E�����[�h�����N���擾�ł��܂���ł����B"
        '    exit sub
        'End If
	ElseIf Instr(wurl,"github.com")>0 then
        wlink = wurl
    End If
    
    'wcmd = "bitsadmin.exe /TRANSFER sakura2 " & wurl & " " & wzipfile
    wcmd = CurlExe & " -L """ & wlink & """ -o " & wzipfile
    If DebugLvl > 0 Then TraceOut ">" & wcmd
    'Tools.DoCmd wcmd, ""
    oSH.Run wcmd, 7, True '

if false then
    wlink = GetRedirectUrl(wlink)
    Call DownloadFile(wlink, wzipfile)
end if

	If Not Tools.IsExistFile(wzipfile) then
	    TraceOut "�_�E�����[�h�ł��܂���ł����B"
		Exit Sub
	End If
	
	TraceOut "�_�E�����[�h�t�@�C����W�J���܂��B"
    Dim SH 'As Object
    Set SH = CreateObject("Shell.Application")
    
    'zip�W�J
    'wcmd = UnzipExe & " -o -j " & wzipfile & " */sakura.exe -d " & WorkDir
    wcmd = UnzipExe & " e -aoa " & wzipfile & " */sakura.exe -o" & WorkDir
    If DebugLvl > 0 Then TraceOut ">" & wcmd
    'Tools.DoCmd wcmd, ""
    oSH.Run wcmd, 7, False

If false Then
    'SH.Namespace("c:\temp\sakura2").CopyHere SH.Namespace("c:\temp\sakura2.zip").Items
    Dim zipitem 'as  FolderItem2
    Dim zipitem2
    'https://docs.microsoft.com/en-us/windows/desktop/shell/folderitem
    'https://docs.microsoft.com/en-us/windows/desktop/shell/folderitems2-object
    'ExtendedProperty
    
    ' sakura.exe��zip�W�J
    If fs.FileExists(WorkDir & "\sakura.exe") Then
        fs.DeleteFile (WorkDir & "\sakura.exe")
    End If
    For Each zipitem In SH.Namespace(wzipfile).items
        'Editor.TraceOut(TypeName(zipitem))
        'Editor.TraceOut(zipitem.Name)
        If zipitem.IsFolder Then
            For Each zipitem2 In zipitem.GetFolder.items
                If DebugLvl > 1 Then TraceOut zipitem2.Path
                If zipitem2.Name = "sakura.exe" Then
                    SH.Namespace(WorkDir).CopyHere zipitem2
                End If
            Next
        Else
            If DebugLvl > 1 Then TraceOut zipitem.Path
            If zipitem.Name = "sakura.exe" Then
                SH.Namespace(WorkDir).CopyHere zipitem
            End If
        End If
    Next
End If

	If Not Tools.IsExistFile(WorkDir & "\sakura.exe") then
	    TraceOut "sakura.exe���_�E�����[�h�t�@�C���ɂ���܂���ł����B"
		Exit Sub
	End If

	TraceOut "sakura.exe���X�V���܂��B"
	TraceOut "�������񂷂ׂĂ�sakura.exe�������I�����Ă���㏑�����܂��B"
	Sleep 3000
	
    ' exe�㏑������
    '    �X�V�X�N���v�g���쐬���A���v���Z�X�Ŏ��s
    '    ���s��T�N���G�f�B�^���I������B
    '    �X�N���v�g�́A�T�N���G�f�B�^�㏑�����o����܂őҋ@����B
    '    program files\sakura�̏ꍇ�̓Z�L�����e�B�x�����ł�B
    Dim wcmdfile
    Dim sakuraexe
    Dim sakuraold
    
    sakuraexe = Editor.ExpandParameter("$S")
    sakuraold = sakuraexe & ".old"
    
    wcmd = "title SakuraUpdate"
    wcmd = wcmd & vbCrLf & "timeout /t 3"
    wcmd = wcmd & vbCrLf & ":L1"
    wcmd = wcmd & vbCrLf & "taskkill /im sakura.exe"
    wcmd = wcmd & vbCrLf & "timeout /t 3"
    wcmd = wcmd & vbCrLf & "del """ & sakuraold & """"
    wcmd = wcmd & vbCrLf & "ren """ & sakuraexe & """ sakura.exe.old"
    wcmd = wcmd & vbCrLf & "if exist """ & sakuraexe & """ goto :L1"
    wcmd = wcmd & vbCrLf & "copy /y """ & WorkDir & "\sakura.exe"" """ & sakuraexe & """"
    'wcmd = wcmd & vbCrLf & """C:\Program Files (x86)\sakura\sakura.exe"""
    'wcmd = wcmd & vbCrLf & "start """" """ & sakuraexe & """"
    wcmd = wcmd & vbCrLf & "timeout /t 3"
    
    wcmdfile = WorkDir & "\sakura_update.bat"

    If DebugLvl > 1 Then Editor.TraceOut "save " & wcmdfile
    Dim TS
    Set TS = fs.CreateTextFile(wcmdfile, True, False)
    'If Err.Number <> 0 Then
        'stderr.WriteLine "[logopen] open error " & wfile & ":" & Err.Description
    TS.write wcmd
    TS.Close
    Set TS = Nothing
    
    wcmd = "powershell -NoProfile -ExecutionPolicy unrestricted -Command ""Start-Process " & wcmdfile & " -Verb runas""" ' -Wait
    'Tools.DoCmd wcmd, ""
    oSH.Run wcmd, 7, False

    Editor.ExitAll

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
    TraceOut "SourceForge�m�F��... " & wlink

    wtmpfile = WorkDir & "\_temp.htm"
    wcmd = CurlExe & " -L """ & wlink & """ -o " & wtmpfile
    If DebugLvl > 0 Then TraceOut ">" & wcmd
    'Tools.DoCmd wcmd, ""
    oSH.Run wcmd, 7, True '

    Dim XmlDoc 'As Object
    Set XmlDoc = CreateObject("Microsoft.XMLDOM")
    XmlDoc.async = False
    'RSS��URL����f�[�^���擾
    'rCode = XmlDoc.Load("https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2")
	'rCode = XmlDoc.Load(aurl & "?path=/" & apath)
    rCode = XmlDoc.Load(wtmpfile)

    '�擾�m�F
    'If rCode = False Then
        If (XmlDoc.parseError.ErrorCode <> 0) Then '���[�h���s
            TraceOut "�ǂݍ��߂܂���ł����B"
            TraceOut XmlDoc.parseError.reason   '�G���[���e���o��
            getSFRSS = -1
            Exit function
        End If
    'End If

    '�u���O�L���̃^�C�g�����擾
    Set Itemtitle = XmlDoc.SelectNodes("//item/link")

    wlink = ""
    '�u���O�L��4�o��
    For i = 0 To Itemtitle.Length - 1
        wlink = Itemtitle(i).Text
        If Instr(wlink, "sakura2-") > 0 And InStr(wlink, ".zip") > 0 Then
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

	TraceOut "GitHub�m�F��.. " & aurl

    Set req = Nothing '������
    Set req = Tools.CreateHttpRequest()
    If req Is Nothing Then Exit function
    req.Open "GET", aurl, False
  
    'XMLHTTPRequest���l�����ăL���b�V���΍�
    'http://vird2002.s8.xrea.com/javascript/XMLHttpRequest.html#XMLHttpRequest_Cache-Control
    'http://www.atmarkit.co.jp/ait/articles/0305/10/news002.html �Q�l
    req.setRequestHeader "Pragma", "no-cache"
    req.setRequestHeader "Cache-Control", "no-cache"
    req.setRequestHeader "If-Modified-Since", "Thu, 01 Jun 1970 00:00:00 GMT"

'https://support.microsoft.com/en-us/help/3140245/update-to-enable-tls-1-1-and-tls-1-2-as-a-default-secure-protocols-in
'    If (A_OSVersion = "WIN_7") {
'        Win7FixPatch_URL = http://download.microsoft.com/download/0/6/5/0658B1A7-6D2E-474F-BC2C-D69E5B9E9A68/MicrosoftEasyFix51044.msi
'        Log("MicrosoftEasyFix51044���_�E�����[�h"
'        Download(Win7FixPatch_URL, "actor_download\" . "MicrosoftEasyFix51044.msi")
'        Log("MicrosoftEasyFix51044���C���X�g�[��")
'        RunWait, actor_download\MicrosoftEasyFix51044.exe /passive /promptrestart
'    }
'    
if false Then
'================== http://madia.world.coocan.jp/cgi-bin/VBBBS/wwwlng.cgi?print+200801/08010037.txt
Const WinHttpRequestOption_SslErrorIgnoreFlags = &H4& 
Const SslErrorFlag_UnknownCA = &H100& 

'SSL�G���[�𖳎����邩�ǂ��������߂�t���O�B 
'�����l��0(�G���[�𖳎����Ȃ�)�B 
Dim flag 'As Long 
flag = req.Option(WinHttpRequestOption_SslErrorIgnoreFlags) 

'�u�M������Ă��Ȃ�CA(�F�؋�)�v��SSL�G���[�𖳎�����B 
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
            Next
        End With
    End If

    GetGitHub = wver

End function

' @see https://www.ka-net.org/blog/?p=4855#HttpRequest
Private Sub DownloadFile(ByVal Url , ByVal SaveFilePath )
'WinHttpRequest/XMLHTTPRequest + ADODB.Stream�Ńt�@�C�����_�E�����[�h
  Dim req 'As Object
  Const adTypeBinary = 1
  Const adSaveCreateOverWrite = 2
  
  Set req = Nothing '������
  Set req = Tools.CreateHttpRequest() 'CreateObject("WinHttp.WinHttpRequest.5.1") '
  'Set req = CreateObject("MSXML2.XMLHTTP")
  If req Is Nothing Then Exit Sub

	TraceOut "�_�E�����[�h��... " & Url
  
  req.Open "GET", Url, False
   
  '2�FSXH_OPTION_IGNORE_SERVER_SSL_CERT_ERROR_FLAGS
  '3�FSXH_OPTION_SELECT_CLIENT_SSL_CERT
  '13056: SXH_OPTION_IGNORE_SERVER_SSL_CERT_ERROR_FLAGS
  'req.SetOption 2, 13056

  'XMLHTTPRequest���l�����ăL���b�V���΍�
  'http://vird2002.s8.xrea.com/javascript/XMLHttpRequest.html#XMLHttpRequest_Cache-Control
  'http://www.atmarkit.co.jp/ait/articles/0305/10/news002.html �Q�l
  req.setRequestHeader "Pragma", "no-cache"
  req.setRequestHeader "Cache-Control", "no-cache"
  req.setRequestHeader "If-Modified-Since", "Thu, 01 Jun 1970 00:00:00 GMT"
   
  req.Send
  Select Case req.Status
    Case 200
      With CreateObject("ADODB.Stream")
        .Type = adTypeBinary
        .Open
        .Write req.responseBody
        .SaveToFile SaveFilePath, adSaveCreateOverWrite
        .Close
      End With
    Case Else
      MsgBox "�G���[���������܂����B" & vbCrLf & _
             "�X�e�[�^�X�R�[�h�F" & req.Status, _
             vbCritical + vbSystemModal
      Exit Sub
  End Select
End Sub

'<noscript>
'    <meta http-equiv="refresh" content="5; url=https://downloads.sourceforge.net/project/sakura-editor/sakura2/2.3.2.0/sakura2-3-2-0.zip?r=&amp;ts=1533634137&amp;use_mirror=jaist">
'</noscript>

Function GetSFLink(aurl)
    Dim wtmpfile
    Dim wcmd
    
    wtmpfile = WorkDir & "\_temp2.htm"
    wcmd = CurlExe & " -L """ & aurl & """ -o " & wtmpfile
    If DebugLvl > 1 Then TraceOut ">" & wcmd
    'Tools.DoCmd wcmd, ""
    oSH.Run wcmd, 7, True '
    
If False Then
    'WinHttpRequest/XMLHTTPRequest + ADODB.Stream�Ńt�@�C�����_�E�����[�h
    Dim req 'As Object
    Const adTypeBinary = 1
    Const adSaveCreateOverWrite = 2
    
    GetSFLink = ""
    
    Set req = Nothing '������
    Set req = Tools.CreateHttpRequest()
    If req Is Nothing Then Exit Function
    'req.Option(17) = False 'WinHttpRequestOption_EnableHttp1_1
    req.Open "GET", aurl, False
     
    '.Option(WinHttpRequestOption_EnableRedirects)
    'XMLHTTPRequest���l�����ăL���b�V���΍�
    'http://vird2002.s8.xrea.com/javascript/XMLHttpRequest.html#XMLHttpRequest_Cache-Control
    'http://www.atmarkit.co.jp/ait/articles/0305/10/news002.html �Q�l
    req.setRequestHeader "Pragma", "no-cache"
    req.setRequestHeader "Cache-Control", "no-cache"
    req.setRequestHeader "If-Modified-Since", "Thu, 01 Jun 1970 00:00:00 GMT"
    
    req.send
End If
    
    Dim i
    Dim j
    Dim wpage
    Dim ohtml
    Dim welems
    Dim wattr
    Dim wnode
    Dim wnode1
    Dim wnode2
    Dim mesg
    Dim wlink
    Dim witem
    
'    If req.Status <> 200 Then
'      Exit Function
'    End If
    
    'wpage = req.responseText
    Dim fs, ts
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set ts = fs.OpenTextFile(wtmpfile)
    wpage = ts.ReadAll
    
    mesg = "<meta http-equiv=""refresh"" content="""
    i = InStr(wpage, mesg)
    If i > 0 Then
        wlink = Mid(wpage, i + Len(mesg))
        i = InStr(wlink, "url=")
        j = InStr(wlink, """")
        If i > 0 And j > 0 Then
            wlink = Mid(wlink, i + 4, j - i - 4)
            wlink = Replace(wlink, "&amp;", "&")
        Else
            wlink = ""
        End If
    End If
    
    GetSFLink = wlink
    Exit Function
    
    
    Set ohtml = CreateObject("htmlfile") '= MSHTML.HTMLDocument
    ohtml.Write wpage
    
    
    mesg = ""
    wlink = ""
    
    Set welems = ohtml.getElementsByTagName("meta")

    For Each wnode In welems
      wattr = wnode.getAttribute("http-equiv")
      'Debug.Print wnode.Name
      'Debug.Print (wattr)
      'Debug.Print wnode.httpEquiv
      If wattr = "refresh" Or wnode.httpEquiv = "refresh" Then
        mesg = wnode.getAttribute("content")
        If InStr(mesg, "url=") > 0 Then
            wlink = Mid(mesg, InStr(mesg, "url=") + 4)
            wlink = Left(wlink, InStr(wlink, """") - 1)
            Exit For
        End If
        'For Each witem In wnode.ChildNodes
        '    If witem.nodeName = "#text" Then
        '        If Len(witem.NodeValue) > 1 Then
                    'WScript.Echo witem.nodeName & ":(" & Len(witem.firstChild.nodeValue) & ")" & witem.firstChild.nodeValue & ";"
        '            mesg = Trim(witem.NodeValue)
                    'Set wnode = node
                    'Exit For
        '        End If
        '    End If
        'Next
      End If
      'WScript.Echo mesg
      
    Next
    
    GetSFLink = wlink
    
End Function

'Declare PtrSafe Function URLDownloadToFile Lib "urlmon" Alias "URLDownloadToFileA" ( ByVal pCaller As Long, _
'    ByVal szURL As String, _
'    ByVal szFileName As String, _
'    ByVal dwReserved As Long, _
'    ByVal lpfnCB As Long ) As Long

'Function URLDownload(strURL, strPath)
'Dim lngRes 'As Long
'Dim strURL As String
'Dim strPath As String
     
    'strPath = "C:\Users\users\Desktop\File\�摜.png"
    'strURL = "https://www.google.co.jp/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png";
    
'	TraceOut "�_�E�����[�h��... " & strURL

'    URLDownload = URLDownloadToFile(0, strURL, strPath, 0, 0)
    ' URLDownload = 0 : ����
'End Sub

Public Function GetRedirectUrl(ByVal url) 
  Dim req
  Dim ret
  Const WinHttpRequestOption_EnableRedirects = 6 'WinHttp.WinHttpRequestOption
  ret = url
  
  If DebugLvl > 0 Then TraceOut "���_�C���N�g�`�F�b�N " & url
  
  On Error Resume Next
  Err.Clear
  set req = CreateObject("WinHttp.WinHttpRequest.5.1")

  if req is nothing then
      If DebugLvl > 1 Then TraceOut "GetRedirectUrl(0): WinHttpRequest�I�u�W�F�N�g���������s"
      Exit Function
  else
      If DebugLvl > 1 Then TraceOut "GetRedirectUrl(0): WinHttpRequest�I�u�W�F�N�g����������"
  End If
  
  With req
     If Err.Number <> 0 then TraceOut "GetRedirectUrl(1): Error " & Error : Exit Function
    .Open "HEAD", url, False
     If Err.Number <> 0 then TraceOut "GetRedirectUrl(2): Error " & Error : Exit Function
    .Option(WinHttpRequestOption_EnableRedirects) = False '���_�C���N�g����
     If Err.Number <> 0 then TraceOut "GetRedirectUrl(3): Error " & Error : Exit Function
    .Send
     If Err.Number <> 0 then TraceOut "GetRedirectUrl(4): Error " & Error : Exit Function
    If DebugLvl > 1 Then TraceOut "GetRedirectUrl(5): Status " & .Status
    Select Case .Status
      Case 302: ret = .GetResponseHeader("Location")
    End Select
  End With

  On Error GoTo 0
  GetRedirectUrl = ret
End Function

Call Main()
