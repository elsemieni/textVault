#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=vault_64px.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#include <Crypt.au3>
#include <File.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

_Crypt_Startup()

Global $encryptionKey = IniRead ( "config.ini", "TextVault", "key", "defaultKey")

#Region ### START Koda GUI section ### Form=C:\Users\elsem\PJs\textVault\window.kxf
$Form1 = GUICreate("TextVault", 612, 219, 192, 124)
$EditTextArea = GUICtrlCreateEdit("", 8, 8, 593, 161)
$Label1 = GUICtrlCreateLabel("TextVault 1.0. - 2018 Enzo Barbaguelatta - Marbleen Hyperware", 296, 184, 306, 17)
$StoreButton = GUICtrlCreateButton("Store text", 16, 184, 105, 25)
$DecryptButton = GUICtrlCreateButton("Decrypt output txt", 128, 184, 113, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Crypt_Shutdown ()
			Exit
		Case $StoreButton
			CryptInput(GUICtrlRead($EditTextArea))
			GUICtrlSetData($EditTextArea, "")
		Case $DecryptButton
			DecryptOutput()
	EndSwitch
WEnd

Func CryptInput($originalString)
	$encrypted = BinaryToString (_Crypt_EncryptData ( $originalString, $encryptionKey, $CALG_AES_256))
	FileWriteLine ( "out.txt", $encrypted)
EndFunc

Func DecryptOutput()
	$fileString = FileOpenDialog ( "Open an encrypted text file", @ScriptDir, "Encrypted text files (*.txt)", 1)
	if (@error ) then Return
	$fp = FileOpen ( $fileString, 128)
	if ($fp = -1) Then
		MsgBox(16, "Error", "Error opening the selected file!")
		Return
	EndIf
	$n = _FileCountLines ( $fileString )

	$sfileString = FileSaveDialog ( "Where to save decrypted file", @ScriptDir, "Plain text file (*.txt)" ,16)
	if (@error ) then
		FileClose($fp)
		Return
	EndIf
	$sfp = FileOpen ( $sfileString, 2)
	if ($sfp = -1) Then
		MsgBox(16, "Error", "Error opening the selected file!")
		FileClose($fp)
		Return
	EndIf

	For $i = 0 To $n
		$in = FileReadLine ( $fp, $i)
		$dec = BinaryToString (_Crypt_DecryptData ($in, $encryptionKey, $CALG_AES_256))
		FileWriteLine ( $sfp, $dec)
	Next
	FileClose($fp)
	FileClose($sfp)
	MsgBox(64, "Info", "Text was decrypted!")
EndFunc
