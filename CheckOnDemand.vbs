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

	Dim lastcheck
	Dim checkfreq
	lastcheck = Plugin.GetOption("�T�N���G�f�B�^", "LASTCHECK")
	checkfreq = Plugin.GetOption("�T�N���G�f�B�^", "CHECKFREQ")
	
	lastcheck = Date
	Plugin.SetOption "�T�N���G�f�B�^", "LASTCHECK", lastcheck
	
    Tools.log "�T�N���G�f�B�^�{�̂̍ŐV�o�[�W�������m�F���܂��B", 0

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

    If wnewver = "" then
        TraceOut "�ŐV�ł��m�F�ł��܂���ł����B"
        Exit Sub
    End If
    
    Tools.log "���݂̃T�N���G�f�B�^�̃o�[�W����:" & wcurver, 0
    Tools.log "�ŐV�̃T�N���G�f�B�^�̃o�[�W����:" & wnewver, 0

    if wnewver <= wcurver Then
        Tools.log "���̃T�N���G�f�B�^�͍ŐV�o�[�W�����ł��B", 0
        Exit Sub
    End If
	'Editor.ActivateWinOutput

    Tools.log "�T�N���G�f�B�^�̐V�o�[�W�����������[�X����Ă��܂��B�X�V�̓c�[�����\�t�g�E�F�A�̍X�V������s���Ă��������B", 0
    
End Sub

Call Main()
