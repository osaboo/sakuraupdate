'   �v���O�C���̍X�V����
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Sub PluginUpdate()
    Dim wchk
    Dim wurl
    Dim wnewver

    Editor.ActivateWinOutput
    
    Tools.log vbCrLf & "����sakuraupdate " & Tools.Version & "����", 0
    Tools.log "sakuraupdate�v���O�C�����ŐV�o�[�W�����ɍX�V���܂��B", 0

    'WorkDir����ɂ���B
    Tools.WorkCleanup(true)

    wchk = Tools.PluginCheck(2, wnewver, wurl)
    If IsNull(wchk) Then Exit Sub

    If wchk = False Then
        If Tools.WSH.Popup("���łɍŐV�łł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) = 7 Then
            Exit Sub
        End If
    End If

    If Tools.PluginDownload(wurl) = False Then
        Exit Sub
    End If
    
    Call Tools.PluginSetup("plugin")

End Sub

PluginUpdate
