;testing auto trainer for mmorpg Mabinogi
;created by wannabecoder_alexdra
#include <ImageSearch2015.au3>

$x = 0
$y = 0
$waitTime = 1.5
global $pictures [3]
$pictures[0] = 2
$pictures[1] = "C:\Users\adria\Downloads\Mabinogi Macros-20200419T053501Z-001\Mabinogi Macros\Pictures\Advance.PNG"
$pictures[2] = "C:\Users\adria\Downloads\Mabinogi Macros-20200419T053501Z-001\Mabinogi Macros\Pictures\Advance1.PNG"
$msg = ""

Opt("MouseCoordMode", 3)

$kunaistorm=1
$kunaistormuses=0
;__________________________

WinActivate("Mabinogi")
WinWaitActive("Mabinogi")

While ($kunaistorm=1)
	$kunaistormuses=$kunaistormuses + 1
    Send("{TAB}")
            Sleep(2000)
    Send("1")
            Sleep(15000)
If $kunaistormuses > 100 Then
	$kunaistormuses=0
	For $i = 1 To $pictures[0]
		$result = _WaitForImagesSearch($pictures[$i], $waitTime, 1, $x, $y, 110, 0)
		Sleep(5000)
		If $result=1 Then
			MouseMove ($x, $y, 1)
			Sleep(2500)
			MouseClick ("left")
		Else
			ConsoleWrite("No Luck!" & @CRLF)
		EndIf
	Next
EndIf
WEnd