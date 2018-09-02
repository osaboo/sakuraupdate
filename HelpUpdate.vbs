' サクラエディタ ヘルプファイルの更新処理
'
' サクラエディタのバージョンと同じバージョンのヘルプファイルを探す
' すでにあるヘルプファイルのバージョンを取得するには？
'   タイムスタンプで判断。テーブル作っておく
' URLとバージョンの関係を収集
'   すべてのヘルプファイルをダウンロードして、展開しタイムスタンプとバージョンのリストを作る。
'   リストはdefファイルに保管する。(JSON形式?)
'
Option Explicit

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Call Tools.HelpUpdate()
