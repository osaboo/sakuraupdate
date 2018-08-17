Option Explicit

'	�T�N���G�f�B�^�{�̂̍X�V�`�F�b�N
'
'	���o�[�W�������擾
'	�ŐV�o�[�W�������C���^�[�l�b�g����擾
'	�X�V����Ă���ꍇ�A���b�Z�[�W��\�����A�X�V����ꍇ�͍X�V����B
'	�X�V����Ă��Ȃ��ꍇ�́A�I��
'	�`�F�b�N�̓G�f�B�^�N��3����Ɏ��{

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

	DebugLvl = Plugin.GetOption("�T�N���G�f�B�^", "DEBUGLVL")
    Tools.DebugLvl = DebugLvl

	'Editor.ActivateWinOutput
	Dim lastcheck
	Dim checkfreq
	lastcheck = Plugin.GetOption("�T�N���G�f�B�^", "LASTCHECK")
	checkfreq = Plugin.GetOption("�T�N���G�f�B�^", "CHECKFREQ")
	
	if not isnumeric(checkfreq) Then
		Exit Sub
	End If
	
	if isdate(lastcheck) Then
		If DateAdd("d", checkfreq, lastcheck) > Date Then
			exit Sub
		End If
	end if
	lastcheck = Date
	Plugin.SetOption "�T�N���G�f�B�^", "LASTCHECK", lastcheck
	
    Set oSH = CreateObject("Wscript.Shell")
    WorkDir = oSH.ExpandEnvironmentStrings("%TEMP%") & "\sakuraupdate"
'	TraceOut "�X�V��Ɨp�t�H���_ " & WorkDir
'    If not Tools.IsExistDir(WorkDir) Then
'    	TraceOut "�X�V��Ɨp�t�H���_���쐬���܂�"
'        Tools.CreateDir fs, workdir
'    End If

    vbCrLf = Chr(13) & Chr(10)
    vbLf = Chr(10)


	If DebugLvl > 0 Then TraceOut "�����[�X�ς݃o�[�W�������m�F���܂��B"

    Dim wurl
    Dim wlink
    Dim wcurver
    Dim wnewver
    wcurver = Editor.ExpandParameter("$V")

    Select Case Plugin.GetOption("�T�N���G�f�B�^", "DOWNLOADSITE")
        Case "0" 'GitHub
        	wurl = Plugin.GetOption("�T�N���G�f�B�^", "GITHUBURL")
            wnewver = GetGitHub(wurl)
        Case "1" 'SourceForge
        	wurl = Plugin.GetOption("�T�N���G�f�B�^", "SFRSSURL")
            wnewver = GetSFRSS(wurl)
    End Select
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        If DebugLvl > 0 Then TraceOut "�ŐV�ł��m�F�ł��܂���ł����B"
        Exit Sub
    End If
    
    If DebugLvl > 0 Then TraceOut "���݂̃T�N���G�f�B�^�̃o�[�W����:" & wcurver
    If DebugLvl > 0 Then TraceOut "�ŐV�̃T�N���G�f�B�^�̃o�[�W����:" & wnewver

    if wnewver <= wcurver Then
        Exit Sub
    End If
	'Editor.ActivateWinOutput

    MessageBox("�T�N���G�f�B�^�̐V�o�[�W�����������[�X����Ă��܂��B�X�V�̓c�[�����\�t�g�E�F�A�̍X�V������s���Ă��������B")
    
End Sub

' Get SourceForge RSS 
function GetSFRSS(byref aurl)
    Dim rCode
    Dim Itemtitle
    Dim i
    Dim wlink
    Dim wver
    
    If DebugLvl > 0 Then TraceOut "SourceForge�m�F��... " & aurl
    
    Dim XmlDoc 'As Object
    Set XmlDoc = CreateObject("Microsoft.XMLDOM")
    XmlDoc.async = False
    'RSS��URL����f�[�^���擾
    'rCode = XmlDoc.Load("https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2")
	rCode = XmlDoc.Load(aurl)

    '�擾�m�F
    If rCode = False Then
        If DebugLvl > 0 Then TraceOut "�ǂݍ��߂܂���ł����B"
        getSFRSS = -1
        Exit function
    End If

    '�u���O�L���̃^�C�g�����擾
    Set Itemtitle = XmlDoc.SelectNodes("//item/link")

    wlink = ""
    '�u���O�L��4�o��
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

	If DebugLvl > 0 Then TraceOut "GitHub�m�F��.. " & aurl

    Set req = Nothing '������
    Set req = CreateHttpRequest()
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
Private Function CreateHttpRequest() ' As Object
'WinHttpRequest/XMLHTTPRequest�I�u�W�F�N�g�쐬
'http://www.f3.dion.ne.jp/~element/msaccess/AcTipsWinHTTP1.html �Q�l
  Dim progIDs ' As Variant
  Dim ret 'As Object
  Dim i 'As Long
   
  Set ret = Nothing '������
  progIDs = Array("MSXML.XMLHTTPRequest", _
                  "WinHttp.WinHttpRequest.5.1", _
                  "WinHttp.WinHttpRequest.5", _
                  "WinHttp.WinHttpRequest", _
                  "Msxml2.ServerXMLHTTP.6.0", _
                  "Msxml2.ServerXMLHTTP.5.0", _
                  "Msxml2.ServerXMLHTTP.4.0", _
                  "Msxml2.ServerXMLHTTP.3.0", _
                  "Msxml2.ServerXMLHTTP", _
                  "Microsoft.ServerXMLHTTP", _
                  "Msxml2.XMLHTTP.6.0", _
                  "Msxml2.XMLHTTP.5.0", _
                  "Msxml2.XMLHTTP.4.0", _
                  "Msxml2.XMLHTTP.3.0", _
                  "Msxml2.XMLHTTP", _
                  "Microsoft.XMLHTTP")
  progIDs = Array( "Msxml2.XMLHTTP")
  On Error Resume Next
  For i = LBound(progIDs) To UBound(progIDs)
    Set ret = CreateObject(progIDs(i))
    If Not ret Is Nothing Then
    	If DebugLvl > 1 Then TraceOut "XMLHTTPRequest��" & progIDs(i) & "�ŏ��������܂����B"
    	Exit For
    End If
  Next
  On Error GoTo 0
  If ret is Nothing Then
  	If DebugLvl > 1 Then TraceOut "XMLHTTPRequest���������ł��܂���ł����B"
  End If
  Set CreateHttpRequest = ret
End Function

Call Main()
