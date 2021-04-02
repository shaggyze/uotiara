#Region
#include <ImageSearch.au3>
#AutoIt3Wrapper_Icon=AutoBot.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion
Global $HFUNC, $PFUNC, $HHOOK, $HMOD, $PIXEL1[2], $ATLCOORD[2],$GUI_EVENT_CLOSE = -3,$x1,$y1,$TOL
Global Const $WH_KEYBOARD_LL = 13, $TAGKBDLLHOOKSTRUCT = "dword vkCode;dword scanCode;dword flags;dword time;ulong_ptr dwExtraInfo"
Global Const $WM_KEYUP = 257, $GUI_DISABLE = 128
ONAUTOITEXITREGISTER ("_cleanUp")
$HFUNC = DLLCALLBACKREGISTER ("_KeyboardHook", "lresult", "int;uint;uint")
$PFUNC = DLLCALLBACKGETPTR ($HFUNC)
$HMOD = _WINAPI_GETMODULEHANDLE(0)
$HHOOK = _WINAPI_SETWINDOWSHOOKEX($WH_KEYBOARD_LL, $PFUNC, $HMOD)
$VK_HOME = 36
$VK_PGUP = 33
$VK_DELETE = 46
$VK_END = 35
$VK_ESC = 27
$I = -1
$WINDOW = WinGetHandle("[CLASS:Mabinogi]")
$REGKEY = "HKEY_CURRENT_USER\Software\ShaggyZE\Blacksmith\"
$LEFT = RegRead($REGKEY, "Left")
$TOP = RegRead($REGKEY, "Top")
$RIGHT = RegRead($REGKEY, "Right")
$BOTTOM = RegRead($REGKEY, "Bottom")
$TOL = RegRead($REGKEY, "TOL")
$FORM1 = GUICreate("Blacksmith", 200, 100, 0, 0)
$LABEL1 = GUICtrlCreateLabel("Hotkeys:", 10, 1, 46, 17)
$LABEL1 = GUICtrlCreateLabel("Esc = Exit", 10, 18, 50, 17)
$LABEL3 = GUICtrlCreateLabel("Page Up = Click", 10, 35, 126, 17)
GUICtrlSetTip(-1, "Click red dot when bar is green.)")
$LABEL5 = GUICtrlCreateLabel("Home = Renew Coords", 10, 52, 150, 17)
GUICtrlSetTip(-1, "Get new area to search within the minigame.")
$LABEL5 = GUICtrlCreateLabel("Tolerance", 10, 69, 70, 17)
GUICtrlSetTip(-1, "Tolerance when searching for reddot.bmp.")
$INPUT1 = GUICtrlCreateInput($TOL, 90, 69, 70, 17)
GUICtrlSetTip(-1, "Tolerance when searching for reddot.bmp.")
$LABEL8 = GUICtrlCreateLabel("Blacksmith Minigame By ShaggyZE", 10, 86, 200, 17)
GUICtrlSetTip(-1, "http://www.mabimods.net")
GUISetState(@SW_SHOW)
WinActivate($WINDOW)
WinSetOnTop("Blacksmith", "Hotkeys:", 1)
If $LEFT = "" Or $TOP = "" Or $RIGHT = "" Or $BOTTOM = "" Then
	MsgBox(64, "ERROR", "Please select your coords before trying to start the bot." & @CRLF & "Move your mouse to the top left of the Blacksmith Minigame and press delete, and again for the bottom right of the Blacksmith Minigame.")
	_SETCOORDS()
EndIf
$TOL = RegRead($REGKEY, "Tol")
While 1
	$NMSG = GUIGetMsg()
	Switch $NMSG
		Case $GUI_EVENT_CLOSE
			Exit
		Case Else
RegWrite($REGKEY, "TOL", "REG_SZ", GUICtrlRead($INPUT1))
	EndSwitch
WEnd


Func _Search()
	If $TOL = "" Then
		$TOL = 80
		RegWrite($REGKEY, "TOL", "REG_SZ", 80)
	EndIf
		WinActivate($WINDOW)
		$result = _ImageSearchArea(@ScriptDir & "\reddot.bmp", 1, $LEFT, $TOP, $RIGHT, $BOTTOM, $x1, $y1, $TOL)
		If $result Then
			ToolTip("reddot.bmp = " & $result & ". Image found.", 0, @DesktopHeight - 20)
			MouseMove($x1, $y1, 2)
			Sleep(100)
			MouseClick("left")
			WinSetOnTop("Blacksmith", "Hotkeys:", 1)
		Else
			ToolTip("reddot.bmp = " & $result & ". Image not found.", 0, @DesktopHeight - 20)
		EndIf
		Sleep(1000)
		ToolTip("", 0, @DesktopHeight - 20)
EndFunc


Func _SETCOORDS()
	While Not _ISPRESSED("2E")
		$ATLCOORD = MouseGetPos()
		Sleep(10)
		ToolTip("Top Left of Minigame:" & @CRLF & "X: " & $ATLCOORD[0] & " Y: " & $ATLCOORD[1] & @CRLF & "Color: " & PixelGetColor($ATLCOORD[0], $ATLCOORD[1], $WINDOW) & @CRLF & "Then press Delete", $ATLCOORD[0], $ATLCOORD[1], "Move Mouse To")
		If _ISPRESSED("2E") Then
			While _ISPRESSED("2E")
				Sleep(10)
			WEnd
			ExitLoop 1
		EndIf
	WEnd
	RegWrite($REGKEY, "Left", "REG_SZ", $ATLCOORD[0])
	RegWrite($REGKEY, "Top", "REG_SZ", $ATLCOORD[1])
	While Not _ISPRESSED("2E")
		Local $ABRCOORD = MouseGetPos()
		Sleep(10)
		ToolTip("Bottom Right of Minigame:" & @CRLF & "X: " & $ABRCOORD[0] & " Y: " & $ABRCOORD[1] & @CRLF & "Color: " & PixelGetColor($ABRCOORD[0], $ABRCOORD[1], $WINDOW) & @CRLF & "Then press Delete", $ABRCOORD[0], $ABRCOORD[1], "Move Mouse To")
		If _ISPRESSED("2E") Then
			While _ISPRESSED("2E")
				Sleep(10)
			WEnd
			ExitLoop 1
		EndIf
	WEnd
	RegWrite($REGKEY, "Right", "REG_SZ", $ABRCOORD[0])
	RegWrite($REGKEY, "Bottom", "REG_SZ", $ABRCOORD[1])
	$LEFT = RegRead($REGKEY, "Left")
	$TOP = RegRead($REGKEY, "Top")
	$RIGHT = RegRead($REGKEY, "Right")
	$BOTTOM = RegRead($REGKEY, "Bottom")
	ToolTip("Successfully set coordinates.", $ABRCOORD[0], $ABRCOORD[1], "SUCCESS!")
	Sleep(3000)
	ToolTip("")
EndFunc


Func _KEYBOARDHOOK($ICODE, $IWPARAM, $ILPARAM)
	Local $TKBDLLHS = DllStructCreate($TAGKBDLLHOOKSTRUCT, $ILPARAM)
	Local $IVKCODE
	If $ICODE > -1 Then
		$IVKCODE = DllStructGetData($TKBDLLHS, "vkCode")
		If $IWPARAM = $WM_KEYUP Then
			Switch $IVKCODE
				Case $VK_PGUP
					_Search()
				Case $VK_HOME
					_SETCOORDS()
				Case $VK_ESC
					Exit
			EndSwitch
		EndIf
	EndIf
	Return _WINAPI_CALLNEXTHOOKEX($HHOOK, $ICODE, $IWPARAM, $ILPARAM)
EndFunc


Func _CLEANUP()
	_WINAPI_UNHOOKWINDOWSHOOKEX($HHOOK)
	DLLCALLBACKFREE ($HFUNC)
EndFunc


Func _ISPRESSED($SHEXKEY, $VDLL = "user32.dll")
	Local $A_R = DllCall($VDLL, "short", "GetAsyncKeyState", "int", "0x" & $SHEXKEY)
	If @error Then Return SetError(@error, @extended, False)
	Return BitAND($A_R[0], 32768) <> 0
EndFunc


Func _WINAPI_CALLNEXTHOOKEX($HHK, $ICODE, $WPARAM, $LPARAM)
	Local $ARESULT = DllCall("user32.dll", "lresult", "CallNextHookEx", "handle", $HHK, "int", $ICODE, "wparam", $WPARAM, "lparam", $LPARAM)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc


Func _WINAPI_UNHOOKWINDOWSHOOKEX($HHK)
	Local $ARESULT = DllCall("user32.dll", "bool", "UnhookWindowsHookEx", "handle", $HHK)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc


Func _WINAPI_SETWINDOWSHOOKEX($IDHOOK, $LPFN, $HMOD, $DWTHREADID = 0)
	Local $ARESULT = DllCall("user32.dll", "handle", "SetWindowsHookEx", "int", $IDHOOK, "ptr", $LPFN, "handle", $HMOD, "dword", $DWTHREADID)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc


Func _WINAPI_GETMODULEHANDLE($SMODULENAME)
	Local $SMODULENAMETYPE = "wstr"
	If $SMODULENAME = "" Then
		$SMODULENAME = 0
		$SMODULENAMETYPE = "ptr"
	EndIf
	Local $ARESULT = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $SMODULENAMETYPE, $SMODULENAME)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc