;Made by Okuu; Fixed and Converted to AU3 by ShaggyZE
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Find\Images\gui\splash.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Tailor
#AutoIt3Wrapper_Res_Description=Tailor
#AutoIt3Wrapper_Res_Fileversion=2.9.0.84
#AutoIt3Wrapper_Res_LegalCopyright=ShaggyZE
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region Header
#Include <ImageSearch.au3>
#include <WinAPI.au3>

Global $ImageX, $ImageY, $EndX, $EndY, $Box[4], $MabiTop, $MabiLeft, $MabiWidth, $MabiHeight
Global $MabiRight, $MabiBottom, $Title, $Title1,$Delay, $MouseDelay, $MouseSpeed, $Tolerance, $Transparency
Global $ImageXOffset, $ImageYOffset, $EndXOffset, $EndYOffset
Global Const $VK_DELETE = 0x2E, $WM_KEYUP = 0x0101, $VK_END = 0x23
$Title1 = "Tailor Minigame By: ShaggyZE"
$Title = IniRead("config.ini","Settings","Title","Mabinogi")
$Delay = IniRead("config.ini","Settings","Delay","300")
$MouseDelay = IniRead("config.ini","Settings","MouseDelay","500")
$MouseSpeed = IniRead("config.ini","Settings","MouseSpeed","10")
$ImageXOffset = IniRead("config.ini","Settings","ImageXOffset","0.5")
$ImageYOffset = IniRead("config.ini","Settings","ImageYOffset","19")
$EndXOffset = IniRead("config.ini","Settings","EndXOffset","0.5")
$EndYOffset = IniRead("config.ini","Settings","EndYOffset","19")
$Tolerance = IniRead("config.ini","Settings","Tolerance","70")
$Transparency = IniRead("config.ini","Settings","Transparency","0x000000")
HotKeySet("{DELETE}", "_Exit")
HotKeySet("{END}", "_Exit")

If ProcessExists ("Client.exe") = False Then
ToolTip ("Error: Mabinogi Not Detected." & @CRLF & "Closing...", 0, @DesktopHeight - 70, $Title1)
Sleep (5000)
Exit 1
EndIf
$hFunc = DllCallbackRegister('_KeyboardHook', 'lresult', 'int;uint;uint')
$pFunc = DllCallbackGetPtr($hFunc)
$hMod = _WinAPI_GetModuleHandle(0)
$hHook = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, $pFunc, $hMod)
If Not WinActive ($Title) Then Winactivate ($Title)
WinWaitActive ($Title)
Sleep ($Delay)

While 1
	$Box = WinGetPos ($Title)
	If IsArray($Box) Then
		$MabiTop = $Box[0]
		$MabiLeft = $Box[1]
		$MabiWidth = $Box[2]
		$MabiHeight = $Box[3]
		$MabiRight = $MabiLeft + $MabiWidth
		$MabiBottom = $MabiTop + $MabiHeight
	Else
		$MabiTop = 0
		$MabiLeft = 0
		$MabiWidth = 1000
		$MabiHeight = 1000
		$MabiRight = $MabiLeft + $MabiWidth
		$MabiBottom = $MabiTop + $MabiHeight
	EndIf
	ToolTip ("Searching.", 0, @DesktopHeight - 60, $Title1)
	Sleep ($Delay)
	$Result = Search()
	If $Result = 0 Then
		ToolTip ("Error: Search Failed.", 0, @DesktopHeight - 60, $Title1)
		Sleep ($Delay * 100)
	EndIf
	Sleep ($Delay)
WEnd

Func Search()
	ToolTip ("Searching..", 0, @DesktopHeight - 60, $Title1)
	$Result = _ImageSearchArea(@ScriptDir & "\Find\Images\buttons\X.bmp", 1, $MabiLeft, $MabiTop, $MabiRight, $MabiBottom, $ImageX, $ImageY, $Tolerance)
	Sleep ($Delay)
	If $Result = 1 Then
		$Result = Tailor_Minigame($ImageX + $ImageXOffset, $ImageY + $ImageYOffset)
		Return 1
	Else
		ToolTip ("Searching..." & @CRLF & "Error: Start X Not Found.", 0, @DesktopHeight - 60, $Title1)
		Sleep ($Delay * 100)
		Return 2
	EndIf
EndFunc

Func Tailor_Minigame($StartX, $StartY)
	ToolTip ("Searching..", 0, @DesktopHeight - 60, $Title1)
	$Result = _ImageSearchArea(@ScriptDir & "\Find\Images\buttons\O.bmp", 1, $MabiLeft, $MabiTop, $MabiRight, $MabiBottom, $EndX, $EndY, $Tolerance)
	Sleep ($Delay)
	If $Result = 1 Then
		_MouseDrag ($StartX, $StartY, $EndX + $EndXOffset, $EndY + $EndYOffset)
		Return 1
	Else
		ToolTip ("Searching..." & @CRLF & "Error: End O Not Found.", 0, @DesktopHeight - 70, $Title1)
		Sleep ($Delay * 100)
		Return 2
	EndIf
EndFunc

Func _MouseDrag($x1, $y1, $x2, $y2)
	MouseMove ($x1, $y1, $MouseSpeed)
	Sleep ($MouseDelay)
	MouseDown ("Left")
	MouseMove ($x2, $y2, $MouseSpeed)
	Sleep ($MouseDelay)
	MouseUp ("Left")
	Sleep ($MouseDelay)
	Return 1
EndFunc

Func _Exit()
	Exit 0
EndFunc

Func _KeyboardHook($iCode, $iwParam, $ilParam)
    Local $tKBDLLHS = DllStructCreate($tagKBDLLHOOKSTRUCT, $ilParam)
    Local $iVkCode
    If $iCode > -1 Then
        $iVkCode = DllStructGetData($tKBDLLHS, 'vkCode')
        If $iwParam = $WM_KEYUP Then
            Switch $iVkCode
				Case $VK_DELETE
					Exit 0
				Case $VK_END
					Exit 0
            EndSwitch
        EndIf
    EndIf
    Return _WinAPI_CallNextHookEx($hHook, $iCode, $iwParam, $ilParam)
EndFunc