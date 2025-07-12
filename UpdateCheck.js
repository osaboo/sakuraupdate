//
//  全コンポーネントの自動更新チェック
//  前回のチェック日から更新チェックの頻度の日数を経過していたらチェックする。
//
(function() {

    var checkfreq;
    checkfreq = Plugin.GetOption("サクラエディタ", "CHECKFREQ");
    //Editor.InfoMsg("checkfreq = "  + checkfreq);
    //Editor.InfoMsg("Number(checkfreq) = " + Number(checkfreq));
    if ( !(Number(checkfreq) > 0) ) {
        return;
    }

	// 2重起動をわざとずらすことで先勝ちにする
	Editor.Sleep(Math.random() * 1000);

	var lastcheck = Plugin.GetOption("サクラエディタ", "LASTCHECK");

    if ( lastcheck ) {
        //Editor.InfoMsg(lastcheck);
        var newcheck = new Date(lastcheck);
        newcheck.setDate(newcheck.getDate() + Number(checkfreq));
        if ( new Date() < newcheck ) {
            return;
        }
    }

    Plugin.SetOption("サクラエディタ", "LASTCHECK", new Date());

	var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);
	
	Tools.log("lastcheck = " + lastcheck.toLocaleString(),2);

    // 自動チェックモード
    var amode = 1;
    
    var wurl = ["",""];
    var wnewver = [""]
    var wchk0;
    var wchk1;
    var wchk2;
    var wchk3;
    var wchk4;
    var wchk5;
    var wchk6;
    var wtargets;

    wtargets = [];

     // WorkDirを空にする。
    Tools.WorkCleanup(true);

    wchk0 = Tools.PluginCheck(amode, wnewver, wurl);
    if ( wchk0 == true ) {
        return;
    }

    wchk1 = Tools.SakuraCheck(amode, wnewver, wurl);

    if ( Plugin.GetOption("サクラエディタ", "REGEXPURL") != "" ) {
        wchk3 = Tools.RegExpCheck(amode, wnewver, wurl);
    }

//    if ( Plugin.GetOption("サクラエディタ", "DIFFURL") != "" ) {
//        wchk4 = Tools.DiffCheck(amode, wnewver, wurl);
//    }
//
//    if ( Plugin.GetOption("サクラエディタ", "CTAGSURL") != "" ) {
//        wchk5 = Tools.CtagsCheck(amode, wnewver, wurl);
//    }
//
//    if ( Plugin.GetOption("サクラエディタ", "MIGEMOURL") != "" ) {
//        wchk6 = Tools.MigemoCheck(amode, wnewver, wurl);
//    }

}());
