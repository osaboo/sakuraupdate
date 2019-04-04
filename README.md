# sakuraupdate
Sakura-Editor Update Plugin (v20190402 (beta))

プラグインでサクラエディタのバージョンアップ機能を実装してみる

## 機能

1. 次のプログラム・ファイルをインターネットからダウンロードして更新します。

	* サクラエディタ本体
	* ヘルプファイル
	* 正規表現ライブラリ
	* Diffコマンド
	* Ctagsコマンド
	* 当プラグイン自身

2. サクラエディタ起動時(正確には編集開始時)に自動的にチェックすることができます。

	自動チェックは初期設定で7日単位で、無効にすることもできます。  
	手動によるチェックもできます。

3. サクラエディタのプレリリース版を反映可能です。

	2019.3.27からリリースされているプレリリース版をダウンロード可能です。  
	オプションの「プレリリース版のダウンロード可否」で設定を変更できます。

4. **2019.4.2現在、「更新チェック」の実行がWindows10のDeffenderの誤検知によりブロックされるようです。オンデマンドスキャンでは検知ありません。**  
  すみませんが、まだ検知される個所が特定できていないため、誤検知が出た場合は、「更新チェック」を使わず個別でアップデートするか、pluginのsakuraupdateフォルダをウイルス検査対象から除外設定して対応ください。

5. 更新バッチが動作する際に、PowerShellの実行で警告が出ることがあります。  
	その際は、[R]で実行を選択ください。

## インストール手順

1. サクラエディタを起動し、メニューから設定⇒共通設定を起動し、プラグインのタブを表示します。

2. 「プラグインを有効にする」のチェックボックスのチェックを入れます。  
	（入っている場合はそのままでよいです)  

3. 「ZIPプラグインを導入」ボタンをクリックします。  
	ここで「Pluginフォルダがありません」と表示されたら、一度「フォルダを開く」をクリックしてからやり直してください。

	zipプラグインが使えない場合(v2.0.6.0より前)は、zipを展開してpluginsフォルダにsakuraupdateフォルダを作って保存し、「新規プラグインの追加」を実行してください。

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
	 └DIFF更新  
	 └CTAGS更新  
	 └このプラグインの更新  

2. 更新チェック  
	各ソフトウェアの最新版が更新されているかを、まとめて確認します。  
	確認結果をアウトプットウィンドウに表示します。  
	更新可能な場合は更新することができます。  
	また、編集開始時に自動的に更新チェックします。(オプションで無効化および確認頻度を設定可能)  
	自動更新時は、更新可能なソフトウェアがあった場合のみアウトプットウィンドウに表示します。

3. サクラエディタ更新  
	サクラエディタ本体のみを更新します。

4. ヘルプファイル更新  
	ヘルプファイルのみを更新します。
	sakura.chmの他、macro.chm, plugin.chmも不足していれば追加・更新します。

5. 正規表現ライブラリ更新  
	正規表現ライブラリのみを更新します。

6. DIFF更新  
	DIFFコマンドのみを更新します。

7. CTAGS更新  
	CTAGSコマンドのみを更新します。

8. このプラグインの更新  
	sakuraupdateプラグインのみを更新します。

## オプション設定

1. ダウンロードサイト  
	GitHub:0 SourceForge:1 OSDN:2 Custom:3  
	から選びます。  
	初期値: GitHub:0
	※Customは未実装のため現時点では無効

2. sourceforgeのsakura-edtiorプロジェクトRSS  
	ダウンロード対象をこのRSSから検索します。  
	初期値:https://sourceforge.net/projects/sakura-editor/rss

3. OSDNのSakura Editor Downloads RSS  
	ダウンロード対象を、このURLから検索します。  
	初期値:https://osdn.net/projects/sakura-editor/releases/rss

4. GitHub sakura-editor Release URL(API)  
	ダウンロード対象を、このURLから検索します。  
	初期値:https://api.github.com/repos/sakura-editor/sakura/releases/latest

5. プレリリース版のダウンロード可否  
    未設定:0 プレリリースもダウンロード:1 リリース版のみ:2  
    から選びます。1の場合、サクラエディタのプレリリース版が出ていればダウンロードします。  
    更新チェック時に初回のみ画面で選択します。  
    初期値：0

6. ヘルプファイルのリリースURL  
	ヘルプファイルダウンロード対象を、このURLから検索します。  
	(未指定時は自動チェック対象外。未指定時も手動更新ではSFから自動取得)  
	初期値:https://sourceforge.net/projects/sakura-editor/rss?path=/help2

7. 正規表現ライブラリのリリースURL  
	正規表現ライブラリのダウンロード対象を、このURLから検索します。  
	(未指定時は自動チェック対象外。未指定時も手動更新ではSFから自動取得)  
	初期値:https://api.bitbucket.org/2.0/repositories/k_takata/bregonig/downloads

8. DIFFのリリースURL  
	DIFFのダウンロード対象のURLを指定します。  
	(未指定時は取得しない)  
	初期値:http://www.ring.gr.jp/archives/text/TeX/ptex-win32/w32/patch-diff-w32.zip  
	一度配置されると、自動チェックではバージョンアップしない。手動更新で更新可能。

9. CTAGSのリリースURL  
	CTAGSのダウンロード対象のURLを指定します。  
	(未指定時は取得しない)  
	初期値:http://hp.vector.co.jp/authors/VA025040/ctags/  
	他に設定可能な値:https://api.github.com/repos/universal-ctags/ctags-win32/releases  
	一度配置されると、自動チェックではバージョンアップしない。手動更新で更新可能。

10. 独自リリース用URL(file:// or http://)  
	社内ネット等インターネット以外からダウンロードする際のURL  
	※未実装のため現時点では無効  
	初期値はダミー

11. プラグインのリリースURL  
	このプラグインを更新するためのURL  
	初期値:https://api.github.com/repos/osaboo/sakuraupdate/releases

12. 最近の更新チェック日  
	更新チェックした最終日。この日から頻度で設定した日数を経過すると編集開始時に自動チェックします。

13. 更新チェックの頻度(単位=日、空白=自動チェックしない)  
	日単位で自動チェック頻度を指定します。  
	初期値: 7(日)

14. Debug Level (0=NODEBUG)  
	1あるいは2。アウトプットウィンドウに詳細なログを出力します。  
	初期値: 0

## 仕様メモ

* 更新対象は、サクラエディタ本体、ヘルプファイル、正規表現ライブラリ、diff、プラグイン自身
* 対象のサクラエディタはVer2以降の32bit版
* 動作OSは、XP以降
* C:\Program Files配下へのコピー時は管理者モードでコピー
* SourceForgeとGithub、OSDNのどれでもダウンロード可能とする
* サクラエディタのダウンロードは、SFとGitHub,OSDNの3種類から選べる
* ヘルプファイルは現状SFのみだが、将来GitHubやOSDNにリリースされれば取得可能とする
* ヘルプファイル自身にバージョン情報が無いためタイムスタンプで判定
* ネットからのダウンロードは、MSXMLでエラーになる場合にCURLで取得。（環境依存の回避)
* zip展開は、7zのコマンドライン版を使用。(これも環境依存の回避)
* 複数更新ある場合は、まとめて更新する
* ctagsを、https://github.com/universal-ctags/ctags-win32/releases からも収集可能とする。  
* 次の動作がOSから割り込むことがある。  
	>パッケージ Microsoft .NET Framework 3.0 の更新 NetFx3 を有効にするために、変更を開始しています。クライアント ID: Windows Optional Component Manager Command-Line。
* マクロヘルプ、プラグインヘルプも無ければダウンロードする
* 次のメッセージが出たら、fix itを適用してください。  
	>エラー: セキュリティで保護されたチャネル サポートでエラーが発生しました  
	http://download.microsoft.com/download/0/6/5/0658B1A7-6D2E-474F-BC2C-D69E5B9E9A68/MicrosoftEasyFix51044.msi
* v2.4.0からのbuild式およびプレリリース対応  
	* v2.4.0からのexe.zipには、sakura.exe以外にヘルプファイル,ctags,bregonigも同封されている。  
	あとsakura_lang_en_US.dllもある。これは英語モードにしたいときのみ必要。
	ossライセンスファイルも同封されている。これも一緒に展開が必要。  
	sakura-doxygen.chmヘルプファイルは開発者以外は不要かな。
	考え方として、exeのみに絞るか、ヘルプファイルは個別は無しとしてここから取るか。sakura.chm以外はそのままぽい。  
	あと、リリースにはexe.zipの他、installer.zipも含まれる。  
	バージョンアップとしてinstallerを起動するオプションも必要か。  
	とりあえずはsakura.exeとsakura.chmを取り出すことにする。
	
	* プレリリース版はlatestではダウンロードできないため、/latestを取って検索する。  
	ただし、/latestのみにしたい場合のため、
	sakuraupdateプラグインのv20190402アップデート時に、プレリリース版をダウンロードするかのフラグを
	オプションに追加する。フラグはデフォルトで未設定で、初回のみon/offを選択させる。
	offにすれば、リリース版のみ取得する。

## ToDo

* GitHubでの新しいExe配布形式に同封されている英語言語DLL, OSSライセンスファイルの反映
* GitHubでの新しいInstaller配布形式への対応。インストーラの起動ができるといい。
* vbsをjsに移行したい。ソースもきれいにしたい。
* ほんとはチェック・ダウンロード処理はサクラエディタと別プロセスで非同期がいいんだろう
* 新しいキーワード定義あればダウンロードし、タイプ別に自動設定する
* VirtualStoreが有効になっているか判断して無効化する
* 処理後のゴミ掃除(%temp%\sakuraupdateを削除する(Cleanup))

## 著作権表示

0. sakuraupdateは、osabooがzlib/libpngライセンスで開発・配布しているフリー・ソフトウェアです。

	**zlib/libpngライセンス**

	Copyright (c) 2018 osaboo

	本ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、何らの保証もなく提供されます。 本ソフトウェアの使用によって生じるいかなる損害についても、作者は一切の責任を負わないものとします。

	以下の制限に従う限り、商用アプリケーションを含めて、本ソフトウェアを任意の目的に使用し、自由に改変して再頒布することをすべての人に許可します。

	本ソフトウェアの出自について虚偽の表示をしてはなりません。あなたがオリジナルのソフトウェアを作成したと主張してはなりません。 あなたが本ソフトウェアを製品内で使用する場合、製品の文書に謝辞を入れていただければ幸いですが、必須ではありません。  
	ソースを変更した場合は、そのことを明示しなければなりません。オリジナルのソフトウェアであるという虚偽の表示をしてはなりません。  
	ソースの頒布物から、この表示を削除したり、表示の内容を変更したりしてはなりません。

	(ライセンス原文)  
https://opensource.org/licenses/zlib-license.php  
(日本語訳)  
https://ja.osdn.net/projects/opensource/wiki/licenses%2Fzlib_libpng_license  

1. サクラエディタは、Norio Nakatani & Collaboratorsが開発・配布しているフリー・ソフトウェアです。  
https://sakura-editor.github.io/

2. 正規表現ライブラリ bregonig.dllは、 K.Takata (高田 謙)氏が開発・配布しているフリー・ソフトウェアです。  
http://k-takata.o.oo7.jp/mysoft/bregonig.html

3. diff（ディフ）とはファイルの比較を行うためのコマンドで2つのファイル間の違いを出力できるプログラム。(wikipediaより)  
https://ja.wikipedia.org/wiki/Diff

4. Ctagsは、はソース及びヘッダ内にある名前のインデックス（又はタグ）ファイルを生成するプログラム。(wikipediaより)  
https://ja.wikipedia.org/wiki/Ctags

5. 同封のcurl.exeはDirk Paehl氏がコンパイル・配布しているものです。  
http://www.paehl.com/open_source/?CURL_7.61.0

6. 同封の7za.exeは、GNU LGPLでライセンスされている、Igor Pavlovの著作物です。  
	7-Zip Extra is package of extra modules of 7-Zip.   
	7-Zip Copyright (C) 1999-2018 Igor Pavlov.  
	7-Zip is free software. Read License.txt for more information about license.  
	Source code of binaries can be found at:  
	  http://www.7-zip.org/

