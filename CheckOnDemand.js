/**
 *	全コンポーネントの更新チェック(オンデマンド)
 */
(function() {
    "use strict";

    toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);

    // 更新チェック
    // amode = 1:自動モード,  2:手動モード
    amode = 2;

    var lastcheck = Date;
    Plugin.SetOption("サクラエディタ", "LASTCHECK", lastcheck);

    var wurl = [""];
    var wnewver = [""];
    var wchk0;
    var wchk1;
    var wchk2;
    var wchk3;
    var wchk4;
    var wtargets = [];

    Editor.ActivateWinOutput;
    Tools.log("\n★★sakuraupdate " + Tools.Version + "★★", 0);

     // WorkDirを空にする。
    Tools.WorkCleanup(true);

    Tools.log("\nプラグインの最新バージョンを確認します。", 0);
    wchk0 = Tools.PluginCheck(amode, wnewver, wurl);
    if ( wchk0 == true ) {
        if ( Tools.PluginDownload(wurl) == true ) {
            Tools.PluginSetup("plugin");
        }
        // プラグインの更新時は他の更新は止める
        return;
    }

    Tools.log("\nサクラエディタ本体の最新バージョンを確認します。", 0);
    wchk1 = Tools.SakuraCheck(amode, wnewver, wurl);
    if ( wchk1 ) {
		if (wurl[0].indexOf("appveyor.com") >= 0){
			Tools.WSH.Popup("AppVeyorビルド版は、正式リリース前の開発版のため、動作が予告なく変更されたり、不具合がある可能性があります。" + 
				            "不具合を報告する場合は使用バージョンを確認し「開発版を利用していること」を添えて報告しましょう。",0,"★開発版利用の注意事項★");
		}
		var installexe = Tools.SakuraDownload(wurl[0]);
	    if ( !installexe ) {
	        return;
	    }
	    Tools.SakuraSetup(installexe);
        // サクラエディタ本体の更新時は他の更新は止める
        return;
    }

    if ( Plugin.GetOption("サクラエディタ", "REGEXPURL") != "" ) {
        Tools.log("\n正規表現ライブラリの最新バージョンを確認します。", 0);
        wchk2 = Tools.RegExpCheck(amode, wnewver, wurl);
        if ( wchk2 == true ) {
            if ( Tools.RegExpDownload(wurl) == true ) {
                wtargets.push("bregonig.dll");
            }
        }
    }

    if ( Plugin.GetOption("サクラエディタ", "DIFFURL") != "" ) {
        Tools.log("\nDiff(差分)ツールの最新バージョンを確認します。", 0);
        wchk3 = Tools.DiffCheck(amode, wnewver, wurl);
        if ( wchk3 == true ) {
            if ( Tools.DiffDownload(wurl) == true ) {
                wtargets.push("diff.exe");
            }
        }
    }

    if ( Plugin.GetOption("サクラエディタ", "CTAGSURL") != "" ) {
        Tools.log("\nCtags(タグ生成)ツールの最新バージョンを確認します。", 0);
        wchk4 = Tools.CtagsCheck(amode, wnewver, wurl);
        if ( wchk4 == true ) {
            if ( Tools.CtagsDownload(wurl) == true ) {
                wtargets.push("ctags.exe");
            }
        }
    }

    if ( Plugin.GetOption("サクラエディタ", "MIGEMOURL") != "" ) {
        Tools.log("\nMigemo(ローマ字インクリメンタル検索)ツールの最新バージョンを確認します。", 0);
        var wchk5 = Tools.MigemoCheck(amode, wnewver, wurl);
        if ( wchk5 == true ) {
            if ( Tools.MigemoDownload(wurl) == true ) {
                wtargets.push("dict");
                wtargets.push("migemo.dll");
            }
        }
    }

    if ( wtargets.length > 0 ) {
        Tools.FileSetup(wtargets);
    }
    
}());
