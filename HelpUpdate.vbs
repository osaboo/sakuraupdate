' �T�N���G�f�B�^ �w���v�t�@�C���̍X�V����
'
' �T�N���G�f�B�^�̃o�[�W�����Ɠ����o�[�W�����̃w���v�t�@�C����T��
' ���łɂ���w���v�t�@�C���̃o�[�W�������擾����ɂ́H
'   �^�C���X�^���v�Ŕ��f�B�e�[�u������Ă���
' URL�ƃo�[�W�����̊֌W�����W
'   ���ׂẴw���v�t�@�C�����_�E�����[�h���āA�W�J���^�C���X�^���v�ƃo�[�W�����̃��X�g�����B
'   ���X�g��def�t�@�C���ɕۊǂ���B(JSON�`��?)
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

	TraceOut "�w���v�t�@�C�����ŐV�o�[�W�����ɍX�V���܂��B"

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
	wurl = Plugin.GetOption("�T�N���G�f�B�^", "HELPURL")

	If Instr(wurl,"sourceforge.net")>0 then
        wnewver = GetSFRSS(wurl, "", wnewdate)
    ElseIf wurl = "" Then '�w��Ȃ��̏ꍇ�́ASourceForge���猟��
    	wurl = Plugin.GetOption("�T�N���G�f�B�^", "SFRSSURL")
        wnewver = GetSFRSS(wurl, "help2", wnewdate)
    End If
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        TraceOut "�����[�X���ꂽ�w���v�t�@�C�����m�F�ł��܂���ł����B"
        Exit Sub
    End If
    
    TraceOut "���݂̃T�N���G�f�B�^�̃o�[�W����:" & wsakuraver
    TraceOut "���݂̃w���v�t�@�C���X�V���t:" & wcurdate
    TraceOut "�ŐV�̃w���v�t�@�C���o�[�W����:" & wnewver
    TraceOut "�ŐV�̃w���v�t�@�C�����s���t:" & wnewdate

    if wnewdate <= wcurdate Then
        If Tools.WSH.Popup("���łɍŐV�łł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
	        Exit Sub
	    End if
    End If

    
    ' �w���v�t�@�C����zip�_�E�����[�h
    Dim wcmd
    Dim wzipfile
    
    wzipfile = Tools.WorkDir & "help.zip"
    
	If Instr(wurl,"sourceforge.net")>0 then
	    wlink = wurl
    End If
    
    Tools.log "�w���v�t�@�C�����_�E�����[�h���܂�.. " & wlink, 0

    'wcmd = "bitsadmin.exe /TRANSFER sakura2 " & wurl & " " & wzipfile
    wcmd = Tools.CurlExe & " -L """ & wlink & """ -o " & wzipfile
    Tools.log ">" & wcmd, 1
    'Tools.DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, True '

	If Not Tools.IsExistFile(wzipfile) then
	    Tools.log "�_�E�����[�h�ł��܂���ł����B", 0
		Exit Sub
	End If
	
	TraceOut "�_�E�����[�h�t�@�C����W�J���܂��B"

    'zip�W�J
    wcmd = Tools.UnzipExe & " e -aoa " & wzipfile & " sakura.chm -o" & Tools.WorkDir
    Tools.log ">" & wcmd, 1
    Tools.WSH.Run wcmd, 7, False

	Sleep 500

	If Not Tools.IsExistFile(Tools.WorkDir & "\sakura.chm") then
	    TraceOut "sakura.chm���_�E�����[�h�t�@�C���ɂ���܂���ł����B"
		Exit Sub
	End If

	TraceOut "sakura.chm���X�V���܂��B"
	If Tools.WSH.Popup("sakura.chm���X�V���܂��B",0,"�\�t�g�E�F�A�̍X�V",1) = 2 Then
        Exit sub
    End If
	
    ' exe�㏑������
    '    �X�V�X�N���v�g���쐬���A���v���Z�X�Ŏ��s
    '    ���s��T�N���G�f�B�^���I������B
    '    �X�N���v�g�́A�T�N���G�f�B�^�㏑�����o����܂őҋ@����B
    '    program files\sakura�̏ꍇ�̓Z�L�����e�B�x�����ł�B
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
    
    Tools.log "SourceForge�m�F��... " & wlink, 0
    
    wtmpfile = Tools.WorkDir & "\_temp.htm"
    wcmd = Tools.CurlExe & " -L """ & wlink & """ -o " & wtmpfile
    Tools.log ">" & wcmd, 1
    'DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, True '
    
    Dim XmlDoc 'As Object
    Set XmlDoc = CreateObject("Microsoft.XMLDOM")
    XmlDoc.async = False
    'RSS��URL����f�[�^���擾
    'rCode = XmlDoc.Load("https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2")
	'rCode = XmlDoc.Load(aurl)
    rCode = XmlDoc.Load(wtmpfile)

    '�擾�m�F
    If (XmlDoc.parseError.ErrorCode <> 0) Then '���[�h���s
        Tools.log "�ǂݍ��߂܂���ł����B", 0
        Tools.log XmlDoc.parseError.reason, 0   '�G���[���e���o��
        GetSFRSS = -1
        Exit Function
    End If

    'item�擾
    Set items = XmlDoc.SelectNodes("//item")

    Dim re, match, matchs
    Set re = CreateObject("VBScript.RegExp")
    re.pattern = "([0-9]\.[0-9]\.[0-9]\.[0-9])/sakura_help[0-9\-]+\.zip"

    wlink = ""
    '�u���O�L��4�o��
    For i = 0 To items.Length - 1
        set ItemLink = items(i).SelectNodes("./link")
        set ItemDate = items(i).SelectNodes("./pubDate")
        wlink = ItemLink(0).Text
        'If re.Test(wlink) Then
        Set matchs = re.Execute(wlink)
        If matchs.Count > 0 Then
            Editor.TraceOut "���������t�@�C��:" & wlink 
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
