' �T�N���G�f�B�^ �w���v�t�@�C���̍X�V����
'
' �T�N���G�f�B�^�̃o�[�W�����Ɠ����o�[�W�����̃w���v�t�@�C����T��
' ���łɂ���w���v�t�@�C���̃o�[�W�������擾����ɂ́H
'   �^�C���X�^���v�Ŕ��f�B�e�[�u������Ă���
' URL�ƃo�[�W�����̊֌W�����W
'   ���ׂẴw���v�t�@�C�����_�E�����[�h���āA�W�J���^�C���X�^���v�ƃo�[�W�����̃��X�g�����B
'   ���X�g��def�t�@�C���ɕۊǂ���B(JSON�`��?)
'
Option Explicit

Dim vbCrLf '= Chr(13) & Chr(10)
Dim vbLf '= Chr(10)

vbCrLf = Chr(13) & Chr(10)
vbLf = Chr(10)

Dim Tools


' Get SourceForge RSS 
function GetSFRSS(byref aurl, apath, byref aupdate)
    Dim rCode
    Dim items
    Dim ItemLink
    Dim ItemDate
    Dim i, j
    Dim wlink
    Dim wver
    Dim wcmd
    Dim wtmpfile
    
    wlink = aurl
    If apath<>"" then wlink = aurl & "?path=/" & apath
    
    Tools.log "SourceForge�m�F��... " & wlink, 0
    
    wtmpfile = Tools.WorkDir & "\_temp.htm"
    wcmd = Tools.CurlExe & " -L """ & wlink & """ -o " & wtmpfile
    Tools.log ">" & wcmd, 1
    'DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, True '
    
    Dim XmlDoc 'As Object
    Set XmlDoc = CreateObject("Microsoft.XMLDOM")
    XmlDoc.async = False
    'RSS��URL����f�[�^���擾
    'rCode = XmlDoc.Load("https://sourceforge.net/projects/sakura-editor/rss?path=/sakura2")
	'rCode = XmlDoc.Load(aurl)
    rCode = XmlDoc.Load(wtmpfile)

    '�擾�m�F
    If (XmlDoc.parseError.ErrorCode <> 0) Then '���[�h���s
        Tools.log "�ǂݍ��߂܂���ł����B", 0
        Tools.log XmlDoc.parseError.reason, 0   '�G���[���e���o��
        GetSFRSS = -1
        Exit Function
    End If

    'item�擾
    Set items = XmlDoc.SelectNodes("//item")

    Dim re, match, matchs
    Set re = CreateObject("VBScript.RegExp")
    re.pattern = "([0-9]\.[0-9]\.[0-9]\.[0-9])/sakura_help[0-9\-]+\.zip"

    wlink = ""
    '�u���O�L��4�o��
    For i = 0 To items.Length - 1
        set ItemLink = items(i).SelectNodes("./link")
        set ItemDate = items(i).SelectNodes("./pubDate")
        wlink = ItemLink(0).Text
        'If re.Test(wlink) Then
        Set matchs = re.Execute(wlink)
        If matchs.Count > 0 Then
            Editor.TraceOut "���������t�@�C��:" & wlink 
            aurl = wlink
            
            Tools.log "pubDate: " & ItemDate(0).Text , 2
            aupdate = ItemDate(0).Text
            aupdate = replace(aupdate, " UT","")
            j = instr(aupdate, ",")
            if j > 0 then aupdate =mid(aupdate, j+1)
            If IsDate(aupdate) then aupdate = DateValue(aupdate)
            Tools.log "aupdate: " & aupdate , 2
            
            If matchs(0).SubMatches.Count > 0 Then
                wver = matchs(0).SubMatches(0)
                'if wver = atargetver then
                'End If
            End If
            Exit For
        End If
        wlink = ""
    Next
    
    GetSFRSS = wver

End function



Call Main()
