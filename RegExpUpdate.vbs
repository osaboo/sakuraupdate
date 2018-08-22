' �T�N���G�f�B�^ ���K�\�����C�u�����̍X�V����
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

    Tools.log "���K�\�����C�u�������ŐV�o�[�W�����ɍX�V���܂��B", 0

    Dim wos, wosver, wosbit
    Tools.GetOSInfo wos, wosver, wosbit
    Tools.log "wos=" & wos, 2
    Tools.log "wosver=" & wosver, 2
    Tools.log "wosbit=" & wosbit, 2

    Dim wurl
    Dim wlink
    Dim wsakurapath
    Dim wregexppath
    Dim wcurver
    Dim wnewver
    
    wsakurapath = Editor.ExpandParameter("$S")
    wregexppath = Tools.FS.GetParentFolderName(wsakurapath) & "\bregonig.dll"
    wcurver = Tools.FS.GetFileVersion(wregexppath)

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
        wnewver = Tools.GetBitBucket(wurl)
    ElseIf wurl = "" Then '�w��Ȃ��̏ꍇ�́ASourceForge���猟��
    	wurl = Plugin.GetOption("�T�N���G�f�B�^", "SFRSSURL")
        wnewver = GetSFRSS(wurl, "wiki")
    End If
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        TraceOut "�ŐV�ł��m�F�ł��܂���ł����B"
        Exit Sub
    End If
    
    TraceOut "���݂̐��K�\�����C�u�����̃o�[�W����:" & wcurver
    TraceOut "�ŐV�̐��K�\�����C�u�����̃o�[�W����:" & wnewver

    if wnewver <= wcurver Then
        If Tools.WSH.Popup("���łɍŐV�łł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
	        Exit Sub
	    End if
    End If

    
    ' ���K�\�����C�u������zip�_�E�����[�h
    Dim wcmd
    Dim wzipfile
    
    wzipfile = Tools.WorkDir & "\regexp.zip"
    
	If Instr(wurl,"sourceforge.net")>0 then
	    wlink = wurl
        'If DebugLvl > 0 Then TraceOut "�_�E�����[�h�����N���m�F���܂��B"
        'wlink = GetSFLink(wurl)
        'if wlink = "" then
        '    If DebugLvl > 0 Then TraceOut "�_�E�����[�h�����N���擾�ł��܂���ł����B"
        '    exit sub
        'End If
	ElseIf Instr(wurl,"bitbucket.org")>0 then
        wlink = wurl
    End If
    
    Tools.log "���K�\�����C�u�������_�E�����[�h���܂�.. " & wlink, 0

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
    wcmd = Tools.UnzipExe & " e -aoa " & wzipfile & " bregonig.dll -o" & Tools.WorkDir
    Tools.log ">" & wcmd, 1
    Tools.WSH.Run wcmd, 7, False

	Sleep 500
	If Not Tools.IsExistFile(Tools.WorkDir & "\bregonig.dll") then
	    TraceOut "bregonig.dll���_�E�����[�h�t�@�C���ɂ���܂���ł����B"
		Exit Sub
	End If

	TraceOut "bregonig.dll���X�V���܂��B"
	If Tools.WSH.Popup("bregonig.dll���X�V���܂��B",0,"�\�t�g�E�F�A�̍X�V",1) = 2 Then
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
	           "set targetfile=bregonig.dll" & vbCrLf

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
function GetSFRSS(byref aurl, apath)
    Dim rCode
    Dim Itemtitle
    Dim i
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
            Tools.log "���������t�@�C��:" & wlink ,2
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


Call Main()
