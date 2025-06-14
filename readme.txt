# sakuraupdate
Sakura-Editor Update Plugin (v20250614 (beta))

プラグインでサクラエディタのバージョンアップ機能を実装してみる

## 機能

1. 次のプログラム・ファイルをインターネットからダウンロードして更新します。

	* サクラエディタ本体
	* ヘルプファイル
	* 正規表現ライブラリ
	* Diffコマンド
	* Ctagsコマンド
	* Migemoライブラリ
	* 当プラグイン自身

2. サクラエディタ起動時(正確には編集開始時)に自動的にチェックすることができます。

	自動チェックは初期設定で7日単位で、無効にすることもできます。  
	手動によるチェックもできます。

3. サクラエディタのプレリリース版およびAppVeyorでの自動ビルド版を反映可能です。

	2019.3.27からリリースされているプレリリース版をダウンロード可能です。  
	オプションの「プレリリース版のダウンロード可否」で設定を変更できます。
	
	AppVeyorでの自動ビルド版をダウンロード可能です。
	オプションの「ダウンロードサイト」でAppVeyorを選択してください。
	
	★開発版利用の注意事項★
	AppVeyorビルド版は、正式リリース前の開発版のため、動作が予告なく変更されたり、不具合がある可能性があります。
	不具合を報告する場合は使用バージョンを確認し「開発版を利用していること」を添えて報告しましょう。
	あとAppVeyorの仕様でビルド後一定期間でファイルが消えると思うので、いつでもダウンロードできるわけではないはず。

4. 更新バッチが動作する際に、PowerShellの実行で実行警告が出ることがあります。  

```
セキュリティ警告
信頼するスクリプトのみを実行してください。インターネットから入手したスクリプトは便利ですが、コンピューターに危害を及ぼ
す可能性があります。このスクリプトを信頼する場合は、この警告メッセージが表示されないように、Unblock-File
コマンドレットを使用して、スクリプトの実行を許可してください。xxxxxxxx.ps1
を実行しますか?
[D] 実行しない(D)  [R] 一度だけ実行する(R)  [S] 中断(S)  [?] ヘルプ (既定値は "D"):
```

その際は、[R]で実行を選択ください。(これはzipプラグインの導入前にダウンロードしたzipファイルのインターネットダウンロード属性を解除しておくことで回避できます)

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
	 └正規表現ライブラリ更新  
	 └DIFF更新  
	 └CTAGS更新  
	 └MIGEMO更新  
	 └このプラグインの更新  

2. 更新チェック  
	各ソフトウェアの最新版が更新されているかを、まとめて確認します。  
	確認結果をアウトプットウィンドウに表示します。  
	更新可能な場合は更新することができます。  
	また、編集開始時に自動的に更新チェックします。(オプションで無効化および確認頻度を設定可能)  
	自動更新時は、更新可能なソフトウェアがあった場合のみアウトプットウィンドウに表示します。

3. サクラエディタ更新  
	サクラエディタ本体のみを更新します。
	更新はファイル単位ではなく、インストーラ起動による上書き動作になります。

4. 正規表現ライブラリ更新  
	正規表現ライブラリのみを更新します。

5. DIFF更新  
	DIFFコマンドのみを更新します。

6. CTAGS更新  
	CTAGSコマンドのみを更新します。

7. MIGEMO更新  
	MIGEMOのみを更新します。

8. このプラグインの更新  
	sakuraupdateプラグインのみを更新します。

## オプション設定

1. ダウンロードサイト  
	GitHub:0 AppVeyor:1 OSDN:2 Custom:3 
	から選びます。  
	初期値: GitHub:0  
	※Customは未実装のため現時点では無効

2. GitHub sakura-editor Release URL(API)  
	ダウンロード対象を、このURLから検索します。  
	初期値:https://api.github.com/repos/sakura-editor/sakura/releases/latest

3. AppVeyor sakura-editor Project URL(API)  
	ダウンロード対象を、このURLから検索します。  
	初期値:https://ci.appveyor.com/api/projects/sakuraeditor/sakura

4. OSDNのSakura Editor Downloads RSS  
	ダウンロード対象を、このURLから検索します。  
	初期値:https://osdn.net/projects/sakura-editor/releases/rss

5. GitHubプレリリース版のダウンロード可否  
    未設定:0 プレリリースもダウンロード:1 リリース版のみ:2  
    から選びます。1の場合、サクラエディタのプレリリース版が出ていればダウンロードします。  
    更新チェック時に初回のみ画面で選択します。  
    初期値：0

6. 正規表現ライブラリのリリースURL  
	正規表現ライブラリのダウンロード対象を、このURLから検索します。  
	(未指定時は自動チェック対象外。未指定時も手動更新ではSFから自動取得)  
	初期値:https://api.bitbucket.org/2.0/repositories/k_takata/bregonig/downloads

7. DIFFのリリースURL  
	DIFFのダウンロード対象のURLを指定します。  
	(未指定時は取得しない)  
	初期値:http://www.ring.gr.jp/archives/text/TeX/ptex-win32/w32/patch-diff-w32.zip  
	一度配置されると、自動チェックではバージョンアップしない。手動更新で更新可能。

8. CTAGSのリリースURL  
	CTAGSのダウンロード対象のURLを指定します。  
	(未指定時は取得しない)  
	初期値:https://api.github.com/repos/universal-ctags/ctags-win32/releases  
	他に設定可能な値:http://hp.vector.co.jp/authors/VA025040/ctags/  
	一度配置されると、自動チェックではバージョンアップしない。手動更新で更新可能。

9. MIGEMOのリリースURL  
	MIGEMOのダウンロード対象のURLを指定します。  
	(未指定時は取得しない)  
	初期値:https://files.kaoriya.net/goto/cmigemo_w32  
	一度配置されると、自動チェックではバージョンアップしない。手動更新で更新可能。

10. 独自リリース用URL(file:// or http://)  
	社内ネット等インターネット以外からダウンロードする際のURL  
	※未実装のため現時点では無効  
	初期値はダミー

11. プラグインのリリースURL  
	このプラグインを更新するためのURL  
	初期値:https://api.github.com/repos/osaboo/sakuraupdate/releases

12. 更新チェックの頻度(単位=日、空白=自動チェックしない)  
	日単位で自動チェック頻度を指定します。  
	初期値: 7(日)

13. 最近の更新チェック日  
	更新チェックした最終日。この日から頻度で設定した日数を経過すると編集開始時に自動チェックします。

14. XMLHTTPRequestを使わずCURLの使用を強制する
	0または1。1の場合XMLHTTPRequestを使わずにCURLでインターネットからファイルを得る。
	初期値: 0

15. CURLのinsecureオプション
	0または1。1の場合CURLに--insecureオプションを付加して実行します。証明書の問題を無視しますのでリスク理解した上で設定のこと。
	初期値: 0

15. サクラエディタのセットモード
    サクラエディタの更新時の動作を、0=画面応答あり、1=インストーラを自動モードにする
    初期値: 0

16. Debug Level (0=NODEBUG)  
	1-3。アウトプットウィンドウに詳細なログを出力します。  
	初期値: 0

## 仕様メモ

* 更新対象は、サクラエディタ本体、正規表現ライブラリ、diff、プラグイン自身
* 対象のサクラエディタはVer2以降の32bit版
* 動作OSは、XP以降
* C:\Program Files配下へのコピー時は管理者モードでコピー
* サクラエディタのダウンロードは、GitHubかOSDNの2種類から選べる(SourceForgeのダウンロードは廃止)
* ヘルプファイルはインストーラに含まれる想定として個別ダウンロードは廃止
* ネットからのダウンロードは、MSXMLでエラーになる場合にCURLで取得。（環境依存の回避)
* zip展開は、7zのコマンドライン版を使用。(これも環境依存の回避)
* 複数更新ある場合は、まとめて更新する
* ctagsを、https://github.com/universal-ctags/ctags-win32/releases からも収集可能とする。  
* 次の動作がOSから割り込むことがある。  
	>パッケージ Microsoft .NET Framework 3.0 の更新 NetFx3 を有効にするために、変更を開始しています。クライアント ID: Windows Optional Component Manager Command-Line。
* 次のメッセージが出たら、fix itを適用してください。  
	>エラー: セキュリティで保護されたチャネル サポートでエラーが発生しました  
	http://download.microsoft.com/download/0/6/5/0658B1A7-6D2E-474F-BC2C-D69E5B9E9A68/MicrosoftEasyFix51044.msi
* v2.4.0からのbuild式およびプレリリース対応  
	* v2.4.0からのexe.zipには、sakura.exe以外にヘルプファイル,ctags,bregonigも同封されている。  
	あとsakura_lang_en_US.dllもある。これは英語モードにしたいときのみ必要。
	ossライセンスファイルも同封されている。これも一緒に展開が必要。  
	sakura-doxygen.chmヘルプファイルは開発者以外は不要かな。
	考え方として、exeのみに絞るか、ヘルプファイルは個別は無しとしてここから取るか。sakura.chm以外はそのままぽい。  
	リリースにはexe.zipの他、installer.zipも含まれるので、バージョンアップとしてinstallerを起動するようにする。
	
	* プレリリース版はlatestではダウンロードできないため、/latestを取って検索する。  
	ただし、/latestのみにしたい場合のため、
	sakuraupdateプラグインのv20190402アップデート時に、プレリリース版をダウンロードするかのフラグを
	オプションに追加する。フラグはデフォルトで未設定で、初回のみon/offを選択させる。
	offにすれば、リリース版のみ取得する。

* .NET 3.5xのインストールを要求する原因がわかった。どうも .NET 4.5から、VBSで.NET のオブジェクトが呼び出しできない。
   なので、System.Text.StringBuilderを使わない実装にした。

* インストーラ形式に対応するために、サクラエディタ本体の更新はインストーラを起動するが、
  その場合は同時に更新が検出された他のコンポーネントは無視する。（プラグインと同じ）

* なんとかvbsからjsに変更した。(残念ながら技術不足で今時ではない)
  JScriptなのでjsc.exeでコンパイルチェックするようにした。
  %SystemRoot%\Microsoft.NET\Framework\v4.0.30319\jsc.exe /warnaserror %APPDATA%\sakura\plugins\sakuraupdate\tools.js

* 開発版もダウンロードできるようにしてみた。
  注意書きで、開発版であることの注意点を補記した。

* CURL.exeの添付をやめてWindows標準を使用するようにした。

## ToDo

* ほんとはチェック・ダウンロード処理はサクラエディタと別プロセスで非同期がいいんだろう
* 新しいキーワード定義あればダウンロードし、タイプ別に自動設定する
* VirtualStoreが有効になっているか判断して無効化する
* 処理後のゴミ掃除(%temp%\sakuraupdateを削除する(Cleanup))

## 著作権表示

0. sakuraupdateは、osabooがzlib/libpngライセンスで開発・配布しているフリー・ソフトウェアです。
   サクラエディタプロジェクト公式のものではなく、個人的に開発・配布しています。

	**zlib/libpngライセンス**

	Copyright (c) 2018 osaboo

	本ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、何らの保証もなく提供されます。 本ソフトウェアの使用によって生じるいかなる損害についても、作者は一切の責任を負わないものとします。

	以下の制限に従う限り、商用アプリケーションを含めて、本ソフトウェアを任意の目的に使用し、自由に改変して再頒布することをすべての人に許可します。

	1. 本ソフトウェアの出自について虚偽の表示をしてはなりません。あなたがオリジナルのソフトウェアを作成したと主張してはなりません。 あなたが本ソフトウェアを製品内で使用する場合、製品の文書に謝辞を入れていただければ幸いですが、必須ではありません。

	2. ソースを変更した場合は、そのことを明示しなければなりません。オリジナルのソフトウェアであるという虚偽の表示をしてはなりません。

	3. ソースの頒布物から、この表示を削除したり、表示の内容を変更したりしてはなりません

  (ライセンス原文)  
  https://opensource.org/license/zlib/

  (日本語訳)  
  https://licenses.opensource.jp/Zlib/Zlib.html

1. サクラエディタは、Norio Nakatani & Collaboratorsが開発・配布しているフリー・ソフトウェアです。  
  https://sakura-editor.github.io/

2. 正規表現ライブラリ bregonig.dllは、 K.Takata (高田 謙)氏が開発・配布しているフリー・ソフトウェアです。  
  http://k-takata.o.oo7.jp/mysoft/bregonig.html

3. diff（ディフ）とはファイルの比較を行うためのコマンドで2つのファイル間の違いを出力できるプログラム。(wikipediaより)  
  https://ja.wikipedia.org/wiki/Diff

4. Ctagsは、はソース及びヘッダ内にある名前のインデックス（又はタグ）ファイルを生成するプログラム。(wikipediaより)  
  https://ja.wikipedia.org/wiki/Ctags

5. Migemoはローマ字のまま日本語をインクリメンタル検索するためのツールです。<br>
  Satoru Takabayashi氏が開発・配布しているフリー・ソフトウェアです。  
  http://0xcc.net/migemo/<br>
  サクラエディタでは、Migemoのdll版であるC/Migemoを使用できます。<br>
  C/Migemoは、MURAOKA Taro (KoRoN)氏が開発・配布しているフリー・ソフトウェアです。  
  http://www.kaoriya.net/software/cmigemo/

6. 同封の7za.exeは、GNU LGPLでライセンスされている、Igor Pavlovの著作物です。  
  7-Zip Extra is package of extra modules of 7-Zip.   
  7-Zip Copyright (C) 1999-2018 Igor Pavlov.  
  7-Zip is free software. Read License.txt for more information about license.  
  Source code of binaries can be found at:  
  http://www.7-zip.org/
