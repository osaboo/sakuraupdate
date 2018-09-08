' サクラエディタ Ctags(タグ生成)ツールの更新処理
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Call Tools.CtagsUpdate()
