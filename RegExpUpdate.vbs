' �T�N���G�f�B�^ ���K�\��DLL�̍X�V����
'
Option Explicit

Dim vbCrLf '= Chr(13) & Chr(10)
Dim vbLf '= Chr(10)

vbCrLf = Chr(13) & Chr(10)
vbLf = Chr(10)

Dim wSH
Dim oSH
Dim WSC_PATH
Dim Tools

Sub Main()

    Dim fs
    Dim fl
    Set fs = CreateObject("Scripting.FileSystemObject")

    WSC_PATH = Plugin.GetPluginDir() & "\Tools.wsc"
    Set Tools = GetObject("script:" & WSC_PATH)
    Set Tools.Editor = Editor
    Set Tools.Plugin = Plugin
    Tools.Init

	TraceOut "���K�\��DLL�t�@�C���̃����[�X�ς݃o�[�W�������m�F���܂��B"

    Dim wurl
    Dim wlink
    Dim wsakurapath
    Dim wregexppath
    Dim wcurver
    Dim wnewver
    
    wsakurapath = Editor.ExpandParameter("$S")
    wregexppath = fs.GetParentFolderName(wsakurapath) & "\bregonig.dll"
    wcurver = fs.GetFileVersion(wregexppath)

    Dim re, match, matchs
    Set re = CreateObject("VBScript.RegExp")
    
    With re
        .pattern = "(\d+)\.(\d+)\.\d+\.\d+"
        .Global = True
        Set matchs = .Execute(wcurver)
        If matchs.Count > 0 Then
            If matchs(0).SubMatches.Count > 1 Then
                Dim sb
                Set sb=CreateObject("System.Text.StringBuilder")
                sb.AppendFormat "{0,0:00}", matchs(0).SubMatches(0)
                sb.Append_3 "."
                sb.AppendFormat "{0,0:00}", matchs(0).SubMatches(1)
                wcurver = sb.ToString()
            End If
        End If
    End With
    
	wurl = Plugin.GetOption("�T�N���G�f�B�^", "REGEXPURL")

	If Instr(wurl,"sourceforge.net")>0 then
        wnewver = GetSFRSS(wurl, "")
	ElseIf Instr(wurl,"api.bitbucket.org")>0 then
        wnewver = GetBitBucket(wurl)
    End If
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        TraceOut "�ŐV�ł��m�F�ł��܂���ł����B"
        Exit Sub
    End If
    
    TraceOut "���݂̐��K�\��DLL�̃o�[�W����:" & wcurver
    TraceOut "�ŐV�̐��K�\��DLL�̃o�[�W����:" & wnewver

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
        If DebugLvl > 0 Then TraceOut "�_�E�����[�h�����N���m�F���܂��B"
        wlink = GetSFLink(wurl)
        if wlink = "" then
            If DebugLvl > 0 Then TraceOut "�_�E�����[�h�����N���擾�ł��܂���ł����B"
            exit sub
        End If
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
    
    'SH.Namespace("c:\temp\sakura2").CopyHere SH.Namespace("c:\temp\sakura2.zip").Items
    Dim zipitem 'as  FolderItem2
    Dim zipitem2
    'https://docs.microsoft.com/en-us/windows/desktop/shell/folderitem
    'https://docs.microsoft.com/en-us/windows/desktop/shell/folderitems2-object
    'ExtendedProperty
    
    ' bregonig.dll�̓W�J
    If fs.FileExists(WorkDir & "\bregonig.dll") Then
        fs.DeleteFile (WorkDir & "\bregonig.dll")
    End If
    For Each zipitem In SH.Namespace(wzipfile).items
        'Editor.TraceOut(TypeName(zipitem))
        'Editor.TraceOut(zipitem.Name)
        If zipitem.IsFolder Then
        '    For Each zipitem2 In zipitem.GetFolder.items
        '        If DebugLvl > 1 Then TraceOut zipitem2.Path
        '        If zipitem2.Name = "bregonig.dll" Then
        '            SH.Namespace(WorkDir).CopyHere zipitem2
        '        End If
        '    Next
        Else
            If DebugLvl > 1 Then TraceOut zipitem.Path
            If zipitem.Name = "bregonig.dll" Then
                SH.Namespace(WorkDir).CopyHere zipitem
            End If
        End If
    Next
    
	If Not Tools.IsExistFile(WorkDir & "\bregonig.dll") then
	    TraceOut "bregonig.dll���_�E�����[�h�t�@�C���ɂ���܂���ł����B"
		Exit Sub
	End If

	TraceOut "bregonig.dll���X�V���܂��B"
	'TraceOut "�������񂷂ׂĂ�sakura.exe�������I�����Ă���㏑�����܂��B"
	Sleep 3000
	
    ' exe�㏑������
    '    �X�V�X�N���v�g���쐬���A���v���Z�X�Ŏ��s
    '    ���s��T�N���G�f�B�^���I������B
    '    �X�N���v�g�́A�T�N���G�f�B�^�㏑�����o����܂őҋ@����B
    '    program files\sakura�̏ꍇ�̓Z�L�����e�B�x�����ł�B
    Dim wcmdfile
    Dim woldfile
    
    woldfile = wregexppath & ".old"
    
    wcmd = "title SakuraUpdate"
    'wcmd = wcmd & vbCrLf & "timeout /t 3"
    wcmd = wcmd & vbCrLf & ":L1"
    'wcmd = wcmd & vbCrLf & "taskkill /im sakura.exe"
    'wcmd = wcmd & vbCrLf & "timeout /t 3"
    wcmd = wcmd & vbCrLf & "del """ & woldfile & """"
    wcmd = wcmd & vbCrLf & "ren """ & wregexppath & """ bregonig.dll.old"
    wcmd = wcmd & vbCrLf & "if exist """ & wregexppath & """ goto :L1"
    wcmd = wcmd & vbCrLf & "copy /y """ & WorkDir & "\bregonig.dll"" """ & wregexppath & """"
    'wcmd = wcmd & vbCrLf & """C:\Program Files (x86)\sakura\sakura.exe"""
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

    'Editor.ExitAll

End Sub

' Get SourceForge RSS 
function GetSFRSS(byref aurl, apath)
    Dim rCode
    Dim Itemtitle
    Dim i
    Dim wlink
    Dim wver
    
    If apath<>"" then aurl = aurl & "?path=/" & apath
    
    TraceOut "SourceForge�m�F��... " & aurl
    
    Dim XmlDoc 'As Object
    Set XmlDoc = CreateObject("Microsoft.XMLDOM")
    XmlDoc.async = False
    'RSS��URL����f�[�^���擾
    'rCode = XmlDoc.Load("https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2")
	rCode = XmlDoc.Load(aurl)

    '�擾�m�F
    If rCode = False Then
        TraceOut "�ǂݍ��߂܂���ł����B"
        getSFRSS = -1
        Exit function
    End If

    '�u���O�L���̃^�C�g�����擾
    Set Itemtitle = XmlDoc.SelectNodes("//item/link")

    Dim re, match, matchs
    Set re = CreateObject("VBScript.RegExp")
    re.pattern = "bron(\d+)\.zip"
    
    wlink = ""
    '�u���O�L��4�o��
    For i = 0 To Itemtitle.Length - 1
        wlink = Itemtitle(i).Text
        If re.Test(wlink) Then
            Editor.TraceOut "���������t�@�C��:" & wlink 
            aurl = wlink
            Exit For
        End If
    Next
    
    if wlink <> "" Then
        With re
            '.pattern = "[0-9]\.[0-9]\.[0-9]\.[0-9]"
            .Global = True
            Set matchs = .Execute(wlink)
            If matchs.Count > 0 Then
                If matchs(0).SubMatches.Count > 0 Then
                    wver = matchs(0).SubMatches(0)
                    Dim sb
	                Set sb=CreateObject("System.Text.StringBuilder")
	                sb.AppendFormat "{0,0:00}", left(wver,1)
	                sb.Append_3 "."
	                sb.AppendFormat "{0,0:00}", mid(wver,2)
	                wver = sb.ToString()

                End If
            End If
        End With
    End If

    GetSFRSS = wver

End function

' Get GitHub Release API 
function GetBitBucket(byref aurl)
    Dim req
    Dim wjson
    Dim wlink
    Dim wver
    Dim wpage
    Dim mesg
    Dim i, j

	TraceOut "BitBucket�m�F��.. " & aurl

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

    req.Send
    If req.Status <> 200 Then
        If DebugLvl > 1 Then TraceOut "Status Error: " & req.Status
        Exit Function
    End If
      
    'set wjson = Tools.ParseJson(req.responseText)
    'wlink = wjson.assets(0).browser_download_url
    wpage = req.responseText
    If DebugLvl > 1 Then TraceOut "Status : " & req.Status
    
    Dim re, match, matchs
    Set re = CreateObject("VBScript.RegExp")
    re.pattern = "https://[^""]+/bron(\d+)\.zip"

    With re
        '.pattern = "[0-9]\.[0-9]\.[0-9]\.[0-9]"
        .Global = True
        Set matchs = .Execute(wpage)
        If matchs.Count > 0 Then
            wlink = matchs(0)
            Editor.TraceOut "���������t�@�C��:" & wlink 
            If matchs(0).SubMatches.Count > 0 Then
                wver = matchs(0).SubMatches(0)
                Dim sb
                Set sb=CreateObject("System.Text.StringBuilder")
                sb.AppendFormat "{0,0:00}", left(wver,1)
                sb.Append_3 "."
                sb.AppendFormat "{0,0:00}", mid(wver,2)
                wver = sb.ToString()
            End If
        End If
    End With

    GetBitBucket = wver

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
    
    If req.Status <> 200 Then
      Exit Function
    End If
    
    wpage = req.responseText
    
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
