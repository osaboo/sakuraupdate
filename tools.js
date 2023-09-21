var  Editor;
var  Plugin;
var  DebugLvl;
var  Version;

var  WorkDir;
var  PluginDir;
var  SakuraDir;

var  CurlExe;
var  CurlInsecure;
var  UnzipExe;

var  FS;
var  WSH;

var  OSVer;

// polyfill
Array.prototype.indexOf = function(obj, start){
    for(var i = (start || 0), j = this.length; i < j; i++){
        if(this[i] === obj){
            return i
        }
    }
    return -1
};

String.prototype.endsWith = function(searchString, position) {
    var s = this.toString();
    if (position === null || position > s.length) {
      position = s.length;
    }
    position -= searchString.length;
    var i = s.indexOf(searchString, position);
    return i !== -1 && i === position;
};

// DebugLvl>=alvl�ŁAamsg��TraceOut����B
function log(amsg, alvl) {
  if ( DebugLvl == "" ) {
    return;
  }
  if (!alvl) {
    alvl = 0;
  }
  if ( (DebugLvl + 0) >= (alvl + 0) ) {
    Editor.TraceOut(amsg);
  }
}

// ������
function Init(editor, plugin) {
  Editor = editor;
  Plugin = plugin;

  Version = "v20230921";

  DebugLvl = Plugin.GetOption("�T�N���G�f�B�^", "DEBUGLVL");

  if ( DebugLvl == "" ) { // �����l���ݒ肳��Ȃ��Â��o�[�W�����̏ꍇ
      Plugin.SetOption("�T�N���G�f�B�^", "SITEPRIORITY", "0");
      Plugin.SetOption("�T�N���G�f�B�^", "GITHUBURL", "https://api.github.com/repos/sakura-editor/sakura/releases/latest");
      Plugin.SetOption("�T�N���G�f�B�^", "APPVEYORURL", "https://ci.appveyor.com/api/projects/sakuraeditor/sakura");
      Plugin.SetOption("�T�N���G�f�B�^", "OSDNURL",  "https://osdn.net/projects/sakura-editor/releases/rss");
      Plugin.SetOption("�T�N���G�f�B�^", "REGEXPURL", "https://api.bitbucket.org/2.0/repositories/k_takata/bregonig/downloads");
      Plugin.SetOption("�T�N���G�f�B�^", "DIFFURL", "http://www.ring.gr.jp/archives/text/TeX/ptex-win32/w32/patch-diff-w32.zip");
      Plugin.SetOption("�T�N���G�f�B�^", "CTAGSURL", "https://api.github.com/repos/universal-ctags/ctags-win32/releases");
      Plugin.SetOption("�T�N���G�f�B�^", "MIGEMOURL", "https://files.kaoriya.net/goto/cmigemo_w32");
      Plugin.SetOption("�T�N���G�f�B�^", "PLUGINURL", "https://api.github.com/repos/osaboo/sakuraupdate/releases");
      Plugin.SetOption("�T�N���G�f�B�^", "CHECKFREQ", "7");
      Plugin.SetOption("�T�N���G�f�B�^", "DEBUGLVL", "0");
      Plugin.SetOption("�T�N���G�f�B�^", "USEPREREL", "0");
      Plugin.SetOption("�T�N���G�f�B�^", "CURLINSECURE", "0");
      DebugLvl = 0;
  }

  OSVer = GetOSInfo();
  //log("OSVer=" + OSVer, 2);

  FS = new ActiveXObject("Scripting.FileSystemObject");

  PluginDir = Plugin.GetPluginDir();
  SakuraDir = FS.GetParentFolderName(Editor.ExpandParameter("$S"));

  CurlExe = "\"" + Plugin.GetPluginDir() + "\\Curl.exe\"";
  CurlInsecure = (Plugin.GetOption("�T�N���G�f�B�^", "CURLINSECURE") == "1");
     // UnzipExe = """" + Plugin.GetPluginDir() + "\\Unzip.exe"""
  UnzipExe = "\"" + Plugin.GetPluginDir() + "\\7za.exe\"";
     // Editor.ActivateWinOutput

  WSH = new ActiveXObject("Wscript.Shell");
  WorkDir = WSH.ExpandEnvironmentStrings("%TEMP%") + "\\sakuraupdate";

  log("�X�V��Ɨp�t�H���_ " + WorkDir, 2);
  if ( ! IsExistDir(WorkDir) ) {
    log("�X�V��Ɨp�t�H���_���쐬���܂�", 2);
    CreateDir(WorkDir);
  }

}

function GetOSInfo() {
    var objLoc;
    var objWMIService;
    var colItems;
    var item;

    objLoc = new ActiveXObject("WbemScripting.SWbemLocator");
    
    objWMIService = objLoc.ConnectServer(); //null, "root\\CIMV2");
//  Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\\\.\\root\\cimv2")
    colItems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem");

    var ret = "";
    var enumSet = new Enumerator(colItems);
    
    while (!enumSet.atEnd()) {
        var item = enumSet.item();
        // aos = item.Caption
        OSVer = item.Version;
        ret = OSVer;
        // abit = item.OSArchitecture
        //log("Win32_OS = " + item.Caption, 0);
        enumSet.moveNext();
    }

    return ret;
}

// WorkDir������ afileony=true�Ńt�@�C���̂ݏ���
function WorkCleanup(afileonly) {

  if ( IsExistDir(WorkDir + "\\install") ) {
      log("install���[�N�f�B���N�g�������B" + WorkDir + "\\install", 3);
      DeleteFile(WorkDir + "\\install\\*.*");
      DeleteDir(WorkDir + "\\install");
  }

  if ( IsExistDir(WorkDir) ) {
    if ( afileonly ) {
      log("���[�N�f�B���N�g�������B" + WorkDir, 2);
      DeleteFile( WorkDir + "\\*.*");
    } else {
      DeleteDir(WorkDir);
    }
  }

}

/** �T�N���G�f�B�^�{�̂̍X�V�`�F�b�N
 * amode = 1:�������[�h,  2:�蓮���[�h
 * �߂�l: 1=�v�������[�X���� -1(true)=�X�V���� 0(false)=�X�V�Ȃ�
 * 0�Ȃ�False
 * 0�ȊO��True
 */
function SakuraCheck(amode, aver, aurl) {
    var wpre;
    var wlink;
    var wcurver;
    wcurver = Editor.ExpandParameter("$V");

	if (aurl.length < 1) {
		return;
	}
	
    if ( amode == 2 ) { log("���̃T�N���G�f�B�^�̃o�[�W����:" + wcurver, 0) }

    switch(Plugin.GetOption("�T�N���G�f�B�^", "SITEPRIORITY")) {
        case "0":
            aurl[0] = Plugin.GetOption("�T�N���G�f�B�^", "GITHUBURL");
            break;
        case "1":
            aurl[0] = Plugin.GetOption("�T�N���G�f�B�^", "APPVEYORURL");
            break;
        case "2":
            aurl[0] = Plugin.GetOption("�T�N���G�f�B�^", "OSDNURL");
            break;
        case "3":
            aurl[0] = Plugin.GetOption("�T�N���G�f�B�^", "CUSTOMURL");
            break;
    }

    wpre = Plugin.GetOption("�T�N���G�f�B�^", "USEPREREL");
    log("�v�������[�X�_�E�����[�h�t���O = " + wpre, 2);
	
    if ( aurl[0].indexOf("github.com") >= 0 ) {
        if ( wpre == "0" ) { // ���ݒ莞
            if ( WSH.Popup("GitHub�̃v�������[�X�ł��_�E�����[�h���܂���?�u�͂��v�Ŏ���ȍ~���v�������[�X�̍X�V�𔽉f���܂��B�u�������v�Ń����[�X�ł̂ݔ��f���܂��B���̐ݒ�̓v���O�C���̃I�v�V�����ŕύX�ł��܂��B", 0, "�\�t�g�E�F�A�̍X�V", 4) == 6 ) {
                wpre = "1"; // �v�������[�X
            } else {
                wpre = "2"; // �����[�X�̂�
            }
            Plugin.SetOption("�T�N���G�f�B�^", "USEPREREL", wpre);
        }
        if ( aurl[0].endsWith("/latest") ) { // �ŐV�Ŏw�肪���������U�Ƃ�B
            aurl[0] = aurl[0].substring(0, aurl[0].length - 7);
        }
        if ( wpre != "1" ) { // �v�������[�X�w��ȊO /latest��t���Ȃ���
            aurl[0] = aurl[0] + "/latest";
        } else {
            aver[0] = GetGitHub(aurl);
        }
    } else if (aurl[0].indexOf("osdn.net") >= 0) {
        aver[0] = GetOSDNRSS(aurl, "sakura");
    } else if (aurl[0].indexOf("appveyor.com") >= 0) {
        aver[0] = GetAppVeyor(aurl);
    }

    if ( aver[0] == "" ) {
        if ( amode == 2 ) { log("�~�ŐV�ł��m�F�ł��܂���ł����B", 0); }
        return null;
    }

    if ( amode == 2 ) { log("�ŐV�̃T�N���G�f�B�^�̃o�[�W����:" + aver[0], 0) }

    if ( aver[0] <= wcurver ) {
        if ( amode == 2 ) { log("���T�N���G�f�B�^�͍ŐV�o�[�W�����ł��B", 0) }
        return false;
    }

    if ( aurl[0].indexOf("alpha") >= 0 || aurl[0].indexOf("beta") >= 0 ) {
        log("���T�N���G�f�B�^�̐V�����v�������[�X�ł������[�X����Ă��܂��B", 0);
        return 1;
    }

    log("���T�N���G�f�B�^�̐V�o�[�W�����������[�X����Ă��܂��B", 0);

    return true;
}

// �T�N���G�f�B�^��installer.zip�_�E�����[�h�ƁAinstaller�̋N��
// installer�́A�ꎞ�t�H���_�ɓW�J����s���邽�߁A���̃��W���[���Ƃ͕ʈ���

function SakuraDownload(wurl) {
    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\installer.zip";

    wlink = wurl;

    log("�T�N���G�f�B�^���_�E�����[�h���܂�.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( !FS.FileExists(wzipfile) ) {
        log("�_�E�����[�h�ł��܂���ł����B", 0);
        return null;
    }

    log("�_�E�����[�h�t�@�C����W�J���܂��B", 0);

    if ( !FS.FileExists(WorkDir + "\\installer.zip") ) {
        log(WorkDir + "\\installer.zip���_�E�����[�h�t�@�C���ɂ���܂���ł����B", 0);
        return null;
    }

    // zip�W�J
    // wcmd = UnzipExe + " -o -j " + wzipfile + " */sakura.exe -d " + WorkDir
    wcmd = UnzipExe + " e -aoa -r " + wzipfile + " -o" + WorkDir + "\\install";
     // wcmd = UnzipExe + " e -aoa " + wzipfile + " -o" + WorkDir + "\\sakura"
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, false);

    Editor.Sleep(2000);

    if (!FS.FolderExists(WorkDir + "\\install") ) {
        log(WorkDir + "\\installer.zip�̓W�J�Ɏ��s���܂����B", 0);
        return null;
    }
    
    var folder = FS.GetFolder(WorkDir + "\\install");
    var installexe = null;
    
    // �C���X�g�[���t�@�C����T��(sakura_install-*-x86.exe)
    for ( var e = new Enumerator(folder.files); !e.atEnd(); e.moveNext()) {
        var file = e.item();
        if (file.name.search(/^sakura_install.+\.exe$/)>=0){
            log("installer�t�@�C�� " + file.name + "�������܂����B", 2);
            file.name = "sakura.exe";
            installexe = file.name;
        }
    }
    
    return installexe;
}

function SakuraSetup(atarget) {
    var wfilelist;
    var wrestart;

    wfilelist = "";
    wrestart = "\r\n" + "���ӁI�C���X�g�[���N���O�ɃT�N���G�f�B�^�͋����I������܂��B�ҏW���̃t�@�C��������ꍇ�͔j������܂��B";

    log("\r\n�T�N���G�f�B�^���X�V���܂��B" + wrestart, 0);

    if ( WSH.Popup("�T�N���G�f�B�^���X�V���܂��B���̉�ʂ̌�C���X�g�[�����N�����܂��̂ŁA�C���X�g�[�������{���Ă��������B" + wrestart, 0, "�\�t�g�E�F�A�̍X�V", 1) == 2 ) {
        return;
    }

    // exe�㏑������
    // �X�V�X�N���v�g���쐬���A���v���Z�X�Ŏ��s
    // ���s��T�N���G�f�B�^���I������B
    // �X�N���v�g�́A�T�N���G�f�B�^�㏑�����o����܂őҋ@����B
    // program files\sakura�̏ꍇ�̓Z�L�����e�B�x�����ł�B
    var wcmd;
    var wcmdfile;
    var wcmdparam;
    var programfiles;
    programfiles = "C:\\Program Files";

    wcmd = "set srcfolder=" + WorkDir + "\\install\n" +
               "set sakurafolder=" + SakuraDir + "\n" +
               "set targetfolder=" + SakuraDir + "\n" +
               "set debuglvl=" + DebugLvl + "\n";

    wcmd = wcmd + "set targetfile1=" + atarget + "\n";

    if ( (OSVer.substring(0, 2) == "6." || OSVer.substring(0,3) == "10." ) &&
          SakuraDir.substring(0,programfiles.length) == programfiles ) {
        wcmd = wcmd + "set _runas=-Verb runas";
    }

    wcmdfile = WorkDir + "\\_setenv.bat";
    SaveText(wcmd, wcmdfile, "Shift_JIS");

     // mainupdate.bat��fileupdate.bat�̑ޔ�
    FS.CopyFile(PluginDir + "\\sleep.js", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\mainupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\fileupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\runas.ps1", WorkDir + "\\", true);
    wcmd = "\"" + WorkDir + "\\mainupdate.bat\"";

    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 1, false);

    //log("�X�V�������I�����܂����B", 0);

}

// �v���O�C���t�@�C���̍X�V�`�F�b�N
// amode = 1:�������[�h,  2:�蓮���[�h
// �߂�l: true=�X�V���� false=�X�V�Ȃ�
//
function PluginCheck(amode, aver, aurl) {

    // Editor.ActivateWinOutput

    var wpluginpath;
    var wdefpath;
    var wdeftext;
    var wcurver = "";
    var wsakuraver;

    wpluginpath = PluginDir;
    wdefpath = wpluginpath + "\\plugin.def";

    wdeftext = LoadText(wdefpath, "");

    var re = new ActiveXObject("VBScript.RegExp");

    re.Pattern = "Version=(v\\d+)";
     // .Global = True
    var matchs = re.Execute(wdeftext);
    if ( matchs.Count > 0 ) {
        if ( matchs(0).SubMatches.Count > 0 ) {
            wcurver = matchs(0).SubMatches(0);
        }
    }

    if ( amode == 2 ) { log("���̃v���O�C���̃o�[�W����:" + wcurver, 0); }

    aurl[0] = Plugin.GetOption("�T�N���G�f�B�^", "PLUGINURL");
    aver[0] = GetGitHub(aurl);

    if ( aver[0] == "" ) {
        if ( amode == 2 ) { log("�~�ŐV�ł��m�F�ł��܂���ł����B", 0) }
        return null;
    }

    if ( amode == 2 ) { log("�ŐV�̃v���O�C���̃o�[�W����:" + aver, 0) }

    if ( aver[0] <= wcurver ) {
        if ( amode == 2 ) { log("���v���O�C���͍ŐV�o�[�W�����ł��B", 0) }
        return false;
    }

    log("���v���O�C���̐V�o�[�W�����������[�X����Ă��܂��B", 0);

    return true;
}

// �v���O�C����zip�_�E�����[�h
function PluginDownload(wurl) {

    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\Plugin.zip";

    wlink = wurl;

    log("�v���O�C�����_�E�����[�h���܂�.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( ! IsExistFile(wzipfile) ) {
        log("�_�E�����[�h�ł��܂���ł����B", 0);
        return false;
    }

    log("�_�E�����[�h�t�@�C����W�J���܂��B", 0);

     // zip�W�J
     // CreateDir(WorkDir + "\\plugin")
    wcmd = UnzipExe + " x -aoa " + wzipfile + " -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

// On Error Resume Next
    Editor.Sleep(2000);
// On Error GoTo 0

    if ( ! IsExistFile(WorkDir + "\\sakuraupdate\\plugin.def") ) {
        log("�v���O�C��zip�ł͂���܂���ł����B", 0);
        return false;
    }

    return true;

}

// plugin�̃t�@�C�����C���X�g�[���t�H���_�փR�s�[����B
//
function PluginSetup(atarget) {

    log("�v���O�C�����X�V���܂��B", 1);
    if ( WSH.Popup("�v���O�C�����X�V���܂��B" + "\r\n" + "���ӁI�X�V�O�ɃT�N���G�f�B�^�͋����I�����܂��B�ҏW���̃t�@�C��������ꍇ�͔j������܂��B", 0, "�\�t�g�E�F�A�̍X�V", 1) == 2 ) {
        return;
    }

     // exe�㏑������
     // �X�V�X�N���v�g���쐬���A���v���Z�X�Ŏ��s
     // ���s��T�N���G�f�B�^���I������B
     // �X�N���v�g�́A�T�N���G�f�B�^�㏑�����o����܂őҋ@����B
     // program files\\sakura�̏ꍇ�̓Z�L�����e�B�x�����ł�B
    var wcmd;
    var wcmdfile;
    var wcmdparam;
    var programfiles;
    programfiles = "C:\\Program Files";

    wcmd = "set srcfolder=" + WorkDir + "\\sakuraupdate" + "\n" +
               "set sakurafolder=" + SakuraDir + "\n" +
               "set targetfolder=" + PluginDir + "\n" +
               "set targetfile1=" + atarget + "\n" +
               "set debuglvl=" + DebugLvl + "\n";

    if ( (OSVer.substring(0, 2) == "6." || OSVer.substring(0,3) == "10." ) &&
          PluginDir.substring(0,programfiles.length) == programfiles ) {
        wcmd = wcmd + "set _runas=-Verb runas";
    }

    wcmdfile = WorkDir + "\\_setenv.bat";
    SaveText(wcmd, wcmdfile, "Shift_JIS");

     // mainupdate.bat��fileupdate.bat�̑ޔ�
    FS.CopyFile(PluginDir + "\\sleep.js", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\mainupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\fileupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\runas.ps1", WorkDir + "\\", true);

    wcmd = "\"" + WorkDir + "\\mainupdate.bat\"";

    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 1, false);

    log("�v���O�C���̍X�V�������I�����܂����B", 0);

}

// ���K�\�����C�u�����̍X�V�`�F�b�N
// amode = 1:�������[�h,  2:�蓮���[�h
// �߂�l: true=�X�V���� false=�X�V�Ȃ�
//
function RegExpCheck(amode, aver, aurl) {
    var wurl = [""];
    var wlink;
    var wsakurapath;
    var wregexppath;
    var wfilever;
    var wcurver = ["",""];

    wsakurapath = Editor.ExpandParameter("$S");
    wregexppath = FS.GetParentFolderName(wsakurapath) + "\\bregonig.dll";
    wfilever = FS.GetFileVersion(wregexppath);
    
    var re;
    re = new ActiveXObject("VBScript.RegExp");
    re.Pattern = "(\\d+)\\.(\\d+)\\.\\d+\\.\\d+";
    re.Global = false;
    var matchs = re.Execute(wfilever);
    //log("matchs.Count = '" + wfilever + "'~/" + re.Pattern + "/ -> " + matchs.Count, 2);
    if ( matchs.Count > 0 ) {
        if ( matchs(0).SubMatches.Count > 1 ) {
            //wcurver = Mid(FormatNumber(matchs(0).SubMatches(0) / 100, 2, -1, 0, 0), 3) +
            //     "." + Mid(FormatNumber(matchs(0).SubMatches(1) / 100, 2, -1, 0, 0), 3);
            wcurver = [Number(matchs(0).SubMatches(0)), Number(matchs(0).SubMatches(1))];
        }
    }

    if ( amode == 2 ) { log("�z�u�ς݂̐��K�\�����C�u�����̃o�[�W����:" + wcurver[0] + "." + wcurver[1], 0); }

    wurl[0] = Plugin.GetOption("�T�N���G�f�B�^", "REGEXPURL");

    if ( wurl[0].indexOf("api.bitbucket.org") >= 0 ) {
        aver = GetBitBucket(wurl);
    }

    if ( aver == "" ) {
        if ( amode == 2 ) { log("�~�ŐV�ł��m�F�ł��܂���ł����B", 0); }
        return null;
    }

    aurl[0] = wurl[0];

    if ( amode == 2 ) { log("�ŐV�̐��K�\�����C�u�����̃o�[�W����:" + aver[0] + "." + aver[1], 0); }

    if ( aver[0] <= wcurver[0] && aver[1] <= wcurver[1] ) {
        if ( amode == 2 ) { log("�����K�\�����C�u�����͍ŐV�o�[�W�����ł��B", 0); }
        return false;
    }

    log("�����K�\�����C�u�����̐V�o�[�W�����������[�X����Ă��܂��B", 0);

    return true;

}

// ���K�\�����C�u������zip�_�E�����[�h

function RegExpDownload(wurl) {
    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\regexp.zip";

    log("typeof=" + new String(wurl), 2);
    
    //if ( (new String(wurl)).indexOf("bitbucket.org") >= 0 ) {
        wlink = wurl;
    //}

    log("���K�\�����C�u�������_�E�����[�h���܂�.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, true);

    if ( ! IsExistFile(wzipfile) ) {
        log("�_�E�����[�h�ł��܂���ł����B", 0);
        return false;
    }

    log("�_�E�����[�h�t�@�C����W�J���܂��B", 1);

     // zip�W�J
    wcmd = UnzipExe + " e -aoa " + wzipfile + " bregonig.dll -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

    Editor.Sleep(2000);

    if ( ! IsExistFile(WorkDir + "\\bregonig.dll") ) {
        log("bregonig.dll���_�E�����[�h�t�@�C���ɂ���܂���ł����B", 0);
        return false;
    }

    return true;
}

// Diff(����)�c�[���̍X�V�`�F�b�N
// amode = 1:�������[�h,  2:�蓮���[�h
// �߂�l: true=�X�V���� false=�X�V�Ȃ�
//
function DiffCheck(amode, aver, aurl) {
    var wurl;
    var wlink;
    var wsakurapath;
    var wdiffpath;
    var wcurdate;

    wsakurapath = Editor.ExpandParameter("$S");
    wdiffpath = FS.GetParentFolderName(wsakurapath) + "\\diff.exe";
    log("Diff(����)�c�[���̑��݃`�F�b�N: " + wdiffpath,2);
    
    wcurdate = "";
    if (FS.FileExists(wdiffpath)) {
        wcurdate = new Date(FS.GetFile(wdiffpath).DateLastModified);
    }

    if ( wcurdate == "" ) {
        if ( amode == 2 ) { log("���݁ADiff(����)�c�[���͔z�u����Ă��܂���B", 0); }
    } else {
        if ( amode == 2 ) { log("�z�u�ς݂�Diff(����)�c�[���̍X�V���t:" + wcurdate.toLocaleString(), 0); }
    }

    aurl[0] = Plugin.GetOption("�T�N���G�f�B�^", "DIFFURL");
    aver[0] = "";

    if ( aurl[0]== "" ) {
        return null;
    }

    var wtmpfile;
    var wcmd;
    var whead;
    var wsts;
    
    whead = GetHTTPStatus(aurl[0]);
    if ( whead == null ) {
        wtmpfile = WorkDir + "\\_temp.htm";
        DeleteFile(wtmpfile);
         // curl --head  -s -w "HTTPCODE=%{http_code}"
        wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " --head -s -L \"" + aurl[0] + "\" -o " + wtmpfile;
        if ( amode == 2 ) { log(">" + wcmd, 1) }
        WSH.Run(wcmd, 7, true); //
        whead = LoadText(wtmpfile, "utf-8");

        log("�X�e�[�^�X�R�[�h: " + whead.substring(0, 10), 2);

        if ( whead.indexOf("200 OK") >= 0 ) {
            wsts = 200;
        } else {
            var statusCode = new Number(whead.substring(0,3));
            wsts = statusCode;
//        } else {
//            wsts = 0;
        }
    } else {
        wsts = whead.status;
    }

    if ( wsts == 200 ) {
        aver[0] = "any date";
    } else {
        if ( amode == 2 ) { log("�~�ŐV�ł��m�F�ł��܂���ł����B", 0); }
        return null;
    }

    if ( wcurdate != "" ) {
        if ( amode == 2 ) { log("��Diff(����)�c�[���͔z�u�ς݂ł��B", 0); }
        return false;
    }

    log("��Diff(����)�c�[�����_�E�����[�h�\�ł��B", 0);

    return true;
}

/** �w�b�_�̂ݗv�����ă��X�|���X�R�[�h��Ԃ�
 */
function GetHTTPStatus(aurl) {
    var req = CreateHttpRequest();

    if ( req == null ) {
        return null;
    }

    log("HEAD�v����... " + aurl, 1);

    req.open("HEAD", aurl, false);
    try {
        req.send();
    } catch(e) {
        log("�G���[: " + e, 0);
        return null;
    }

    log("�X�e�[�^�X�R�[�h�F" + req.status, 2);
    
    var headers = req.getAllResponseHeaders();
    //for (var h in headers) {
    //  log("���X�|���X�w�b�_: " + headers);
	//}
    return req; //.status;

}

// Diff(����)�c�[����zip�_�E�����[�h

function DiffDownload(wurl) {

    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\Diff.zip";

    wlink = wurl;

    log("Diff(����)�c�[�����_�E�����[�h���܂�.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( ! IsExistFile(wzipfile) ) {
        log("�_�E�����[�h�ł��܂���ł����B", 0);
        return false;
    }

    log("�_�E�����[�h�t�@�C����W�J���܂��B", 1);

     // zip�W�J
    wcmd = UnzipExe + " e -aoa " + wzipfile + " diff.exe -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

    Editor.Sleep(2000);

    if ( ! IsExistFile(WorkDir + "\\diff.exe") ) {
        log("diff.exe���_�E�����[�h�t�@�C���ɂ���܂���ł����B", 0);
        return false;
    }

    return true

}

/** Ctags(�^�O����)�c�[���̍X�V�`�F�b�N
 * amode = 1:�������[�h,  2:�蓮���[�h
 * �߂�l: true=�X�V���� false=�X�V�Ȃ�
 */
function CtagsCheck(amode, aver, aurl) {
    var wurl;
    var wlink;
    var wsakurapath;
    var wctagspath;
    var wcurdate;

    wsakurapath = Editor.ExpandParameter("$S");
    wctagspath = FS.GetParentFolderName(wsakurapath) + "\\ctags.exe";

    wcurdate = "";
    if (FS.FileExists(wctagspath)) {
        wcurdate = new Date(FS.GetFile(wctagspath).DateLastModified);
    }

    if ( wcurdate== "" ) {
        if ( amode == 2 ) {
        	log("���݁ACtags(�^�O����)�c�[���͔z�u����Ă��܂���B", 0);
        }
    } else {
        if ( amode == 2 ) {
        	log("�z�u�ς݂�Ctags(�^�O����)�c�[���̍X�V���t:" + wcurdate.toLocaleString(), 0);
        }
        if ( amode == 1 ) {
            return false;
        }
    }

    aurl[0] = Plugin.GetOption("�T�N���G�f�B�^", "CTAGSURL");
    aver = "";

    if ( aurl[0] == "" ) {
        return null;
    }

    var wpage;

    if ( aurl[0].indexOf("hp.vector.co.jp/authors/VA025040/ctags") >= 0 ) {
        wpage = DownloadFile(aurl[0], "");
        if ( wpage== "" || wpage.substring(0, 7) == "#ERROR#" ) {
             // nop
        } else {
            var re;
            re = new ActiveXObject("VBScript.RegExp");
            re.Pattern = "downloads/ec(\\d+j\\d)w32bin\\.zip";
             // a href="downloads/ec58j2w32bin.zip

            re.Global = true;
            var matchs = re.Execute(wpage);
            if ( matchs.Count > 0 ) {
                wlink = matchs(0);
                log("���������t�@�C��:" + wlink, 2);
                aurl[0] = aurl[0] + wlink;
                if ( matchs(0).SubMatches.Count > 0 ) {
                    aver = matchs(0).SubMatches(0);
                }
            }
        }
    } else if ( aurl[0].indexOf("github.com") >= 0 ) {
        aver = GetGitHub(aurl);
    }

    if ( aver == "" ) {
        if ( amode == 2 ) { log("�~�ŐV�ł��m�F�ł��܂���ł����B", 0) }
        return null;
    } else {
        if ( amode == 2 ) { log("�ŐV��Ctags(�^�O����)�c�[���̃o�[�W����:" + aver, 0) }
    }

    if ( wcurdate != "" ) {
        if ( amode == 2 ) { log("��Ctags(�^�O����)�c�[���͔z�u�ς݂ł��B", 0) }
        return false;
    }

    log("��Ctags(�^�O����)�c�[�����_�E�����[�h�\�ł��B", 0);

    return true;
}

// Ctags(�^�O����)�c�[����zip�_�E�����[�h

function CtagsDownload(wurl) {

    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\Ctags.zip";

    wlink = wurl;

    log("Ctags(�^�O����)�c�[�����_�E�����[�h���܂�.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( ! IsExistFile(wzipfile) ) {
        log("�_�E�����[�h�ł��܂���ł����B", 0);
        return false;
    }

    log("�_�E�����[�h�t�@�C����W�J���܂��B", 1);

     // zip�W�J
    wcmd = UnzipExe + " e -aoa " + wzipfile + " -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

// On Error Resume Next
    Editor.Sleep(2000);
// On Error GoTo 0

    if ( ! IsExistFile(WorkDir + "\\ctags.exe") ) {
        log("ctags.exe���_�E�����[�h�t�@�C���ɂ���܂���ł����B", 0);
        return false;
    }

    return true;
}


/** Migemo(���[�}���C���N�������^������)�c�[���̍X�V�`�F�b�N
 * amode = 1:�������[�h,  2:�蓮���[�h
 * �߂�l: true=�X�V���� false=�X�V�Ȃ�
 */
function MigemoCheck(amode, aver, aurl) {
    var wurl;
    var wlink;
    var wsakurapath;
    var wmigemopath;
    var wcurdate;

    wsakurapath = Editor.ExpandParameter("$S");
    wmigemopath = FS.GetParentFolderName(wsakurapath) + "\\migemo.dll";

    wcurdate = "";
    if (FS.FileExists(wmigemopath)) {
        wcurdate = new Date(FS.GetFile(wmigemopath).DateLastModified);
    }

    if ( wcurdate== "" ) {
        if ( amode == 2 ) {
        	log("���݁AMigemo(���[�}���C���N�������^������)�c�[���͔z�u����Ă��܂���B", 0);
        }
    } else {
        if ( amode == 2 ) {
        	log("�z�u�ς݂�Migemo(���[�}���C���N�������^������)�c�[���̍X�V���t:" + wcurdate.toLocaleString(), 0);
        }
        if ( amode == 1 ) {
            return false;
        }
    }

    aurl[0] = Plugin.GetOption("�T�N���G�f�B�^", "MIGEMOURL");
    aver = "";

    if ( aurl[0] == "" ) {
        return null;
    }

    var whead = GetHTTPStatus(aurl[0]);
	if (whead != null && whead.status == 200) {
	   try {
           var ldate = whead.getResponseHeader("Last-Modified");
           //log("Last-Modified: " + ldate);
           aver = new Date(ldate);
	   } catch(e) {
	   }
	}
    
    if ( aver == "" ) {
        if ( amode == 2 ) { log("�~�ŐV�ł��m�F�ł��܂���ł����B", 0) }
        return null;
    } else {
        if ( amode == 2 ) { log("�ŐV��Migemo(���[�}���C���N�������^������)�c�[���̔z�z���t:" + aver.toLocaleString(), 0) }
    }

    if ( wcurdate != "" ) {
        if ( amode == 2 ) { log("��Migemo(���[�}���C���N�������^������)�c�[���͔z�u�ς݂ł��B", 0) }
        return false;
    }

    log("��Migemo(���[�}���C���N�������^������)�c�[�����_�E�����[�h�\�ł��B", 0);

    return true;
}

/** Mimego(���[�}���C���N�������^������)�c�[����zip�_�E�����[�h
 *
 *  zip��W�J��Adist�t�H���_��migemo.dll���R�s�[����B
 *
 */
function MigemoDownload(wurl) {

    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\migemo.zip";

    wlink = wurl;

    log("Migemo(���[�}���C���N�������^������)�c�[�����_�E�����[�h���܂�.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( ! IsExistFile(wzipfile) ) {
        log("�_�E�����[�h�ł��܂���ł����B", 0);
        return false;
    }

    log("�_�E�����[�h�t�@�C����W�J���܂��B", 1);

     // zip�W�J
    wcmd = UnzipExe + " x -aoa " + wzipfile + " -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

    Editor.Sleep(2000);

    if ( ! IsExistFile(WorkDir + "\\cmigemo-default-win32\\migemo.dll") ) {
        log("migemo.dll���_�E�����[�h�t�@�C���ɂ���܂���ł����B", 0);
        return false;
    }

    return true;
}

// %temp%\sakuraupdate���̎w��t�@�C�����C���X�g�[���t�H���_�փR�s�[����B
// atargets = �w��t�@�C���̔z��(1�`)

function FileSetup(atargets) {
    var wfilelist;
    var wrestart;

    wfilelist = "";
    wrestart = "";
    for ( var i = 0 ; i < atargets.length ; i++ ) {
        if (atargets[i] && atargets[i] != "") {
            wfilelist = wfilelist + "," + atargets[i];
        }
        if ( atargets[i] == "sakura.exe") {  // 
            wrestart = "\r\n" + "���ӁI�X�V�O�ɃT�N���G�f�B�^�͋����I�����܂��B�ҏW���̃t�@�C��������ꍇ�͔j������܂��B";
        }
    }

    log("\r\n" + wfilelist.substring(1) + "���X�V���܂��B" + wrestart, 0);

    if ( WSH.Popup(wfilelist.substring(1) + "���X�V���܂��B" + wrestart, 0, "�\�t�g�E�F�A�̍X�V", 1) == 2 ) {
        return;
    }

     // exe�㏑������
     // �X�V�X�N���v�g���쐬���A���v���Z�X�Ŏ��s
     // ���s��T�N���G�f�B�^���I������B
     // �X�N���v�g�́A�T�N���G�f�B�^�㏑�����o����܂őҋ@����B
     // program files\sakura�̏ꍇ�̓Z�L�����e�B�x�����ł�B
    var wcmd;
    var wcmdfile;
    var wcmdparam;
    var programfiles;
    programfiles = "C:\\Program Files";

    wcmd = "set srcfolder=" + WorkDir + "\n" +
               "set sakurafolder=" + SakuraDir + "\n" +
               "set targetfolder=" + SakuraDir + "\n" +
               "set debuglvl=" + DebugLvl + "\n";

    for ( var i = 0 ; i < atargets.length ; i++ ) {
        if (atargets[i] && atargets[i] != "") {
            wcmd = wcmd + "set targetfile" + (i+1) + "=" + atargets[i] + "\n";
        }
    }

    if ( (OSVer.substring(0, 2) == "6." || OSVer.substring(0,3) == "10." ) && 
          SakuraDir.substring(0,programfiles.length) == programfiles ) {
        wcmd = wcmd + "set _runas=-Verb runas";
    }

    wcmdfile = WorkDir + "\\_setenv.bat";
    SaveText(wcmd, wcmdfile, "Shift_JIS");

     // mainupdate.bat��fileupdate.bat�̑ޔ�
    FS.CopyFile(PluginDir + "\\sleep.js", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\mainupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\fileupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\runas.ps1", WorkDir + "\\", true);

    wcmd = "\"" + WorkDir + "\\mainupdate.bat\"";

    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 1, false);

    log("�X�V�������I�����܂����B", 0);

}

/* --------------------------------------------------------------------------- */

// Get GitHub Release API
function GetGitHub(aurl) {
    var req;
    var wjson;
    var wlink;
    var wver;
    var wpage;
    var mesg;
    var i;
    var wcmd;
    var wtmpfile;
    var re;

    wver = "";
    wlink = aurl[0];
    log("GitHub�m�F��.. " + wlink, 1);

     // wtmpfile = WorkDir + "\\_temp.htm"
     // wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L """ + wlink + """ -o " + wtmpfile
     // log ">" + wcmd, 1
     // DoCmd wcmd, ""
     // WSH.Run wcmd, 7, True '

     // wpage = LoadText(wtmpfile, "utf-8")
    wpage = DownloadFile(wlink, "");

    re = new ActiveXObject("VBScript.RegExp");

    if ( aurl[0].indexOf("sakura") >= 0 ) { // sakura or sakuraupdate
            wlink = "";

            if ( aurl[0].indexOf("sakuraupdate") >= 0 ) {
                 // .Pattern = "ctags-2018-09-18_3480c6de-x86.zip"
                 // sakuraupdate "https://github.com/osaboo/sakuraupdate/releases/download/v20190224/sakuraupdate.zip"
                re.Pattern = "\"browser_download_url\": ?\"([^ \"]+\\.zip)";
            } else if ( aurl[0].indexOf("sakura-editor") >= 0 ) {
                     // sakura "https://github.com/sakura-editor/sakura/releases/download/v2.3.2.0/sakura2-3-2-0.zip"
                     // sakura pre-release "https://github.com/sakura-editor/sakura/releases/download/v2.4.0-alpha1/sakura-tag-v2.4.0-alpha1-build1699-2582c34c-Win32-Release-Exe.zip"
                     // sakura betarelease "https://github.com/sakura-editor/sakura/releases/download/v2.4.0-beta/sakura-build2313-Win32-Release-Exe.zip"
                     // sakura product-rel "https://github.com/sakura-editor/sakura/releases/download/v2.4.0/sakura-tag-v2.4.0-build2686-782347a-Win32-Release-Exe.zip
                     // sakura installer   "browser_download_url": "https://github.com/sakura-editor/sakura/releases/download/v2.4.2/sakura-tag-v2.4.2-build4203-a3e63915b-Win32-Release-Installer.zip"
                 // re.Pattern = """browser_download_url"": ?""([^ ""]+sakura2-[0-9]+-[0-9]+-[0-9]+\.zip)|([^ ""]+sakura-tag-[^ ""]+-Win32-Release-Exe\.zip)|([^ ""]+sakura-[^ ""]+-Win32-Release-Exe\.zip)"
                re.Pattern = "\"browser_download_url\": ?\"([^ \"]+sakura2-[0-9]+-[0-9]+-[0-9]+\\.zip|[^ \"]+sakura-[^ \"]+-Win32-Release-Installer\\.zip)";
            }
            re.Global = true;
            var matchs = re.Execute(wpage);
             // For Each match In matchs
             // log "��������������:" + match.Value, 2
             // Next
            if ( matchs.Count > 0 ) {
                if ( DebugLvl > 2 ) {
                    log("��������������:" + matchs(0).Value, 2);
                    log("����������������̐�:" + matchs(0).SubMatches.Count, 2);
                    for ( i = 0 ; i <= matchs(0).SubMatches.Count - 1 ; i++ ) {
                        log("����������������(" + i + "):" + matchs(0).SubMatches(i), 2);
                    }
                }
                if ( matchs(0).SubMatches.Count > 1 ) {
                    wlink = matchs(0).SubMatches(1).trim();
                }
                if ( wlink == "" ) {
                    if ( matchs(0).SubMatches.Count > 0 ) {
                        wlink = matchs(0).SubMatches(0);
                    }
                }
                if ( wlink != "" ) {
                    log("���������t�@�C��:" + wlink, 2);
                    aurl[0] = wlink;
                }
            }

            if ( wlink != "" ) {
                if ( aurl[0].indexOf("sakuraupdate") >= 0 ) {
                     // sakuraupdate "https://github.com/osaboo/sakuraupdate/releases/download/v20190224/sakuraupdate.zip"
                    re.Pattern = "v[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]";
                    matchs = re.Execute(wlink);
                    if ( matchs.Count > 0 ) {
                        wver = matchs(0).Value;
                    }
                } else if ( aurl[0].indexOf("sakura-editor") >= 0 ) {
                     // sakura "https://github.com/sakura-editor/sakura/releases/download/v2.3.2.0/sakura2-3-2-0.zip"
                    re.Pattern = "v[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+";
                    matchs = re.Execute(wlink);
                    if ( matchs.Count > 0 ) {
                        wver = matchs(0).Value.substring(1);
                    }
                    if ( wver== "" ) {
                         // sakura betarelease "https://github.com/sakura-editor/sakura/releases/download/v2.4.0-beta/sakura-build2313-Win32-Release-Exe.zip"
                        re.Pattern = "v([0-9]+\\.[0-9]+\\.[0-9]+)-.+build([0-9]+)";
                        matchs = re.Execute(wlink);
                        if ( matchs.Count > 0 ) {
                            if ( matchs(0).SubMatches.Count > 1 ) {
                                wver = matchs(0).SubMatches(0) + "." + matchs(0).SubMatches(1);
                            }
                        }
                    }
                    if ( wver== "" ) {
                         // sakura pre-release "https://github.com/sakura-editor/sakura/releases/download/v2.4.0-alpha1/sakura-tag-v2.4.0-alpha1-build1699-2582c34c-Win32-Release-Exe.zip"
                        re.Pattern = "tag-v([0-9]+\\.[0-9]+\\.[0-9]+)-.*build([0-9]+)";
                        matchs = re.Execute(wlink);
                        if ( matchs.Count > 0 ) {
                            if ( matchs(0).SubMatches.Count > 1 ) {
                                wver = matchs(0).SubMatches(0) + "." + matchs(0).SubMatches(1);
                            }
                        }
                    }
                }
            }
//         End With

    } else if ( aurl[0].indexOf("universal-ctags") >= 0 ) {
            wlink = "";

             // re.Pattern = "ctags-2018-09-18_3480c6de-x86.zip"
             // "browser_download_url": "../ctags-2021-01-06_p5.9.20210103.0-23-g08b1c490-x86.zip"
             // re.Pattern = """browser_download_url"": ?""([^ ""]+ctags-\d+-\d+-\d+_[0-9a-z.\-]+-x86\.zip)"
             // "browser_download_url": "https://github.com/universal-ctags/ctags-win32/releases/download/2023-01-03/p6.0.20230101.0-1-g13d8e3f/ctags-2023-01-03_p6.0.20230101.0-1-g13d8e3f-clang-x86.zip
            re.Pattern = "\"browser_download_url\": ?\"([^ \"]+ctags-\\d+-\\d+-\\d+_p[0-9a-z.\\-]+-clang-x86\\.zip)";
            re.Global = true;
            matchs = re.Execute(wpage);
            if ( matchs.Count > 0 ) {
                if ( matchs(0).SubMatches.Count > 0 ) {
                    wlink = matchs(0).SubMatches(0);
                    log("���������t�@�C��:" + wlink, 2);
                    aurl[0] = wlink;
                }
            }

            if ( wlink != "" ) {
                re.Pattern = "ctags-(\\d+-\\d+-\\d+)_p[0-9a-z.\\-]+-clang-x86\\.zip";
                re.Global = true;
                matchs = re.Execute(wlink);
                if ( matchs.Count > 0 ) {
                    if ( matchs(0).SubMatches.Count > 0 ) {
                        wver = matchs(0).SubMatches(0);
                    	wver = wver.replace(/-/g, "/");
                    }
                }
            }
    }

    return wver;
}

// Get GetOSDNRSS RSS
function GetOSDNRSS(aurl, apath) {
    var rCode;
    var ItemFile;
    var i;
    var wlink;
    var wurl;
    var wver = "";
    var wcmd;
    var wtmpfile;

    wlink = aurl[0];
    if (apath == "sakura2") { wlink = aurl[0] + "?path=/sakura2"; }
    
    log("OSDN �m�F��... " + wlink,1);

    //wtmpfile = WorkDir & "\_temp.htm"
    //wcmd = CurlExe & " -L """ & wlink & """ -o " & wtmpfile
    //log ">" & wcmd, 1
    //'DoCmd wcmd, ""
    //WSH.Run wcmd, 7, True '

	var xmldata = DownloadFile(wlink, "");
	//log(xmldata);

	if (xmldata == null){
		return "";
	}
	
	var XmlDoc = new ActiveXObject("Microsoft.XMLDOM");
    XmlDoc.async = false;
    rCode = XmlDoc.loadXML(xmldata);

    //�擾�m�F
    if (XmlDoc.parseError.errorCode != 0) { //���[�h���s
        log("�ǂݍ��߂܂���ł����BErrorCode:" & XmlDoc.parseError.errorCode, 0);
        log("�G���[���e:" & XmlDoc.parseError.reason, 0); //�G���[���e���o��
        return "";
    }
    
    switch(apath) {
        case "sakura":
	        ItemFile = XmlDoc.selectNodes("//osdn:file");

	        wlink = "";
	        
	        for(var i = 0 ; i <= ItemFile.length - 1; i++){
	            wurl = ItemFile(i).getAttribute("url");
	        	log(wurl, 2);
	        	if (wurl.indexOf("sakura-tag-v2") >= 0 && wurl.indexOf("Installer.zip") >= 0) {
	                wlink = wurl;
	                break;
	   			}
	        }
	        
	    	if (wlink != "") {
	            var re, match, matchs;
	            re = new ActiveXObject("VBScript.RegExp");
	            
                // sakura pre-release "https://github.com/sakura-editor/sakura/releases/download/v2.4.0-alpha1/sakura-tag-v2.4.0-alpha1-build1699-2582c34c-Win32-Release-Exe.zip"
                re.Pattern = "tag-v([0-9]+\\.[0-9]+\\.[0-9]+)-.*build([0-9]+)";
                matchs = re.Execute(wlink);
                if ( matchs.Count > 0 ) {
                    if ( matchs(0).SubMatches.Count > 1 ) {
                        wver = matchs(0).SubMatches(0) + "." + matchs(0).SubMatches(1);
                    }
                }
	            
	            log("���������t�@�C��:" + wlink, 2);
	            aurl[0] = wlink;
	    	}
    		break;
        case "sakura2":
	        ItemFile = XmlDoc.selectNodes("//osdn:file");

	        wlink = "";
	        
	        for(var i = 0 ; i <= ItemFile.length - 1; i++){
	            wurl = ItemFile(i).getAttribute("url");
	        	log(wurl, 2);
	        	if (wurl.indexOf("sakura2-") >= 0 && wurl.indexOf(".zip") >= 0) {
	                wlink = wurl;
	                break;
	   			}
	        }
	        
	    	if (wlink != "") {
	            var re, match, matchs;
	            re = new ActiveXObject("VBScript.RegExp");
	            
	            re.Pattern = "[0-9]+-[0-9]+-[0-9]+-[0-9]+";
	            re.Global = true;
	            matchs = re.execute(wlink);
	            if ( matchs.count > 0 ) {
	                wver = matchs(0).value;
	                wver = wver.replace(/-/g, ".");
			    }
	            
	            log("���������t�@�C��:" + wlink, 2);
	            aurl[0] = wlink;
	    	}
    		break;
	}
	
    return wver;
}

// Get BitBucket Release API
function GetBitBucket(aurl) {
    var req;
    var wjson;
    var wlink;
    var wver = ["",""];
    var wpage;
    var mesg;
    var i;
    var wcmd;
    var wtmpfile;

    wlink = aurl;
    log("BitBucket�m�F��.. " + wlink, 1);

    wpage = DownloadFile(wlink, "");

     // set wjson = ParseJson(req.responseText)
     // wlink = wjson.assets(0).browser_download_url
     // wpage = req.responseText
     // log "Status : " + req.Status, 1

    var re;
    re = new ActiveXObject("VBScript.RegExp");
    re.Pattern = "https://[^\"]+/bron(\\d+)\\.zip";

    re.Global = true;
    var matchs = re.Execute(wpage);
    if ( matchs.Count > 0 ) {
        wlink = matchs(0);
        log("���������t�@�C��:" + wlink, 2);
        aurl[0] = wlink;
        if ( matchs(0).SubMatches.Count > 0 ) {
            wver = [Number(matchs(0).SubMatches(0).substring(0,1)),Number(matchs(0).SubMatches(0).substring(1))];
            //wver = Mid(FormatNumber(wver.substring(0,1) / 100, 2, -1, 0, 0), 3) +
            // "." + Mid(FormatNumber(wver.substring(1) / 100, 2, -1, 0, 0), 3);
            log("version match = " + wver[0] + "." + wver[1], 2);
        }
    }

    return wver;
}

// Get AppVeyor CI Build
function GetAppVeyor(aurl) {
    var req;
    var wjson;
    var wlink;
    var wver = "";
    var wtext;
    var mesg;
    var i;

    wlink = aurl;
    log("AppVeyor�m�F��.. " + wlink, 1);

	// projects���𓾂�
    wjson = DownloadFile(wlink, "");
    //log("json = " + wjson);
    wjson = eval('(' + wjson + ')');
	//log("build.buildId = " + wjson.build.buildId);
	//log("build.jobs[0].jobId = " + wjson.build.jobs[0].jobId);
	//log("build.jobs[0].name = " + wjson.build.jobs[0].name);
    //wver = wjson.build.version;
	var jobId = wjson.build.jobs[0].jobId;
	
	// �ŐV�̃r���h��artifacts�̈ꗗ�𓾂�
	wlink = "https://ci.appveyor.com/api/buildjobs/" + jobId + "/artifacts";
    wjson = DownloadFile(wlink, "");
	//log(wjson);
	wjson = eval('(' + wjson + ')');
	var fileName = "";
	for (var af in wjson) {
		fileName = wjson[af].fileName;
		//log("artifacts[" + af + "].fileName = " + fileName);
		if (fileName && fileName.indexOf("Win32-Release-Installer.zip") >= 0 && fileName.indexOf("zip.md5") < 0) {
			log("���������t�@�C��:" + fileName, 2);
			break;
		}
		fileName = "";
	}
	
	if (fileName == "") {
		return "";
	}
	
	aurl[0] = wlink + "/" + fileName;

	// SHA256.txt�𓾂āA�o�[�W�������𓾂�
	wlink = "https://ci.appveyor.com/api/buildjobs/" + jobId + "/artifacts/sha256.txt";
    wtext = DownloadFile(wlink, "");

	// sha256.txt�̒���sakura_install2-4-2-xxxx-x86.exe��T��
    var re;
    re = new ActiveXObject("VBScript.RegExp");
    re.Pattern = "sakura_install(2-[0-9]+-[0-9]+-[0-9]+)-x86\.exe";
	
    re.Global = true;
    var matchs = re.Execute(wtext);
    if ( matchs.Count > 0 ) {
		log("���������t�@�C����:" + matchs(0).value, 2);
        if ( matchs(0).SubMatches.Count > 0 ) {
            wver = matchs(0).SubMatches(0);
            wver = wver.replace(/-/g, ".");
        }
    }

    return wver;
}

// @see https://www.ka-net.org/blog/?p=4855#HttpRequest
function DownloadFile(aurl, SaveFilePath) {
    var req; // As Object
    var adTypeBinary = 1;
    var adSaveCreateOverWrite = 2;

    req = null;        // ������
    req = CreateHttpRequest();
    if ( req == null ) {
        //DownloadFile = DownloadCURL(aurl, SaveFilePath);
        return null;
    }

    log("�_�E�����[�h��... " + aurl, 1);

    req.open("GET", aurl, false);

     // 2�FSXH_OPTION_IGNORE_SERVER_SSL_CERT_ERROR_FLAGS
     // 3�FSXH_OPTION_SELECT_CLIENT_SSL_CERT
     // 13056: SXH_OPTION_IGNORE_SERVER_SSL_CERT_ERROR_FLAGS
     // req.SetOption 2, 13056

     // XMLHTTPRequest���l�����ăL���b�V���΍�
     // http://vird2002.s8.xrea.com/javascript/XMLHttpRequest.html#XMLHttpRequest_Cache-Control
     // http://www.atmarkit.co.jp/ait/articles/0305/10/news002.html �Q�l
    req.setRequestHeader("Pragma", "no-cache");
    req.setRequestHeader("Cache-Control", "no-cache");
    req.setRequestHeader("If-Modified-Since", "Thu, 01 Jun 1970 00:00:00 GMT");

    try {
        req.send();
    } catch(e) {
        log("XMLHTTPRequest�ł̎擾�����s���܂����B(" + e.message + ")", 1);
        log("CURL.exe�ł̎擾�ɐ؂�ւ��܂��B", 1);
        //return DownloadCURL(aurl, SaveFilePath);
    	return null;
    }

    log("�X�e�[�^�X�R�[�h�F" + req.status, 2);

    if ( req.status == 200 ) {
        if ( SaveFilePath != "" ) {
            var st = new ActiveXObject("ADODB.Stream");
            st.type = adTypeBinary;
            st.open();
            st.write(req.responseBody);
            st.saveToFile(SaveFilePath, adSaveCreateOverWrite);
            st.close();
        }
        return req.responseText;
    } else {
        //log("�X�e�[�^�X�G���[�F" + req.status, 1);
        return "#ERROR# " + req.status;
    }

}

// WinHttpRequest/XMLHTTPRequest�I�u�W�F�N�g�쐬
// http://www.f3.dion.ne.jp/~element/msaccess/AcTipsWinHTTP1.html �Q�l
// @see https://www.ka-net.org/blog/?p=4855#HttpRequest
function CreateHttpRequest() {  // As Object
  var progIDs; // As Variant
  var ret; // As Object
  var i; // As Long

  ret = null;        // ������
// progIDs = Array("MSXML.XMLHTTPRequest", _
// "WinHttp.WinHttpRequest.5.1", _
// "WinHttp.WinHttpRequest.5", _
// "WinHttp.WinHttpRequest", _
// "Msxml2.ServerXMLHTTP60", _
// "Msxml2.ServerXMLHTTP.6.0", _
// "Msxml2.ServerXMLHTTP.5.0", _
// "Msxml2.ServerXMLHTTP.4.0", _
// "Msxml2.ServerXMLHTTP.3.0", _
// "Msxml2.ServerXMLHTTP", _
// "Microsoft.ServerXMLHTTP", _
// "Msxml2.XMLHTTP.6.0", _
// "Msxml2.XMLHTTP.5.0", _
// "Msxml2.XMLHTTP.4.0", _
// "Msxml2.XMLHTTP.3.0", _
// "Msxml2.XMLHTTP", _
// "Microsoft.XMLHTTP")
// @see https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ms753798(v=vs.85)
// WinHttp.WinHttpRequest.5.1 EnableRedirects

  progIDs = ["Msxml2.ServerXMLHTTP.6.0","Msxml2.ServerXMLHTTP","Msxml2.XMLHTTP"];

  for ( var i = 0; i <= progIDs.length ; i++ ) {
    try {
      ret = new ActiveXObject(progIDs[i]);
      log("XMLHTTPRequest��" + progIDs[i] + "�ŏ��������܂����B", 2);
      break;
    } catch(e) {
      log("XMLHTTPRequest��" + progIDs[i] + "�ŏ������Ɏ��s���܂���:" + e.message, 2);
      // for(k in e) { log("error e." + k + ": " + e[k]);}
    }
  }
  
  if (ret == null) {
    log("XMLHTTPRequest���������ł��܂���ł����B", 0);
  }
  return ret;
}


function IsExistFile(afile) {
  if ( FS == null ) { FS = new ActiveXObject("Scripting.FileSystemObject"); }
  return FS.FileExists(afile);
}

function IsExistDir(adir) {
  if ( FS == null ) {
      FS = new ActiveXObject("Scripting.FileSystemObject");
  }
  return FS.FolderExists(adir);
}

function CreateDir(adir) {
  if ( FS == null ) {
      FS = new ActiveXObject("Scripting.FileSystemObject");
  }

  try {
    FS.CreateFolder(adir);
  } catch (e) {    
    log(adir + "�t�H���_���쐬�ł��܂���ł����B", 1);
  }
}

function DeleteDir(adir) {
  if ( FS == null ) { FS = new ActiveXObject("Scripting.FileSystemObject"); }
  try {
    FS.DeleteFolder(adir, true);
  } catch (e) {
    log(adir + "�t�H���_���폜�ł��܂���ł����B" + e, 1);
  }
}

function DeleteFile(afile) {
  if ( FS == null ) { FS = new ActiveXObject("Scripting.FileSystemObject"); }
  
  try {
    FS.DeleteFile(afile, true);
  } catch (e) {
     log(afile + "���폜�ł��܂���ł����B" + e, 1);
  }
}

function DoCmd(acmd) {
  var oEX;
  oEX = WSH.Exec(acmd);

  while( oEX.Status == 0 ) {
    Editor.Sleep(100);
  }

  return oEX.StdOut.ReadAll();
}

function LoadText(afile, aenc) {
  var wbuff;

  wbuff = "";

  if ( aenc == "" ) { aenc = "Shift_JIS" }

   // ADODB.Stream�̎Q��URL
   // http://msdn.microsoft.com/ja-jp/library/cc364272.aspx
   // http://msdn.microsoft.com/ja-jp/library/cc364273.aspx
    var st;
    st = new ActiveXObject("ADODB.Stream");     // ADODB.Stream����
    st.Type = 2;  // �I�u�W�F�N�g�ɕۑ�����f�[�^�̎�ނ𕶎���^�Ɏw�肷��
    st.Charset = aenc; // "utf-8"  '�����R�[�h�iShift_JIS, Unicode�Ȃǁj
    st.LineSeparator = 10; // ���sLF�i10�j
    try {
      st.Open;         // Stream�̃I�[�v��
      st.LoadFromFile(afile); // �t�@�C���ǂݍ���
      wbuff = st.ReadText(-1);
    } catch(e) {
      wbuff = "#ERROR#";
    } finally {
      st.Close;  // Stream�̃N���[�Y
    }
    st = null;

    return wbuff;
}

function SaveText(atext, apath, aenc) {
  if ( aenc == "" ) { aenc = "Shift_JIS" }
   // ADODB.Stream�̎Q��URL
   // http://msdn.microsoft.com/ja-jp/library/cc364272.aspx
   // http://msdn.microsoft.com/ja-jp/library/cc364273.aspx
    var st;
    st = new ActiveXObject("ADODB.Stream");     // ADODB.Stream����
    st.Type = 2;  // �I�u�W�F�N�g�ɕۑ�����f�[�^�̎�ނ𕶎���^�Ɏw�肷��
    st.Charset = aenc; // "utf-8"  '�����R�[�h�iShift_JIS, Unicode�Ȃǁj
    st.LineSeparator = -1; // ���sLF�i10�jCRLF(-1)
    st.Open;         // Stream�̃I�[�v��
    st.WriteText(atext.replace("\n", "\r\n"), 0);
    st.SaveToFile(apath, 2);
    st.Close;  // Stream�̃N���[�Y
    st = null;
    return atext;
}

function formatDate(d){
    var year   = d.getFullYear();
    var month  = ('0' + (d.getMonth()+1)).slice(-2);
    var day    = ('0' + d.getDate()).slice(-2);
    var hour   = ('0' + d.getHours()).slice(-2);
    var minute = ('0' + d.getMinutes()).slice(-2);
    var second = ('0' + d.getSeconds()).slice(-2);

    return year + '/' + month + '/' + day + ' ' + hour + ':' + minute + ':' + second;
}
