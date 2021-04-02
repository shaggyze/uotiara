#AutoIt3Wrapper_UseX64=y ; Set to Y or N depending on your situation/preference!!
#include-once
Global $sOSArch,$sAutoItX64
#include <WinAPIFiles.au3> ; for _WinAPI_Wow64EnableWow64FsRedirection
#include <ScreenCapture.au3> ;_ScreenCapture_CaptureWnd etc. ;using this in the example to create a test image, otherwise not neccessary here
#include <MsgBoxConstants.au3>

#Region When running compiled script, Install needed DLLs if they don't exist yet
If Not FileExists("ImageSearchDLLx32.dll") Then FileInstall("ImageSearchDLLx32.dll", "ImageSearchDLLx32.dll", 1);FileInstall ( "source", "dest" [, flag = 0] )
If Not FileExists("ImageSearchDLLx64.dll") Then FileInstall("ImageSearchDLLx64.dll", "ImageSearchDLLx64.dll", 1)
If Not FileExists("msvcr110d.dll") Then FileInstall("msvcr110d.dll", "msvcr110d.dll", 1);Microsoft Visual C++ Redistributable dll x64
If Not FileExists("msvcr110.dll") Then FileInstall("msvcr110.dll", "msvcr110.dll", 1);Microsoft Visual C++ Redistributable dll x32
#EndRegion

Local $h_ImageSearchDLL = -1; Will become Handle returned by DllOpen() that will be referenced in the _ImageSearchRegion() function

#Region TESTING/Example
Local $bTesting = True; Change to TRUE to turn on testing/example

If $bTesting Then
	cr(">" & "_ImageSearchStartup()=" & _ImageSearchStartup(), 2)
	OnAutoItExitRegister(_ImageSearchShutdown)

	cr("!Testing...")
	;using Notepad as a simple example
	#Region Notepad Snapshot Creation
	$hWin = WinGetHandle("[CLASS:Notepad]")
	If Not IsHWnd($hWin) Then
		If Run("notepad.exe") = 0 Then cr("Couldn't run notepad.exe")
		Local $hWin = WinWait("[CLASS:Notepad]", "", 10)
		If $hWin = 0 Then cr("Notepad WinWait Timeout!")
	EndIf
	WinSetState($hWin, "", @SW_RESTORE)
	WinSetState($hWin, "", @SW_SHOW)
	WinActivate($hWin)
	Local $testimage = "24bit.bmp"
	_ScreenCapture_CaptureWnd($testimage, $hWin, 0, 0, -1, -1, False);_ScreenCapture_CaptureWnd ( $sFileName, $hWnd [, $iLeft = 0 [, $iTop = 0 [, $iRight = -1 [, $iBottom = -1 [, $bCursor = True]]]]] )
	cr("made Notepad Window screenshot")
	#EndRegion Notepad Snapshot Creation

	#Region Test if application appeared
	Local $y = 0, $x = 0, $result
	$result = _ImageSearch($testimage, 1, $x, $y, 0, 0);_ImageSearch($findImage, $resultPosition, ByRef $x, ByRef $y, $tolerance, $transparency = 0)
	If $result = 1 Then
		cr("! $result=" & $result, 1)
		MouseMove($x, $y, 0)
		cr("+" & "recognised notepad! moved mouse to center of notepad!")
		MsgBox($MB_SYSTEMMODAL, "Test", "recognised notepad! moved mouse to center of notepad!", 5)
	Else
		cr("! $result=" & $result, 1)
		Exit
	EndIf
	#EndRegion Test if application appeared

	#Region Test if application vanished
	WinSetState($hWin, "", @SW_MINIMIZE)
	Local $y = 0, $x = 0, $result
	$result = _ImageSearch($testimage, 1, $x, $y, 0, 0);_ImageSearch($findImage, $resultPosition, ByRef $x, ByRef $y, $tolerance, $transparency = 0)
	If $result = 1 Then
		cr("! $result=" & $result, 1)
		Exit
	Else
		cr("! $result=" & $result, 1)
		cr("+" & "notepad dissapeared!")
	EndIf
	#EndRegion Test if application vanished
	cr()
	cr("!Test finished")
	Exit
EndIf

#EndRegion TESTING/Example

#Region ImageSearch Startup/Shutdown
Func _ImageSearchStartup()
	_WinAPI_Wow64EnableWow64FsRedirection(True)
	$sOSArch = @OSArch ;Check if running on x64 or x32 Windows ;@OSArch Returns one of the following: "X86", "IA64", "X64" - this is the architecture type of the currently running operating system.
	$sAutoItX64 = @AutoItX64 ;Check if using x64 AutoIt ;@AutoItX64 Returns 1 if the script is running under the native x64 version of AutoIt.
	If $sOSArch = "X86" Or $sAutoItX64 = 0 Then
		;cr("+>" & "@OSArch=" & $sOSArch & @TAB & "@AutoItX64=" & $sAutoItX64 & @TAB & "therefore using x32 ImageSearch DLL")
		$h_ImageSearchDLL = DllOpen("ImageSearchDLLx32.dll")
		If $h_ImageSearchDLL = -1 Then Return "DllOpen failure"
	ElseIf $sOSArch = "X64" And $sAutoItX64 = 1 Then
		;cr("+>" & "@OSArch=" & $sOSArch & @TAB & "@AutoItX64=" & $sAutoItX64 & @TAB & "therefore using x64 ImageSearch DLL")
		$h_ImageSearchDLL = DllOpen("ImageSearchDLLx64.dll")
		If $h_ImageSearchDLL = -1 Then Return "DllOpen failure"
	Else
		Return "Inconsistent or incompatible Script/Windows/CPU Architecture"
	EndIf
	Return True
EndFunc   ;==>_ImageSearchStartup

Func _ImageSearchShutdown()
	DllClose($h_ImageSearchDLL)
	_WinAPI_Wow64EnableWow64FsRedirection(False)
	cr(">" & "_ImageSearchShutdown() completed")
	Return True
EndFunc   ;==>_ImageSearchShutdown
#EndRegion ImageSearch Startup/Shutdown

#Region ImageSearch UDF;slightly modified
; ------------------------------------------------------------------------------
;
; AutoIt Version: 3.0
; Language:       English
; Description:    Functions that assist with Image Search
;                 Require that the ImageSearchDLL.dll be loadable
;
; ------------------------------------------------------------------------------
;===============================================================================
;
; Description:      Find the position of an image on the desktop
; Syntax:           _ImageSearchArea, _ImageSearch
; Parameter(s):
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;                   $transparency - TRANSBLACK, TRANSWHITE or hex value (e.g. 0xffffff) of
;                                  the color to be used as transparency; can be omitted if
;                                  not needed
;
; Return Value(s):  On Success - Returns True
;                   On Failure - Returns False
;
; Note: Use _ImageSearch to search the entire desktop, _ImageSearchArea to specify
;       a desktop region to search
;
;===============================================================================
Func _ImageSearch($findImage, $resultPosition, ByRef $x, ByRef $y, $tolerance, $transparency = 0)
	Return _ImageSearchArea($findImage, $resultPosition, 0, 0, @DesktopWidth, @DesktopHeight, $x, $y, $tolerance, $transparency)
EndFunc   ;==>_ImageSearch

Func _ImageSearchArea($findImage, $resultPosition, $x1, $y1, $right, $bottom, ByRef $x, ByRef $y, $tolerance = 0, $transparency = 0);Credits to Sven for the Transparency addition
	If Not FileExists($findImage) Then Return "Image File not found"
	If $tolerance < 0 Or $tolerance > 255 Then $tolerance = 0
	If $h_ImageSearchDLL = -1 Then _ImageSearchStartup()

	If $transparency <> 0 Then $findImage = "*" & $transparency & " " & $findImage
	If $tolerance > 0 Then $findImage = "*" & $tolerance & " " & $findImage
	$result = DllCall($h_ImageSearchDLL, "str", "ImageSearch", "int", $x1, "int", $y1, "int", $right, "int", $bottom, "str", $findImage)
	If @error Then Return "DllCall Error=" & @error
	If $result = "0" Or Not IsArray($result) Or $result[0] = "0" Then Return False

	$array = StringSplit($result[0], "|")
	If (UBound($array) >= 4) Then
		$x = Int(Number($array[2])); Get the x,y location of the match
		$y = Int(Number($array[3]))
		If $resultPosition = 1 Then
			$x = $x + Int(Number($array[4]) / 2); Account for the size of the image to compute the centre of search
			$y = $y + Int(Number($array[5]) / 2)
		EndIf
		Return True
	EndIf
EndFunc   ;==>_ImageSearchArea

;===============================================================================
;
; Description:      Wait for a specified number of seconds for an image to appear
;
; Syntax:           _WaitForImageSearch, _WaitForImagesSearch
; Parameter(s):
;                   $waitSecs  - seconds to try and find the image
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;                   $transparency - TRANSBLACK, TRANSWHITE or hex value (e.g. 0xffffff) of
;                                  the color to be used as transparency can be omitted if
;                                  not needed
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImageSearch($findImage, $waitSecs, $resultPosition, ByRef $x, ByRef $y, $tolerance, $transparency = 0)
	$waitSecs = $waitSecs * 1000
	$startTime = TimerInit()
	While TimerDiff($startTime) < $waitSecs
		Sleep(100)
		If _ImageSearch($findImage, $resultPosition, $x, $y, $tolerance, $transparency) Then
			Return True
		EndIf
	WEnd
	Return False
EndFunc   ;==>_WaitForImageSearch

;===============================================================================
;
; Description:      Wait for a specified number of seconds for any of a set of
;                   images to appear
;
; Syntax:           _WaitForImagesSearch
; Parameter(s):
;                   $waitSecs  - seconds to try and find the image
;                   $findImage - the ARRAY of images to locate on the desktop
;                              - ARRAY[0] is set to the number of images to loop through
;                                ARRAY[1] is the first image
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;                   $transparent - TRANSBLACK, TRANSWHITE or hex value (e.g. 0xffffff) of
;                                  the color to be used as transparent; can be omitted if
;                                  not needed
;
; Return Value(s):  On Success - Returns the index of the successful find
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImagesSearch($findImage, $waitSecs, $resultPosition, ByRef $x, ByRef $y, $tolerance, $transparency = 0)
	$waitSecs = $waitSecs * 1000
	$startTime = TimerInit()
	While TimerDiff($startTime) < $waitSecs
		For $i = 1 To $findImage[0]
			Sleep(100)
			If _ImageSearch($findImage[$i], $resultPosition, $x, $y, $tolerance, $transparency) Then
				Return $i
			EndIf
		Next
	WEnd
	Return False
EndFunc   ;==>_WaitForImagesSearch
#EndRegion ImageSearch UDF;slightly modified

#Region My Custom ConsoleWrite/debug Function
Func cr($text = "", $addCR = 1, $printTime = False) ;Print to console
	Static $sToolTip
	If Not @Compiled Then
		If $printTime Then ConsoleWrite(@HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & " ")
		ConsoleWrite($text)
		If $addCR >= 1 Then ConsoleWrite(@CR)
		If $addCR = 2 Then ConsoleWrite(@CR)
	Else
		If $printTime Then $sToolTip &= @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & " "
		$sToolTip &= $text
		If $addCR >= 1 Then $sToolTip &= @CR
		If $addCR = 2 Then $sToolTip &= @CR
		ToolTip($sToolTip)
	EndIf
	Return $text
EndFunc   ;==>cr
#EndRegion My Custom ConsoleWrite/debug Function
