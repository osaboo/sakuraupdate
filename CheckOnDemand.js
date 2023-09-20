/**
 *	�S�R���|�[�l���g�̍X�V�`�F�b�N(�I���f�}���h)
 */
(function() {
    "use strict";

    toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);

    // �X�V�`�F�b�N
    // amode = 1:�������[�h,  2:�蓮���[�h
    amode = 2;

    var lastcheck = Date;
    Plugin.SetOption("�T�N���G�f�B�^", "LASTCHECK", lastcheck);

    var wurl = [""];
    var wnewver = [""];
    var wchk0;
    var wchk1;
    var wchk2;
    var wchk3;
    var wchk4;
    var wtargets = [];

    Editor.ActivateWinOutput;
    Tools.log("\n����sakuraupdate " + Tools.Version + "����", 0);

     // WorkDir����ɂ���B
    Tools.WorkCleanup(true);

    Tools.log("\n�v���O�C���̍ŐV�o�[�W�������m�F���܂��B", 0);
    wchk0 = Tools.PluginCheck(amode, wnewver, wurl);
    if ( wchk0 == true ) {
        if ( Tools.PluginDownload(wurl) == true ) {
            Tools.PluginSetup("plugin");
        }
        // �v���O�C���̍X�V���͑��̍X�V�͎~�߂�
        return;
    }

    Tools.log("\n�T�N���G�f�B�^�{�̂̍ŐV�o�[�W�������m�F���܂��B", 0);
    wchk1 = Tools.SakuraCheck(amode, wnewver, wurl);
    if ( wchk1 ) {
		if (wurl[0].indexOf("appveyor.com") >= 0){
			Tools.WSH.Popup("AppVeyor�r���h�ł́A���������[�X�O�̊J���ł̂��߁A���삪�\���Ȃ��ύX���ꂽ��A�s�������\��������܂��B" + 
				            "�s���񍐂���ꍇ�͎g�p�o�[�W�������m�F���u�J���ł𗘗p���Ă��邱�Ɓv��Y���ĕ񍐂��܂��傤�B",0,"���J���ŗ��p�̒��ӎ�����");
		}
		var installexe = Tools.SakuraDownload(wurl[0]);
	    if ( !installexe ) {
	        return;
	    }
	    Tools.SakuraSetup(installexe);
        // �T�N���G�f�B�^�{�̂̍X�V���͑��̍X�V�͎~�߂�
        return;
    }

    if ( Plugin.GetOption("�T�N���G�f�B�^", "REGEXPURL") != "" ) {
        Tools.log("\n���K�\�����C�u�����̍ŐV�o�[�W�������m�F���܂��B", 0);
        wchk2 = Tools.RegExpCheck(amode, wnewver, wurl);
        if ( wchk2 == true ) {
            if ( Tools.RegExpDownload(wurl) == true ) {
                wtargets.push("bregonig.dll");
            }
        }
    }

    if ( Plugin.GetOption("�T�N���G�f�B�^", "DIFFURL") != "" ) {
        Tools.log("\nDiff(����)�c�[���̍ŐV�o�[�W�������m�F���܂��B", 0);
        wchk3 = Tools.DiffCheck(amode, wnewver, wurl);
        if ( wchk3 == true ) {
            if ( Tools.DiffDownload(wurl) == true ) {
                wtargets.push("diff.exe");
            }
        }
    }

    if ( Plugin.GetOption("�T�N���G�f�B�^", "CTAGSURL") != "" ) {
        Tools.log("\nCtags(�^�O����)�c�[���̍ŐV�o�[�W�������m�F���܂��B", 0);
        wchk4 = Tools.CtagsCheck(amode, wnewver, wurl);
        if ( wchk4 == true ) {
            if ( Tools.CtagsDownload(wurl) == true ) {
                wtargets.push("ctags.exe");
            }
        }
    }

    if ( Plugin.GetOption("�T�N���G�f�B�^", "MIGEMOURL") != "" ) {
        Tools.log("\nMigemo(���[�}���C���N�������^������)�c�[���̍ŐV�o�[�W�������m�F���܂��B", 0);
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
