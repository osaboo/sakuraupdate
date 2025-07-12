//
//  �S�R���|�[�l���g�̎����X�V�`�F�b�N
//  �O��̃`�F�b�N������X�V�`�F�b�N�̕p�x�̓������o�߂��Ă�����`�F�b�N����B
//
(function() {

    var checkfreq;
    checkfreq = Plugin.GetOption("�T�N���G�f�B�^", "CHECKFREQ");
    //Editor.InfoMsg("checkfreq = "  + checkfreq);
    //Editor.InfoMsg("Number(checkfreq) = " + Number(checkfreq));
    if ( !(Number(checkfreq) > 0) ) {
        return;
    }

	// 2�d�N�����킴�Ƃ��炷���ƂŐ揟���ɂ���
	Editor.Sleep(Math.random() * 1000);

	var lastcheck = Plugin.GetOption("�T�N���G�f�B�^", "LASTCHECK");

    if ( lastcheck ) {
        //Editor.InfoMsg(lastcheck);
        var newcheck = new Date(lastcheck);
        newcheck.setDate(newcheck.getDate() + Number(checkfreq));
        if ( new Date() < newcheck ) {
            return;
        }
    }

    Plugin.SetOption("�T�N���G�f�B�^", "LASTCHECK", new Date());

	var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);
	
	Tools.log("lastcheck = " + lastcheck.toLocaleString(),2);

    // �����`�F�b�N���[�h
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

     // WorkDir����ɂ���B
    Tools.WorkCleanup(true);

    wchk0 = Tools.PluginCheck(amode, wnewver, wurl);
    if ( wchk0 == true ) {
        return;
    }

    wchk1 = Tools.SakuraCheck(amode, wnewver, wurl);

    if ( Plugin.GetOption("�T�N���G�f�B�^", "REGEXPURL") != "" ) {
        wchk3 = Tools.RegExpCheck(amode, wnewver, wurl);
    }

//    if ( Plugin.GetOption("�T�N���G�f�B�^", "DIFFURL") != "" ) {
//        wchk4 = Tools.DiffCheck(amode, wnewver, wurl);
//    }
//
//    if ( Plugin.GetOption("�T�N���G�f�B�^", "CTAGSURL") != "" ) {
//        wchk5 = Tools.CtagsCheck(amode, wnewver, wurl);
//    }
//
//    if ( Plugin.GetOption("�T�N���G�f�B�^", "MIGEMOURL") != "" ) {
//        wchk6 = Tools.MigemoCheck(amode, wnewver, wurl);
//    }

}());
