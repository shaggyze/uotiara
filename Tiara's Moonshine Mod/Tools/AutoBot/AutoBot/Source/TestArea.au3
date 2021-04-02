#include-once
#include <WindowsConstants.au3>
;Example
;while 1
	;_TestArea(100,100,200,200,5000)
;wend
Func _TestArea($x1, $y1, $x2, $y2, $delay)
Local $SELECT_H
ToolTIP($x1 & " , " & $y1 & " , " & $x2 & " , " & $y2,0,@DesktopHeight-20)
Sleep($delay)
$SELECT_H =  GUICreate( "AU3SelectionBox", $x1 , $y1 , $x2, $y2,  $WS_POPUP + $WS_BORDER, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW)
GUISetBkColor(0x00FFFF,$SELECT_H)
WinSetTrans("AU3SelectionBox","",60)
GUISetState(@SW_SHOW,$SELECT_H)
GUISetState(@SW_RESTORE,$SELECT_H)
Sleep($delay)
GUISetState(@SW_HIDE,$SELECT_H)
EndFunc