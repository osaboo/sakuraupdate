// �T�N���G�f�B�^ Migemo(���[�}���C���N�������^������)�c�[���̍X�V����
//
// migemo.dll�ƁAdict�t�H���_�̃_�E�����[�h
//
// migemo.dll�́A�v���O�����t�H���_�Ɠ����t�H���_
// dict�t�H���_���v���O�����t�H���_�Ɠ����t�H���_
// (Editor.GetPluginDir()+"/../"+)sakura.ini��
// [Common]
//  szMigemoDict=dict
//  szMigemoDll=migemo.dll
// ���X�V���āA�T�N���G�f�B�^���ċN������ior �ċN����ɔ��f�ƃ��b�Z�[�W�o��)

(function() {
    var toolsfile = "script:" + Plugin.GetPluginDir() + "\\tools-js.wsc";
    var Tools = GetObject(toolsfile);
    Tools.Init(Editor, Plugin);
    var wchk;
    var wurl = ["",""];
    var wnewver;

    // https://files.kaoriya.net/goto/cmigemo_w32"
    Editor.ActivateWinOutput();

    Tools.log("\r\n" + "����sakuraupdate " + Tools.Version + "����", 0);
    Tools.log("Migemo(���[�}���C���N�������^������)�c�[����z�u���܂��B", 0);

    wchk = Tools.MigemoCheck(2, wnewver, wurl);
    if ( wchk == null ) { return; }

    if ( wchk == false ) {
        if ( Tools.WSH.Popup("���łɔz�u�ς݂ł����A�X�V���܂���?", 0, "�\�t�g�E�F�A�̍X�V", 4) == 7 ) {
            return;
        }
    }

     // WorkDir����ɂ���B
    Tools.WorkCleanup(true);

    if ( Tools.MigemoDownload(wurl[0]) == false ) {
        return;
    }

    Tools.FileSetup(["dict", "migemo.dll"]);

}());
