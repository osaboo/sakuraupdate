' �T�N���G�f�B�^�{�̂̍X�V����
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
    
	Editor.ActivateWinOutput

    Tools.log "�����[�X�ς݃o�[�W�������m�F���܂��B", 0

    Dim wurl
    Dim wlink
    Dim wcurver
    Dim wnewver
    wcurver = Editor.ExpandParameter("$V")
    
    Select Case Plugin.GetOption("�T�N���G�f�B�^", "SITEPRIORITY")
    Case "0"
        wurl = Plugin.GetOption("�T�N���G�f�B�^", "GITHUBURL")
    Case "1"
        wurl = Plugin.GetOption("�T�N���G�f�B�^", "SFRSSURL")
    Case "2"
        wurl = Plugin.GetOption("�T�N���G�f�B�^", "CUSTOMURL")
    End Select

	If Instr(wurl,"sourceforge.net")>0 then
        wnewver = Tools.GetSFRSS(wurl, "sakura2")
	ElseIf Instr(wurl,"github.com")>0 then
        wnewver = Tools.GetGitHub(wurl)
    End If
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        Tools.log "�ŐV�ł��m�F�ł��܂���ł����B", 0
        Exit Sub
    End If
    
    Tools.log "���݂̃T�N���G�f�B�^�̃o�[�W����:" & wcurver, 0
    Tools.log "�ŐV�̃T�N���G�f�B�^�̃o�[�W����:" & wnewver, 0

    if wnewver <= wcurver Then
        If Tools.WSH.Popup("���łɍŐV�łł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
        'If  MessageBox("���łɍŐV�łł����A�X�V���܂���?",4) = 7 then 
	        Exit Sub
	    End if
    End If

    ' �T�N���G�f�B�^��zip�_�E�����[�h

    Dim wcmd
    Dim wzipfile
    
    wzipfile = Tools.WorkDir & "\sakura.zip"
    
	If Instr(wurl,"sourceforge.net")>0 then
	    wlink = wurl
        'Tools.log "�_�E�����[�h�����N���m�F���܂��B", 1
        'wlink = GetSFLink(wurl)
        'if wlink = "" then
        '    Tools.log "�_�E�����[�h�����N���擾�ł��܂���ł����B", 1
        '    exit sub
        'End If
	ElseIf Instr(wurl,"github.com")>0 then
        wlink = wurl
    End If
    
    Tools.log "�T�N���G�f�B�^���_�E�����[�h���܂�.. " & wlink, 0
    
    'wcmd = "bitsadmin.exe /TRANSFER sakura2 " & wurl & " " & wzipfile
    wcmd = Tools.CurlExe & " -L """ & wlink & """ -o " & wzipfile
    Tools.log ">" & wcmd, 1
    'Tools.DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, True '

	If Not fs.FileExists(wzipfile) then
	    Tools.log "�_�E�����[�h�ł��܂���ł����B", 0
		Exit Sub
	End If
	
	Tools.log "�_�E�����[�h�t�@�C����W�J���܂��B", 0
    
    'zip�W�J
    'wcmd = UnzipExe & " -o -j " & wzipfile & " */sakura.exe -d " & Tools.WorkDir
    wcmd = Tools.UnzipExe & " e -aoa " & wzipfile & " */sakura.exe -o" & Tools.WorkDir
    Tools.log ">" & wcmd, 1
    'Tools.DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, False
    
    Sleep 500
    If Not fs.FileExists(Tools.WorkDir & "\sakura.exe") then
	    Tools.log Tools.WorkDir & "\sakura.exe���_�E�����[�h�t�@�C���ɂ���܂���ł����B", 0
		Exit Sub
	End If

	If Tools.WSH.Popup("sakura.exe���X�V���܂��B" & vbCrLf & "���ׂĂ�sakura.exe�������I����A�㏑�����܂��B",0,"�\�t�g�E�F�A�̍X�V",1) = 2 Then
        Exit sub
    End If

    ' exe�㏑������
    '    �X�V�X�N���v�g���쐬���A���v���Z�X�Ŏ��s
    '    ���s��T�N���G�f�B�^���I������B
    '    �X�N���v�g�́A�T�N���G�f�B�^�㏑�����o����܂őҋ@����B
    '    C:\program files\sakura�̏ꍇ�̓Z�L�����e�B�x�����ł�B
    Dim wcmdfile
    Dim wcmdparam
    Dim sakuraexe
    Dim sakuraold
    Dim programfiles
    sakuraexe = Editor.ExpandParameter("$S")
    sakuraold = sakuraexe & ".old"
    programfiles = "C:\Program Files"

'   workdir + "/_temp.ps1" �ɁA
'   plugindir + "/fileupdate.ps1" + �p�����[�^1, 2, 3
'   ���Ăԏ�����ۑ����āA_temp.ps1���Astart-process -Verb runas�ŌĂ�
    wcmdfile = """" & Tools.PluginDir & "\fileupdate.ps1"""
    wcmd     = "& " & wcmdfile & " " & _
                Tools.WorkDir  & " " & _
                """" & Tools.SakuraDir & """ " & _
                "sakura.exe" + vbCrLf

    wcmdfile = Tools.WorkDir & "\_fileupdate.ps1"
    Tools.SaveText wcmd, wcmdfile, "Shift_JIS"
    
    wcmdparam = "Start-Process PowerShell -ArgumentList " & wcmdfile & " "
    If left(sakuraexe, Len(programfiles)) = programfiles Then
        '�Ǘ��҃��[�h�ŃR�s�[
        wcmdparam = wcmdparam + " -Verb runas" ' -Wait
    End If

    'wcmd = "powershell -NoProfile -ExecutionPolicy unrestricted -Command ""Start-Process PowerShell -ArgumentList " & wcmdparam & """"
    wcmd = "powershell -NoProfile -ExecutionPolicy unrestricted -Command """ & wcmdparam & """"
    '-NoNewWindow -PassThru
    Tools.log ">" & wcmd, 1

    'Tools.DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, False

    Editor.ExitAll

End Sub


Call Main()
