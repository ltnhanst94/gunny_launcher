#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\..\..\Personal\Logo.ico
#AutoIt3Wrapper_Outfile=D:\Cloud\OnlineDrive\Programing\AutoIt\Program Files\ISN AutoIt Studio\Projects\Gunny Client\Gunny Launcher.exe
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/sf /sv /pe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;*****************************************
#AutoIt3Wrapper_Au3stripper_OnError=ForceUse
;*****************************************

#include-once
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <IE.au3>
#include <Include/CoProc.au3>

Global $Form1 = GUICreate("Gunny Launcher",269,128,-1,-1,-1,$WS_EX_TOPMOST)
GUICtrlCreateLabel("Username",11,10,74,15,-1,-1)
GUICtrlSetFont(-1,11,400,0,"Arial")
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Password",11,35,74,15,-1,-1)
GUICtrlSetFont(-1,11,400,0,"Arial")
GUICtrlSetBkColor(-1,"-2")
Global $Ip_Username = GUICtrlCreateInput("",110,7,150,22,-1,$WS_EX_CLIENTEDGE)
GUICtrlSetFont(-1,11,400,0,"Arial")
Global $Ip_Password = GUICtrlCreateInput("",110,32,150,22,-1,$WS_EX_CLIENTEDGE)
GUICtrlSetFont(-1,11,400,0,"Arial")
Global $Bt_Login = GUICtrlCreateButton("Login",139,90,100,30,-1,-1)
GUICtrlSetFont(-1,11,400,0,"Arial")
Global $Cb_Server = GUICtrlCreateCombo("",110,57,150,24,-1,-1)
GUICtrlSetData(-1,"")
GUICtrlSetFont(-1,11,400,0,"Arial")
GUICtrlCreateLabel("Server",11,60,50,15,-1,-1)
GUICtrlSetFont(-1,11,400,0,"Arial")
GUICtrlSetBkColor(-1,"-2")
Global $Bt_AutoLogin = GUICtrlCreateButton("Auto Login",31,90,100,30,-1,-1)
GUICtrlSetFont(-1,11,400,0,"Arial")

#include <Include/_HttpRequest.au3>
#include <Array.au3>

Global $isFlashObj = True

Global $cloneUser = "gunnyclone0"
Global $clonePass = "gunnyclone0"

Global $ServerList = _GetServerList()

For $sv in $ServerList
	GUICtrlSetData($Cb_Server, $sv, "Gà Con")
Next

GUISetState()

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Bt_Login
			_Launch_Open(StringLower(GUICtrlRead($Ip_Username)), GUICtrlRead($Ip_Password), GUICtrlRead($Cb_Server), $isFlashObj)
		Case $Bt_AutoLogin
			Local $AccArray = FileReadToArray(@ScriptDir & "\AccountLogin.txt")
			For $Acc in $AccArray
				Local $rAcc = StringSplit($Acc, "|", 2)
				_Launch_Open(StringLower($rAcc[0]), $rAcc[1], $rAcc[2], $isFlashObj)
			Next

	EndSwitch
	Sleep(10)
Wend


Func _Launch_Open($username, $password, $server, $isFlashObj = False)
	_HttpRequest_SessionClear()
	_HttpRequest(0, 'http://idgunny.360game.vn?download=direct')
	Local $data = _HttpRequest(1, 'https://sso3.zing.vn/xlogin', _Data2SendEncode('u=' & $username & '&p=' & $password & '&u1=http%3A%2F%2Fidgunny.360game.vn%2Flogin-game%3Fdownload%3Ddirect%26sid%3Dnone%26err%3D1&fp=http%3A%2F%2Fidgunny.360game.vn%2Flogin-game%3Fdownload%3Ddirect%26sid%3Dnone%26err%3D1&pid=243&apikey=848dfc7c1dfe4da3b8dd3c58f8d34be8'))
	Local $id = _GetLocationRedirect()

	$data = _HTMLDecode(_HttpRequest(2, 'http://idgunny.360game.vn/server-game?download=direct&sid=none&err=1&mess=succ&sid=' & $id))

	Local $pos = StringInStr($data, 'title="' & StringLower($server)&'"')
	If @error Then $pos = StringInStr($data, 'title="' & StringLower($server))
	$data = StringTrimLeft(StringLower($data), $pos)

	$data = StringRegExp($data, 'href="(.*?)">', 3)
	If @error Then Exit MsgBox(4096, 'Lỗi', 'Đăng nhập thất bại')

	$data = _HttpRequest(2, $data[0])

	Local $Key = StringRegExp($data, 'key=(.*?)"', 3)
	If @error Then Exit MsgBox(4096, 'Lỗi', 'Đăng nhập thất bại')

	Local $SeverID = StringRegExp($data, 'src="http:\/\/s(.*?)\.', 3)

	If @error Then Exit MsgBox(4096, 'Lỗi', 'Đăng nhập thất bại')

	ConsoleWrite('server ID: ' & $SeverID[0] & @CRLF)
	ConsoleWrite('user name: ' & $username & @CRLF)
	ConsoleWrite('key: ' &  $Key[0] & @CRLF)
	$id = StringMid($id, StringInStr($id, 'sid=') + 4)
	ConsoleWrite('sId: ' &  $id & @CRLF)

	If $isFlashObj Then
		Local $url = StringFormat('http://res%s.gn.zing.vn/flash/Loading.swf?download=direct&user=%s&key=%s&isGuest=False&ua=&fbapp=false&v=&rand=&config=http://s%s.gn.zing.vn/config.xml&sessionId=%s', $SeverID[0] == "1" ? "" : $SeverID[0], $username, $Key[0], $SeverID[0], $id)
	Else
		Local $url = StringFormat("http://s%s.gn.zing.vn/Default.aspx?download=direct&user=%s&key=%s", $SeverID[0], $username, $Key[0])
	EndIf
	ConsoleWrite('url: ' &  $url & @CRLF)

	_CoProc('_Launch_Cmd("'& $isFlashObj &'", "'& $url &'")')
EndFunc

#Au3Stripper_Ignore_Funcs = _Launch_Cmd
Func _Launch_Cmd($isFlashObj, $url)
	Local $isObj = StringLower($isFlashObj) == 'true'

	If $isObj Then
		Local $oSWF = ObjCreate("ShockwaveFlash.ShockwaveFlash.1")
	Else
		Local $oSWF = _IECreateEmbedded()
	EndIf

	If @error Or Not IsObj($oSWF) Then Exit MsgBox(4096, 'Lỗi', 'Vui lòng cài Flash ActiveX')
	GUICreate("Gunny Client", 1000, 600);, Default, Default, Default, Default, $Form1)
	GUICtrlCreateObj($oSWF, 0, 0, 1000, 600)
	GUISetState()

	If $isObj Then
		With $oSWF
			.Movie = $url
			.allowScriptAccess = "always"
			.quality2 = "medium"
			.menu = "true";"false"
			.bgcolor = "#000000"
			.wmode = "direct"
		EndWith
	Else
		_IENavigate($oSWF, $url)
	EndIf

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit
		EndSwitch
		Sleep(1)
	WEnd
EndFunc

Func _GetServerList()
	_HttpRequest_SessionClear()
	_HttpRequest(0, 'http://idgunny.360game.vn?download=direct')
	Local $data = _HttpRequest(1, 'https://sso3.zing.vn/xlogin', _Data2SendEncode('u=' & $cloneUser & '&p=' & $clonePass & '&u1=http%3A%2F%2Fidgunny.360game.vn%2Flogin-game%3Fdownload%3Ddirect%26sid%3Dnone%26err%3D1&fp=http%3A%2F%2Fidgunny.360game.vn%2Flogin-game%3Fdownload%3Ddirect%26sid%3Dnone%26err%3D1&pid=243&apikey=848dfc7c1dfe4da3b8dd3c58f8d34be8'))
	Local $id = _GetLocationRedirect()

	$data = _HTMLDecode(_HttpRequest(2, 'http://idgunny.360game.vn/server-game?download=direct&sid=none&err=1&mess=succ&sid=' & $id))

	$data = StringTrimLeft($data, StringInStr($data, 'class="Active ServerList"'))

	Return StringRegExp($data, '<li><a title="(.*?)"', 3)
EndFunc