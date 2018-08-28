# sakuraupdate
Sakura-Editor Update Plugin (v20180828 (beta))

プラグインでサクラエディタのバージョンアップ機能を実装してみる

## 機能

1.次のプログラム・ファイルをインターネットからダウンロードして更新します。

* サクラエディタ本体
* ヘルプファイル
* 正規表現ライブラリ

2.サクラエディタ起動時に自動的にチェックすることができます。

	自動チェックは初期設定で7日単位で、無効にすることもできます。  
	手動によるチェックもできます。

## インストール手順

1. サクラエディタを起動し、メニューから設定⇒共通設定を起動し、プラグインのタブを表示します。

2. 「プラグインを有効にする」のチェックボックスのチェックを入れます。  
	（入っている場合はそのままでよいです)  

3. 「ZIPプラグインを導入」ボタンをクリックします。  
	ここで「Pluginフォルダがありません」と表示されたら、一度「フォルダを開く」をクリックしてからやり直してください。

4. 当プラグインのzipファイル(SakuraUpdate.zip)を指定します。


5. プラグイン一覧にsakuraupdateが追加されます。


6. 共通設定ウィンドウを「OK」ボタンで閉じます。


7. サクラエディタをいったんすべて終了してから再度起動します。


## 使い方

1. 次のコマンドがツールメニューに追加されます。

	ソフトウェアの更新  
	 └更新チェック  
	 └サクラエディタ更新  
	 └ヘルプファイル更新  
	 └正規表現ライブラリ更新  

2. 更新チェック  
	インターネットサイトのリリースバージョンが更新されているかを確認します。
	更新可能な場合は更新することができます。

3. サクラエディタ更新  
	サクラエディタ本体のみを更新します。

4. ヘルプファイル更新  
	ヘルプファイルのみを更新します。

5. 正規表現ライブラリ更新  
	正規表現ライブラリのみを更新します。

## オプション設定

1. ダウンロードサイト
	GitHub:0 SourceForge:1 Custom:2
	から選びます。
	※Customは未実装のため現時点では無効

2. sourceforgeのsakura-edtiorプロジェクトRSS
	ダウンロード対象をこのRSSから検索します。
	初期値:https://sourceforge.net/projects/sakura-editor/rss

3. GitHub sakura-editor Release URL(API)
	ダウンロード対象を、このURLから検索します。
	初期値:https://api.github.com/repos/sakura-editor/sakura/releases/latest

4. ヘルプファイルのリリースURL(未指定時はSFから自動取得)
	ヘルプファイルダウンロード対象を、このURLから検索します。
	初期値:https://sourceforge.net/projects/sakura-editor/rss?path=/help2


5. 正規表現ライブラリのリリースURL(未指定時はSFから自動取得)
	正規表現ライブラリのダウンロード対象を、このURLから検索します。
	初期値:https://api.bitbucket.org/2.0/repositories/k_takata/bregonig/downloads


6. 独自リリース用URL(file:// or http://)
	社内ネット等インターネット以外からダウンロードする際のURL
	※未実装のため現時点では無効
	初期値はダミー

7. プラグインのリリースURL
	このプラグインを更新するためのURL
	初期値:https://github.com/osaboo/sakuraupdate/releases

8. 最近の更新チェック日
	更新チェックした最終日。この日から頻度で設定した日数を経過するとチェックします。

9. 更新チェックの頻度(単位=日、空白=自動チェックしない)
	日単位でチェック頻度を指定します。

10. Debug Level (0=NODEBUG)
	1あるいは2でアウトプットウィンドウに詳細なログを出力します。

## 仕様メモ

* 更新対象は、サクラエディタ本体、ヘルプファイル、正規表現ライブラリの3つのみ
* 対象のサクラエディタはVer2以降の32bit版
* 動作OSは、XP以降
* C:\Program Files配下へのコピー時は管理者モードでコピー
* SourceForgeとGithubのどちらでもダウンロード可能とする
* サクラエディタのダウンロードは、SFとGitHubの2種類から選べる
* ヘルプファイルは現状SFのみだが、将来GitHubにリリースされれば取得可能とする
* ヘルプファイル自身にバージョン情報が無いためタイムスタンプで判定
* ネットからのダウンロードは、MSXMLを使わずcURLで取得。（環境依存の回避)
* zip展開は、7zのコマンドライン版を使用。(これも環境依存の回避)
* vbsをjsに移行したい

## 著作権表示

1. サクラエディタは、Norio Nakatani & Collaboratorsが開発・配布しているフリー・ソフトウェアです。
https://sakura-editor.github.io/

2. 正規表現ライブラリ bregonig.dllは、 K.Takata (高田 謙)氏が開発・配布しているフリー・ソフトウェアです。
http://k-takata.o.oo7.jp/mysoft/bregonig.html

3. 同封のcurl.exeはDirk Paehl氏がコンパイル・配布しているものです。
http://www.paehl.com/open_source/?CURL_7.61.0

4. 同封の7za.exeは、GNU LGPLでライセンスされている、Igor Pavlovの著作物です。
	```
	7-Zip Extra is package of extra modules of 7-Zip. 
	7-Zip Copyright (C) 1999-2018 Igor Pavlov.
	7-Zip is free software. Read License.txt for more information about license.
	Source code of binaries can be found at:
	  http://www.7-zip.org/
	```
