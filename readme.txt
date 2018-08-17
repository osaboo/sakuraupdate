サクラエディタを更新するプラグイン

次のコマンドがツールメニューに追加されます。

ソフトウェアの更新

★★インストール手順★★

1.SakuraUpdate.zipを展開し、サクラエディタの実行プログラムパスの直下にコピーします。
  コピー後、次のようなフォルダ構成になるようにします。
  (C:\Program Files\sakuraフォルダの場合はコピー時に管理者のアクセス許可確認が
   表示されますが続行してコピーしてください)

<サクラエディタの実行プログラムパス。C:\Program Files\sakura など>
└Plugins フォルダ
  └SakuraUpdate フォルダ
    └SakuraUpdate.vbs ファイル
    └Tools.wsc  ファイル
    └plugin.def ファイル
    └readme.txt ファイル

2.サクラエディタを起動し、メニューから設定⇒共通設定を起動し、
  プラグインのタブを表示します。
  「プラグインを有効にする」のチェックボックスのチェックを入れます。
  （入っている場合はそのままでよいです)
  「新規プラグインを追加」ボタンをクリックします。
  「プラグイン「SakuraUpdate」をインストールしますか?」の確認画面が表示されたら
  「はい」でインストールします。
  共通設定ウィンドウを「OK」ボタンで閉じ、
  サクラエディタをいったん終了してから再度起動します。

3.サクラエディタを起動し、メニューから設定⇒共通設定を起動し、
  プラグインのタブを表示します。
  プラグインの一覧にあるSakuraUpdateの行をダブルクリックすると設定画面が表示されます。
  (設定ボタンでも同じ)

★★使い方★★

★★動作仕様★★

リリースが更新されている場合にメッセージ表示し、
更新を選択した時は、ダウンロード、サクラエディタの終了、exe差し替え、サクラエディタの再起動を実行する。
ダウンロード先はデフォルトで
https://sourceforge.net/projects/sakura-editor/files/sakura2/
内の最新verを参照
https://sourceforge.net/projects/sakura-editor/files/latest/download?source=navbar

https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2

サクラエディタ起動時にチェック可能か
EditorStartイベント時にチェック

ToDo
イントラ向けにURLをカスタマイズ可能とする
SakuraDownでサポートしているコンポーネントの管理
・ヘルプファイル
・正規表現ライブラリ

処理
URLの取得
Rssで取得し、最新のzipのパスを取得
http://でのファイルダウンロード
ダウンロードフォルダにダウンロード
zipを展開
Sakura.exeの終了
exe差し替え
Sakura.exeの再起動

★使用著作権表示★★

同封のcurlバイナリはDirk Paehl氏が配布しているものです。
http://www.paehl.com/open_source/?CURL_7.61.0

同封の7za.exeは、GNU LGPLでライセンスされている、Igor Pavlovの著作物です。
-----------------
7-Zip Extra is package of extra modules of 7-Zip. 
7-Zip Copyright (C) 1999-2018 Igor Pavlov.
7-Zip is free software. Read License.txt for more information about license.
Source code of binaries can be found at:
  http://www.7-zip.org/

