// サクラエディタ Migemo(ローマ字インクリメンタル検索)ツールの更新処理
//
// migemo.dllと、dictフォルダのダウンロード
//
// migemo.dllは、プログラムフォルダと同じフォルダ
// dictフォルダもプログラムフォルダと同じフォルダ
// (Editor.GetPluginDir()+"/../"+)sakura.iniの
// [Common]
//  szMigemoDict=dict
//  szMigemoDll=migemo.dll
// を更新して、サクラエディタを再起動する（or 再起動後に反映とメッセージ出す)

(function() {
    var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);
    var wchk;
    var wurl = ["",""];
    var wnewver;

    // https://files.kaoriya.net/goto/cmigemo_w32"
    Editor.ActivateWinOutput();

    Tools.log("\r\n" + "★★sakuraupdate " + Tools.Version + "★★", 0);
    Tools.log("Migemo(ローマ字インクリメンタル検索)ツールを配置します。", 0);

    wchk = Tools.MigemoCheck(2, wnewver, wurl);
    if ( wchk == null ) { return; }

    if ( wchk == false ) {
        if ( Tools.WSH.Popup("すでに配置済みですが、更新しますか?", 0, "ソフトウェアの更新", 4) == 7 ) {
            return;
        }
    }

     // WorkDirを空にする。
    Tools.WorkCleanup(true);

    if ( Tools.MigemoDownload(wurl[0]) == false ) {
        return;
    }

    Tools.FileSetup(["dict", "migemo.dll"]);

}());
