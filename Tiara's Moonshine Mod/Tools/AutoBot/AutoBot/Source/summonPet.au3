#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Find\Images\gui\splash.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_LegalCopyright=ShaggyZE
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
if _Singleton("summonPet",1) = 0 Then
    Exit 1
EndIf
#Region Global Variables and Constants
Global $x1,$y1,$desummonkey,$summonkey,$summontime,$hidewindows,$topleftcorner[2],$bottomrightcorner[2],$searchbox[4]
Global Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"
#EndRegion Global Variables and Constants
#Region Main Script
$mabititle = IniRead("config.ini","Settings","mabititle","Mabinogi")
$summonkey = IniRead("config.ini","Pet Settings","summonkey","9")
$summontime = IniRead("config.ini","Pet Settings","summontime","10000")
$desummonkey = IniRead("config.ini","Pet Settings","desummonkey","=")
$hidewindows = IniRead("config.ini","Settings","hidewindows","1")
#EndRegion Global Variables and Constants
If Not WinActive($mabititle) Then WinActivate($mabititle)
$box = WinGetPos($mabititle)
$topleftcorner[0] = 0
$topleftcorner[1] = 0
$bottomrightcorner[0] = $box[2]
$bottomrightcorner[1] = $box[3]
$searchbox[0] = $topleftcorner[0]
$searchbox[1] = $topleftcorner[1]
$searchbox[2] = $bottomrightcorner[0]
$searchbox[3] = $bottomrightcorner[1]
_summonPet()
sleep(500)
_hideWindows()
sleep($summontime)
_desummonPet()
sleep(500)
_hideWindows()
sleep(60000)
Exit 0
#Region Main Script
#Region Core Functions
;=======================================================================================
Func _summonPet()
$summonkey= StringReplace($summonkey,"`","")
If Not WinActive($mabititle) Then WinActivate($mabititle)
Send("{"&$summonkey&"}")
EndFunc
;=======================================================================================
Func _desummonPet()
$desummonkey= StringReplace($desummonkey,"`","")
If Not WinActive($mabititle) Then WinActivate($mabititle)
Send("{"&$desummonkey&"}")
Sleep(500)
If Not WinActive($mabititle) Then WinActivate($mabititle)
Send("{"&$desummonkey&"}")
EndFunc
;=======================================================================================
func _hideWindows()
If $hidewindows=1 Then
	Do
		$result = _ImageSearchArea("Find\Images\buttons\F1.bmp",1,$searchbox[0],$searchbox[1],$searchbox[2],$searchbox[3],$x1,$y1,30)
		If $result=1 Then
			Send("{\}")
			Sleep(3000)
		EndIf
	Until $result = 0
EndIf
EndFunc
;=======================================================================================
Func _ImageSearch($findImage,$resultPosition,ByRef $x, ByRef $y,$tolerance)
Return _ImageSearchArea($findImage,$resultPosition,0,0,@DesktopWidth,@DesktopHeight,$x,$y,$tolerance)
EndFunc
;=======================================================================================
Func _ImageSearchArea($findImage,$resultPosition,$x1,$y1,$right,$bottom,ByRef $x, ByRef $y, $tolerance)
;MsgBox(0,"asd","" & $x1 & " " & $y1 & " " & $right & " " & $bottom)
If $tolerance>0 Then $findImage = "*" & $tolerance & " " & $findImage
$result = DllCall("ImageSearchDLL.dll","str","ImageSearch","int",$x1,"int",$y1,"int",$right,"int",$bottom,"str",$findImage)
; If error exit
If $result[0]="0" Then Return 0
; Otherwise get the x,y location of the match and the size of the image to
; compute the centre of search
$array = StringSplit($result[0],"|")
$x=Int(Number($array[2]))
$y=Int(Number($array[3]))
If $resultPosition=1 Then
	$x=$x + Int(Number($array[4])/2)
	$y=$y + Int(Number($array[5])/2)
EndIf
Return 1
EndFunc
Func _Singleton($sOccurenceName, $iFlag = 0)
	Local Const $ERROR_ALREADY_EXISTS = 183
	Local Const $SECURITY_DESCRIPTOR_REVISION = 1
	Local $pSecurityAttributes = 0

	If BitAND($iFlag, 2) Then
		; The size of SECURITY_DESCRIPTOR is 20 bytes.  We just
		; need a block of memory the right size, we aren't going to
		; access any members directly so it's not important what
		; the members are, just that the total size is correct.
		Local $tSecurityDescriptor = DllStructCreate("dword[5]")
		Local $pSecurityDescriptor = DllStructGetPtr($tSecurityDescriptor)
		; Initialize the security descriptor.
		Local $aRet = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", _
				"ptr", $pSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
		If @error Then Return SetError(@error, @extended, 0)
		If $aRet[0] Then
			; Add the NULL DACL specifying access to everybody.
			$aRet = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", _
					"ptr", $pSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
			If @error Then Return SetError(@error, @extended, 0)
			If $aRet[0] Then
				; Create a SECURITY_ATTRIBUTES structure.
				Local $structSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
				; Assign the members.
				DllStructSetData($structSecurityAttributes, 1, DllStructGetSize($structSecurityAttributes))
				DllStructSetData($structSecurityAttributes, 2, $pSecurityDescriptor)
				DllStructSetData($structSecurityAttributes, 3, 0)
				; Everything went okay so update our pointer to point to our structure.
				$pSecurityAttributes = DllStructGetPtr($structSecurityAttributes)
			EndIf
		EndIf
	EndIf

	Local $handle = DllCall("kernel32.dll", "handle", "CreateMutexW", "ptr", $pSecurityAttributes, "bool", 1, "wstr", $sOccurenceName)
	If @error Then Return SetError(@error, @extended, 0)
	Local $lastError = DllCall("kernel32.dll", "dword", "GetLastError")
	If @error Then Return SetError(@error, @extended, 0)
	If $lastError[0] = $ERROR_ALREADY_EXISTS Then
		If BitAND($iFlag, 1) Then
			Return SetError($lastError[0], $lastError[0], 0)
		Else
			Exit -1
		EndIf
	EndIf
	Return $handle[0]
EndFunc   ;==>_Singleton
#EndRegion Core Functions