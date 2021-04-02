#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Find\Images\gui\splash.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_LegalCopyright=ShaggyZE
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $version,$tries=0,$mirror,$timetoget,$BytesTotal,$FileKBS,$FileBS
Global Const $PBS_MARQUEE = 0x00000008 ; The progress bar moves like a marquee
Global Const $PBS_SMOOTH = 1
Global Const $PBS_SMOOTHREVERSE = 0x10 ; Vista
Global Const $PBS_VERTICAL = 4
Global Const $GUI_SS_DEFAULT_PROGRESS = 0
Global Const $__PROGRESSBARCONSTANT_WM_USER = 0X400
Global Const $PBM_DELTAPOS = $__PROGRESSBARCONSTANT_WM_USER + 3
Global Const $PBM_GETBARCOLOR = 0x040F ; Vista
Global Const $PBM_GETBKCOLOR = 0x040E ; Vista
Global Const $PBM_GETPOS = $__PROGRESSBARCONSTANT_WM_USER + 8
Global Const $PBM_GETRANGE = $__PROGRESSBARCONSTANT_WM_USER + 7
Global Const $PBM_GETSTATE = 0x0411 ; Vista
Global Const $PBM_GETSTEP = 0x040D ; Vista
Global Const $PBM_SETBARCOLOR = $__PROGRESSBARCONSTANT_WM_USER + 9
Global Const $PBM_SETBKCOLOR = 0x2000 + 1
Global Const $PBM_SETMARQUEE = $__PROGRESSBARCONSTANT_WM_USER + 10
Global Const $PBM_SETPOS = $__PROGRESSBARCONSTANT_WM_USER + 2
Global Const $PBM_SETRANGE = $__PROGRESSBARCONSTANT_WM_USER + 1
Global Const $PBM_SETRANGE32 = $__PROGRESSBARCONSTANT_WM_USER + 6
Global Const $PBM_SETSTATE = 0x0410 ; Vista
Global Const $PBM_SETSTEP = $__PROGRESSBARCONSTANT_WM_USER + 4
Global Const $PBM_STEPIT = $__PROGRESSBARCONSTANT_WM_USER + 5
$MabiPath = RegRead("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "")
If $MabiPath = "" Then
	RegWrite("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "", "REG_SZ", "C:\Nexon\Library\mabinogi\appdata")
	$MabiPath = RegRead("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "")
EndIf
; ===============================================================================================================================
$mirror=iniread("AutoBot\config.ini","Settings","mirror","0")
if $mirror =1 then
$FileDownloadURL = "http://uotiara.com/shaggyze/"
$FileToDownload = "version.ini"
$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
if $FileSize = 0 Then
$FileDownloadURL = "http://uotiara.com/shaggyze/"
$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
endif
if $FileSize = 0 Then
$FileDownloadURL = "http://uotiara.com/shaggyze/"
$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
endif
Elseif $mirror =2 then
$FileDownloadURL = "http://shaggyze.hobby-site.com:8080/Mabinogi%20Mods/"
$FileToDownload = "version.ini"
$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
if $FileSize = 0 Then
$FileDownloadURL = "http://uotiara.com/shaggyze/"
$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
endif
if $FileSize = 0 Then
$FileDownloadURL = "http://uotiara.com/shaggyze/"
$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
endif
Elseif $mirror=0 or $mirror=4 then
$FileDownloadURL = "http://uotiara.com/shaggyze/"
$FileToDownload = "version.ini"
$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
if $FileSize = 0 Then
$FileDownloadURL = "http://uotiara.com/shaggyze/"
$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
endif
if $FileSize = 0 Then
$FileDownloadURL = "http://shaggyze.uotiara.com"
$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
endif
endif
$FileDownloading = InetGet ($FileDownloadURL & $FileToDownload, @ScriptDir & "\" & $FileToDownload,1,1)
$version=iniread("version.ini","version","version","")
$FileToDownload = "AutoBot.rar"
$FileToReplace = $MabiPath & "\" & $FileToDownload
$Decompressor = "UnRAR.exe x -o+ "
Updater()
; =====================================================================
Func Updater()

	local $progress,$percentDownloaded
    FileRecycle ($filetoreplace)
    ProcessWaitClose ($FileToReplace) ;Wait for process to close before file will be available for replacement
    if FileExists("UnRAR.exe")=False then InetGet ("http://uotiara.com/shaggyze/UnRAR.exe", @Scriptdir & "\UnRAR.exe",1,1)
	if $mirror=1 then
		$FileDownloadURL = "http://uotiara.com/shaggyze/"
		$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
		if $FileSize = 0 Then
			$FileDownloadURL = "http://uotiara.com/shaggyze/"
			$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
		endif
		if $FileSize = 0 Then
			$FileDownloadURL = "http://uotiara.com/shaggyze/"
			$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
		endif
	Elseif $mirror=2 then
		$FileDownloadURL = "http://uotiara.com/shaggyze/"
		$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
		if $FileSize = 0 Then
			$FileDownloadURL = "http://uotiara.com/shaggyze/"
			$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
		endif
		if $FileSize = 0 Then
			$FileDownloadURL = "http://uotiara.com/shaggyze/"
			$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
		endif
	Elseif $mirror=0 or $mirror=4 then
		$FileDownloadURL = "http://uotiara.com/shaggyze/"
		$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
		if $FileSize = 0 Then
			$FileDownloadURL = "http://uotiara.com/shaggyze/"
			$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
		endif
		if $FileSize = 0 Then
			$FileDownloadURL = "http://uotiara.com/shaggyze/"
			$FileSize = InetGetSize ($FileDownloadURL & $FileToDownload,1)
		endif
	endif
	$Start = Timerinit()
    $FileDownloading = InetGet ($FileDownloadURL & $FileToDownload, $FileToReplace,1,1) ;1 for Force redownload, 1 for Do not wait till downloaded and go next
	If $FileSize = 0 Then
		if $tries=4 then
			IniWrite("AutoBot\config.ini","Settings","mirror","0")
		exit
		endif
		$mirror=$tries
		$tries=$tries+1
		MsgBox(0,"ERROR","Can not connect to servers.." & @CRLF & $FileDownloadURL)
		Updater()
	EndIf
	$FileDownloadingInfo = InetGetInfo ($FileDownloading)
	$Return = _ProgressGUI("Downloading " & $FileToDownload & @CRLF & $FileDownloadURL, 1, 12, "", 250, 250);, 4, 6)
        For $i = 1 to $FileSize step 1
			$timetoget = TimerDiff($Start)
			$LastBytesTotal=$FileDownloadingInfo[0]
			$FileDownloadingInfo = InetGetInfo ($FileDownloading)
			$FileBS=round($FileDownloadingInfo[0] / round($timetoget,0)/1000,1)
			$FileKBS=round(($FileDownloadingInfo[0]*1024) / round($timetoget,0)/1000,1)
			$FileETA=round(($FileSize/1000000-$FileDownloadingInfo[0]/1000000) / ($FileBS),0)
			$FilePercentDownloaded = Round($FileDownloadingInfo[0]*100/$FileSize, 2)

			GUICtrlSetData($Return[2], "Downloading " & $FileToDownload & @CRLF & $FileDownloadURL & @CRLF & $FilePercentDownloaded & "%  @  " & $FileKBS & " Kb/s  ETA: " & $FileETA & " sec/s")
			GUICtrlSetData($Return[1], $FilePercentDownloaded )
			If InetGetInfo($FileDownloading,2) Then
				GUICtrlSetData($Return[1], 100)
				GUICtrlSetData($Return[2], "Downloading " & $FileToDownload & @CRLF & $FileDownloadURL & @CRLF & "100%  @  " & $FileKBS & " Kb/s  ATA: " & round($timetoget/1000,0) & " sec/s")
				InetGetInfo($FileDownloading, 2)    ; Check if the download is complete.
				Local $aData = InetGetInfo($FileDownloading)  ; Get all information.
				;MsgBox(0, "", "Bytes read: " & $aData[0] & @CRLF & "Size: " & $aData[1] & @CRLF & "Complete?: " & $aData[2] & @CRLF & "Successful?: " & $aData[3] & @CRLF & "@error: " & $aData[4] & @CRLF & "@extended: " & $aData[5] & @CRLF)
				InetClose($FileDownloading)
				ExitLoop
			Else
				ContinueLoop
			EndIf
        Next
		sleep(1000)
		$FileToReplace=FileGetShortName($FileToReplace)
		$DecompressCommand = ($Decompressor & $FileToDownload & " " & $MabiPath)
		;Runwait ($DecompressCommand,$MabiPath)
        Runwait (FileGetShortName($DecompressCommand),$MabiPath)
        ;FileRecycle ($filetoreplace) ;erase downloaded file
		sleep(1000)
		GUIDelete()
		Local $open
		;If Not FileExists("C:\Nexon\Mabinogi\ZEP.ini") or iniread("Patcher.ini","Patcher","ForcePatch","0")=0 then
		;		$open=MsgBox(4,'Information',"Update Complete !" & @CRLF & "Do you want to use ZE Patcher?")
		;		If $open=6 then
		;			$open=MsgBox(4,'Information',"Update Complete !" & @CRLF & "Are you using Windows 7?")
		;			If $open=6 then
		;				IniWrite("Patcher.ini","Patcher","ForcePatch","1")
		;				FileDelete("C:\Nexon\Mabinogi\dbghelp.dll")
		;				FileDelete("C:\Nexon\Mabinogi\ZEP.ini")
		;				FileMove("C:\Nexon\Mabinogi\ZEP-ReleaseWindows7\dbghelp.zep","C:\Nexon\Mabinogi\dbghelp.zep")
		;				FileMove("C:\Nexon\Mabinogi\ZEP-ReleaseWindows7\dbghelp.dll","C:\Nexon\Mabinogi\dbghelp.dll")
		;				FileMove("C:\Nexon\Mabinogi\ZEP-ReleaseWindows7\ZEP.ini","C:\Nexon\Mabinogi\ZEP.ini")
		;			Else
		;				IniWrite("Patcher.ini","Patcher","ForcePatch","1")
		;				FileDelete("C:\Nexon\Mabinogi\dbghelp.dll")
		;				FileDelete("C:\Nexon\Mabinogi\ZEP.ini")
		;				FileMove("C:\Nexon\Mabinogi\ZEP-PreWin7\dbghelp.zep","C:\Nexon\Mabinogi\dbghelp.zep")
		;				FileMove("C:\Nexon\Mabinogi\ZEP-PreWin7\dbghelp.dll","C:\Nexon\Mabinogi\dbghelp.dll")
		;				FileMove("C:\Nexon\Mabinogi\ZEP-PreWin7\ZEP.ini","C:\Nexon\Mabinogi\ZEP.ini")
		;			EndIf
		;		Else
		;		IniWrite("ZEP.ini","Patcher","ForcePatch","1")
		;		IniWrite("Patcher.ini","Patcher","ForcePatch","1")
		;		endif
		;EndIf
		Run(FileGetShortName($MabiPath &"\AutoBot\AutoBot.exe"),$MabiPath & "\AutoBot")
	GUIDelete($Return[0])
EndFunc
; =====================================================================
func _RTRIM($sString, $sTrimChars=' ')
	$sTrimChars = StringReplace( $sTrimChars, "%%whs%%", " " & chr(9) & chr(11) & chr(12) & @CRLF )
	local $nCount, $nFoundChar
	local $aStringArray = StringSplit($sString, "")
	local $aCharsArray = StringSplit($sTrimChars, "")

	for $nCount = $aStringArray[0] to 1 step -1
		$nFoundChar = 0
		for $i = 1 to $aCharsArray[0]
			if $aCharsArray[$i] = $aStringArray[$nCount] then
				$nFoundChar = 1
			EndIf
		next
		if $nFoundChar = 0 then return StringTrimRight( $sString, ($aStringArray[0] - $nCount) )
	next
endfunc
; =====================================================================
Func _ProgressGUI($MsgText = "Text Message", $_MarqueeType = 1, $_iFontsize = 9, $_sFont = "Arial", $_iXSize = 290, $_iYSize = 100, $_GUIColor = 0x0000000, $_FontColor = 0x0000000)
	Local $PBMarquee[3]
	; bounds checking/correcting
	If $_iFontsize = "" Or $_iFontsize = "Default" Or $_iFontsize = "-1" Then $_iFontsize = 9
	If $_iFontsize < 1 Then $_iFontsize = 1
	If $_iXSize = "" Or $_iXSize = "-1" Or $_iXSize = Default Then $_iXSize = 290
	If $_iXSize < 80 Then $_iXSize = 80
	If $_iXSize > @DesktopWidth - 50 Then $_iXSize = @DesktopWidth - 50
	If $_iYSize = "" Or $_iYSize = "-1" Or $_iYSize = Default Then $_iYSize = 100
	If $_iYSize > @DesktopHeight - 50 Then $_iYSize = @DesktopHeight - 50
	If $_GUIColor = "" Or $_GUIColor = "-1" Then $_GUIColor = 0x00080FF
	If $_sFont = "" Or $_sFont = "-1" Or $_sFont = "Default" Then $_sFont = "Arial"
	;create the GUI
	$PBMarquee[0] = GUICreate("", $_iXSize, $_iYSize, -1, -1, BitOR(0x00400000, 0x80000000))



	If @error Then Return SetError(@error, 0, 0) ; if there's any error with creating the GUI, return the error code
	GUISetBkColor($_GUIColor, $PBMarquee[0])
	;	Create the progressbar
	If $_MarqueeType < 1 Then ; if $_MarqueeType < 1 then use the Marquee style progress bar
		$PBMarquee[1] = GUICtrlCreateProgress(20, $_iYSize - 20, $_iXSize - 40, 15, 9) ; uses the $PBS_SMOOTH and $PBS_MARQUEE style
		GUICtrlSendMsg($PBMarquee[1], 1034, True, 20)
	Else ; If $_MarqueeType > 0 then use the normal style progress bar
		$PBMarquee[1] = GUICtrlCreateProgress(20, $_iYSize - 20, $_iXSize - 40, 15, 1) ; Use the $PBS_SMOOTH style
	EndIf
	$PBMarquee[2] = GUICtrlCreateLabel($MsgText, 20, $_iYSize-70, $_iXSize + 400, $_iYSize - 45) ; create the label for the GUI
	GUICtrlSetFont(-1, 9, 400, Default, $_sFont)
	GUICtrlSetColor(-1, $_FontColor)
	$oObj = ObjCreate("Shell.Explorer.2")
	$oObj_ctrl = GUICtrlCreateObj($oObj, 0, 0, $_iXSize+10, $_iYSize-70)
	$sGIF = "http://www.uotiara.com/shaggyze/autobot-loading1.gif"
	$URL = "about:<html><body bgcolor='#000000' scroll='no'>load<img src='"&$sGIF&"' width='180' height='180' border='0'></img></body></html>"
	$oObj.Navigate($URL)
	GUISetState()
	Return SetError(0, 0, $PBMarquee) ;Return the ControlIDs of the GUI and the Progress bar
EndFunc   ;==>_ProgressGUI