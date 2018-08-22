sakuraupdate ver 0.5

サクラエディタを更新するプラグイン

★★機能★★

1.次のプログラム・ファイルをインターネットからダウンロードして更新します。
・サクラエディタ本体
・ヘルプファイル
・正規表現ライブラリ

2.サクラエディタ起動時に自動的にチェックすることができます。
自動チェックは初期設定で7日単位で、無効にすることもできます。
手動によるチェックもできます。

★★インストール手順★★

1.サクラエディタを起動し、メニューから設定⇒共通設定を起動し、
   プラグインのタブを表示します。
2.「プラグインを有効にする」のチェックボックスのチェックを入れます。
  （入っている場合はそのままでよいです)
3.「ZIPプラグインを導入」ボタンをクリックします。
4.当プラグインのzipファイル(SakuraUpdate.zip)を指定します。
5.プラグイン一覧にsakuraupdateが追加されます。
6.共通設定ウィンドウを「OK」ボタンで閉じます。
7.サクラエディタをいったんすべて終了してから再度起動します。

★★使い方★★

1.次のコマンドがツールメニューに追加されます。

ソフトウェアの更新
└更新チェック
└サクラエディタ更新
└ヘルプファイル更新
└正規表現ライブラリ更新

2.更新チェック
インターネットサイトのリリースバージョンが更新されているかを確認します。
更新可能な場合は更新することができます。

3.サクラエディタ更新
サクラエディタ本体のみを更新します。

4.ヘルプファイル更新
ヘルプファイルのみを更新します。

5.正規表現ライブラリ更新
正規表現ライブラリのみを更新します。

★★オプション設定★★

リリースが更新されている場合にメッセージ表示し、
更新を選択した時は、ダウンロード、サクラエディタの終了、exe差し替え、サクラエディタの再起動を実行する。
ダウンロード先はSorceForgeの場合
https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2
内の最新verを取得
GitHubの場合
https://api.github.com/repos/sakura-editor/sakura/releases/latest
の最新verを取得
管理者モード対応は、PowerShellのrunasを使用

ToDo
イントラ向けにURLをカスタマイズ可能とする
サクラエディタ起動時にチェック可能か。EditorStartイベント時にチェック

★★著作権表示★★

サクラエディタは、Norio Nakatani & Collaboratorsが開発・配布しているフリー・ソフトウェアです。
https://sakura-editor.github.io/

同封のcurl.exeはDirk Paehl氏がコンパイル・配布しているものです。
http://www.paehl.com/open_source/?CURL_7.61.0

同封の7za.exeは、GNU LGPLでライセンスされている、Igor Pavlovの著作物です。
-----------------
7-Zip Extra is package of extra modules of 7-Zip. 
7-Zip Copyright (C) 1999-2018 Igor Pavlov.
7-Zip is free software. Read License.txt for more information about license.
Source code of binaries can be found at:
  http://www.7-zip.org/

