//
// �T�N���G�f�B�^�{�̂̍X�V����
// 
// �X�V��exe�`���̃t�@�C�����_�E�����[�h���Ď��s����

(function() {
    var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);
    
    var wchk;
    var wurl = [""];
    var wnewver = [""];

    Editor.ActivateWinOutput;

    Tools.log("\r\n" + "����sakuraupdate " + Tools.Version + "����", 0);
    Tools.log("�T�N���G�f�B�^���ŐV�o�[�W�����ɍX�V���܂��B", 0);

     // WorkDir����ɂ���B
    Tools.WorkCleanup(true);

    wchk = Tools.SakuraCheck(2, wnewver, wurl);
    if ( wchk == null ) { return; }

    if ( wchk == false ) {
        if ( Tools.WSH.Popup("���łɍŐV�łł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) == 7 ) {
            return;
        }
    } else if ( wchk > 0 ) {
        if ( Tools.WSH.Popup("�V�����v�������[�X��(" + wnewver + ")������܂��B�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) == 7 ) {
            return;
        }
    }

	if (wurl[0].indexOf("appveyor.com") >= 0){
		Tools.WSH.Popup("AppVeyor�r���h�ł́A���������[�X�O�̊J���ł̂��߁A���삪�\���Ȃ��ύX���ꂽ��A�s�������\��������܂��B" + 
			            "�s���񍐂���ꍇ�͎g�p�o�[�W�������m�F���u�J���ł𗘗p���Ă��邱�Ɓv��Y���ĕ񍐂��܂��傤�B",0,"���J���ŗ��p�̒��ӎ�����");
	}
	
	var installexe = Tools.SakuraDownload(wurl[0]);
    if ( !installexe ) {
        return;
    }

    Tools.SakuraSetup(installexe);

}());
