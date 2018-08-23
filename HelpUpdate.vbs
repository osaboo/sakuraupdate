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

Dim vbCrLf '= Chr(13) & Chr(10)
Dim vbLf '= Chr(10)

vbCrLf = Chr(13) & Chr(10)
vbLf = Chr(10)

Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Call Tools.HelpUpdate()
