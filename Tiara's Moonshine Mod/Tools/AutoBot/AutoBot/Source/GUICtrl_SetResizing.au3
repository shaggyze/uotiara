

AdlibRegister("_GUICtrl_SetResizing_Handler", 50)

Global $iCursorIsSet 			= False
Global $iCtrlEdgeSize 			= 5
Global $iDefCtrlMinSize 		= 20

Global $aSetResizing_Arr[1][1]

;Function to set resizing for specific control
Func _GUICtrl_SetOnResize($hWnd, $nCtrlID=-1, $iWait=10, $iCtrlMinSize=$iDefCtrlMinSize)
	If $nCtrlID = -1 Then $nCtrlID = _GUIGetLastCtrlID()

	If Not IsHWnd($hWnd) Then
		Local $aTmpSetResArr[1][1]

		For $i = 1 To $aSetResizing_Arr[0][0]
			If $nCtrlID <> $aSetResizing_Arr[$i][1] Then
				$aTmpSetResArr[0][0] += 1
				ReDim $aTmpSetResArr[$aTmpSetResArr[0][0]+1][4]
				$aTmpSetResArr[$aTmpSetResArr[0][0]][0] = $aSetResizing_Arr[$i][0]
				$aTmpSetResArr[$aTmpSetResArr[0][0]][1] = $aSetResizing_Arr[$i][1]
				$aTmpSetResArr[$aTmpSetResArr[0][0]][2] = $aSetResizing_Arr[$i][2]
				$aTmpSetResArr[$aTmpSetResArr[0][0]][3] = $aSetResizing_Arr[$i][3]
			EndIf
		Next

		GUICtrlSetCursor($nCtrlID, -1)
		$aSetResizing_Arr = $aTmpSetResArr

		Return 1
	EndIf

	$aSetResizing_Arr[0][0] += 1
	ReDim $aSetResizing_Arr[$aSetResizing_Arr[0][0]+1][4]
	$aSetResizing_Arr[$aSetResizing_Arr[0][0]][0] = $hWnd
	$aSetResizing_Arr[$aSetResizing_Arr[0][0]][1] = $nCtrlID
	$aSetResizing_Arr[$aSetResizing_Arr[0][0]][2] = $iWait
	$aSetResizing_Arr[$aSetResizing_Arr[0][0]][3] = $iCtrlMinSize
EndFunc

;Handler to call the set functions (for all controls that _GUICtrl_SetOnResize() is set)
Func _GUICtrl_SetResizing_Handler()
	If $aSetResizing_Arr[0][0] = 0 Then Return

	For $i = 1 To $aSetResizing_Arr[0][0]
		_GUICtrl_Resizing_Proc($aSetResizing_Arr[$i][0], $aSetResizing_Arr[$i][1], _
			$aSetResizing_Arr[$i][2], $aSetResizing_Arr[$i][3])
	Next
EndFunc

;Main Resizing Control Function
Func _GUICtrl_Resizing_Proc($hWnd, $nCtrlID, $iWait=10, $iCtrlMinSize=$iDefCtrlMinSize)
	Local $aCurInfo = GUIGetCursorInfo($hWnd)
	If @error Then Return

	Local $aCtrlInfo = ControlGetPos($hWnd, "", $nCtrlID)
	If @error Then Return

	Local $iCursorID
	Local $iCheckFlag = -1
	Local $nOld_Opt_GOEM = Opt("GUIOnEventMode", 0)

	If ($aCurInfo[0] > $aCtrlInfo[0] - $iCtrlEdgeSize And $aCurInfo[0] < $aCtrlInfo[0] + $iCtrlEdgeSize) And _
		($aCurInfo[1] >= $aCtrlInfo[1] And $aCurInfo[1] <= $aCtrlInfo[1]+$aCtrlInfo[3]) Then 					;Left

		$iCheckFlag = 1
		$iCursorID = 13
	EndIf

	If ($aCurInfo[0] > ($aCtrlInfo[0]+$aCtrlInfo[2]) - $iCtrlEdgeSize And _
		$aCurInfo[0] < ($aCtrlInfo[0]+$aCtrlInfo[2]) + $iCtrlEdgeSize) And _
		($aCurInfo[1] >= $aCtrlInfo[1] And $aCurInfo[1] <= $aCtrlInfo[1]+$aCtrlInfo[3]) Then 					;Right

		$iCheckFlag = 2
		$iCursorID = 13
	EndIf

	If ($aCurInfo[1] > $aCtrlInfo[1] - $iCtrlEdgeSize And $aCurInfo[1] < $aCtrlInfo[1] + $iCtrlEdgeSize) And _
		($aCurInfo[0] >= $aCtrlInfo[0] And $aCurInfo[0] <= $aCtrlInfo[0]+$aCtrlInfo[2]) Then 					;Top

		If $iCheckFlag = 1 Then 		;Left+Top
			$iCheckFlag = 5
			$iCursorID = 12
		ElseIf $iCheckFlag = 2 Then 	;Right+Top
			$iCheckFlag = 7
			$iCursorID = 10
		Else 							;Just Top
			$iCheckFlag = 3
			$iCursorID = 11
		EndIf
	EndIf

	If ($aCurInfo[1] > ($aCtrlInfo[1]+$aCtrlInfo[3]) - $iCtrlEdgeSize And _
		$aCurInfo[1] < ($aCtrlInfo[1]+$aCtrlInfo[3]) + $iCtrlEdgeSize) And _
		($aCurInfo[0] >= $aCtrlInfo[0] And $aCurInfo[0] <= $aCtrlInfo[0]+$aCtrlInfo[2]) Then 					;Bottom

		If $iCheckFlag = 1 Then 		;Left+Bottom
			$iCheckFlag = 6
			$iCursorID = 10
		ElseIf $iCheckFlag = 2 Then 	;Right+Bottom
			$iCheckFlag = 8
			$iCursorID = 12
		Else 							;Just Bottom
			$iCheckFlag = 4
			$iCursorID = 11
		EndIf
	EndIf

	If $iCheckFlag = -1 Then
		If ($aCurInfo[4] = 0 Or $aCurInfo[4] = $nCtrlID) And Not $iCursorIsSet Then
			If $aCurInfo[4] = $nCtrlID Then $iCursorIsSet = True
			GUISetCursor(-1, 0, $hWnd)
			GUICtrlSetCursor($nCtrlID, -1)
		EndIf

		Return
	Else
		$iCursorIsSet = False
		GUICtrlSetCursor($nCtrlID, $iCursorID)
		GUISetCursor($iCursorID, 0, $hWnd)
	EndIf

	While $aCurInfo[2] = 1
		;This loop is to prevent control movement while the mouse is not moving
		While GUIGetMsg() <> -11 ;$GUI_EVENT_MOUSEMOVE
			Sleep(10)
		WEnd

		$aCurInfo = GUIGetCursorInfo($hWnd)
		If @error Then ExitLoop

		$aCtrlInfo = ControlGetPos($hWnd, "", $nCtrlID)
		If @error Then ExitLoop

		; $iCheckFlag Values:
		;1 = Left
		;2 = Right
		;3 = Top
		;4 = Bottom
		;5 = Left + Top
		;6 = Left + Bottom
		;7 = Right + Top
		;8 = Right + Bottom

		If $iCheckFlag = 1 Or $iCheckFlag = 5 Or $iCheckFlag = 6 Then
			If $aCtrlInfo[2] - ($aCurInfo[0]-$aCtrlInfo[0]) > $iCtrlMinSize Then 		;Move from Left
				$aCtrlInfo[2] = $aCtrlInfo[2]-($aCurInfo[0]-$aCtrlInfo[0])
				$aCtrlInfo[0] = $aCurInfo[0]
				ControlMove($hWnd, "", $nCtrlID, $aCtrlInfo[0], $aCtrlInfo[1], $aCtrlInfo[2])
			EndIf
		EndIf

		If $iCheckFlag = 2 Or $iCheckFlag = 7 Or $iCheckFlag = 8 Then
			If $aCurInfo[0] - $aCtrlInfo[0] > $iCtrlMinSize Then 						;Move from Right
				$aCtrlInfo[2] = $aCurInfo[0]-$aCtrlInfo[0]
				ControlMove($hWnd, "", $nCtrlID, $aCtrlInfo[0], $aCtrlInfo[1], $aCtrlInfo[2])
			EndIf
		EndIf

		If $iCheckFlag = 3 Or $iCheckFlag = 5 Or $iCheckFlag = 7 Then
			If $aCtrlInfo[3] - ($aCurInfo[1]-$aCtrlInfo[1]) > $iCtrlMinSize Then 		;Move from Top
				$aCtrlInfo[3] = $aCtrlInfo[3]-($aCurInfo[1]-$aCtrlInfo[1])
				$aCtrlInfo[1] = $aCurInfo[1]
				ControlMove($hWnd, "", $nCtrlID, $aCtrlInfo[0], $aCtrlInfo[1], $aCtrlInfo[2], $aCtrlInfo[3])
			EndIf
		EndIf

		If $iCheckFlag = 4 Or $iCheckFlag = 6 Or $iCheckFlag = 8 Then
			If $aCurInfo[1] - $aCtrlInfo[1] > $iCtrlMinSize Then 						;Move from Bottom
				$aCtrlInfo[3] = $aCurInfo[1]-$aCtrlInfo[1]
				ControlMove($hWnd, "", $nCtrlID, $aCtrlInfo[0], $aCtrlInfo[1], $aCtrlInfo[2], $aCtrlInfo[3])
			EndIf
		EndIf

		Sleep($iWait)
	WEnd

	Opt("GUIOnEventMode", $nOld_Opt_GOEM)
EndFunc

;Function to get last CtrlID (in case that user will pass -1 as $iCtrlID)
Func _GUIGetLastCtrlID()
	Local $aRet = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", GUICtrlGetHandle(-1))

	Return $aRet[0]
EndFunc
