' �T�N���G�f�B�^ Diff(����)�c�[���̍X�V����
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Call Tools.DiffUpdate()
