Option Explicit

'	サクラエディタ本体の更新チェック(オンデマンド)
'
'	現バージョンを取得
'	最新バージョンをインターネットから取得
'	更新されている場合、メッセージを表示する。
'	更新されていない場合は、何も表示せず終了。
Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Call Tools.UpdateCheck(2)
