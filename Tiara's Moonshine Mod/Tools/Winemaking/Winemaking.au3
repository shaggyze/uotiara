
#Region
#AutoIt3Wrapper_Icon=Icons\Blade3575.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion
Global $HFUNC, $PFUNC, $HHOOK, $HMOD, $PIXEL1[2], $ATLCOORD[2]
Global Const $WH_KEYBOARD_LL = 13, $GUI_EVENT_CLOSE = -3, $TAGKBDLLHOOKSTRUCT = "dword vkCode;dword scanCode;dword flags;dword time;ulong_ptr dwExtraInfo"
Global Const $WM_KEYUP = 257, $GUI_DISABLE = 128
ONAUTOITEXITREGISTER ("_cleanUp")
$HFUNC = DLLCALLBACKREGISTER ("_KeyboardHook", "lresult", "int;uint;uint")
$PFUNC = DLLCALLBACKGETPTR ($HFUNC)
$HMOD = _WINAPI_GETMODULEHANDLE(0)
$HHOOK = _WINAPI_SETWINDOWSHOOKEX($WH_KEYBOARD_LL, $PFUNC, $HMOD)
$VK_HOME = 36
$VK_PGUP = 33
$VK_PGDN = 34
$VK_DELETE = 46
$VK_END = 35
$VK_ESC = 27
$I = -1
$WINDOW = WinGetHandle("[CLASS:Mabinogi]")
$REGKEY = "HKEY_CURRENT_USER\Software\Blade3575\Winemaking\"
$LEFT = RegRead($REGKEY, "Left")
$TOP = RegRead($REGKEY, "Top")
$RIGHT = RegRead($REGKEY, "Right")
$BOTTOM = RegRead($REGKEY, "Bottom")
$COLOR = RegRead($REGKEY, "Color")
$SHADE = RegRead($REGKEY, "Shade")
$CLICKLAST = RegRead($REGKEY, "ClickLast")
If $COLOR = "" Then $COLOR = 7544950
If $SHADE = "" Then $SHADE = 10
If $CLICKLAST = "" Then $CLICKLAST = 0
$FORM1 = GUICreate("Winemaking", 192, 250, 0, 0)
$LABEL1 = GUICtrlCreateLabel("Hotkeys:", 10, 1, 46, 17)
$LABEL1 = GUICtrlCreateLabel("Esc = Exit", 10, 18, 50, 17)
$LABEL2 = GUICtrlCreateLabel("Home = Start", 10, 33, 128, 17)
GUICtrlSetTip(-1, "Start or Stop the bot.")
$LABEL3 = GUICtrlCreateLabel("PgUp = Mouse Wheel Up", 10, 50, 126, 17)
GUICtrlSetTip(-1, "Zoom in.")
$LABEL4 = GUICtrlCreateLabel("PgDn = Mouse Wheel Down", 10, 70, 140, 17)
GUICtrlSetTip(-1, "Zoom out.")
$LABEL5 = GUICtrlCreateLabel("End = Renew Coords", 10, 90, 105, 17)
GUICtrlSetTip(-1, "Get new area to search within the barrel.")
$LABEL6 = GUICtrlCreateLabel("Delete = Take Coord Position", 10, 110, 192, 17)
GUICtrlSetTip(-1, "Captures X and Y mouse postiion of area to search.")
$LABEL7 = GUICtrlCreateLabel("Blotch Color: Default = 7544950", 10, 130, 192, 17)
GUICtrlSetTip(-1, "A Shade of the Color Purple of a Blotch.")
$INPUT1 = GUICtrlCreateInput($COLOR, 10, 150, 70, 17)
GUICtrlSetTip(-1, "A Shade of the Color Purple of a Blotch.")
$LABEL8 = GUICtrlCreateLabel("Shade Variance: Default = 10", 10, 170, 192, 17)
GUICtrlSetTip(-1, "How many Shades plus and minus to also look for.")
$INPUT2 = GUICtrlCreateInput($SHADE, 10, 190, 70, 17)
GUICtrlSetTip(-1, "How many Color Shades plus and minus to also look for.")
$INPUT3 = GUICtrlCreateCheckbox("Click Previous Blotch Location", 10, 210, 215, 17)
GUICtrlSetTip(-1, "If no New Blotch is found continue clicking Last Blotch.")
$LABEL8 = GUICtrlCreateLabel("By ShaggyZE and Blade3575", 10, 230, 160, 17)
GUICtrlSetTip(-1, "http://www.mabimods.net")
GUICtrlSetState($INPUT3, $CLICKLAST)
GUISetState(@SW_SHOW)
WinActivate($WINDOW)
WinSetOnTop("Winemaking", "Hotkeys:", 1)
If $LEFT = "" Or $TOP = "" Or $RIGHT = "" Or $BOTTOM = "" Then
	MsgBox(64, "ERROR", "Please select your coords before trying to start the bot." & @CRLF & "Move your mouse to the top left of the Barrel and press delete, and again for the bottom right of the barrel.")
	_SETCOORDS()
EndIf
ADLIBREGISTER ("_Search", 1000)
While 1
	$NMSG = GUIGetMsg()
	Switch $NMSG
		Case $GUI_EVENT_CLOSE
			Exit
		Case Else
			RegWrite($REGKEY, "Color", "REG_SZ", GUICtrlRead($INPUT1))
			RegWrite($REGKEY, "Shade", "REG_SZ", GUICtrlRead($INPUT2))
			RegWrite($REGKEY, "ClickLast", "REG_SZ", GUICtrlRead($INPUT3))
	EndSwitch
WEnd

Func _SEARCH()
	$COLOR = RegRead($REGKEY, "Color")
	$SHADE = RegRead($REGKEY, "Shade")
	$CLICKLAST = RegRead($REGKEY, "ClickLast")
	If $COLOR = "" Then $COLOR = 7544950
	If $SHADE = "" Then $SHADE = 10
	If $CLICKLAST = "" Then $CLICKLAST = 0
	GUICtrlSetState($INPUT3, $CLICKLAST)
	While $I = 1
		GUICtrlSetData($LABEL2, "Home = Stop")
		WinActivate($WINDOW)
		$PIXEL = PixelSearch($LEFT, $TOP, $RIGHT, $BOTTOM, $COLOR, $SHADE, 1, $WINDOW)
		If IsArray($PIXEL) Then
			MouseClick("PRIMARY", $PIXEL[0], $PIXEL[1], 1, 1)
			$PIXEL1 = $PIXEL
			WinSetOnTop("Winemaking", "Hotkeys:", 1)
		ElseIf $CLICKLAST = 1 Then
			If IsArray($PIXEL1) Then
				MouseClick("PRIMARY", $PIXEL1[0], $PIXEL1[1], 1, 1)
			Else
				$ATLCOORD = MouseGetPos()
				MouseClick("PRIMARY", $ATLCOORD[0], $ATLCOORD[1], 1, 1)
			EndIf
		EndIf
	WEnd
	GUICtrlSetData($LABEL2, "Home = Start")
EndFunc


Func _SETCOORDS()
	While Not _ISPRESSED("2E")
		$ATLCOORD = MouseGetPos()
		Sleep(10)
		ToolTip("Top Left of Barrel:" & @CRLF & "X: " & $ATLCOORD[0] & " Y: " & $ATLCOORD[1] & @CRLF & "Color: " & PixelGetColor($ATLCOORD[0], $ATLCOORD[1], $WINDOW) & @CRLF & "Then press Delete", $ATLCOORD[0], $ATLCOORD[1], "Move Mouse To")
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
		ToolTip("Bottom Right of Barrel:" & @CRLF & "X: " & $ABRCOORD[0] & " Y: " & $ABRCOORD[1] & @CRLF & "Color: " & PixelGetColor($ABRCOORD[0], $ABRCOORD[1], $WINDOW) & @CRLF & "Then press Delete", $ABRCOORD[0], $ABRCOORD[1], "Move Mouse To")
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
				Case $VK_HOME
					$I *= -1
				Case $VK_PGUP
					MouseWheel("UP")
				Case $VK_PGDN
					MouseWheel("DOWN")
				Case $VK_DELETE
					$I = -1
				Case $VK_END
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