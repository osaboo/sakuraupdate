//
// サクラエディタ Diff(差分)ツールの更新処理
// 
(function() {
    var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);
    
    var wchk;
    var wurl = [""];
    var wnewver = [""];

    Editor.ActivateWinOutput;

    Tools.log("\r\n" + "★★sakuraupdate " + Tools.Version + "★★", 0);
    Tools.log("Diff(差分)ツールを配置します。", 0);

     // WorkDirを空にする。
    Tools.WorkCleanup(true);

    wchk = Tools.DiffCheck(2, wnewver, wurl);
    if ( wchk == null ) { return; }

    if ( wchk == false ) {
        if ( Tools.WSH.Popup("すでに配置済みですが、更新しますか?", 0, "ソフトウェアの更新", 4) == 7 ) {
            return;
        }
    }

    if ( Tools.DiffDownload(wurl[0]) == false ) {
        return;
    }

    Tools.FileSetup(["", "diff.exe"]);

}());
