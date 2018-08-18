Option Explicit

'	�T�N���G�f�B�^�{�̂̍X�V�`�F�b�N(�I���f�}���h)
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

	DebugLvl = Plugin.GetOption("�T�N���G�f�B�^", "DEBUGLVL")
    Tools.DebugLvl = DebugLvl

	CurlExe = """" & Plugin.GetPluginDir() & "\Curl.exe"""
	'UnzipExe = """" & Plugin.GetPluginDir() & "\Unzip.exe"""
	UnzipExe = """" & Plugin.GetPluginDir() & "\7za.exe"""
	'Editor.ActivateWinOutput

	Dim lastcheck
	Dim checkfreq
	lastcheck = Plugin.GetOption("�T�N���G�f�B�^", "LASTCHECK")
	checkfreq = Plugin.GetOption("�T�N���G�f�B�^", "CHECKFREQ")
	
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


	TraceOut "�����[�X�ς݃o�[�W�������m�F���܂��B"

    Dim wurl
    Dim wlink
    Dim wcurver
    Dim wnewver
    wcurver = Editor.ExpandParameter("$V")

    Select Case Plugin.GetOption("�T�N���G�f�B�^", "SITEPRIORITY")
    Case 0
        wurl = Plugin.GetOption("�T�N���G�f�B�^", "GITHUBURL")
    Case 1
        wurl = Plugin.GetOption("�T�N���G�f�B�^", "SFRSSURL")
    Case 2
        wurl = Plugin.GetOption("�T�N���G�f�B�^", "CUSTOMURL")
    End Select

	If Instr(wurl,"sourceforge.net")>0 then
        wnewver = GetSFRSS(wurl, "sakura2")
	ElseIf Instr(wurl,"github.com")>0 then
        wnewver = GetGitHub(wurl)
    End If

    If wnewver = "" then
        TraceOut "�ŐV�ł��m�F�ł��܂���ł����B"
        Exit Sub
    End If
    
    TraceOut "���݂̃T�N���G�f�B�^�̃o�[�W����:" & wcurver
    TraceOut "�ŐV�̃T�N���G�f�B�^�̃o�[�W����:" & wnewver

    if wnewver <= wcurver Then
        TraceOut "���̃T�N���G�f�B�^�͍ŐV�o�[�W�����ł��B"
        Exit Sub
    End If
	'Editor.ActivateWinOutput

    TraceOut "�T�N���G�f�B�^�̐V�o�[�W�����������[�X����Ă��܂��B�X�V�̓c�[�����\�t�g�E�F�A�̍X�V������s���Ă��������B"
    
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
            Editor.TraceOut "���������t�@�C��:" & wlink 
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
                Editor.TraceOut "���������t�@�C��:" & wlink
            Next
        End With
    End If

    GetGitHub = wver

End function

Call Main()
