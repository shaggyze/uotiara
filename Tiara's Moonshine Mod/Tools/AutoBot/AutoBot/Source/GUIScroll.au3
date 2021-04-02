#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.13.3 (beta)
 Author:         Kip

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here


#cs

Functions:

Scrollbar_Create($hWnd, $iBar, $iMax)
Scrollbar_Scroll($hWnd, $iBar, $iPos)
Scrollbar_GetPos($hWnd, $iBar)
Scrollbar_Step($iStep, $hWnd=0, $iBar=0)

#CE


#Include <GuiScrollBars.au3>
#include<GuiconstantsEx.au3>
#include<WindowsConstants.au3>
#include <ScrollBarConstants.au3>

Global $SCROLL_AMOUNTS[1][3]
$SCROLL_AMOUNTS[0][0] = 1

func Scrollbar_Create($hWnd, $iBar, $iMax)
	
	Local $Size = WinGetClientSize($hWnd)
	
	If $iBar = $SB_HORZ Then
		$Size = $Size[0]
	ElseIf $iBar = $SB_VERT Then
		$Size = $Size[1]
	Else
		Return 0
	EndIf
	
	ReDim $SCROLL_AMOUNTS[UBound($SCROLL_AMOUNTS)+1][3]
	$SCROLL_AMOUNTS[UBound($SCROLL_AMOUNTS)-1][0] = $hWnd
	$SCROLL_AMOUNTS[UBound($SCROLL_AMOUNTS)-1][1] = $iBar
	$SCROLL_AMOUNTS[UBound($SCROLL_AMOUNTS)-1][2] = $SCROLL_AMOUNTS[0][0]
	
	_GUIScrollBars_EnableScrollBar($hWnd, $iBar)
	_GUIScrollBars_SetScrollRange($hWnd, $iBar, 0,$iMax-1)

	_GUIScrollBars_SetScrollInfoPage($hWnd, $iBar, $Size)
	
	GUIRegisterMsg($WM_VSCROLL, "WM_VSCROLL")
	GUIRegisterMsg($WM_HSCROLL, "WM_HSCROLL")
	
	Return $iMax
	
EndFunc

Func Scrollbar_GetPos($hWnd, $iBar)
	
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $iBar)
	
	Return DllStructGetData($tSCROLLINFO, "nPos")
	
EndFunc

Func Scrollbar_Scroll($hWnd, $iBar, $iPos)
	
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $iBar)
	
	$iCurrentPos = DllStructGetData($tSCROLLINFO, "nPos")
	
	DllStructSetData($tSCROLLINFO, "nPos", $iPos)
	DllStructSetData($tSCROLLINFO, "fMask", $SIF_POS)
    _GUIScrollBars_SetScrollInfo($hWnd, $iBar, $tSCROLLINFO)
	
	If $iBar = $SB_VERT Then
		
		$iRound = 0
		
		for $i = 1 to UBound($SCROLL_AMOUNTS)-1
			If $SCROLL_AMOUNTS[$i][0] = $hWnd And $SCROLL_AMOUNTS[$i][1] = $SB_VERT Then
				$iRound = $SCROLL_AMOUNTS[$i][2]
			EndIf
		Next
		
		If Not $iRound Then Return 0
		
		_GUIScrollBars_ScrollWindow($hWnd, 0, Round(($iCurrentPos-$iPos)/$iRound)*$iRound)
	ElseIf $iBar = $SB_HORZ Then
		
		$iRound = 0
		
		for $i = 1 to UBound($SCROLL_AMOUNTS)-1
			If $SCROLL_AMOUNTS[$i][0] = $hWnd And $SCROLL_AMOUNTS[$i][1] = $SB_HORZ Then
				$iRound = $SCROLL_AMOUNTS[$i][2]
			EndIf
		Next
		
		If Not $iRound Then Return 0
		
		_GUIScrollBars_ScrollWindow($hWnd, Round(($iCurrentPos-$iPos)/$iRound)*$iRound, 0)
	Else
		Return 0
	EndIf
	
	Return 1
	
EndFunc

Func Scrollbar_Step($iStep, $hWnd=0, $iBar=0)
	
	If not $hWnd or Not $iBar Then
		
		$SCROLL_AMOUNTS[0][0] = $iStep
		Return 1
		
	EndIf
	
	$iID = 0
	
	for $i = 1 to UBound($SCROLL_AMOUNTS)-1
		If $SCROLL_AMOUNTS[$i][0] = $hWnd And $SCROLL_AMOUNTS[$i][1] = $iBar Then
			$iID = $i
			ExitLoop
		EndIf
	Next
	
	If Not $iID Then Return 0
	
	$SCROLL_AMOUNTS[$iID][2] = $iStep
	
	Return 1
	
EndFunc

Func WM_VSCROLL($hWnd, $Msg, $wParam, $lParam)
    
	#forceref $Msg, $wParam, $lParam
    Local $nScrollCode = BitAND($wParam, 0x0000FFFF)
    Local $index = -1, $yChar, $yPos
    Local $Min, $Max, $Page, $Pos, $TrackPos

    ; Get all the vertial scroll bar information
    Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $SB_VERT)
    $Min = DllStructGetData($tSCROLLINFO, "nMin")
    $Max = DllStructGetData($tSCROLLINFO, "nMax")
    $Page = DllStructGetData($tSCROLLINFO, "nPage")
    ; Save the position for comparison later on
    $yPos = DllStructGetData($tSCROLLINFO, "nPos")
    $Pos = $yPos
    $TrackPos = DllStructGetData($tSCROLLINFO, "nTrackPos")
	
	$iRound = 0
	
	for $i = 1 to UBound($SCROLL_AMOUNTS)-1
		If $SCROLL_AMOUNTS[$i][0] = $hWnd And $SCROLL_AMOUNTS[$i][1] = $SB_VERT Then
			$iRound = $SCROLL_AMOUNTS[$i][2]
		EndIf
	Next
	
	if Not $iRound Then Return $GUI_RUNDEFMSG
	
    Switch $nScrollCode
        Case $SB_TOP ; user clicked the HOME keyboard key
            DllStructSetData($tSCROLLINFO, "nPos", $Min)

        Case $SB_BOTTOM ; user clicked the END keyboard key
            DllStructSetData($tSCROLLINFO, "nPos", $Max)

        Case $SB_LINEUP ; user clicked the top arrow
            DllStructSetData($tSCROLLINFO, "nPos", $Pos - $iRound)

        Case $SB_LINEDOWN ; user clicked the bottom arrow
            DllStructSetData($tSCROLLINFO, "nPos", $Pos + $iRound)

        Case $SB_PAGEUP ; user clicked the scroll bar shaft above the scroll box
            DllStructSetData($tSCROLLINFO, "nPos", $Pos - $Page)

        Case $SB_PAGEDOWN ; user clicked the scroll bar shaft below the scroll box
            DllStructSetData($tSCROLLINFO, "nPos", $Pos + $Page)

        Case $SB_THUMBTRACK ; user dragged the scroll box
            DllStructSetData($tSCROLLINFO, "nPos", Round($TrackPos/$iRound)*$iRound)
    EndSwitch
    
;~    // Set the position and then retrieve it.  Due to adjustments
;~    //   by Windows it may not be the same as the value set.

    DllStructSetData($tSCROLLINFO, "fMask", $SIF_POS)
    _GUIScrollBars_SetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)
    _GUIScrollBars_GetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)
    ;// If the position has changed, scroll the window and update it
    $Pos = DllStructGetData($tSCROLLINFO, "nPos")
	
	
    If ($Pos <> $yPos) Then
        _GUIScrollBars_ScrollWindow($hWnd, 0, $yPos - $Pos)
    EndIf

    Return $GUI_RUNDEFMSG

EndFunc   ;==>WM_VSCROLL

Func WM_HSCROLL($hWnd, $Msg, $wParam, $lParam)
    
	#forceref $Msg, $wParam, $lParam
    Local $nScrollCode = BitAND($wParam, 0x0000FFFF)
    Local $index = -1, $yChar, $yPos
    Local $Min, $Max, $Page, $Pos, $TrackPos

    ; Get all the vertial scroll bar information
    Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $SB_HORZ)
    $Min = DllStructGetData($tSCROLLINFO, "nMin")
    $Max = DllStructGetData($tSCROLLINFO, "nMax")
    $Page = DllStructGetData($tSCROLLINFO, "nPage")
    ; Save the position for comparison later on
    $yPos = DllStructGetData($tSCROLLINFO, "nPos")
    $Pos = $yPos
    $TrackPos = DllStructGetData($tSCROLLINFO, "nTrackPos")
	
	$iRound = 0
	
	for $i = 1 to UBound($SCROLL_AMOUNTS)-1
		If $SCROLL_AMOUNTS[$i][0] = $hWnd And $SCROLL_AMOUNTS[$i][1] = $SB_HORZ Then
			$iRound = $SCROLL_AMOUNTS[$i][2]
		EndIf
	Next
	
	if Not $iRound Then Return $GUI_RUNDEFMSG
	
    Switch $nScrollCode
        Case $SB_TOP ; user clicked the HOME keyboard key
            DllStructSetData($tSCROLLINFO, "nPos", $Min)

        Case $SB_BOTTOM ; user clicked the END keyboard key
            DllStructSetData($tSCROLLINFO, "nPos", $Max)

        Case $SB_LINEUP ; user clicked the top arrow
            DllStructSetData($tSCROLLINFO, "nPos", $Pos - $iRound)

        Case $SB_LINEDOWN ; user clicked the bottom arrow
            DllStructSetData($tSCROLLINFO, "nPos", $Pos + $iRound)

        Case $SB_PAGEUP ; user clicked the scroll bar shaft above the scroll box
            DllStructSetData($tSCROLLINFO, "nPos", $Pos - $Page)

        Case $SB_PAGEDOWN ; user clicked the scroll bar shaft below the scroll box
            DllStructSetData($tSCROLLINFO, "nPos", $Pos + $Page)

        Case $SB_THUMBTRACK ; user dragged the scroll box
            DllStructSetData($tSCROLLINFO, "nPos", Round($TrackPos/$iRound)*$iRound)
    EndSwitch
    
;~    // Set the position and then retrieve it.  Due to adjustments
;~    //   by Windows it may not be the same as the value set.

    DllStructSetData($tSCROLLINFO, "fMask", $SIF_POS)
    _GUIScrollBars_SetScrollInfo($hWnd, $SB_HORZ, $tSCROLLINFO)
    _GUIScrollBars_GetScrollInfo($hWnd, $SB_HORZ, $tSCROLLINFO)
    ;// If the position has changed, scroll the window and update it
    $Pos = DllStructGetData($tSCROLLINFO, "nPos")
	
	
    If ($Pos <> $yPos) Then
        _GUIScrollBars_ScrollWindow($hWnd, $yPos - $Pos, 0)
    EndIf

    Return $GUI_RUNDEFMSG

EndFunc   ;==>WM_HSCROLL