Option Explicit

'	�T�N���G�f�B�^�{�̂̍X�V�`�F�b�N(�I���f�}���h)
'
'	���o�[�W�������擾
'	�ŐV�o�[�W�������C���^�[�l�b�g����擾
'	�X�V����Ă���ꍇ�A���b�Z�[�W��\������B
'	�X�V����Ă��Ȃ��ꍇ�́A�����\�������I���B
Dim Tools

Set Tools = GetObject("script:" & Plugin.GetPluginDir() & "\Tools.wsc")
Set Tools.Editor = Editor
Set Tools.Plugin = Plugin
Tools.Init

Call Tools.UpdateCheck(2)
