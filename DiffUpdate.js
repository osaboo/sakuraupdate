//
// �T�N���G�f�B�^ Diff(����)�c�[���̍X�V����
// 
(function() {
    var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);
    
    var wchk;
    var wurl = [""];
    var wnewver = [""];

    Editor.ActivateWinOutput;

    Tools.log("\r\n" + "����sakuraupdate " + Tools.Version + "����", 0);
    Tools.log("Diff(����)�c�[����z�u���܂��B", 0);

     // WorkDir����ɂ���B
    Tools.WorkCleanup(true);

    wchk = Tools.DiffCheck(2, wnewver, wurl);
    if ( wchk == null ) { return; }

    if ( wchk == false ) {
        if ( Tools.WSH.Popup("���łɔz�u�ς݂ł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) == 7 ) {
            return;
        }
    }

    if ( Tools.DiffDownload(wurl[0]) == false ) {
        return;
    }

    Tools.FileSetup(["", "diff.exe"]);

}());
