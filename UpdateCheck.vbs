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

vbCrLf = Chr(13) & Chr(10)
vbLf = Chr(10)

Dim Tools

Sub Main()

    Dim WSC_PATH
    Dim fs
    Dim fl
    Set fs = CreateObject("Scripting.FileSystemObject")

    WSC_PATH = Plugin.GetPluginDir() & "\Tools.wsc"
    Set Tools = GetObject("script:" & WSC_PATH)
    Set Tools.Editor = Editor
    Set Tools.Plugin = Plugin
    Tools.Init

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
        Exit Sub
    End If
	'Editor.ActivateWinOutput

    MessageBox("�T�N���G�f�B�^�̐V�o�[�W�����������[�X����Ă��܂��B�X�V�̓c�[�����\�t�g�E�F�A�̍X�V������s���Ă��������B")
    
End Sub

Call Main()
