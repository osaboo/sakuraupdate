' �T�N���G�f�B�^ Diff(����)�c�[���̍X�V����
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub DiffUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput

    Tools.log vbCrLf & "����sakuraupdate " & Tools.Version & "����", 0
    Tools.log "Diff(����)�c�[����z�u���܂��B", 0
    
    wchk = Tools.DiffCheck(2, wnewver, wurl)
    If IsNull(wchk) Then Exit Sub

    If wchk = False Then
        If Tools.WSH.Popup("���łɔz�u�ς݂ł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
            Exit Sub
        End If
    End If
    
    If Tools.DiffDownload(wurl) = False Then
        Exit Sub
    End If

    Call Tools.FileSetup(Array("","diff.exe"))

End Sub

DiffUpdate
