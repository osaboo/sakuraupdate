' �T�N���G�f�B�^ ���K�\�����C�u�����̍X�V����
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub RegExpUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput

    Tools.log vbCrLf & "����sakuraupdate " & Tools.Version & "����", 0
    Tools.log "���K�\�����C�u�������ŐV�o�[�W�����ɍX�V���܂��B", 0
    
    'WorkDir����ɂ���B
    Tools.WorkCleanup(true)

    wchk = Tools.RegExpCheck(2, wnewver, wurl) 
    If IsNull(wchk) Then Exit Sub

    If wchk = False Then
        If Tools.WSH.Popup("���łɍŐV�łł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
            Exit Sub
        End If
    End If

    If Tools.RegExpDownload(wurl) = False Then
        Exit Sub
    End If

    Call Tools.FileSetup(Array("","bregonig.dll"))

End Sub

RegExpUpdate