//
// �v���O�C���̍X�V����
// 
(function() {
    var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);

    var wchk;
    var wurl = ["",""];
    var wnewver = [""];

    Editor.ActivateWinOutput;

    Tools.log("\r\n" + "����sakuraupdate " + Tools.Version + "����", 0);
    Tools.log("sakuraupdate�v���O�C�����ŐV�o�[�W�����ɍX�V���܂��B", 0);

     // WorkDir����ɂ���B
    Tools.WorkCleanup(false);

    wchk = Tools.PluginCheck(2, wnewver, wurl);
    if ( wchk == null ) { return; }

    if ( wchk == false ) {
        if ( Tools.WSH.Popup("���łɍŐV�łł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) == 7 ) {
            return;
        }
    }

    if ( Tools.PluginDownload(wurl[0]) == false ) {
        return;
    }

    Tools.PluginSetup("plugin");

}());
