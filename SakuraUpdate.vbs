' �T�N���G�f�B�^�{�̂̍X�V����
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub SakuraUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput
    
    Tools.log vbCrLf & "����sakuraupdate " & Tools.Version & "����", 0
    Tools.log "�T�N���G�f�B�^�{�̂��ŐV�o�[�W�����ɍX�V���܂��B", 0

    'WorkDir����ɂ���B
    Tools.WorkCleanup(true)

    wchk = Tools.SakuraCheck(2, wnewver, wurl)
    If IsNull(wchk) Then Exit Sub

    If wchk = False Then
        If Tools.WSH.Popup("���łɍŐV�łł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
            Exit Sub
        End If
    ElseIf wchk > 0 Then
        If Tools.WSH.Popup("�V�����v�������[�X��(" & wnewver & ")������܂��B�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
            Exit Sub
        End If
    End If
    
    If Tools.SakuraDownload(wurl) = False Then
        Exit Sub
    End If

    If Tools.FS.FileExists(Tools.WorkDir & "\sakura.chm") Then
        Call Tools.FileSetup(Array("","sakura.exe","sakura.chm"))
    Else
        Call Tools.FileSetup(Array("","sakura.exe"))
    End If

End Sub

SakuraUpdate
