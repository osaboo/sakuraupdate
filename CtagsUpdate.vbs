' �T�N���G�f�B�^ Ctags(�^�O����)�c�[���̍X�V����
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub CtagsUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput

    Tools.log vbCrLf & "����sakuraupdate " & Tools.Version & "����", 0
    Tools.log "Ctags(�^�O����)�c�[����z�u���܂��B", 0
    
    wchk = Tools.CtagsCheck(2, wnewver, wurl)
    If IsNull(wchk) Then Exit Sub

    If wchk = false Then
        If Tools.WSH.Popup("���łɔz�u�ς݂ł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
            Exit Sub
        End If
    End If
    
    If Tools.CtagsDownload(wurl) = False Then
        Exit Sub
    End If

    Call Tools.FileSetup(Array("","ctags.exe"))

End Sub

CtagsUpdate
