//
// サクラエディタ 正規表現ライブラリの更新処理
// 
(function() {
    var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);

    var wchk;
    var wurl = [""];
    var wnewver;

    Editor.ActivateWinOutput;

    Tools.log("\r\n" + "★★sakuraupdate " + Tools.Version + "★★", 0);
    Tools.log("正規表現ライブラリを最新バージョンに更新します。", 0);

     // WorkDirを空にする。
    Tools.WorkCleanup(true);

    wchk = Tools.RegExpCheck(2, wnewver, wurl);
    if ( wchk == null ) { return; }

    if ( wchk == false ) {
        if ( Tools.WSH.Popup("すでに最新版ですが、更新しますか?", 0, "ソフトウェアの更新", 4) == 7 ) {
            return;
        }
    }

    if ( Tools.RegExpDownload(wurl[0]) == false ) {
        return;
    }

    Tools.FileSetup(["bregonig.dll"]);
}());
