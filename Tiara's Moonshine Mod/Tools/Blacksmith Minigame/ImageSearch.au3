#include-once
Local $h_ImageSearchDLL = -1; Will become Handle returned by DllOpen() that will be referenced in the _ImageSearchRegion() function
;#include <WinAPIFiles.au3> ; for _WinAPI_Wow64EnableWow64FsRedirection
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
;                   $findImage - the image file location or HBitmap to locate on the
;									desktop or in the Specified HBitmap
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
;					$HBMP - optional hbitmap to search in. sending 0 will search the desktop.
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
; Note: Use _ImageSearch to search the entire desktop, _ImageSearchArea to specify
;       a desktop region to search
;
;===============================================================================
Func _ImageSearch($findImage,$resultPosition, ByRef $x, ByRef $y,$tolerance, $HBMP=0)
   return _ImageSearchArea($findImage,$resultPosition,0,0,@DesktopWidth,@DesktopHeight,$x,$y,$tolerance,$HBMP)
EndFunc

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
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImageSearch($findImage,$waitSecs,$resultPosition, ByRef $x, ByRef $y,$tolerance,$HBMP=0)
	$waitSecs = $waitSecs * 1000
	$startTime=TimerInit()
	While TimerDiff($startTime) < $waitSecs
		sleep(100)
		$result=_ImageSearch($findImage,$resultPosition,$x, $y,$tolerance,$HBMP)
		if $result > 0 Then
			return 1
		EndIf
	WEnd
	return 0
EndFunc

;===============================================================================
;
; Description:      Wait for a specified number of seconds for any of a set of
;                   images to appear
;
; Syntax:           _WaitForImagesSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the ARRAY of images to locate on the desktop
;                              - ARRAY[0] is set to the number of images to loop through
;								 ARRAY[1] is the first image
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
; Return Value(s):  On Success - Returns the index of the successful find
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImagesSearch($findImage,$waitSecs,$resultPosition, ByRef $x, ByRef $y,$tolerance,$HBMP=0)
	$waitSecs = $waitSecs * 1000
	$startTime=TimerInit()
	While TimerDiff($startTime) < $waitSecs
		for $i = 1 to $findImage[0]
		    sleep(100)
		    $result=_ImageSearch($findImage[$i],$resultPosition,$x, $y,$tolerance,$HBMP)
		    if $result > 0 Then
			    return $i
		    EndIf
		Next
	WEnd
	return 0
EndFunc

Func _WinAPI_Wow64EnableWow64FsRedirection($bEnable)
	Local $aRet = DllCall('kernel32.dll', 'boolean', 'Wow64EnableWow64FsRedirection', 'boolean', $bEnable)
	If @error Then Return SetError(@error, @extended, 0)
	; If Not $aRet[0] Then Return SetError(1000, 0, 0)

	Return $aRet[0]
EndFunc   ;==>_WinAPI_Wow64EnableWow64FsRedirection

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