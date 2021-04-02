; Ego Feeder by theavantgarde
; Big thank you to Apocalpyse Feeder, and Autobot for being references
; ShaggyZE for completing it and making it work with less images.


; Pseudocode
; Moves mouse to Primary equipment slot
; Moves mouse down over weapon
; If red is seen then progress to buy item and feed ego
; If not, then sleep then try again
; When red is found
	; ctrl+click center screen which clicks the npc
	; buys food from npc, in this case sandals
		; buys 5 times
		; ends chat with npc

	; presses "/" which opens the ego chat menu
		; selects give food
		; gives food 5 times
		; ends chat
		; pauses for 30 seconds
		; proceeds to constantly scan for "is hungry"

; Make sure you have nothing Else that can be fed in your inventory before using this bot
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Find\Images\gui\splash.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=EgoFeeder
#AutoIt3Wrapper_Res_Description=EgoFeeder
#AutoIt3Wrapper_Res_Fileversion=2.9.0.84
#AutoIt3Wrapper_Res_LegalCopyright=ShaggyZE
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region Header
#include-once
#include <ImageSearch.au3>
#include <WinAPI.au3>
#include <TestArea.au3>
#include <Misc.au3>
HotKeySet("{DELETE}", "_Exit")
HotKeySet("{END}", "_Exit")
HotKeySet("{q}", "_Exit")

MsgBox (0,"EgoFeeder", "Make sure you have nothing else that can be fed in your inventory before using this bot.")

If Not WinActive("[CLASS:Mabinogi]") Then WinActivate("[CLASS:Mabinogi]")

; coordinates of "is " not sure why I'm storing this
Global $hcoordx, $hcoordy ; coordinates for "is hungry"
Global $shopx, $shopy ; coordinates for shop button
Global $tabx, $taby ; coordinates for shop tab
Global $tabxy[2] ; coordinates for shop tab
Global $itemxy[2]; coordinates of the feed item
Global $buyx, $buyy ; coordinates of the buy button
Global $spacex, $spacey ; coordinates of the space to put feeding item into
Global $endconvox, $endconvoy ; location of "end conversation"
Global $givex, $givey ; location of "give item"
Global $continuey,$continuex ; location of "continue"
Global $feedx, $feedy ; location of #1 slot item to be fed
Global $okayx, $okayy ; location of "okay"
Global $equipxy[2] ;location of the equipslot 1 button
Global $topleftcorner[2]
Global $bottomrightcorner[2]
Global $center[2]
Global $windowSize[4]
Global $found
Global $result
Global $feedcount
Global $count
Global $scan
Global $result
Global $mustcontinue, $mustcontinuex, $mustcontinuey
Global $hFunc,$pFunc,$hHook,$hMod
Global Const $VK_DELETE = 0x2E, $VK_END = 0x23
$Title1 = "EgoFeeder By: ShaggyZE"

If ProcessExists ("Client.exe") = False Then
	ToolTip ("Error: Mabinogi Not Detected." & @CRLF & "Closing...", 0, @DesktopHeight - 70, $Title1)
	Sleep (3000)
	Exit 1
EndIf
$hFunc = DllCallbackRegister('_KeyboardHook', 'lresult', 'int;uint;uint')
$pFunc = DllCallbackGetPtr($hFunc)
$hMod = _WinAPI_GetModuleHandle(0)
$hHook = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, $pFunc, $hMod)
If Not WinActive (WinGetTitle("[CLASS:Mabinogi]")) Then Winactivate (WinGetTitle("[CLASS:Mabinogi]"))
WinWaitActive (WinGetTitle("[CLASS:Mabinogi]"))
Sleep (2000)
GetWindowSize()
While 1
	Sleep(1000)
	HungerCheck()
WEnd

;===================================================================================
Func GetWindowSize()
	; gets info of Mabinogi and stores them into a 4 element array
	$windowSize=WinGetPos(WinGetTitle("[CLASS:Mabinogi]"))
	; determines specIfic locations
	If IsArray($windowSize) Then
		$topleftcorner[0] =$windowSize[0]
		$topleftcorner[1] = $windowSize[1]
		$bottomrightcorner[0] =$windowSize[2]
		$bottomrightcorner[1] = $windowSize[3]
		$center[0]=($topleftcorner[0] + $bottomrightcorner[0]) / 2
		$center[1]=(($topleftcorner[1] + $bottomrightcorner[1]) / 2) - 50
	Else
		$windowSize=WinGetClientSize(WinGetTitle("[CLASS:Mabinogi]"))
		$topleftcorner[0] =1
		$topleftcorner[1] = 1
		$bottomrightcorner[0] =$windowSize[0]
		$bottomrightcorner[1] = $windowSize[1]
		$center[0]=($topleftcorner[0] + $bottomrightcorner[0]) / 2
		$center[1]=(($topleftcorner[1] + $bottomrightcorner[1]) / 2) - 50
	EndIf
EndFunc

;===================================================================================
Func HungerCheck()
	;! Should also add in an If statement in the case that the inven is not already open
	; Displays a tooltip that shows the user that the bot is searching for the words "is hungry"
	ToolTip ("Checking for hungry ego..." , 0,@desktopheight-20)
	Sleep(500)
	;searches for the I slot in the inventory

	If $equipxy[0]=0 or $equipxy[1]=0 Then
		$equipxy=_GetXY("Hover over Ego then press 'a' key.")


	Else
		Sleep(500)
		;moves mouse down onto the weapon
		MouseMove($equipxy[0], $equipxy[1])
		;pausecheck
		Sleep(500)
		;gets the mouse's current position to use for PixelSearch
		$scan= MouseGetPos()
		;uses the mouse's position before and creates a search area for the red pixels
		_TestArea(200,205, $scan[0]+30, $scan[1]+30, 5000)
		;uses coordinates in test area to check area using PixElsearch
		$found = PixElsearch($scan[0]+30 ,$scan[1]+30, $scan[0]+230, $scan[1]+235, 0xff0000)
		; If hungry then...
		If $found >= 1 Then
			ToolTip ("Ego is hungry", 0,@desktopheight-20)
			Sleep(500)
			BuyEgoFood()
		; If red numbers are not found
		Else
			; moves the mouse back up so that it may check the status of the weapon later
			ToolTip ("Ego is not hungry yet", 0,@desktopheight-20)

			; this makes it so that even if it isn't hungry, the mouse will move off the ego and back on so that the ego info will update
			MouseMove($equipxy[0]-100, $equipxy[1])
			MouseMove($equipxy[0], $equipxy[1])

			Sleep(3000)
		EndIf
	EndIf
EndFunc

;===================================================================================
Func BuyEgoFood ()
	; holds down control so that the NPC may be selected
	MouseMove($center[0] , $center[1])
	MouseClick("primary" , $center[0] , $center[1])
	Sleep(100)
	Send("{CTRLDOWN}")
	Sleep(100)
	; clicks in the middle of the screen to initiate a conversation with the NPC
	MouseClick("primary" , $center[0] , $center[1])
	Sleep(100)
	; releases control key
	Send("{CTRLUP}")

	; checks if one must press continue before talking to npc
	$mustcontinue=_ImageSearch(@ScriptDir & "\Find\Images\buttons\continue.bmp", 1, $mustcontinuex, $mustcontinuey, 30)
	If $mustcontinue=1 Then
			MouseClick("primary", $mustcontinuex, $mustcontinuey, 1)

	Else
		ToolTip ("Checking for shop..." , 0,@desktopheight-20)
		Sleep(1500)

		; searches for shop button and clicks it
		$result=_ImageSearch(@ScriptDir & "\Find\Images\buttons\shop.bmp", 1, $shopx, $shopy, 30)
		If $result=1 then
			MouseClick("Primary", $shopx, $shopy, 1)
			; search for "tab" and clicks it
			; tab.bmp may be changed depending on which npc you are feeding from
			; for the sake of this experiment, I am using Malcolm
			Sleep(2500)

			; maybe $tabxy=_GetXY("Hover over shop Tab then press 'a' key")
			;$result=_ImageSearchArea("tab.bmp", 1, $topleftcorner[0],$topleftcorner[1],$bottomrightcorner[0],$bottomrightcorner[1],$tabx,$taby, 30,100)
			;If $result=1 Then

				;implemented tabxy
				If $tabxy[0]=0 or $tabxy[1]=0 Then
					$tabxy=_GetXY("Hover over Tab then press 'a' key.")

				Else
					MouseMove($tabxy[0], $tabxy[1],0)
					Sleep(200)
					MouseClick("Primary", $tabxy[0], $tabxy[1], 1)
					Sleep(200)
				EndIf
					;_ImageSearchArea("tab.bmp", 1, $topleftcorner[0],$topleftcorner[1],$bottomrightcorner[0],$bottomrightcorner[1],$tabx,$taby, 50)
					;MouseClick("Primary", $tabx, $taby, 1)

					; buys said item 5 times
					$count = 0
					While $count <5
						Sleep(200)
						; search for "item" you wish to feed
						; item.bmp may be changed depending on which item you want to feed
						; for the sake of this experiment, I am using Sandals, as I have a female sword ego
						;_ImageSearch("item.bmp", 1, $itemx, $itemy, 30)
						;Transparency
						;This part needs a little work. I keep getting an error that says:
						;"called with wrong number of args."
						If $itemxy[0]=0 or $itemxy[1]=0 Then
							$itemxy=_GetXY("Hover over Item then press 'a' key.")
						Else
							MouseMove($itemxy[0], $itemxy[1],0)
							Sleep(200)
							Send("{CTRLDOWN}")
							Sleep(100)
							MouseClick("Primary", $itemxy[0], $itemxy[1], 1)
							Sleep(100)
							Send("{CTRLUP}")
							$count = $count + 1
							ToolTip ("Item Count= " & $count, 0,@desktopheight-20)
						EndIf
					WEnd

					; end conversation with NPC
					$result=_ImageSearch(@ScriptDir & "\Find\Images\buttons\endconvo.bmp", 1, $endconvox, $endconvoy, 30)
					If $result=1 then
						MouseClick("Primary", $endconvox, $endconvoy, 1)
						; proceed to feed ego
						Sleep(1000)
						FeedEgo()

					Else
						ToolTip ("endconvo.bmp not Found. Take new screenshots" , 0,@desktopheight-20)
					EndIf

			;Else
			;	ToolTip ("tab.bmp not found. Take new screenshots" , 0,@desktopheight-20)
			;	Sleep(2000)
			;EndIf
		Else
			ToolTip ("shop.bmp not Found. Take new screenshots" , 0,@desktopheight-20)
		EndIf
	EndIf
EndFunc

;===================================================================================
Func FeedEgo ()
	; press ego hotkey
	Send("{/}")
	; give item to ego
	sleep(3000)
	$result=_ImageSearch(@ScriptDir & "\Find\Images\buttons\give.bmp", 1, $givex, $givey, 30)
	If $result=1 then
		MouseClick("Primary", $givex, $givey, 1)
		Sleep(3000)
		; continue
		$result=_ImageSearch(@ScriptDir & "\Find\Images\buttons\continue.bmp", 1, $continuex, $continuey, 30)
		If $result=1 then
			MouseClick("Primary", $continuex, $continuey, 1)
			Sleep(1000)
			$feedcount = 0
			While $feedcount < 5
				; feeds item in #1 slot
				$result=_ImageSearch(@ScriptDir & "\Find\Images\buttons\feed.bmp", 1, $feedx, $feedy, 30,50)
				If $result=1 Then
				MouseClick("Primary", $feedx, $feedy, 1)
				Sleep(3000)
				; presses okay to feed item in #1 slot
				$result=_ImageSearch(@ScriptDir & "\Find\Images\buttons\ok.bmp", 1, $okayx, $okayy, 30,50)
				MouseClick("Primary", $okayx, $okayy, 1)
				$feedcount = $feedcount + 1
				ToolTip ("Ego has been fed: " & $feedcount & " item(s)", 0,@desktopheight-20)
				Sleep(3000)
				; presses continue
				$result=_ImageSearch(@ScriptDir & "\Find\Images\buttons\continue.bmp", 1, $continuex, $continuey, 30)
				MouseClick("Primary", $continuex, $continuey, 1)
				Sleep(3000)

				MouseClick("Primary", $continuex, $continuey, 1)
				Sleep(3000)
				EndIf
			WEnd
		Else
			ToolTip ("continue.bmp not found..." , 0,@desktopheight-20)
		EndIf
		; Closes Ego Window and pauses for 30seconds before searching for "is hungry"
		Send("{/}")
		Sleep(10000)
	Else
		ToolTip ("give.bmp not found..." , 0,@desktopheight-20)
	EndIf
EndFunc

;===================================================================================
Func _Exit()
	Exit 0
EndFunc
;===================================================================================
Func _GetXY($message)
    HotKeySet("a","_DoNothing")
    While Not _IsPressed('41')
        Local $currCoord = MouseGetPos()
        Sleep(10)
        ToolTip($message & @CRLF & "First coord: " & $currCoord[0] & "," & $currCoord[1])
        If _IsPressed('41') Then
            While _IsPressed('41')
				return MouseGetPos()
            WEnd
            ExitLoop 1
        EndIf
    WEnd
EndFunc
;===================================================================================
Func _DoNothing()
EndFunc
;===================================================================================
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