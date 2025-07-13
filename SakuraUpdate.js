//
// サクラエディタ本体の更新処理
// 
// 更新はexe形式のファイルをダウンロードして実行する

(function() {
    var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);
    
    var wchk;
    var wurl = ["",""];
    var wnewver = [""];

    Editor.ActivateWinOutput;

    Tools.log("\r\n" + "★★sakuraupdate " + Tools.Version + "★★", 0);
    Tools.log("サクラエディタを最新バージョンに更新します。", 0);

     // WorkDirを空にする。
    Tools.WorkCleanup(false);

    wchk = Tools.SakuraCheck(2, wnewver, wurl);
    if ( wchk == null ) { return; }

    if ( wchk == false ) {
        if ( Tools.WSH.Popup("すでに最新版ですが、更新しますか?", 0, "ソフトウェアの更新", 4) == 7 ) {
            return;
        }
    } else if ( wchk > 0 ) {
        if ( Tools.WSH.Popup("新しいプレリリース版(" + wnewver + ")があります。更新しますか?", 0, "ソフトウェアの更新", 4) == 7 ) {
            return;
        }
    }

	if (wurl[0].indexOf("github.com") >= 0 && wurl[0].indexOf("actions") >= 0 ){
		Tools.WSH.Popup("GitHubActionsビルド版は、正式リリース前の開発版のため、動作が予告なく変更されたり、不具合がある可能性があります。" + 
			            "不具合を報告する場合は使用バージョンを確認し「開発版を利用していること」を添えて報告しましょう。",0,"★開発版利用の注意事項★");
	}
	
	var installexe = Tools.SakuraDownload(wurl);
    if ( !installexe ) {
        return;
    }

    if (Tools.SakuraSetup(installexe)) {
    	if (wurl[1]) {
	    	Plugin.SetOption("サクラエディタ", "LASTCHECKID", wurl[1]);
	    }
    }

}());
