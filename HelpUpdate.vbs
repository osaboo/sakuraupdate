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

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub HelpUpdate
    Editor.ActivateWinOutput

    Tools.log vbCrLf & "����sakuraupdate " & Tools.Version & "����", 0
    Tools.log "�w���v�t�@�C�����ŐV�o�[�W�����ɍX�V���܂��B", 0

    Dim wtargets
    wtargets = Array("")

    If HelpCheck("sakura.chm") Then
        redim preserve wtargets(ubound(wtargets)+1)
        wtargets(ubound(wtargets)) = "sakura.chm"
    End If
    If HelpCheck("macro.chm") Then
        redim preserve wtargets(ubound(wtargets)+1)
        wtargets(ubound(wtargets)) = "macro.chm"
    End If
    If HelpCheck("plugin.chm") Then
        redim preserve wtargets(ubound(wtargets)+1)
        wtargets(ubound(wtargets)) = "plugin.chm"
    End If

    if ubound(wtargets) > 0 Then
        Call Tools.FileSetup(wtargets)
    End If

End Sub

Function HelpCheck(atarget)
    Dim wchk
    Dim wurl
    Dim wnewver

    HelpCheck = false

    wchk = Tools.HelpCheck(2, atarget, wnewver, wurl)
    If IsNull(wchk) Then Exit Function

    If wchk = False Then
        If Tools.WSH.Popup("���łɍŐV�łł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
            Exit Function
        End If
    End If

    If Tools.HelpDownload(atarget, wurl) = False Then
        Exit Function
    End If

    HelpCheck = true

End Function

HelpUpdate
