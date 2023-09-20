
// サクラエディタ Ctags(タグ生成)ツールの更新処理
// 
(function() {
    var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);
    var wchk;
    var wurl = [""];
    var wnewver;

    Editor.ActivateWinOutput();

    Tools.log("\r\n" + "★★sakuraupdate " + Tools.Version + "★★", 0);
    Tools.log("Ctags(タグ生成)ツールを配置します。", 0);

    wchk = Tools.CtagsCheck(2, wnewver, wurl);
    if ( wchk == null ) { return; }

    if ( wchk == false ) {
        if ( Tools.WSH.Popup("すでに配置済みですが、更新しますか?", 0, "ソフトウェアの更新", 4) == 7 ) {
            return;
        }
    }

     // WorkDirを空にする。
    Tools.WorkCleanup(true);

    if ( Tools.CtagsDownload(wurl[0]) == false ) {
        return;
    }

    Tools.FileSetup(["ctags.exe"]);

}());
