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

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Call Tools.HelpUpdate()
