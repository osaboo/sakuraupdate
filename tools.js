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

// DebugLvl>=alvlで、amsgをTraceOutする。
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

// 初期化
function Init(editor, plugin) {
  Editor = editor;
  Plugin = plugin;

  Version = "v20230921";

  DebugLvl = Plugin.GetOption("サクラエディタ", "DEBUGLVL");

  if ( DebugLvl == "" ) { // 初期値が設定されない古いバージョンの場合
      Plugin.SetOption("サクラエディタ", "SITEPRIORITY", "0");
      Plugin.SetOption("サクラエディタ", "GITHUBURL", "https://api.github.com/repos/sakura-editor/sakura/releases/latest");
      Plugin.SetOption("サクラエディタ", "APPVEYORURL", "https://ci.appveyor.com/api/projects/sakuraeditor/sakura");
      Plugin.SetOption("サクラエディタ", "OSDNURL",  "https://osdn.net/projects/sakura-editor/releases/rss");
      Plugin.SetOption("サクラエディタ", "REGEXPURL", "https://api.bitbucket.org/2.0/repositories/k_takata/bregonig/downloads");
      Plugin.SetOption("サクラエディタ", "DIFFURL", "http://www.ring.gr.jp/archives/text/TeX/ptex-win32/w32/patch-diff-w32.zip");
      Plugin.SetOption("サクラエディタ", "CTAGSURL", "https://api.github.com/repos/universal-ctags/ctags-win32/releases");
      Plugin.SetOption("サクラエディタ", "MIGEMOURL", "https://files.kaoriya.net/goto/cmigemo_w32");
      Plugin.SetOption("サクラエディタ", "PLUGINURL", "https://api.github.com/repos/osaboo/sakuraupdate/releases");
      Plugin.SetOption("サクラエディタ", "CHECKFREQ", "7");
      Plugin.SetOption("サクラエディタ", "DEBUGLVL", "0");
      Plugin.SetOption("サクラエディタ", "USEPREREL", "0");
      Plugin.SetOption("サクラエディタ", "CURLINSECURE", "0");
      DebugLvl = 0;
  }

  OSVer = GetOSInfo();
  //log("OSVer=" + OSVer, 2);

  FS = new ActiveXObject("Scripting.FileSystemObject");

  PluginDir = Plugin.GetPluginDir();
  SakuraDir = FS.GetParentFolderName(Editor.ExpandParameter("$S"));

  CurlExe = "\"" + Plugin.GetPluginDir() + "\\Curl.exe\"";
  CurlInsecure = (Plugin.GetOption("サクラエディタ", "CURLINSECURE") == "1");
     // UnzipExe = """" + Plugin.GetPluginDir() + "\\Unzip.exe"""
  UnzipExe = "\"" + Plugin.GetPluginDir() + "\\7za.exe\"";
     // Editor.ActivateWinOutput

  WSH = new ActiveXObject("Wscript.Shell");
  WorkDir = WSH.ExpandEnvironmentStrings("%TEMP%") + "\\sakuraupdate";

  log("更新作業用フォルダ " + WorkDir, 2);
  if ( ! IsExistDir(WorkDir) ) {
    log("更新作業用フォルダを作成します", 2);
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

// WorkDirを消す afileony=trueでファイルのみ消す
function WorkCleanup(afileonly) {

  if ( IsExistDir(WorkDir + "\\install") ) {
      log("installワークディレクトリ消去。" + WorkDir + "\\install", 3);
      DeleteFile(WorkDir + "\\install\\*.*");
      DeleteDir(WorkDir + "\\install");
  }

  if ( IsExistDir(WorkDir) ) {
    if ( afileonly ) {
      log("ワークディレクトリ消去。" + WorkDir, 2);
      DeleteFile( WorkDir + "\\*.*");
    } else {
      DeleteDir(WorkDir);
    }
  }

}

/** サクラエディタ本体の更新チェック
 * amode = 1:自動モード,  2:手動モード
 * 戻り値: 1=プレリリースあり -1(true)=更新あり 0(false)=更新なし
 * 0ならFalse
 * 0以外はTrue
 */
function SakuraCheck(amode, aver, aurl) {
    var wpre;
    var wlink;
    var wcurver;
    wcurver = Editor.ExpandParameter("$V");

	if (aurl.length < 1) {
		return;
	}
	
    if ( amode == 2 ) { log("このサクラエディタのバージョン:" + wcurver, 0) }

    switch(Plugin.GetOption("サクラエディタ", "SITEPRIORITY")) {
        case "0":
            aurl[0] = Plugin.GetOption("サクラエディタ", "GITHUBURL");
            break;
        case "1":
            aurl[0] = Plugin.GetOption("サクラエディタ", "APPVEYORURL");
            break;
        case "2":
            aurl[0] = Plugin.GetOption("サクラエディタ", "OSDNURL");
            break;
        case "3":
            aurl[0] = Plugin.GetOption("サクラエディタ", "CUSTOMURL");
            break;
    }

    wpre = Plugin.GetOption("サクラエディタ", "USEPREREL");
    log("プレリリースダウンロードフラグ = " + wpre, 2);
	
    if ( aurl[0].indexOf("github.com") >= 0 ) {
        if ( wpre == "0" ) { // 未設定時
            if ( WSH.Popup("GitHubのプレリリース版をダウンロードしますか?「はい」で次回以降もプレリリースの更新を反映します。「いいえ」でリリース版のみ反映します。この設定はプラグインのオプションで変更できます。", 0, "ソフトウェアの更新", 4) == 6 ) {
                wpre = "1"; // プレリリース
            } else {
                wpre = "2"; // リリースのみ
            }
            Plugin.SetOption("サクラエディタ", "USEPREREL", wpre);
        }
        if ( aurl[0].endsWith("/latest") ) { // 最新版指定があったら一旦とる。
            aurl[0] = aurl[0].substring(0, aurl[0].length - 7);
        }
        if ( wpre != "1" ) { // プレリリース指定以外 /latestを付けなおす
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
        if ( amode == 2 ) { log("×最新版を確認できませんでした。", 0); }
        return null;
    }

    if ( amode == 2 ) { log("最新のサクラエディタのバージョン:" + aver[0], 0) }

    if ( aver[0] <= wcurver ) {
        if ( amode == 2 ) { log("●サクラエディタは最新バージョンです。", 0) }
        return false;
    }

    if ( aurl[0].indexOf("alpha") >= 0 || aurl[0].indexOf("beta") >= 0 ) {
        log("★サクラエディタの新しいプレリリース版がリリースされています。", 0);
        return 1;
    }

    log("★サクラエディタの新バージョンがリリースされています。", 0);

    return true;
}

// サクラエディタのinstaller.zipダウンロードと、installerの起動
// installerは、一時フォルダに展開後実行するため、他のモジュールとは別扱い

function SakuraDownload(wurl) {
    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\installer.zip";

    wlink = wurl;

    log("サクラエディタをダウンロードします.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( !FS.FileExists(wzipfile) ) {
        log("ダウンロードできませんでした。", 0);
        return null;
    }

    log("ダウンロードファイルを展開します。", 0);

    if ( !FS.FileExists(WorkDir + "\\installer.zip") ) {
        log(WorkDir + "\\installer.zipがダウンロードファイルにありませんでした。", 0);
        return null;
    }

    // zip展開
    // wcmd = UnzipExe + " -o -j " + wzipfile + " */sakura.exe -d " + WorkDir
    wcmd = UnzipExe + " e -aoa -r " + wzipfile + " -o" + WorkDir + "\\install";
     // wcmd = UnzipExe + " e -aoa " + wzipfile + " -o" + WorkDir + "\\sakura"
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, false);

    Editor.Sleep(2000);

    if (!FS.FolderExists(WorkDir + "\\install") ) {
        log(WorkDir + "\\installer.zipの展開に失敗しました。", 0);
        return null;
    }
    
    var folder = FS.GetFolder(WorkDir + "\\install");
    var installexe = null;
    
    // インストールファイルを探す(sakura_install-*-x86.exe)
    for ( var e = new Enumerator(folder.files); !e.atEnd(); e.moveNext()) {
        var file = e.item();
        if (file.name.search(/^sakura_install.+\.exe$/)>=0){
            log("installerファイル " + file.name + "を見つけました。", 2);
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
    wrestart = "\r\n" + "注意！インストーラ起動前にサクラエディタは強制終了されます。編集中のファイルがある場合は破棄されます。";

    log("\r\nサクラエディタを更新します。" + wrestart, 0);

    if ( WSH.Popup("サクラエディタを更新します。この画面の後インストーラが起動しますので、インストールを実施してください。" + wrestart, 0, "ソフトウェアの更新", 1) == 2 ) {
        return;
    }

    // exe上書き処理
    // 更新スクリプトを作成し、他プロセスで実行
    // 実行後サクラエディタを終了する。
    // スクリプトは、サクラエディタ上書きが出来るまで待機する。
    // program files\sakuraの場合はセキュリティ警告がでる。
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

     // mainupdate.batとfileupdate.batの退避
    FS.CopyFile(PluginDir + "\\sleep.js", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\mainupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\fileupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\runas.ps1", WorkDir + "\\", true);
    wcmd = "\"" + WorkDir + "\\mainupdate.bat\"";

    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 1, false);

    //log("更新処理を終了しました。", 0);

}

// プラグインファイルの更新チェック
// amode = 1:自動モード,  2:手動モード
// 戻り値: true=更新あり false=更新なし
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

    if ( amode == 2 ) { log("このプラグインのバージョン:" + wcurver, 0); }

    aurl[0] = Plugin.GetOption("サクラエディタ", "PLUGINURL");
    aver[0] = GetGitHub(aurl);

    if ( aver[0] == "" ) {
        if ( amode == 2 ) { log("×最新版を確認できませんでした。", 0) }
        return null;
    }

    if ( amode == 2 ) { log("最新のプラグインのバージョン:" + aver, 0) }

    if ( aver[0] <= wcurver ) {
        if ( amode == 2 ) { log("●プラグインは最新バージョンです。", 0) }
        return false;
    }

    log("★プラグインの新バージョンがリリースされています。", 0);

    return true;
}

// プラグインのzipダウンロード
function PluginDownload(wurl) {

    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\Plugin.zip";

    wlink = wurl;

    log("プラグインをダウンロードします.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( ! IsExistFile(wzipfile) ) {
        log("ダウンロードできませんでした。", 0);
        return false;
    }

    log("ダウンロードファイルを展開します。", 0);

     // zip展開
     // CreateDir(WorkDir + "\\plugin")
    wcmd = UnzipExe + " x -aoa " + wzipfile + " -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

// On Error Resume Next
    Editor.Sleep(2000);
// On Error GoTo 0

    if ( ! IsExistFile(WorkDir + "\\sakuraupdate\\plugin.def") ) {
        log("プラグインzipではありませんでした。", 0);
        return false;
    }

    return true;

}

// pluginのファイルをインストールフォルダへコピーする。
//
function PluginSetup(atarget) {

    log("プラグインを更新します。", 1);
    if ( WSH.Popup("プラグインを更新します。" + "\r\n" + "注意！更新前にサクラエディタは強制終了します。編集中のファイルがある場合は破棄されます。", 0, "ソフトウェアの更新", 1) == 2 ) {
        return;
    }

     // exe上書き処理
     // 更新スクリプトを作成し、他プロセスで実行
     // 実行後サクラエディタを終了する。
     // スクリプトは、サクラエディタ上書きが出来るまで待機する。
     // program files\\sakuraの場合はセキュリティ警告がでる。
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

     // mainupdate.batとfileupdate.batの退避
    FS.CopyFile(PluginDir + "\\sleep.js", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\mainupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\fileupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\runas.ps1", WorkDir + "\\", true);

    wcmd = "\"" + WorkDir + "\\mainupdate.bat\"";

    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 1, false);

    log("プラグインの更新処理を終了しました。", 0);

}

// 正規表現ライブラリの更新チェック
// amode = 1:自動モード,  2:手動モード
// 戻り値: true=更新あり false=更新なし
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

    if ( amode == 2 ) { log("配置済みの正規表現ライブラリのバージョン:" + wcurver[0] + "." + wcurver[1], 0); }

    wurl[0] = Plugin.GetOption("サクラエディタ", "REGEXPURL");

    if ( wurl[0].indexOf("api.bitbucket.org") >= 0 ) {
        aver = GetBitBucket(wurl);
    }

    if ( aver == "" ) {
        if ( amode == 2 ) { log("×最新版を確認できませんでした。", 0); }
        return null;
    }

    aurl[0] = wurl[0];

    if ( amode == 2 ) { log("最新の正規表現ライブラリのバージョン:" + aver[0] + "." + aver[1], 0); }

    if ( aver[0] <= wcurver[0] && aver[1] <= wcurver[1] ) {
        if ( amode == 2 ) { log("●正規表現ライブラリは最新バージョンです。", 0); }
        return false;
    }

    log("★正規表現ライブラリの新バージョンがリリースされています。", 0);

    return true;

}

// 正規表現ライブラリのzipダウンロード

function RegExpDownload(wurl) {
    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\regexp.zip";

    log("typeof=" + new String(wurl), 2);
    
    //if ( (new String(wurl)).indexOf("bitbucket.org") >= 0 ) {
        wlink = wurl;
    //}

    log("正規表現ライブラリをダウンロードします.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, true);

    if ( ! IsExistFile(wzipfile) ) {
        log("ダウンロードできませんでした。", 0);
        return false;
    }

    log("ダウンロードファイルを展開します。", 1);

     // zip展開
    wcmd = UnzipExe + " e -aoa " + wzipfile + " bregonig.dll -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

    Editor.Sleep(2000);

    if ( ! IsExistFile(WorkDir + "\\bregonig.dll") ) {
        log("bregonig.dllがダウンロードファイルにありませんでした。", 0);
        return false;
    }

    return true;
}

// Diff(差分)ツールの更新チェック
// amode = 1:自動モード,  2:手動モード
// 戻り値: true=更新あり false=更新なし
//
function DiffCheck(amode, aver, aurl) {
    var wurl;
    var wlink;
    var wsakurapath;
    var wdiffpath;
    var wcurdate;

    wsakurapath = Editor.ExpandParameter("$S");
    wdiffpath = FS.GetParentFolderName(wsakurapath) + "\\diff.exe";
    log("Diff(差分)ツールの存在チェック: " + wdiffpath,2);
    
    wcurdate = "";
    if (FS.FileExists(wdiffpath)) {
        wcurdate = new Date(FS.GetFile(wdiffpath).DateLastModified);
    }

    if ( wcurdate == "" ) {
        if ( amode == 2 ) { log("現在、Diff(差分)ツールは配置されていません。", 0); }
    } else {
        if ( amode == 2 ) { log("配置済みのDiff(差分)ツールの更新日付:" + wcurdate.toLocaleString(), 0); }
    }

    aurl[0] = Plugin.GetOption("サクラエディタ", "DIFFURL");
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

        log("ステータスコード: " + whead.substring(0, 10), 2);

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
        if ( amode == 2 ) { log("×最新版を確認できませんでした。", 0); }
        return null;
    }

    if ( wcurdate != "" ) {
        if ( amode == 2 ) { log("●Diff(差分)ツールは配置済みです。", 0); }
        return false;
    }

    log("★Diff(差分)ツールがダウンロード可能です。", 0);

    return true;
}

/** ヘッダのみ要求してレスポンスコードを返す
 */
function GetHTTPStatus(aurl) {
    var req = CreateHttpRequest();

    if ( req == null ) {
        return null;
    }

    log("HEAD要求中... " + aurl, 1);

    req.open("HEAD", aurl, false);
    try {
        req.send();
    } catch(e) {
        log("エラー: " + e, 0);
        return null;
    }

    log("ステータスコード：" + req.status, 2);
    
    var headers = req.getAllResponseHeaders();
    //for (var h in headers) {
    //  log("レスポンスヘッダ: " + headers);
	//}
    return req; //.status;

}

// Diff(差分)ツールのzipダウンロード

function DiffDownload(wurl) {

    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\Diff.zip";

    wlink = wurl;

    log("Diff(差分)ツールをダウンロードします.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( ! IsExistFile(wzipfile) ) {
        log("ダウンロードできませんでした。", 0);
        return false;
    }

    log("ダウンロードファイルを展開します。", 1);

     // zip展開
    wcmd = UnzipExe + " e -aoa " + wzipfile + " diff.exe -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

    Editor.Sleep(2000);

    if ( ! IsExistFile(WorkDir + "\\diff.exe") ) {
        log("diff.exeがダウンロードファイルにありませんでした。", 0);
        return false;
    }

    return true

}

/** Ctags(タグ生成)ツールの更新チェック
 * amode = 1:自動モード,  2:手動モード
 * 戻り値: true=更新あり false=更新なし
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
        	log("現在、Ctags(タグ生成)ツールは配置されていません。", 0);
        }
    } else {
        if ( amode == 2 ) {
        	log("配置済みのCtags(タグ生成)ツールの更新日付:" + wcurdate.toLocaleString(), 0);
        }
        if ( amode == 1 ) {
            return false;
        }
    }

    aurl[0] = Plugin.GetOption("サクラエディタ", "CTAGSURL");
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
                log("見つかったファイル:" + wlink, 2);
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
        if ( amode == 2 ) { log("×最新版を確認できませんでした。", 0) }
        return null;
    } else {
        if ( amode == 2 ) { log("最新のCtags(タグ生成)ツールのバージョン:" + aver, 0) }
    }

    if ( wcurdate != "" ) {
        if ( amode == 2 ) { log("●Ctags(タグ生成)ツールは配置済みです。", 0) }
        return false;
    }

    log("★Ctags(タグ生成)ツールがダウンロード可能です。", 0);

    return true;
}

// Ctags(タグ生成)ツールのzipダウンロード

function CtagsDownload(wurl) {

    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\Ctags.zip";

    wlink = wurl;

    log("Ctags(タグ生成)ツールをダウンロードします.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( ! IsExistFile(wzipfile) ) {
        log("ダウンロードできませんでした。", 0);
        return false;
    }

    log("ダウンロードファイルを展開します。", 1);

     // zip展開
    wcmd = UnzipExe + " e -aoa " + wzipfile + " -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

// On Error Resume Next
    Editor.Sleep(2000);
// On Error GoTo 0

    if ( ! IsExistFile(WorkDir + "\\ctags.exe") ) {
        log("ctags.exeがダウンロードファイルにありませんでした。", 0);
        return false;
    }

    return true;
}


/** Migemo(ローマ字インクリメンタル検索)ツールの更新チェック
 * amode = 1:自動モード,  2:手動モード
 * 戻り値: true=更新あり false=更新なし
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
        	log("現在、Migemo(ローマ字インクリメンタル検索)ツールは配置されていません。", 0);
        }
    } else {
        if ( amode == 2 ) {
        	log("配置済みのMigemo(ローマ字インクリメンタル検索)ツールの更新日付:" + wcurdate.toLocaleString(), 0);
        }
        if ( amode == 1 ) {
            return false;
        }
    }

    aurl[0] = Plugin.GetOption("サクラエディタ", "MIGEMOURL");
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
        if ( amode == 2 ) { log("×最新版を確認できませんでした。", 0) }
        return null;
    } else {
        if ( amode == 2 ) { log("最新のMigemo(ローマ字インクリメンタル検索)ツールの配布日付:" + aver.toLocaleString(), 0) }
    }

    if ( wcurdate != "" ) {
        if ( amode == 2 ) { log("●Migemo(ローマ字インクリメンタル検索)ツールは配置済みです。", 0) }
        return false;
    }

    log("★Migemo(ローマ字インクリメンタル検索)ツールがダウンロード可能です。", 0);

    return true;
}

/** Mimego(ローマ字インクリメンタル検索)ツールのzipダウンロード
 *
 *  zipを展開後、distフォルダとmigemo.dllをコピーする。
 *
 */
function MigemoDownload(wurl) {

    var wlink;
    var wcmd;
    var wzipfile;

    wzipfile = WorkDir + "\\migemo.zip";

    wlink = wurl;

    log("Migemo(ローマ字インクリメンタル検索)ツールをダウンロードします.. " + wlink, 0);

     // wcmd = "bitsadmin.exe /TRANSFER sakura2 " + wurl + " " + wzipfile
    wcmd = CurlExe + (CurlInsecure?" --insecure":"") + " -L \"" + wlink + "\" -o " + wzipfile;
    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 7, true); //

    if ( ! IsExistFile(wzipfile) ) {
        log("ダウンロードできませんでした。", 0);
        return false;
    }

    log("ダウンロードファイルを展開します。", 1);

     // zip展開
    wcmd = UnzipExe + " x -aoa " + wzipfile + " -o" + WorkDir;
    log(">" + wcmd, 1);
    WSH.Run(wcmd, 7, false);

    Editor.Sleep(2000);

    if ( ! IsExistFile(WorkDir + "\\cmigemo-default-win32\\migemo.dll") ) {
        log("migemo.dllがダウンロードファイルにありませんでした。", 0);
        return false;
    }

    return true;
}

// %temp%\sakuraupdate内の指定ファイルをインストールフォルダへコピーする。
// atargets = 指定ファイルの配列(1～)

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
            wrestart = "\r\n" + "注意！更新前にサクラエディタは強制終了します。編集中のファイルがある場合は破棄されます。";
        }
    }

    log("\r\n" + wfilelist.substring(1) + "を更新します。" + wrestart, 0);

    if ( WSH.Popup(wfilelist.substring(1) + "を更新します。" + wrestart, 0, "ソフトウェアの更新", 1) == 2 ) {
        return;
    }

     // exe上書き処理
     // 更新スクリプトを作成し、他プロセスで実行
     // 実行後サクラエディタを終了する。
     // スクリプトは、サクラエディタ上書きが出来るまで待機する。
     // program files\sakuraの場合はセキュリティ警告がでる。
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

     // mainupdate.batとfileupdate.batの退避
    FS.CopyFile(PluginDir + "\\sleep.js", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\mainupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\fileupdate.bat", WorkDir + "\\", true);
    FS.CopyFile(PluginDir + "\\runas.ps1", WorkDir + "\\", true);

    wcmd = "\"" + WorkDir + "\\mainupdate.bat\"";

    log(">" + wcmd, 1);
     // DoCmd wcmd, ""
    WSH.Run(wcmd, 1, false);

    log("更新処理を終了しました。", 0);

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
    log("GitHub確認中.. " + wlink, 1);

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
             // log "見つかった文字列:" + match.Value, 2
             // Next
            if ( matchs.Count > 0 ) {
                if ( DebugLvl > 2 ) {
                    log("見つかった文字列:" + matchs(0).Value, 2);
                    log("見つかった副文字列の数:" + matchs(0).SubMatches.Count, 2);
                    for ( i = 0 ; i <= matchs(0).SubMatches.Count - 1 ; i++ ) {
                        log("見つかった副文字列(" + i + "):" + matchs(0).SubMatches(i), 2);
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
                    log("見つかったファイル:" + wlink, 2);
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
                    log("見つかったファイル:" + wlink, 2);
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
    
    log("OSDN 確認中... " + wlink,1);

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

    //取得確認
    if (XmlDoc.parseError.errorCode != 0) { //ロード失敗
        log("読み込めませんでした。ErrorCode:" & XmlDoc.parseError.errorCode, 0);
        log("エラー内容:" & XmlDoc.parseError.reason, 0); //エラー内容を出力
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
	            
	            log("見つかったファイル:" + wlink, 2);
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
	            
	            log("見つかったファイル:" + wlink, 2);
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
    log("BitBucket確認中.. " + wlink, 1);

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
        log("見つかったファイル:" + wlink, 2);
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
    log("AppVeyor確認中.. " + wlink, 1);

	// projects情報を得る
    wjson = DownloadFile(wlink, "");
    //log("json = " + wjson);
    wjson = eval('(' + wjson + ')');
	//log("build.buildId = " + wjson.build.buildId);
	//log("build.jobs[0].jobId = " + wjson.build.jobs[0].jobId);
	//log("build.jobs[0].name = " + wjson.build.jobs[0].name);
    //wver = wjson.build.version;
	var jobId = wjson.build.jobs[0].jobId;
	
	// 最新のビルドのartifactsの一覧を得る
	wlink = "https://ci.appveyor.com/api/buildjobs/" + jobId + "/artifacts";
    wjson = DownloadFile(wlink, "");
	//log(wjson);
	wjson = eval('(' + wjson + ')');
	var fileName = "";
	for (var af in wjson) {
		fileName = wjson[af].fileName;
		//log("artifacts[" + af + "].fileName = " + fileName);
		if (fileName && fileName.indexOf("Win32-Release-Installer.zip") >= 0 && fileName.indexOf("zip.md5") < 0) {
			log("見つかったファイル:" + fileName, 2);
			break;
		}
		fileName = "";
	}
	
	if (fileName == "") {
		return "";
	}
	
	aurl[0] = wlink + "/" + fileName;

	// SHA256.txtを得て、バージョン情報を得る
	wlink = "https://ci.appveyor.com/api/buildjobs/" + jobId + "/artifacts/sha256.txt";
    wtext = DownloadFile(wlink, "");

	// sha256.txtの中のsakura_install2-4-2-xxxx-x86.exeを探す
    var re;
    re = new ActiveXObject("VBScript.RegExp");
    re.Pattern = "sakura_install(2-[0-9]+-[0-9]+-[0-9]+)-x86\.exe";
	
    re.Global = true;
    var matchs = re.Execute(wtext);
    if ( matchs.Count > 0 ) {
		log("見つかったファイル名:" + matchs(0).value, 2);
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

    req = null;        // 初期化
    req = CreateHttpRequest();
    if ( req == null ) {
        //DownloadFile = DownloadCURL(aurl, SaveFilePath);
        return null;
    }

    log("ダウンロード中... " + aurl, 1);

    req.open("GET", aurl, false);

     // 2：SXH_OPTION_IGNORE_SERVER_SSL_CERT_ERROR_FLAGS
     // 3：SXH_OPTION_SELECT_CLIENT_SSL_CERT
     // 13056: SXH_OPTION_IGNORE_SERVER_SSL_CERT_ERROR_FLAGS
     // req.SetOption 2, 13056

     // XMLHTTPRequestを考慮してキャッシュ対策
     // http://vird2002.s8.xrea.com/javascript/XMLHttpRequest.html#XMLHttpRequest_Cache-Control
     // http://www.atmarkit.co.jp/ait/articles/0305/10/news002.html 参考
    req.setRequestHeader("Pragma", "no-cache");
    req.setRequestHeader("Cache-Control", "no-cache");
    req.setRequestHeader("If-Modified-Since", "Thu, 01 Jun 1970 00:00:00 GMT");

    try {
        req.send();
    } catch(e) {
        log("XMLHTTPRequestでの取得が失敗しました。(" + e.message + ")", 1);
        log("CURL.exeでの取得に切り替えます。", 1);
        //return DownloadCURL(aurl, SaveFilePath);
    	return null;
    }

    log("ステータスコード：" + req.status, 2);

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
        //log("ステータスエラー：" + req.status, 1);
        return "#ERROR# " + req.status;
    }

}

// WinHttpRequest/XMLHTTPRequestオブジェクト作成
// http://www.f3.dion.ne.jp/~element/msaccess/AcTipsWinHTTP1.html 参考
// @see https://www.ka-net.org/blog/?p=4855#HttpRequest
function CreateHttpRequest() {  // As Object
  var progIDs; // As Variant
  var ret; // As Object
  var i; // As Long

  ret = null;        // 初期化
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
      log("XMLHTTPRequestを" + progIDs[i] + "で初期化しました。", 2);
      break;
    } catch(e) {
      log("XMLHTTPRequestを" + progIDs[i] + "で初期化に失敗しました:" + e.message, 2);
      // for(k in e) { log("error e." + k + ": " + e[k]);}
    }
  }
  
  if (ret == null) {
    log("XMLHTTPRequestを初期化できませんでした。", 0);
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
    log(adir + "フォルダを作成できませんでした。", 1);
  }
}

function DeleteDir(adir) {
  if ( FS == null ) { FS = new ActiveXObject("Scripting.FileSystemObject"); }
  try {
    FS.DeleteFolder(adir, true);
  } catch (e) {
    log(adir + "フォルダを削除できませんでした。" + e, 1);
  }
}

function DeleteFile(afile) {
  if ( FS == null ) { FS = new ActiveXObject("Scripting.FileSystemObject"); }
  
  try {
    FS.DeleteFile(afile, true);
  } catch (e) {
     log(afile + "を削除できませんでした。" + e, 1);
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

   // ADODB.Streamの参照URL
   // http://msdn.microsoft.com/ja-jp/library/cc364272.aspx
   // http://msdn.microsoft.com/ja-jp/library/cc364273.aspx
    var st;
    st = new ActiveXObject("ADODB.Stream");     // ADODB.Stream生成
    st.Type = 2;  // オブジェクトに保存するデータの種類を文字列型に指定する
    st.Charset = aenc; // "utf-8"  '文字コード（Shift_JIS, Unicodeなど）
    st.LineSeparator = 10; // 改行LF（10）
    try {
      st.Open;         // Streamのオープン
      st.LoadFromFile(afile); // ファイル読み込み
      wbuff = st.ReadText(-1);
    } catch(e) {
      wbuff = "#ERROR#";
    } finally {
      st.Close;  // Streamのクローズ
    }
    st = null;

    return wbuff;
}

function SaveText(atext, apath, aenc) {
  if ( aenc == "" ) { aenc = "Shift_JIS" }
   // ADODB.Streamの参照URL
   // http://msdn.microsoft.com/ja-jp/library/cc364272.aspx
   // http://msdn.microsoft.com/ja-jp/library/cc364273.aspx
    var st;
    st = new ActiveXObject("ADODB.Stream");     // ADODB.Stream生成
    st.Type = 2;  // オブジェクトに保存するデータの種類を文字列型に指定する
    st.Charset = aenc; // "utf-8"  '文字コード（Shift_JIS, Unicodeなど）
    st.LineSeparator = -1; // 改行LF（10）CRLF(-1)
    st.Open;         // Streamのオープン
    st.WriteText(atext.replace("\n", "\r\n"), 0);
    st.SaveToFile(apath, 2);
    st.Close;  // Streamのクローズ
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
