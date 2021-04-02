#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Find\Images\gui\splash.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Comment=AutoBot
#AutoIt3Wrapper_Res_Description=AutoBot
#AutoIt3Wrapper_Res_Fileversion=258.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=ShaggyZE
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;=======================================================================================
;Credits to darkforce9999's for Fossil 9.5, dkend, theri and vb286 For pelvis fossil fix and all unknowns for various edits
;to fossil macros, hackmaster for .rst support and diometer for his awesome incomplete code.
;If you think you are worth memntioning let me know and i'll mention you
;here...
;Core.au3 Source Credit goes to Theri though much of the code had errors, needed fixed and or updated
;So I cleaned it up and added more functions-ShaggyZE.
;=======================================================================================

#region Includes
#include-once
#include <GuiButton.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiComboBoxEx.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <IE.au3>
#include <Math.au3>
#include <ImageSearch2015.au3>
#include <GUIListView.au3>
#include <WinAPI.au3>
#include <File.au3>
#include <Misc.au3>
#include <vkConstants.au3>
#include <GUIScrollBars_Ex.au3>
#include <GuiScrollBars.au3>
#include <GuiScroll.au3>
#include <GUICtrl_SetResizing.au3>
#endregion Includes

#region Global Variables And Constants
;=======================================================================================
;TODO: compress more variables into arrays
GUIRegisterMsg($WM_MOUSEWHEEL, "_Scrollbars_WM_MOUSEWHEEL")
;HotKeySet("{DELETE}", "ExitNow")
;HotKeySet("{HOME}", "_cleanUp")

Global $iID, $iRound, $sHexKeys, $sMouse, $sString, $hHookKeyboard, $pStub_KeyProc,$ClearID
Global $ButtonS[9], $width, $height, $tl_x, $tl_y, $br_x, $br_y, $center_x, $center_y,$holdctrlCHK,$holdctrl,$2xCtrlClick,$2xCtrlClickSkill1,$2xCtrlClickSkill2,$2xCtrlClickSkill3
Global $x, $y, $a_size, $corr, $fossil_x, $fossil_y, $toleranceold, $F1_x, $F1_y,$dropitemsCHK,$movetargeting,$switchweapon,$centerclickCHK,$centerxoffsetINP,$centeryoffsetINP
Global $x1, $y1, $coords[6], $topleftcorner[2], $bottomrightcorner[2], $searchbox[4],$holdaltCHK,$holdalt,$centerclickCMB,$centerclickusesINP,$centerclickdelayINP
Global $center[2], $result, $broken, $brokenhex = 0xb502, $array, $hidewindows, $File_Name, $clickloopdelay,$hotkeyINP,$hotkey
Global $box, $temparray, $count, $runonce, $num, $times, $unit, $usemover, $debug, $DelCount, $clickcountINP
Global $checkupdate, $searchmode, $searchmodeCHK, $checkupdateCHK, $SELECT_H, $DelCount1, $clickdelayINP
Global $time, $aInput, $autoscan, $hitdelay, $Mode, $mirror, $clickloopdelayINP,$centerclickafter,$centerclick,$centerclickuses,$centerclickdelay,$centerxoffset,$centeryoffset
Global $fossil, $randomnumber, $x, $y, $sString, $hitcount, $finditems, $founditems, $clickcount, $clickdelay
Global $fossil_x, $fossil_y, $quantity0, $quantity, $quantity1, $line[2], $file, $pause, $twoslots, $dotwice
Global $shortestdelay, $shortdelay, $delay, $longdelay, $longestdelay, $F1x, $F1y, $F1x0, $F1y0
Global $account, $password, $useitems, $completefossil, $mousedelay, $usefossil, $packed,$metalxoffsetINP,$metalyoffsetINP
Global $nMsg, $mouse_speed, $Button6, $Group1, $Group2, $Button7, $toleranceSLD[3],$dropxoffset,$dropyoffset,$metalxoffset,$metalyoffset
Global $Group3, $Group4, $Group5, $Group6, $Form1, $Tab1, $TabSheet1, $TabSheet2, $TabSheet3,$fossilxoffset,$fossilyoffset
Global $TabSheet4, $TabSheet5, $TabSheet6, $IE, $__IEAU3V1Compatibility, $summonpet, $notdetected
Global $Pic1, $Form, $msg, $finditemsCHK[4], $useitemsCHK[5], $selfclickCMB, $petinvkey,$dropxoffsetINP,$dropyoffsetINP
Global $completefossilCHK[2], $autoscanCHK[2], $hidewindowsCHK[5], $twoslotsCHK[4],$fossilxoffsetINP,$fossilyoffsetINP
Global $mobsearchCHK, $attackanythingCHK, $mobsearch, $attackanything, $selfclick, $questnumb, $questnumr
Global $useskill, $useskillCHK, $useskillusesINP, $useskillhotkeyINP[2], $useskilldelayINP
Global $useskilldelay, $skilluses, $firstskill, $skilldelay, $selfclickafter, $msgs,$dropitems
Global $useskill2, $useskill2CHK, $useskilluses2INP, $useskillhotkey2INP, $useskilldelay2INP
Global $useskill2delay, $skill2uses, $secondskill, $skill2delay, $selfclickdelayINP, $hitdelayINP
Global $useskill3, $useskill3CHK, $useskilluses3INP, $useskillhotkey3INP, $useskilldelay3INP
Global $useskill3delay, $skill3uses, $thirdskill, $skill3delay, $selfclickusesINP, $MabiPathINP
Global $selfclickCHK, $Button7, $startTime, $percent, $x2, $y2, $selfclickdelayINP, $MabiPathBTN
Global $selfclickuses, $selfclickdelay, $listviewContextItem, $dirCHK[5], $Files[4], $msgs1
Global $FileList[9999], $File_Name, $File1, $File2, $File3, $items[9999], $items1[9999], $listview[6]
Global $Status, $Full_Name, $hGUI, $listviewContext, $Last_Name, $Debug_LV, $Debug_LB, $Files1[3]
Global $DROPLISTING, $ITEMLISTING, $USELISTING, $MOBLISTING, $PROPLISTING, $_Width, $hitcountINP
Global $VersionsInfo, $oldVersion, $newVersion, $Ini, $boxarea, $version, $_PngPath, $MabiPath
Global $fullscreenRDO[4], $centerscreenRDO[4], $fullcenterscreenRDO[4], $_GuiDelete, $_Height
Global $_Image, $_Ratio, $_Gui, $colorhex, $colorhex2, $colorhex3, $configini, $directory, $clickerimage, $clickerimage2, $clickerimage3
Global $deathcheck, $deathCHK[4], $closewindowsCHK[5], $closewindows, $tolerance1, $tolerance2
Global $tolerance3, $tolerancelbl1, $tolerancelbl2, $tolerancelbl3, $swapCHK, $timer, $File_Name1
Global $VersionsInfo1, $FileSize, $findpropsCHK, $usemoverCHK[8], $findprops, $swapsieves, $MabiDir
Global $useskillhotkeyBTN, $fossil_x1, $fossil_y1, $tolerance, $mabititle, $beak, $egg, $tooth, $MouseCoordMode, $PixelCoordMode
Global $TabSheet7, $Group7, $mousemodeCMB, $changearea, $boxarea1, $TabSheet, $Group, $TabSheet0, $Group0, $CancelSkill1, $CancelSkill2, $CancelSkill3
Global $FossilNamesCHK, $return, $InterfaceCHK, $Patcher[2], $listview1, $List_Name, $ModStatus, $CancelSkill1CHK, $CancelSkill2CHK, $CancelSkill3CHK,$2xCtrlClickSkill1CHK, $2xCtrlClickSkill2CHK, $2xCtrlClickSkill3CHK
Global $Tab2, $TabSheet8, $TabSheet9, $HugeKeysCHK, $iScrollPos, $listviewContextItem1, $listviewContext1
Global $THREAD_PROTECT, $THREAD_TARGET, $THREAD_DELAY, $UseDataFolder, $Adver2Party, $AdverToParty, $BlockEndingAds, $ClearDungeonFog, $ControlDayTime, $TimeOfDay, $DeadlyHPShow, $ElfLag, $EnableNameColoring, $EnableSelfRightClick, $HotbarAnything, $InfinitePartyTime, $ModifyZoomLimit, $ZoomDefault, $ZoomNear, $ZoomFar, $MoveToSameChannel, $NaoSoon, $RemoveLoginDelay, $ShowCombatPower, $ShowItemPrice, $ShowMinutes, $ShowTrueDurability, $ShowItemColor, $ShowTrueFoodQuality, $TalkToUnequippedEgo, $TargetMimics, $TargetSulfurGolem, $TargetProps, $UseBitmapFonts, $ViewNpcEquip, $DefaultRangeSwap
Global $THREAD_PROTECTCHK, $THREAD_TARGETCHK, $THREAD_DELAYINP, $UseDataFolderCHK, $Adver2PartyCHK, $AdverToPartyCHK, $BlockEndingAdsCHK, $ClearDungeonFogCHK, $ControlDayTimeCMB, $TimeOfDayINP, $DeadlyHPShowCHK, $ElfLagCHK, $EnableNameColoringCHK, $EnableSelfRightClickCHK, $HotbarAnythingCHK, $InfinitePartyTimeCHK, $ModifyZoomLimitCHK, $ZoomDefaultINP, $ZoomNearINP, $ZoomFarINP, $MoveToSameChannelCHK, $NaoSoonCHK, $RemoveLoginDelayCHK, $ShowCombatPowerCHK, $ShowItemPriceCHK, $ShowMinutesCHK, $ShowTrueDurabilityCHK, $ShowItemColorCHK, $ShowTrueFoodQualityCHK, $TalkToUnequippedEgoCHK, $TargetMimicsCHK, $TargetSulfurGolemCHK, $TargetPropsCHK, $UseBitmapFontsCMB, $ViewNpcEquipCHK, $DefaultRangeSwapCMB
Global $_SCROLLBARCONSTANTS_ESB_ENABLE_BOTH
Global Const $TRAY_EVENT_PRIMARYDOUBLE = -13, $TRAY_EVENT_PRIMARYDOWN = -7, $SS_NOTIFY = 0x0100, $VK_ENTER = 0x0D
Global Const $LB_ITEMFROMPOINT = 0x01A9, $LB_SETCURSEL = 0x0186
Global Const $__LISTBOXCONSTANT_ClassNames = "SysListView32|TListbox"
Global Const $LBS_MULTIPLESEL = 0x00000008
;Global Const $FO_READ		= 0 ; Read mode
;Global Const $FO_APPEND		= 1 ; Write mode (append)
;Global Const $FO_OVERWRITE	= 2 ; Write mode (erase previous contents)
#endregion Global Variables And Constants

#region Main Script
;=======================================================================================
;Main Program Preparing
AdlibRegister("_GUICtrl_SetResizing_Handler", 50)
If Not IsAdmin() Then _errorHandler(0)
$configini = "Frontend.ini"
If FileExists("Frontend.ini") = False Then InetGet("http://shaggyze.uotiara.com/Frontend.ini", @ScriptDir & "\Frontend.ini", 1, 1)
_readINI()
$MabiPath = RegRead("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "")
If $MabiPath = "" Then
	RegWrite("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "", "REG_SZ", "C:\Nexon\Mabinogi")
	$MabiPath = RegRead("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "")
EndIf
If FileExists($MabiPath & "\Client.exe") = False Then
	If FileExists(_RTRIM(@ScriptDir, "\AutoBot") & "\Client.exe") = True Then
		MsgBox(0, "Mabinogi not detected", "AutoBot doesn't appear to be in the correct location:" & @CRLF & "Copy AutoBot to the " & _RTRIM(@ScriptDir, "\AutoBot") & " directory")
		RegWrite("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "", "REG_SZ", _RTRIM(@ScriptDir, "\AutoBot"))
		$MabiPath = RegRead("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "")
		Exit
	ElseIf FileExists($MabiDir & "\Client.exe") = True Then
		MsgBox(0, "Mabinogi not detected", "AutoBot doesn't appear to be in the correct location:" & @CRLF & "Copy AutoBot to the " & $MabiDir & " directory")
		RegWrite("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "", "REG_SZ", $MabiDir)
		$MabiPath = RegRead("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "")
		Exit
	ElseIf FileExists("C:\Nexon\Mabinogi\Client.exe") = True Then
		MsgBox(0, "Mabinogi not detected", "AutoBot doesn't appear to be in the correct location:" & @CRLF & "Copy AutoBot to the C:\Nexon\Mabinogi directory")
		RegWrite("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "", "REG_SZ", "C:\Nexon\Mabinogi")
		$MabiPath = RegRead("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "")
		Exit
	Else
		MsgBox(0, "Mabinogi not detected", "AutoBot doesn't appear to be in the correct location:" & @CRLF & "Copy AutoBot to the Mabinogi root directory and fix the Mabinogi Path in AutoBot's Settings")
		RegWrite("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "", "REG_SZ", "")
		$MabiPath = RegRead("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "")
		Exit
	EndIf
EndIf
$version = IniRead($MabiPath & "\AutoBot\config.ini", "Settings", "version", "1")
$MouseCoordMode = IniRead($MabiPath & "\AutoBot\config.ini", "Settings", "MouseCoordMode", "0")
$PixelCoordMode = IniRead($MabiPath & "\AutoBot\config.ini", "Settings", "PixelCoordMode", "1")
_Updater()
SoundPlay("intro.mp3")
_splashImage()
Opt("MouseCoordMode", $MouseCoordMode) ;Mouse coords by active winDow.
Opt("PixelCoordMode", $PixelCoordMode) ;Pixel coords by active winDow.
Opt("MustDeclareVars", 1) ;Must declare variables.
Opt("TrayOnEventMode", 1) ;Tray events on.
Opt("TrayMenuMode", 1) ;No tra menu.
Opt("WinTitleMatchMode", 2)
TraySetIcon(@ScriptDir & "\Find\Images\gui\splash.ico")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "ExitNow") ;Tray function on Double click.
TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "ExitNow") ;Tray function on Single click.
;TraySetOnEvent($TRAY_EVENT_SECONDARYDOWN,"Sleep(10000)")        ;Tray function on Right click.
TraySetState()
$pStub_KeyProc = DllCallbackRegister("_KeyboardHook", "int", "int;ptr;ptr")
$hHookKeyboard = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($pStub_KeyProc), _WinAPI_GetModuleHandle(0), 0)
;FileDelete (@DesktopCommonDir & "\AutoBot.lnk")
;If FileExists(@DesktopCommonDir & "\AutoBot.lnk") = False Then
;FileCreateShortcut($MabiPath & "\AutoBot\AutoBot.exe", @DesktopCommonDir & "\AutoBot.lnk", $MabiPath & "\AutoBot\")
;EndIf
;========================================================
;GUI Start
$Form1 = GUICreate("AutoBot v" & $version, 900, 430,-1,-1,BitOR ($GUI_SS_DEFAULT_GUI, $WS_THICKFRAME, $WS_VSCROLL))
_GUIScrollBars_Init(-1)
_GUIScrollBars_SetScrollInfo(-1,$iScrollPos, $SB_VERT)
_GUICtrl_SetOnResize(-1)
GUICtrlSetTip(-1, "")
GUICtrlSetState(-1, $GUI_DISABLE)
GUISetIcon(@ScriptDir & "\Find\Images\gui\splash.ico")
$Tab1 = GUICtrlCreateTab(0, 0, 805, -1, -1)
GUICtrlSetTip(-1, "")
;========================================================
;GUI Frontend
$TabSheet0 = GUICtrlCreateTabItem("Frontend")
GUICtrlCreateLabel("", 0, 19, 925, 1025)
GUICtrlSetTip(-1, "")
;GUICtrlSetBkColor(-1, $colorhex)
;GUICtrlSetState(-1, $GUI_DISABLE)
;$ButtonS[7] = GUICtrlCreateButton("", 216, 52, 70, 25)
$Group0 = GUICtrlCreateGroup("UO Tiara Mods", 6, 88, 879, 339)
;GUICtrlSetBkColor(-1, $colorhex2)
;GUICtrlCreateGroup("", -99, -99, 1, 1)
;$ButtonS[8] = GUICtrlCreateButton("", 16, 32, 65, 25)
;========================================================
;GUI Fossil
$TabSheet = GUICtrlCreateTabItem("Fossil Restoration")
GUICtrlCreateLabel("", 0, 19, 925, 455)
GUICtrlSetTip(-1, "")
GUICtrlSetBkColor(-1, $colorhex)
GUICtrlSetState(-1, $GUI_DISABLE)
$Group1 = GUICtrlCreateGroup("Restoration Settings", 6, 88, 579, 339)
GUICtrlSetBkColor(-1, $colorhex2)
$useitemsCHK[0] = GUICtrlCreateCheckbox("Use Items", 10, 100)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("X Offset", 195, 105, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$fossilxoffsetINP = GUICtrlCreateInput("", 255, 105, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Y Offset", 335, 105, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$fossilyoffsetINP = GUICtrlCreateInput("", 395, 105, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$autoscanCHK[0] = GUICtrlCreateCheckbox("Auto Scan", 10, 120)
GUICtrlSetBkColor(-1, $colorhex2)
$completefossilCHK[0] = GUICtrlCreateCheckbox("Complete Fossils", 10, 140)
GUICtrlSetBkColor(-1, $colorhex2)
$hidewindowsCHK[0] = GUICtrlCreateCheckbox("Hide Windows", 10, 160)
GUICtrlSetBkColor(-1, $colorhex2)
$closewindowsCHK[0] = GUICtrlCreateCheckbox("Close Windows", 10, 180)
GUICtrlSetBkColor(-1, $colorhex2)
$dirCHK[0] = GUICtrlCreateCombo("", 585, 0, 80, 20)
GUICtrlSetData(-1, "Use|Drop|", "Use")
GUICtrlSetTip(-1, "Select list to enable/disable images.")
GUICtrlSetBkColor(-1, $colorhex3)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonS[0] = GUICtrlCreateButton("Start", 16, 32, 65, 25)
;========================================================
;GUI Mining
$TabSheet2 = GUICtrlCreateTabItem("Mining")
GUICtrlCreateLabel("", 0, 19, 925, 455)
GUICtrlSetTip(-1, "")
GUICtrlSetBkColor(-1, $colorhex)
GUICtrlSetState(-1, $GUI_DISABLE)
$Group2 = GUICtrlCreateGroup("Mining Settings", 6, 88, 579, 339)
GUICtrlSetBkColor(-1, $colorhex2)
$finditemsCHK[0] = GUICtrlCreateCheckbox("Find Items", 10, 100)
GUICtrlSetBkColor(-1, $colorhex2)
$useitemsCHK[1] = GUICtrlCreateCheckbox("Use Items", 10, 120)
GUICtrlSetBkColor(-1, $colorhex2)
$usemoverCHK[1] = GUICtrlCreateCheckbox("Use Mover", 90, 120)
GUICtrlSetBkColor(-1, $colorhex2)
$autoscanCHK[1] = GUICtrlCreateCheckbox("Auto Scan", 10, 140)
GUICtrlSetBkColor(-1, $colorhex2)
$completefossilCHK[1] = GUICtrlCreateCheckbox("Complete Fossils", 10, 160)
GUICtrlSetBkColor(-1, $colorhex2)
$hidewindowsCHK[1] = GUICtrlCreateCheckbox("Hide Windows", 10, 180)
GUICtrlSetBkColor(-1, $colorhex2)
$closewindowsCHK[1] = GUICtrlCreateCheckbox("Close Windows", 10, 200)
GUICtrlSetBkColor(-1, $colorhex2)
$twoslotsCHK[0] = GUICtrlCreateCheckbox("Two Axes", 10, 220)
GUICtrlSetBkColor(-1, $colorhex2)
$deathCHK[0] = GUICtrlCreateCheckbox("Death Check", 10, 240)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Screen Region Searching", 10, 260, 125, 20)
GUICtrlSetBkColor(-1, $colorhex2)
$fullscreenRDO[0] = GUICtrlCreateRadio("Full screen", 10, 280)
GUICtrlSetBkColor(-1, $colorhex2)
$fullcenterscreenRDO[0] = GUICtrlCreateRadio("Center+Full screen", 10, 300)
GUICtrlSetBkColor(-1, $colorhex2)
$centerscreenRDO[0] = GUICtrlCreateRadio("Center screen", 10, 320)
GUICtrlSetBkColor(-1, $colorhex2)
$dirCHK[1] = GUICtrlCreateCombo("", 585, 0, 80, 20)
GUICtrlSetData(-1, "Item|Prop|Equip|Use|Drop|", "Use")
GUICtrlSetTip(-1, "Select list to enable/disable images.")
GUICtrlSetBkColor(-1, $colorhex3)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonS[1] = GUICtrlCreateButton("Start", 16, 32, 65, 25)
;========================================================
;GUI Gathering
$TabSheet3 = GUICtrlCreateTabItem("Gathering")
GUICtrlCreateLabel("", 0, 19, 925, 455)
GUICtrlSetTip(-1, "")
GUICtrlSetBkColor(-1, $colorhex)
GUICtrlSetState(-1, $GUI_DISABLE)
$Group3 = GUICtrlCreateGroup("Gathering Settings", 6, 88, 579, 339)
GUICtrlSetBkColor(-1, $colorhex2)
$finditemsCHK[1] = GUICtrlCreateCheckbox("Find Items", 10, 100)
GUICtrlSetBkColor(-1, $colorhex2)
$findpropsCHK = GUICtrlCreateCheckbox("Find Props", 10, 120)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Hit Count", 150, 100, 100)
GUICtrlSetBkColor(-1, $colorhex2)
$hitcountINP = GUICtrlCreateInput("", 150, 120)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Hit Delay", 250, 100, 100)
GUICtrlSetBkColor(-1, $colorhex2)
$hitdelayINP = GUICtrlCreateInput("", 250, 120)
GUICtrlSetBkColor(-1, $colorhex2)
$usemoverCHK[2] = GUICtrlCreateCheckbox("Use Mover", 10, 140)
GUICtrlSetBkColor(-1, $colorhex2)
$useitemsCHK[2] = GUICtrlCreateCheckbox("Use Items", 10, 160)
GUICtrlSetBkColor(-1, $colorhex2)
$hidewindowsCHK[2] = GUICtrlCreateCheckbox("Hide Windows", 10, 180)
GUICtrlSetBkColor(-1, $colorhex2)
$closewindowsCHK[2] = GUICtrlCreateCheckbox("Close Windows", 10, 200)
GUICtrlSetBkColor(-1, $colorhex2)
$twoslotsCHK[1] = GUICtrlCreateCheckbox("Two Tools", 10, 220)
GUICtrlSetBkColor(-1, $colorhex2)
$deathCHK[1] = GUICtrlCreateCheckbox("Death Check", 10, 240)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Screen Region Searching", 10, 260, 125, 20)
GUICtrlSetBkColor(-1, $colorhex2)
$fullscreenRDO[1] = GUICtrlCreateRadio("Full screen", 10, 280)
GUICtrlSetBkColor(-1, $colorhex2)
$fullcenterscreenRDO[1] = GUICtrlCreateRadio("Center+Full screen", 10, 300)
GUICtrlSetBkColor(-1, $colorhex2)
$centerscreenRDO[1] = GUICtrlCreateRadio("Center screen", 10, 320)
GUICtrlSetBkColor(-1, $colorhex2)
$dirCHK[2] = GUICtrlCreateCombo("", 585, 0, 80, 20)
GUICtrlSetData(-1, "Item|Prop|Equip|Use|Drop|", "Use")
GUICtrlSetTip(-1, "Select list to enable/disable images.")
GUICtrlSetBkColor(-1, $colorhex3)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonS[2] = GUICtrlCreateButton("Start", 16, 32, 65, 25)
;========================================================
;GUI Metallurgy
$TabSheet4 = GUICtrlCreateTabItem("Metallurgy")
GUICtrlCreateLabel("", 0, 19, 925, 455)
GUICtrlSetTip(-1, "")
GUICtrlSetBkColor(-1, $colorhex)
GUICtrlSetState(-1, $GUI_DISABLE)
$Group4 = GUICtrlCreateGroup("Metallurgy Settings", 6, 88, 579, 339)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Hotkey", 10, 100, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskillhotkeyINP[0] = GUICtrlCreateInput("", 50, 100, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskillhotkeyBTN = GUICtrlCreateButton("Save", 92, 100, 40, 20)
$finditemsCHK[2] = GUICtrlCreateCheckbox("Find Items", 10, 120)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateLabel("X Offset", 195, 105, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$metalxoffsetINP = GUICtrlCreateInput("", 255, 105, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Y Offset", 335, 105, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$metalyoffsetINP = GUICtrlCreateInput("", 395, 105, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useitemsCHK[3] = GUICtrlCreateCheckbox("Use Items", 10, 140)
GUICtrlSetBkColor(-1, $colorhex2)
$hidewindowsCHK[3] = GUICtrlCreateCheckbox("Hide Windows", 10, 160)
GUICtrlSetBkColor(-1, $colorhex2)
$closewindowsCHK[3] = GUICtrlCreateCheckbox("Close Windows", 10, 180)
GUICtrlSetBkColor(-1, $colorhex2)
$twoslotsCHK[2] = GUICtrlCreateCheckbox("Two Sieves", 10, 200)
GUICtrlSetBkColor(-1, $colorhex2)
$swapCHK = GUICtrlCreateCheckbox("Swap Sieves", 10, 220)
GUICtrlSetBkColor(-1, $colorhex2)
$deathCHK[2] = GUICtrlCreateCheckbox("Death Check", 10, 240)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Screen Region Searching", 10, 260, 125, 20)
GUICtrlSetBkColor(-1, $colorhex2)
$fullscreenRDO[2] = GUICtrlCreateRadio("Full screen", 10, 280)
GUICtrlSetBkColor(-1, $colorhex2)
$fullcenterscreenRDO[2] = GUICtrlCreateRadio("Center+Full screen", 10, 300)
GUICtrlSetBkColor(-1, $colorhex2)
$centerscreenRDO[2] = GUICtrlCreateRadio("Center screen", 10, 320)
GUICtrlSetBkColor(-1, $colorhex2)
$dirCHK[3] = GUICtrlCreateCombo("", 585, 0, 80, 20)
GUICtrlSetData(-1, "Item|Prop|Equip|Use|Drop|", "Use")
GUICtrlSetTip(-1, "Select list to enable/disable images.")
GUICtrlSetBkColor(-1, $colorhex3)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonS[3] = GUICtrlCreateButton("Start", 16, 32, 65, 25)
;========================================================
;GUI Fight
$TabSheet5 = GUICtrlCreateTabItem("Fight")
GUICtrlCreateLabel("", 0, 19, 925, 1025)
GUICtrlSetTip(-1, "")
GUICtrlSetBkColor(-1, $colorhex)
GUICtrlSetState(-1, $GUI_DISABLE)
$Group5 = GUICtrlCreateGroup("Fight Settings", 6, 88, 579, 339)
GUICtrlSetBkColor(-1, $colorhex2)
$finditemsCHK[3] = GUICtrlCreateCheckbox("Find Items", 10, 100)
GUICtrlSetBkColor(-1, $colorhex2)
$dropitemsCHK = GUICtrlCreateCheckbox("Drop Items", 120, 100)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("X Offset", 195, 100, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$dropxoffsetINP = GUICtrlCreateInput("", 240, 100, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Y Offset", 305, 100, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$dropyoffsetINP = GUICtrlCreateInput("", 350, 100, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useitemsCHK[4] = GUICtrlCreateCheckbox("Use Items", 10, 120)
GUICtrlSetBkColor(-1, $colorhex2)
$hidewindowsCHK[4] = GUICtrlCreateCheckbox("Hide Windows", 10, 140)
GUICtrlSetBkColor(-1, $colorhex2)
$closewindowsCHK[4] = GUICtrlCreateCheckbox("Close Windows", 10, 160)
GUICtrlSetBkColor(-1, $colorhex2)
$twoslotsCHK[3] = GUICtrlCreateCheckbox("Two Weapons", 10, 180)
GUICtrlSetBkColor(-1, $colorhex2)
$mobsearchCHK = GUICtrlCreateCheckbox("Mob Search", 10, 200)
GUICtrlSetBkColor(-1, $colorhex2)
$attackanythingCHK = GUICtrlCreateCheckbox("Attack Anything", 10, 220)
GUICtrlSetBkColor(-1, $colorhex2)
$selfclickCHK = GUICtrlCreateCheckbox("Click Anywhere", 10, 240)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Click After", 115, 225, 80)
GUICtrlSetBkColor(-1, $colorhex2)
$selfclickCMB = GUICtrlCreateCombo("", 115, 240)
GUICtrlSetData(-1, "First Skill|Second Skill|Third Skill")
GUICtrlSetBkColor(-1, $colorhex3)
GUICtrlCreateLabel("Times", 195, 225, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$selfclickusesINP = GUICtrlCreateInput("", 195, 240, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Delay", 235, 225, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$selfclickdelayINP = GUICtrlCreateInput("", 235, 240, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$centerclickCHK = GUICtrlCreateCheckbox("Click Yourself", 10, 280)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Click After", 115, 265, 80)
GUICtrlSetBkColor(-1, $colorhex2)
$centerclickCMB = GUICtrlCreateCombo("", 115, 280)
GUICtrlSetData(-1, "First Skill|Second Skill|Third Skill")
GUICtrlSetBkColor(-1, $colorhex3)
GUICtrlCreateLabel("Times", 195, 265, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$centerclickusesINP = GUICtrlCreateInput("", 195, 280, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Delay", 235, 265, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$centerclickdelayINP = GUICtrlCreateInput("", 235, 280, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("X Offset", 300, 260, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$centerxoffsetINP = GUICtrlCreateInput("", 300, 280, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Y Offset", 350, 260, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$centeryoffsetINP = GUICtrlCreateInput("", 350, 280, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$deathCHK[3] = GUICtrlCreateCheckbox("Death Check", 10, 300)
GUICtrlSetBkColor(-1, $colorhex2)
$useskillCHK = GUICtrlCreateCheckbox("Use Skill", 10, 320)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Hotkey", 115, 305, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskillhotkeyINP[1] = GUICtrlCreateInput("", 115, 320, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Times", 155, 305, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskillusesINP = GUICtrlCreateInput("", 155, 320, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Delay", 195, 305, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskilldelayINP = GUICtrlCreateInput("", 195, 320, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$CancelSkill1CHK = GUICtrlCreateCheckbox("Cancel Skill", 235, 320, 90)
GUICtrlSetBkColor(-1, $colorhex2)
$2xCtrlClickSkill1CHK = GUICtrlCreateCheckbox("2 x Ctrl", 330, 320, 50)
GUICtrlSetBkColor(-1, $colorhex2)
;==========
$useskill2CHK = GUICtrlCreateCheckbox("Use Skill", 10, 360)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Hotkey", 115, 345, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskillhotkey2INP = GUICtrlCreateInput("", 115, 360, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Times", 155, 345, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskilluses2INP = GUICtrlCreateInput("", 155, 360, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Delay", 195, 345, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskilldelay2INP = GUICtrlCreateInput("", 195, 360, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$CancelSkill2CHK = GUICtrlCreateCheckbox("Cancel Skill", 235, 360, 90)
GUICtrlSetBkColor(-1, $colorhex2)
$2xCtrlClickSkill2CHK = GUICtrlCreateCheckbox("2 x Ctrl", 330, 360, 50)
GUICtrlSetBkColor(-1, $colorhex2)
;==========
$useskill3CHK = GUICtrlCreateCheckbox("Use Skill", 10, 400)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Hotkey", 115, 385, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskillhotkey3INP = GUICtrlCreateInput("", 115, 400, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Times", 155, 385, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskilluses3INP = GUICtrlCreateInput("", 155, 400, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Delay", 195, 385, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$useskilldelay3INP = GUICtrlCreateInput("", 195, 400, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$CancelSkill3CHK = GUICtrlCreateCheckbox("Cancel Skill", 235, 400, 90)
GUICtrlSetBkColor(-1, $colorhex2)
$2xCtrlClickSkill3CHK = GUICtrlCreateCheckbox("2 x Ctrl", 330, 400, 50)
GUICtrlSetBkColor(-1, $colorhex2)
;==========
GUICtrlCreateLabel("Screen Region Searching", 400, 320, 125, 20)
GUICtrlSetBkColor(-1, $colorhex2)
$fullscreenRDO[3] = GUICtrlCreateRadio("Full screen", 400, 340)
GUICtrlSetBkColor(-1, $colorhex2)
$fullcenterscreenRDO[3] = GUICtrlCreateRadio("Center+Full screen", 400, 360)
GUICtrlSetBkColor(-1, $colorhex2)
$centerscreenRDO[3] = GUICtrlCreateRadio("Center screen", 400, 380)
GUICtrlSetBkColor(-1, $colorhex2)
;==========
$dirCHK[4] = GUICtrlCreateCombo("", 585, 0, 80, 20)
GUICtrlSetData(-1, "Item|Mob|Equip|Use|Drop|", "Use")
GUICtrlSetTip(-1, "Select list to enable/disable images.")
GUICtrlSetBkColor(-1, $colorhex3)
;GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonS[4] = GUICtrlCreateButton("Start", 16, 32, 65, 25)
;========================================================
;GUI Clicker
$TabSheet7 = GUICtrlCreateTabItem("Clicker")
GUICtrlCreateLabel("", 0, 19, 925, 455)
GUICtrlSetTip(-1, "")
GUICtrlSetBkColor(-1, $colorhex)
GUICtrlSetState(-1, $GUI_DISABLE)
$Group7 = GUICtrlCreateGroup("Clicker Settings", 6, 88, 579, 339)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Click Mode", 10, 100, 80)
GUICtrlSetBkColor(-1, $colorhex2)
$holdaltCHK = GUICtrlCreateCheckbox("Hold ALT", 100, 120)
GUICtrlSetBkColor(-1, $colorhex2)
$holdctrlCHK = GUICtrlCreateCheckbox("Hold CTRL", 180, 120)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Hotkey", 260, 100, 40)
GUICtrlSetBkColor(-1, $colorhex2)
$hotkeyINP = GUICtrlCreateInput("", 260, 120, 40)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Click Count", 335, 106, 70)
GUICtrlSetTip(-1, "Times to click per loop")
GUICtrlSetBkColor(-1, $colorhex2)
$clickcountINP = GUICtrlCreateInput("", 335, 125, 40)
GUICtrlSetTip(-1, "Times to click per loop")
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Click Delay", 395, 106, 70)
GUICtrlSetTip(-1, "Delay between clicks per loop")
GUICtrlSetBkColor(-1, $colorhex2)
$clickdelayINP = GUICtrlCreateInput("", 395, 125, 40)
GUICtrlSetTip(-1, "Delay between clicks 1000 = 1 second")
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Loop Delay", 455, 106, 70)
GUICtrlSetTip(-1, "Delay between loops")
GUICtrlSetBkColor(-1, $colorhex2)
$clickloopdelayINP = GUICtrlCreateInput("", 455, 125, 40)
GUICtrlSetTip(-1, "Delay between loops 1000 = 1 second")
GUICtrlSetBkColor(-1, $colorhex2)
$mousemodeCMB = GUICtrlCreateCombo("", 10, 120, 80, 20)
GUICtrlSetData(-1, "Current|Image|Images|Static X/Y", "Current")
GUICtrlSetTip(-1, "Select mode to use for mouse clicks.")
GUICtrlSetBkColor(-1, $colorhex3)
$ButtonS[5] = GUICtrlCreateButton("Start", 16, 32, 65, 25)
;========================================================
;GUI Settings
$TabSheet6 = GUICtrlCreateTabItem("Settings")
GUICtrlCreateLabel("", 0, 19, 925, 455)
GUICtrlSetTip(-1, "")
GUICtrlSetBkColor(-1, $colorhex)
GUICtrlSetState(-1, $GUI_DISABLE)
$Group6 = GUICtrlCreateGroup("Advanced Settings", 6, 88, 569, 329)
GUICtrlSetBkColor(-1, $colorhex2)
$ButtonS[7] = GUICtrlCreateButton("Open Config", 16, 32, 65, 25)
GUICtrlSetTip(-1, "Primarily for MAIN/GUI Settings")
$toleranceSLD[0] = GUICtrlCreateSlider(10, 115, 100, 20)
GUICtrlSetTip(-1, "Primarily for Fossil Restoration")
GUICtrlSetLimit(-1, 255, 1)
GUICtrlSetData(-1, 30)
GUICtrlSetBkColor(-1, $colorhex2)
$toleranceSLD[1] = GUICtrlCreateSlider(10, 155, 100, 20)
GUICtrlSetLimit(-1, 255, 1)
GUICtrlSetData(-1, 75)
GUICtrlSetBkColor(-1, $colorhex2)
$toleranceSLD[2] = GUICtrlCreateSlider(10, 195, 100, 20)
GUICtrlSetTip(-1, "Primarily for Metallurgy")
GUICtrlSetLimit(-1, 255, 1)
GUICtrlSetData(-1, 100)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Search Mode", 10, 220, 120)
GUICtrlSetBkColor(-1, $colorhex2)
$searchmodeCHK = GUICtrlCreateCombo("", 10, 240, 80, 20)
GUICtrlSetData(-1, "Desktop|Client", "Desktop")
GUICtrlSetTip(-1, "Select search area mode Desktop or Client.")
GUICtrlSetBkColor(-1, $colorhex3)
$checkupdateCHK = GUICtrlCreateCheckbox("Check Update", 10, 260)
GUICtrlSetBkColor(-1, $colorhex2)
GUICtrlCreateLabel("Mabinogi Path", 10, 280, 120)
GUICtrlSetBkColor(-1, $colorhex2)
$MabiPathINP = GUICtrlCreateInput($MabiPath, 10, 300, 400, 20)
GUICtrlSetBkColor(-1, $colorhex3)
$MabiPathBTN = GUICtrlCreateButton("Save", 10, 320)
;========================================================
;GUI Screen Capture Button
GUICtrlCreateTabItem("")
$Button6 = GUICtrlCreateButton("Screen Capture", 487, 0, 100, 20)
GUICtrlSetTip(-1, "Screen Capture")
$Button7 = GUICtrlCreateButton("ShaggyZE's Site", 780, 0, 100, 20)
GUICtrlSetTip(-1, "http://shaggyze.uotiara.com")
;========================================================
;Main Program Start
If $useitems = 1 Then
	GUICtrlSetState($dirCHK[0], $GUI_ENABLE)
	GUICtrlSetState($listview, $GUI_ENABLE)
Else
	GUICtrlSetState($dirCHK[0], $GUI_DISABLE)
	GUICtrlSetState($listview, $GUI_DISABLE)
EndIf
;option to enable/disable GUI transparency
;on
_WinAPI_SetLayeredWindowAttributes($Form1, 0xFFFFFE, 255)
;off
;_WinAPI_SetLayeredWindowAttributes($Form1, 0x000002, 255)
_setValues()
$directory = "Use"
GUISetState(@SW_SHOW)
GUICtrlSetState($listview, $GUI_DISABLE)
_content2()
Scrollbar_Create($Form1, $SB_VERT, 1000)
$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
Scrollbar_Step(0, $Form1, $SB_VERT)
_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $ESB_DISABLE_BOTH)
$packed = IniRead("config.ini", "Settings", "packed", "0")
If $packed = 0 Or "" Then
	MsgBox(0, "AutoBot v" & $version, "Please be sure to apply mods with data packer or logue's mabipacker before starting Mabinogi.")
	IniWrite("config.ini", "Settings", "packed", "1")
EndIf
$tolerance = $tolerance2
;========================================================
;Main Program Loop
While 1
	$nMsg = GUIGetMsg()

	Switch $nMsg


		;========================================================
		;Close 'X' Button
		Case $GUI_EVENT_CLOSE
			Exit (20)
			;========================================================
			;Fossil Restoration
		Case $ButtonS[0]
			SoundPlay("")
			GUISetState(@SW_HIDE)
			$Mode = "Restoration"
			IniWrite("config.ini", "Settings", "fossilxoffset", GUICtrlRead($fossilxoffsetINP))
			IniWrite("config.ini", "Settings", "fossilyoffset", GUICtrlRead($fossilyoffsetINP))
			_startUp()
			While $Mode = "Restoration"
				If $usefossil = 1 Then
					If _restore() = 1 Then Sleep($pause)
				EndIf
				;_logCheck()
				;_deathCheck()
				_hideWindows()
				If $autoscan = 1 Then
					If $useitems = 1 Then
						If _useItem() = 1 And $usefossil = 1 Then
							If _restore() = 1 Then Sleep($pause)
						EndIf
					Else
						If _restore() = 1 Then Sleep($pause)
					EndIf
				EndIf
			WEnd
			;========================================================
		Case $ButtonS[1]
			SoundPlay("")
			GUISetState(@SW_HIDE)
			$Mode = "Mining"
			_startUp()
			While $Mode = "Mining"
				_logCheck()
				_deathCheck()
				Send("{ESC}")
				If $twoslots = 1 Then _switchWeapon()
				_hideWindows()
				Sleep($delay)
				If $usemover = 0 Then _forceMover()
				_nameSearch($hitcount, $hitdelay, 0, 0)
				If $summonpet = 1 Then
					If ProcessExists("summonPet.exe") = False Then Run("summonPet.exe", @ScriptDir)
				EndIf
				Sleep($longestdelay)
				_findItems()
				If $useitems = 1 Then
					If $founditems >= 1 Then
						If _useItem() = 1 And $usefossil = 1 Then
							If _restore() = 1 Then Sleep($pause)
						EndIf
						_closeItems()
					EndIf
				EndIf
			WEnd
			;========================================================
		Case $ButtonS[2]
			SoundPlay("")
			GUISetState(@SW_HIDE)
			$Mode = "Gathering"
			_startUp()
			While $Mode = "Gathering"
				;_showWindows()
				_logCheck()
				_deathCheck()
				_hideWindows()
				If $twoslots = 1 Then _switchWeapon()
				_nameSearch($hitcount, $hitdelay, 0, 0)
				If $summonpet = 1 Then
					If ProcessExists("summonPet.exe") = False Then Run("summonPet.exe", @ScriptDir)
				EndIf
				Sleep($longestdelay)
				Sleep($longestdelay)
				_findItems()
				_useMover()
			WEnd
			;========================================================
		Case $ButtonS[3]
			SoundPlay("")
			GUISetState(@SW_HIDE)
			$Mode = "Metallurgy"
			IniWrite("metallurgy.ini", "Settings", "metalxoffset", GUICtrlRead($metalxoffsetINP))
			IniWrite("metallurgy.ini", "Settings", "metalyoffset", GUICtrlRead($metalyoffsetINP))
			_startUp()
			While $Mode = "Metallurgy"
				$finditems = 1
				$notdetected = 0
				_logCheck()
				_deathCheck()
				_hideWindows()
				If $swapsieves = 1 Then Send("{ESC}")
				_findItems()
				If $twoslots = 1 Then _switchWeapon()
				_useSkill($firstskill, $skilldelay, $skilluses)
				If $swapsieves = 0 Or $swapsieves = 4 Then
					$notdetected = $notdetected + 1
					If _nameSearch($hitcount, $hitdelay, $metalxoffset, $metalyoffset, $tolerance3) = 1 Then
						$notdetected = 0
						;_hideWindows()
					Else
						Do
							$notdetected = $notdetected + 1
							Sleep($delay)
						Until $notdetected >= 5
					EndIf
				ElseIf $swapsieves = 1 Then
					If _metallurgyLoaded() = 1 Then
						Do
							;_showWindows()
							$notdetected = $notdetected + 1
							If _nameSearch($hitcount, $hitdelay, $metalxoffset, $metalyoffset, $tolerance3) = 1 Then
								$notdetected = 0
								;_hideWindows()
							Else
								Do
									$notdetected = $notdetected + 1
									Sleep($delay)
								Until $notdetected >= 5
							EndIf
						Until _metallurgyLoaded() = 0
					Else
						;_showWindows()
						If $summonpet = 1 Then
							If ProcessExists("summonPet.exe") = False Then Run("summonPet.exe", @ScriptDir)
						EndIf
						_openItems()
						Sleep($longdelay)
						If _brokenCheck() = 1 Then
							_equip()
							_dropItems()
						EndIf
					EndIf
				EndIf
			WEnd
			;========================================================
		Case $ButtonS[4]
			SoundPlay("")
			GUISetState(@SW_HIDE)
			$Mode = "Fight"
			IniWrite($configini, "Skill Settings", "useskill", GUICtrlRead($useskillCHK))
			IniWrite($configini, "Skill Settings", "firstskill", "|" & GUICtrlRead($useskillhotkeyINP[1]) & "|")
			IniWrite($configini, "Skill Settings", "skilluses", GUICtrlRead($useskillusesINP))
			IniWrite($configini, "Skill Settings", "skilldelay", GUICtrlRead($useskilldelayINP))

			IniWrite($configini, "Skill Settings", "useskill2", GUICtrlRead($useskill2CHK))
			IniWrite($configini, "Skill Settings", "secondskill", "|" & GUICtrlRead($useskillhotkey2INP) & "|")
			IniWrite($configini, "Skill Settings", "skill2uses", GUICtrlRead($useskilluses2INP))
			IniWrite($configini, "Skill Settings", "skill2delay", GUICtrlRead($useskilldelay2INP))

			IniWrite($configini, "Skill Settings", "useskill3", GUICtrlRead($useskill3CHK))
			IniWrite($configini, "Skill Settings", "thirdskill", "|" & GUICtrlRead($useskillhotkey3INP) & "|")
			IniWrite($configini, "Skill Settings", "skill3uses", GUICtrlRead($useskilluses3INP))
			IniWrite($configini, "Skill Settings", "skill3delay", GUICtrlRead($useskilldelay3INP))

			IniWrite($configini, "Skill Settings", "selfclick", GUICtrlRead($selfclickCHK))
			IniWrite($configini, "Skill Settings", "selfclickafter", GUICtrlRead($selfclickCMB))

			IniWrite($configini, "Skill Settings", "selfclickafter", GUICtrlRead($selfclickCMB))
			IniWrite($configini, "Skill Settings", "selfclickuses", GUICtrlRead($selfclickusesINP))
			IniWrite($configini, "Skill Settings", "selfclickdelay", GUICtrlRead($selfclickdelayINP))

			IniWrite($configini, "Skill Settings", "centerclick", GUICtrlRead($centerclickCHK))
			IniWrite($configini, "Skill Settings", "centerclickafter", GUICtrlRead($centerclickCMB))

			IniWrite($configini, "Skill Settings", "centerclickafter", GUICtrlRead($centerclickCMB))
			IniWrite($configini, "Skill Settings", "centerclickuses", GUICtrlRead($centerclickusesINP))
			IniWrite($configini, "Skill Settings", "centerclickdelay", GUICtrlRead($centerclickdelayINP))

			IniWrite($configini, "Skill Settings", "centerxoffset", GUICtrlRead($centerxoffsetINP))
			IniWrite($configini, "Skill Settings", "centeryoffset", GUICtrlRead($centeryoffsetINP))
			_startUp()
			While $Mode = "Fight"
				;_logCheck()
				_deathCheck()
				_dropItems()
				Sleep($shortdelay)
				If $twoslots = 1 Then _switchWeapon()
				;_hideWindows()
				If $useskill = 1 Then
				_useSkill($firstskill, $skilldelay, $skilluses)
				If $selfclickafter = "First Skill" And $selfclick = 1 Then _selfClick($selfclickuses, $selfclickdelay, 1, 0, 0)
				If $centerclickafter = "First Skill" And $centerclick = 1 Then _selfClick($centerclickuses, $centerclickdelay, 0, $centerxoffset, $centeryoffset)
				If $CancelSkill1 = "1" Then
					Send("{ESC}")
					Sleep($shortestdelay)
				EndIf
				If $attackanything = 1 Then
					_attackAnything($2xCtrlClickSkill1)
					Sleep($delay)
					If $summonpet = 1 Then
						;If ProcessExists("summonPet.exe") = False Then Run("summonPet.exe", @ScriptDir)
					EndIf
					;Sleep($longestdelay)
				ElseIf $mobsearch = 1 And _mobSearch() = 1 Then
					If $summonpet = 1 Then
						;If ProcessExists("summonPet.exe") = False Then Run("summonPet.exe", @ScriptDir)
					EndIf
					;Sleep($longestdelay)
				EndIf
				EndIf
				If $useskill2 = 1 Then
				_useSkill($secondskill, $skill2delay, $skill2uses)
				If $selfclickafter = "Second Skill" And $selfclick = 1 Then _selfClick($selfclickuses, $selfclickdelay, 1, 0, 0)
				If $centerclickafter = "Second Skill" And $centerclick = 1 Then _selfClick($centerclickuses, $centerclickdelay, 0, $centerxoffset, $centeryoffset)
				If $CancelSkill2 = "1" Then
					Send("{ESC}")
					Sleep($shortestdelay)
				EndIf
				If $attackanything = 1 Then
					_attackAnything($2xCtrlClickSkill2)
					Sleep($delay)
					If $summonpet = 1 Then
						;If ProcessExists("summonPet.exe") = False Then Run("summonPet.exe", @ScriptDir)
					EndIf
					;Sleep($longestdelay)
				ElseIf $mobsearch = 1 And _mobSearch() = 1 Then
					If $summonpet = 1 Then
						;If ProcessExists("summonPet.exe") = False Then Run("summonPet.exe", @ScriptDir)
					EndIf
					;Sleep($longestdelay)
				EndIf
				EndIf
				If $useskill3 = 1 Then
				_useSkill($thirdskill, $skill3delay, $skill3uses)
				If $selfclickafter = "Third Skill" And $selfclick = 1 Then _selfClick($selfclickuses, $selfclickdelay, 1, 0, 0)
				If $centerclickafter = "Third Skill" And $centerclick = 1 Then _selfClick($centerclickuses, $centerclickdelay, 0, $centerxoffset, $centeryoffset)
				If $CancelSkill3 = "1" Then
					Send("{ESC}")
					Sleep($shortestdelay)
				EndIf
				If $attackanything = 1 Then
					_attackAnything($2xCtrlClickSkill3)
					Sleep($delay)
					If $summonpet = 1 Then
						;If ProcessExists("summonPet.exe") = False Then Run("summonPet.exe", @ScriptDir)
					EndIf
					;Sleep($longestdelay)
				ElseIf $mobsearch = 1 And _mobSearch() = 1 Then
					If $summonpet = 1 Then
						;If ProcessExists("summonPet.exe") = False Then Run("summonPet.exe", @ScriptDir)
					EndIf
					;Sleep($longestdelay)
				EndIf
				EndIF
				_findItems()
			WEnd
			;========================================================
		Case $ButtonS[5]
			SoundPlay("")
			GUISetState(@SW_HIDE)
			$Mode = "Clicker"
			IniWrite("clicker.ini", "Settings", "clickdelay", GUICtrlRead($clickdelayINP))
			IniWrite("clicker.ini", "Settings", "clickloopdelay", GUICtrlRead($clickloopdelayINP))
			IniWrite("clicker.ini", "Settings", "clickcount", GUICtrlRead($clickcountINP))
			_startUp()
			For $quantity0 = 5 To 1 Step -1
				ToolTip("starting in " & $quantity0, 0, @DesktopHeight - 20)
				Sleep(1000)
				If Not $Mode = "Clicker" Then ExitLoop 1
			Next
			Local $mouseorigin = MouseGetPos()
			While $Mode = "Clicker"
				$tolerance = $tolerance2
				If GUICtrlRead($mousemodeCMB) = "Current" Then
					$hotkey = GUICtrlRead($hotkeyINP)
					If Not $hotkey = "" Then Send("{" & $hotkey & "}")
					For $quantity = 0 To $clickcount - 1 Step 1
						If $holdalt = "1" Then Send("{ALTDOWN}")
						If $holdctrl = "1" Then Send("{CTRLDOWN}")
						ToolTip("Click " & $quantity + 1 & " of " & $clickcount & " Delay = " & $clickdelay, 0, @DesktopHeight - 20)
						MouseClick("Left", $mouseorigin[0], $mouseorigin[1])
						Sleep($clickdelay)
						$mouseorigin = MouseGetPos()
						If Not $Mode = "Clicker" Or Not GUICtrlRead($mousemodeCMB) = "Current" Then ExitLoop 2
					Next
					For $quantity1 = $clickloopdelay To 0 Step -1000
						ToolTip("Click " & $quantity & " of " & $clickcount & " Delay = " & $quantity1, 0, @DesktopHeight - 20)
						Sleep($shortestdelay)
						If Not $Mode = "Clicker" Or Not GUICtrlRead($mousemodeCMB) = "Current" Then ExitLoop 2
					Next
					_cleanUp()
				ElseIf GUICtrlRead($mousemodeCMB) = "Image" Then
					$hotkey = GUICtrlRead($hotkeyINP)
					If Not $hotkey = "" Then Send("{" & $hotkey & "}")
					If $clickerimage = "" Then IniWrite("clicker.ini", "Settings", "clickimage", "firewood.bmp")
					$clickerimage = IniRead("clicker.ini", "Settings", "clickimage", "firewood.bmp")
						If $holdalt = "1" Then Send("{ALTDOWN}")
						If $holdctrl = "1" Then Send("{CTRLDOWN}")
					Sleep($delay)
					$result = _ImageSearch(@ScriptDir & "\Find\Images\clicker\" & $clickerimage, 1, $x1, $y1, $tolerance)
					ToolTip("Found " & $clickerimage & " at " & $x1 & " x " & $y1, 0, @DesktopHeight - 20)
					If $result = 1 Then
						For $quantity = 0 To $clickcount - 1 Step 1
							Sleep($delay)
							$result = _ImageSearch(@ScriptDir & "\Find\Images\clicker\" & $clickerimage, 1, $x1, $y1, $tolerance)
							If $result = 1 Then
								ToolTip("Click " & $quantity + 1 & " of " & $clickcount & " Delay = " & $clickdelay, 0, @DesktopHeight - 20)
								MouseClick("Left", $x1, $y1)
								Sleep($clickdelay)
							EndIf
							_cleanUp()
							MouseMove($mouseorigin[0], $mouseorigin[1])
							If Not $Mode = "Clicker" Or Not GUICtrlRead($mousemodeCMB) = "Image" Then ExitLoop 2
						Next
						For $quantity1 = $clickloopdelay To 0 Step -1000
							ToolTip("Click " & $quantity & " of " & $clickcount & " Delay = " & $quantity1, 0, @DesktopHeight - 20)
							Sleep($shortestdelay)
							If Not $Mode = "Clicker" Or Not GUICtrlRead($mousemodeCMB) = "Image" Then ExitLoop 2
						Next
					Else
						_cleanUp()
						MouseMove($mouseorigin[0], $mouseorigin[1])
					EndIf
				ElseIf GUICtrlRead($mousemodeCMB) = "Images" Then
					;sleep($clickdelay)
					Send("{ALTDOWN}")
					;sleep($longdelay)
					;_setSearchCoords($boxarea)
					;$result = _ImageSearchArea(@ScriptDir & "\Find\Images\item\" & $file[$i],1,$searchbox[0],$s_cleanUp()
					$result = _ImageSearch(@ScriptDir & "\Find\Images\clicker\" & $clickerimage, 1, $x1, $y1, $tolerance)
					ToolTip($clickerimage & " = " & $result & " Delay = " & $clickdelay, 0, @DesktopHeight - 20)
					If $result = 1 Then
						If $questnumb = 0 Or $questnumb = 1 Then
							Local $mouseorigin = MouseGetPos()
							;$result = _ImageSearch(@ScriptDir & "\Find\Images\clicker\" & $clickerimage2,1,$x1,$y1,$tolerance)
							;tooltip($clickerimage2 & " = " & $result & " Delay = " & $clickdelay,0,@desktopheight-20)
							;	If $result=1 Then
							;_cleanUp()
							;		_target($x1,$y1)
							If $questnumr = 2 Then
								_target($mouseorigin[0] - 100, $mouseorigin[1])
								$questnumr = 1
							Else
								_target($mouseorigin[0] - 50, $mouseorigin[1])
								$questnumb = 2
							EndIf
							MouseClick("Left")
							Sleep($shortestdelay)
							MouseMove($mouseorigin[0], $mouseorigin[1], 1)
							;	Else
									_cleanUp()
							;	EndIf
						Else
							_cleanUp()
							;MouseMove($mouseorigin[0],$mouseorigin[1],1)
							MouseClick("Left")
						EndIf
					Else
						If $questnumr = 0 Or $questnumr = 1 Then
							Local $mouseorigin = MouseGetPos()
							;$result = _ImageSearch(@ScriptDir & "\Find\Images\clicker\" & $clickerimage3,1,$x1,$y1,$tolerance)
							;tooltip($clickerimage3 & " = " & $result & " Delay = " & $clickdelay,0,@desktopheight-20)
							;	If $result=1 Then
							_cleanUp()
							;		_target($x1,$y1)
							If $questnumb = 2 Then
								_target($mouseorigin[0] + 100, $mouseorigin[1])
								$questnumb = 1
							Else
								_target($mouseorigin[0] + 50, $mouseorigin[1])
								$questnumr = 2
							EndIf
							MouseClick("Left")
							Sleep($shortestdelay)
							MouseMove($mouseorigin[0], $mouseorigin[1], 1)
							;	Else
									_cleanUp()
							;	EndIf
						Else

							;MouseMove($mouseorigin[0],$mouseorigin[1],1)
							MouseClick("Left")
						EndIf
					EndIf
				ElseIf GUICtrlRead($mousemodeCMB) = "Static X/Y" Then

				EndIf
			WEnd
			;========================================================
			;Case $ButtonS[6]
			;GUISetState(@SW_MINIMIZE)
			;If ProcessExists("Client.exe")=false and ProcessExists("Mabinogi.exe")=false Then Run($MabiPath & "\Mabinogi.exe",$MabiPath & "\",@SW_SHOWDEFAULT)
			;========================================================
		Case $ButtonS[7]
			;GUISetState(@SW_MINIMIZE)
			Run ( "notepad.exe " & $MabiPath & "\AutoBot\config.ini", @WindowsDir, @SW_SHOWDEFAULT )
			;========================================================
		;Case $ButtonS[8]
			;GUISetState(@SW_MINIMIZE)
			;If ProcessExists("Client.exe") = False And ProcessExists("DATA packer.exe") = False Then Run($MabiPath & "\DATA packer.exe", $MabiPath & "\", @SW_SHOWDEFAULT)
			;If ProcessExists("Client.exe")=false Then
			;Runwait (FileGetShortName($mabipath & "\UOTiaraDataPack.bat"),$MabiPath)
			;GUISetState(@SW_RESTORE)
			;endif
			;========================================================
		Case $Button6
			GUISetState(@SW_MINIMIZE)
			If Not ProcessExists("Screen Capture.exe") Then Run(FileGetShortName(@ScriptDir & "\Screen Capture.exe", @ScriptDir))
			;If Not ProcessExists("Screen Capture.exe") Then
			;Runwait (FileGetShortName(@ScriptDir & "\Screen Capture.exe",@ScriptDir))
			;GUISetState(@SW_RESTORE)
			;endif
			;========================================================
		Case $Button7
			$IE = _IECreate("http://shaggyze.uotiara.com")
			;========================================================
		Case $autoscanCHK[0]
			IniWrite($configini, "Fossil Settings", "autoscan", GUICtrlRead($autoscanCHK[0]))
		Case $autoscanCHK[1]
			IniWrite($configini, "Fossil Settings", "autoscan", GUICtrlRead($autoscanCHK[1]))
			;========================================================
		Case $completefossilCHK[0]
			IniWrite($configini, "Fossil Settings", "completefossil", GUICtrlRead($completefossilCHK[0]))
		Case $completefossilCHK[1]
			IniWrite($configini, "Fossil Settings", "completefossil", GUICtrlRead($completefossilCHK[1]))
			;========================================================
		Case $finditemsCHK[0]
			IniWrite($configini, "Settings", "finditems", GUICtrlRead($finditemsCHK[0]))
		Case $finditemsCHK[1]
			IniWrite($configini, "Settings", "finditems", GUICtrlRead($finditemsCHK[1]))
			;Case $finditemsCHK[2]
			;IniWrite($configini,"Settings","finditems",GUICtrlRead($finditemsCHK[2]))
		Case $finditemsCHK[3]
			IniWrite($configini, "Settings", "finditems", GUICtrlRead($finditemsCHK[3]))
			;========================================================
		Case $fullscreenRDO[0]
			$boxarea = "fullscreen"
			IniWrite($configini, "Settings", "boxarea", "fullscreen")
		Case $fullscreenRDO[1]
			$boxarea = "fullscreen"
			IniWrite($configini, "Settings", "boxarea", "fullscreen")
		Case $fullscreenRDO[2]
			$boxarea = "fullscreen"
			IniWrite($configini, "Settings", "boxarea", "fullscreen")
		Case $fullscreenRDO[3]
			$boxarea = "fullscreen"
			IniWrite($configini, "Settings", "boxarea", "fullscreen")
			;========================================================
		Case $centerscreenRDO[0]
			$boxarea = "center"
			IniWrite($configini, "Settings", "boxarea", "center")
		Case $centerscreenRDO[1]
			$boxarea = "center"
			IniWrite($configini, "Settings", "boxarea", "center")
		Case $centerscreenRDO[2]
			$boxarea = "center"
			IniWrite($configini, "Settings", "boxarea", "center")
		Case $centerscreenRDO[3]
			$boxarea = "center"
			IniWrite($configini, "Settings", "boxarea", "center")
			;========================================================
		Case $fullcenterscreenRDO[0]
			$boxarea = "centerfull"
			IniWrite($configini, "Settings", "boxarea", "centerfull")
		Case $fullcenterscreenRDO[1]
			$boxarea = "centerfull"
			IniWrite($configini, "Settings", "boxarea", "centerfull")
		Case $fullcenterscreenRDO[2]
			$boxarea = "centerfull"
			IniWrite($configini, "Settings", "boxarea", "centerfull")
		Case $fullcenterscreenRDO[3]
			$boxarea = "centerfull"
			IniWrite($configini, "Settings", "boxarea", "centerfull")
			;========================================================
		Case $useitemsCHK[0]
			IniWrite($configini, "Settings", "useitems", GUICtrlRead($useitemsCHK[0]))
			If GUICtrlRead($useitemsCHK[0]) = 1 Then
				GUICtrlSetState($dirCHK[0], $GUI_ENABLE)
				GUICtrlSetState($listview, $GUI_ENABLE)
			Else
				GUICtrlSetState($dirCHK[0], $GUI_DISABLE)
				GUICtrlSetState($listview, $GUI_DISABLE)
			EndIf
		Case $useitemsCHK[1]
			IniWrite($configini, "Settings", "useitems", GUICtrlRead($useitemsCHK[1]))
		Case $useitemsCHK[2]
			IniWrite($configini, "Settings", "useitems", GUICtrlRead($useitemsCHK[2]))
		Case $useitemsCHK[3]
			IniWrite($configini, "Settings", "useitems", GUICtrlRead($useitemsCHK[3]))
		Case $useitemsCHK[4]
			IniWrite($configini, "Settings", "useitems", GUICtrlRead($useitemsCHK[4]))
			;========================================================
		Case $dropitemsCHK
			IniWrite("fight.ini", "Settings", "dropitems", GUICtrlRead($dropitemsCHK))
			IniWrite("fight.ini", "Settings", "dropxoffset", GUICtrlRead($dropxoffsetINP))
			IniWrite("fight.ini", "Settings", "dropyoffset", GUICtrlRead($dropyoffsetINP))
			;========================================================
		Case $holdaltCHK
			IniWrite("clicker.ini", "Settings", "holdalt", GUICtrlRead($holdaltCHK))
		Case $holdctrlCHK
			IniWrite("clicker.ini", "Settings", "holdctrl", GUICtrlRead($holdctrlCHK))
			;========================================================
		Case $hidewindowsCHK[0]
			IniWrite($configini, "Settings", "hidewindows", GUICtrlRead($hidewindowsCHK[0]))
		Case $hidewindowsCHK[1]
			IniWrite($configini, "Settings", "hidewindows", GUICtrlRead($hidewindowsCHK[1]))
		Case $hidewindowsCHK[2]
			IniWrite($configini, "Settings", "hidewindows", GUICtrlRead($hidewindowsCHK[2]))
		Case $hidewindowsCHK[3]
			IniWrite($configini, "Settings", "hidewindows", GUICtrlRead($hidewindowsCHK[3]))
		Case $hidewindowsCHK[4]
			IniWrite($configini, "Settings", "hidewindows", GUICtrlRead($hidewindowsCHK[4]))
			;========================================================
		Case $closewindowsCHK[0]
			IniWrite($configini, "Settings", "closewindows", GUICtrlRead($closewindowsCHK[0]))
		Case $closewindowsCHK[1]
			IniWrite($configini, "Settings", "closewindows", GUICtrlRead($closewindowsCHK[1]))
		Case $closewindowsCHK[2]
			IniWrite($configini, "Settings", "closewindows", GUICtrlRead($closewindowsCHK[2]))
		Case $closewindowsCHK[3]
			IniWrite($configini, "Settings", "closewindows", GUICtrlRead($closewindowsCHK[3]))
		Case $closewindowsCHK[4]
			IniWrite($configini, "Settings", "closewindows", GUICtrlRead($closewindowsCHK[4]))
			;========================================================
		Case $twoslotsCHK[0]
			IniWrite($configini, "Settings", "twoslots", GUICtrlRead($twoslotsCHK[0]))
		Case $twoslotsCHK[1]
			IniWrite($configini, "Settings", "twoslots", GUICtrlRead($twoslotsCHK[1]))
		Case $twoslotsCHK[2]
			IniWrite($configini, "Settings", "twoslots", GUICtrlRead($twoslotsCHK[2]))
		Case $twoslotsCHK[3]
			IniWrite($configini, "Settings", "twoslots", GUICtrlRead($twoslotsCHK[3]))
			;========================================================
		Case $deathCHK[0]
			IniWrite($configini, "Settings", "deathcheck", GUICtrlRead($deathCHK[0]))
		Case $deathCHK[1]
			IniWrite($configini, "Settings", "deathcheck", GUICtrlRead($deathCHK[1]))
		Case $deathCHK[2]
			IniWrite($configini, "Settings", "deathcheck", GUICtrlRead($deathCHK[2]))
		Case $deathCHK[3]
			IniWrite($configini, "Settings", "deathcheck", GUICtrlRead($deathCHK[3]))
			;========================================================
		Case $mobsearchCHK
			IniWrite($configini, "Settings", "mobsearch", GUICtrlRead($mobsearchCHK))
		Case $attackanythingCHK
			IniWrite($configini, "Settings", "attackanything", GUICtrlRead($attackanythingCHK))
		Case $selfclickCHK
			IniWrite($configini, "Skill Settings", "selfclick", GUICtrlRead($selfclickCHK))
			IniWrite($configini, "Skill Settings", "selfclickafter", GUICtrlRead($selfclickCMB))
		Case $centerclickCHK
			IniWrite($configini, "Skill Settings", "centerclick", GUICtrlRead($centerclickCHK))
			IniWrite($configini, "Skill Settings", "centerclickafter", GUICtrlRead($centerclickCMB))
			IniWrite($configini, "Skill Settings", "centerxoffset", GUICtrlRead($centerxoffsetINP))
			IniWrite($configini, "Skill Settings", "centeryoffset", GUICtrlRead($centeryoffsetINP))
		Case $selfclickCMB
			IniWrite($configini, "Skill Settings", "selfclickafter", GUICtrlRead($selfclickCMB))
			IniWrite($configini, "Skill Settings", "selfclickuses", GUICtrlRead($selfclickusesINP))
			IniWrite($configini, "Skill Settings", "selfclickdelay", GUICtrlRead($selfclickdelayINP))
			;========================================================
		Case $centerclickCMB
			IniWrite($configini, "Skill Settings", "centerclickafter", GUICtrlRead($centerclickCMB))
			IniWrite($configini, "Skill Settings", "centerclickuses", GUICtrlRead($centerclickusesINP))
			IniWrite($configini, "Skill Settings", "centerclickdelay", GUICtrlRead($centerclickdelayINP))
			;========================================================
		Case $useskillCHK
			IniWrite($configini, "Skill Settings", "useskill", GUICtrlRead($useskillCHK))
			IniWrite($configini, "Skill Settings", "firstskill", "|" & GUICtrlRead($useskillhotkeyINP[1]) & "|")
			IniWrite($configini, "Skill Settings", "skilluses", GUICtrlRead($useskillusesINP))
			IniWrite($configini, "Skill Settings", "skilldelay", GUICtrlRead($useskilldelayINP))
		Case $useskill2CHK
			IniWrite($configini, "Skill Settings", "useskill2", GUICtrlRead($useskill2CHK))
			IniWrite($configini, "Skill Settings", "secondskill", "|" & GUICtrlRead($useskillhotkey2INP) & "|")
			IniWrite($configini, "Skill Settings", "skill2uses", GUICtrlRead($useskilluses2INP))
			IniWrite($configini, "Skill Settings", "skill2delay", GUICtrlRead($useskilldelay2INP))
		Case $useskill3CHK
			IniWrite($configini, "Skill Settings", "useskill3", GUICtrlRead($useskill3CHK))
			IniWrite($configini, "Skill Settings", "thirdskill", "|" & GUICtrlRead($useskillhotkey3INP) & "|")
			IniWrite($configini, "Skill Settings", "skill3uses", GUICtrlRead($useskilluses3INP))
			IniWrite($configini, "Skill Settings", "skill3delay", GUICtrlRead($useskilldelay3INP))
			;========================================================
		Case $items[1] To $items[_GUICtrlListView_GetItemCount($listview)]
			If Not $Mode = "" Then
				If Not $Mode = "Frontend" Then
					$Files = StringSplit(GUICtrlRead($items[_GUICtrlListView_GetSelectedIndices($listview) + 1]), "|")
					$File1 = StringReplace($Files[1], ".bmp", "")
					$File2 = StringTrimRight($File1, 1)
					$File3 = StringReplace($File1, $File2, "")
					If _hasNum($File3) = False Then
						$Status = IniRead($configini, $directory & " List", $File3, "0")
						If $Status = 1 Then
							IniWrite($configini, $directory & " List", $File3, 0)
							GUICtrlSetData($items[_GUICtrlListView_GetSelectedIndices($listview) + 1], $Files[1] & "|0|" & $File3)
						Else
							IniWrite($configini, $directory & " List", $File3, 1)
							GUICtrlSetData($items[_GUICtrlListView_GetSelectedIndices($listview) + 1], $Files[1] & "|1|" & $File3)
						EndIf
					EndIf
				EndIf
			EndIf
			;========================================================
		Case $listviewContextItem
			$Files = StringSplit(GUICtrlRead($items[_GUICtrlListView_GetSelectedIndices($listview) + 1]), "|")
			$File1 = StringReplace($Files[1], ".bmp", "")
			$File2 = StringTrimRight($File1, 1)
			$File3 = StringReplace($File1, $File2, "")
			If _hasNum($File3) = False Then
				$Status = IniRead($configini, $directory & " List", $Files[3], "0")
				If $Status = 1 Then
					IniWrite($configini, $directory & " List", $Files[3], 0)
					GUICtrlSetData($items[_GUICtrlListView_GetSelectedIndices($listview) + 1], $Files[1] & "|0|" & $Files[3])
				Else
					IniWrite($configini, $directory & " List", $Files[3], 1)
					GUICtrlSetData($items[_GUICtrlListView_GetSelectedIndices($listview) + 1], $Files[1] & "|1|" & $Files[3])
				EndIf
			EndIf
			;========================================================
		Case $listviewContextItem1
			Local $FSelected, $SelFiles
			$SelFiles = _GUICtrlListView_GetSelectedIndices($listview1, 1)
			For $FSelected = 1 To UBound($SelFiles) - 1
				;msgbox(0,"",$SelFiles[0] & " " & $SelFiles[$FSelected]+1)
				$Files1 = StringSplit(GUICtrlRead($items1[$SelFiles[$FSelected] + 1]), "|")
				$ModStatus = IniRead($MabiDir & "AutoBot\Frontend.ini", "Settings", $SelFiles[$FSelected] + 1, "0")
				$File_Name1 = IniRead($MabiDir & "AutoBot\Frontend.ini", "File List", $SelFiles[$FSelected] + 1, "")
				$MabiDir = IniRead($MabiDir & "AutoBot\Frontend.ini", "Settings", "MabiDir", "")

				If FileExists($MabiDir & $File_Name1) = True Or FileExists($MabiDir & $File_Name1 & ".off") = True Then
					If $ModStatus = "1" Then
						$ModStatus = "Disabled"
						IniWrite($MabiDir & "AutoBot\Frontend.ini", "Settings", $SelFiles[$FSelected] + 1, 0)
						GUICtrlSetData($items1[$SelFiles[$FSelected] + 1], $Files1[1] & "|Disabled|" & $File_Name1 & ".off")
						If FileExists($MabiDir & $File_Name1) = True And FileExists($MabiDir & $File_Name1 & ".off") = True Then
							FileDelete($MabiDir & $File_Name1 & ".off")
						EndIf
						If FileExists($MabiDir & $File_Name1) = True Then FileMove($MabiDir & $File_Name1, $MabiDir & $File_Name1 & ".off")
					Else
						$ModStatus = "Enabled"
						IniWrite($MabiDir & "AutoBot\Frontend.ini", "Settings", $SelFiles[$FSelected] + 1, 1)
						GUICtrlSetData($items1[$SelFiles[$FSelected] + 1], $Files1[1] & "|Enabled|" & $File_Name1)
						If FileExists($MabiDir & $File_Name1) = True And FileExists($MabiDir & $File_Name1 & ".off") = True Then
							FileDelete($MabiDir & $File_Name1)
						EndIf
						If FileExists($MabiDir & $File_Name1 & ".off") = True Then FileMove($MabiDir & $File_Name1 & ".off", $MabiDir & $File_Name1)
					EndIf
				Else
					IniWrite($MabiDir & "AutoBot\Frontend.ini", "Settings", $SelFiles[$FSelected] + 1, 0)
					GUICtrlSetData($items1[$SelFiles[$FSelected] + 1], $Files1[1] & "|Disabled|" & "Not Found")
				EndIf
			Next
			;========================================================
		Case $dirCHK[0]
			$directory = GUICtrlRead($dirCHK[0])
			_content(GUICtrlRead($dirCHK[0]))
		Case $dirCHK[1]
			$directory = GUICtrlRead($dirCHK[1])
			_content(GUICtrlRead($dirCHK[1]))
		Case $dirCHK[2]
			$directory = GUICtrlRead($dirCHK[2])
			_content(GUICtrlRead($dirCHK[2]))
		Case $dirCHK[3]
			$directory = GUICtrlRead($dirCHK[3])
			_content(GUICtrlRead($dirCHK[3]))
		Case $dirCHK[4]
			$directory = GUICtrlRead($dirCHK[4], 3)
			_content(GUICtrlRead($dirCHK[4]))
			;========================================================
		Case $findpropsCHK
			IniWrite($configini, "Settings", "findprops", GUICtrlRead($findpropsCHK))
		Case $usemoverCHK[1]
			IniWrite("Mining.ini", "Settings", "usemover", GUICtrlRead($usemoverCHK))
		Case $usemoverCHK[2]
			IniWrite("Gathering.ini", "Settings", "usemover", GUICtrlRead($usemoverCHK))
			;========================================================
		Case $toleranceSLD[0]
			GUICtrlSetData($tolerancelbl1, "Tolerance 1 = " & GUICtrlRead($toleranceSLD[0]))
			IniWrite("config.ini", "Settings", "tolerance1", GUICtrlRead($toleranceSLD[0]))
		Case $toleranceSLD[1]
			GUICtrlSetData($tolerancelbl2, "Tolerance 2 = " & GUICtrlRead($toleranceSLD[1]))
			IniWrite("config.ini", "Settings", "tolerance2", GUICtrlRead($toleranceSLD[1]))
		Case $toleranceSLD[2]
			GUICtrlSetData($tolerancelbl3, "Tolerance 3 = " & GUICtrlRead($toleranceSLD[2]))
			IniWrite("config.ini", "Settings", "tolerance3", GUICtrlRead($toleranceSLD[2]))
			;========================================================
		Case $hitcountINP
			IniWrite($configini, "Settings", "hitcount", GUICtrlRead($hitcountINP))
			;========================================================
		Case $hitdelayINP
			IniWrite($configini, "Settings", "hitdelay", GUICtrlRead($hitdelayINP))
			;========================================================
		Case $swapCHK
			IniWrite($configini, "Settings", "swapsieves", GUICtrlRead($swapCHK))
			;========================================================
		Case $checkupdateCHK
			IniWrite("config.ini", "Settings", "checkupdate", GUICtrlRead($checkupdateCHK))
			;========================================================
		Case $useskillhotkeyBTN
			IniWrite($configini, "Skill Settings", "firstskill", "|" & GUICtrlRead($useskillhotkeyINP[0]) & "|")
			;========================================================
		Case $searchmodeCHK
			IniWrite("config.ini", "Settings", "searchmode", GUICtrlRead($searchmodeCHK))
			;========================================================
		Case $CancelSkill1CHK
			IniWrite($configini, "Skill Settings", "CancelSkill1", GUICtrlRead($CancelSkill1CHK))
		Case $CancelSkill2CHK
			IniWrite($configini, "Skill Settings", "CancelSkill2", GUICtrlRead($CancelSkill2CHK))
		Case $CancelSkill3CHK
			IniWrite($configini, "Skill Settings", "CancelSkill3", GUICtrlRead($CancelSkill3CHK))
			;========================================================
		Case $2xCtrlClickSkill1CHK
			IniWrite($configini, "Skill Settings", "2xCtrlClickSkill1", GUICtrlRead($2xCtrlClickSkill1CHK))
		Case $2xCtrlClickSkill2CHK
			IniWrite($configini, "Skill Settings", "2xCtrlClickSkill2", GUICtrlRead($2xCtrlClickSkill2CHK))
		Case $2xCtrlClickSkill3CHK
			IniWrite($configini, "Skill Settings", "2xCtrlClickSkill3", GUICtrlRead($2xCtrlClickSkill3CHK))
			;========================================================
		Case $MabiPathBTN
			If FileExists(GUICtrlRead($MabiPathINP) & "\Client.exe") = True Then
				RegWrite("HKEY_CURRENT_USER\Software\Nexon\Mabinogi", "", "REG_SZ", GUICtrlRead($MabiPathINP))
			Else
				MsgBox(0, "Error", "Could not find Client.exe in " & GUICtrlRead($MabiPathINP))
			EndIf
		Case $Form1
			;_GUICtrlButton_SetFocus($ButtonS[6],true)
		Case $Tab1
			;_GUICtrlButton_SetFocus($ButtonS[6],true)
			GUICtrlSetState($listview, $GUI_DISABLE)
			;msgbox(0,"Test",guictrlread($Tab1))
			GUICtrlSetData($tolerancelbl1, "")
			GUICtrlSetData($tolerancelbl2, "")
			GUICtrlSetData($tolerancelbl3, "")
			GUICtrlDelete($tolerancelbl1)
			GUICtrlDelete($tolerancelbl2)
			GUICtrlDelete($tolerancelbl3)
			$directory = "Use"
			;if guictrlread($Tab1) = 0 then
			;		GUICtrlDelete($listview1)
			;		GUICtrlDelete($listview)
			;		_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $_SCROLLBARCONSTANTS_ESB_ENABLE_BOTH)
			;		$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
			;		Scrollbar_Step(20, $Form1, $SB_VERT)
			;		$Mode="ZEP"
			;		$configini=$Mode & ".ini"
			;		_readINI()
			;		_setValues()
			If GUICtrlRead($Tab1) = 0 Then
					GUICtrlDelete($listview1)
					GUICtrlDelete($listview)
				$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
				Scrollbar_Step(0, $Form1, $SB_VERT)
				_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $ESB_DISABLE_BOTH)
				GUICtrlSetState($listview, $GUI_ENABLE)
				$configini = "Frontend.ini"
				_content2()
			ElseIf GUICtrlRead($Tab1) = 1 Then
				GUICtrlDelete($listview1)
				GUICtrlSetData($dirCHK[0], $directory)
				$configini = "Restoration.ini"
				$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
				Scrollbar_Step(0, $Form1, $SB_VERT)
				_readINI()
				_makeINILists()
				_setValues()
				_content($directory)
				GUICtrlSetState($listview, $GUI_ENABLE)
				_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $ESB_DISABLE_BOTH)
			ElseIf GUICtrlRead($Tab1) = 2 Then
				GUICtrlDelete($listview1)
				GUICtrlSetData($dirCHK[1], $directory)
				$configini = "Mining.ini"
				$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
				Scrollbar_Step(0, $Form1, $SB_VERT)
				_readINI()
				_makeINILists()
				_setValues()
				_content($directory)
				GUICtrlSetState($listview, $GUI_ENABLE)
				_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $ESB_DISABLE_BOTH)
			ElseIf GUICtrlRead($Tab1) = 3 Then
				GUICtrlDelete($listview1)
				GUICtrlSetData($dirCHK[2], $directory)
				$configini = "Gathering.ini"
				$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
				Scrollbar_Step(0, $Form1, $SB_VERT)
				_readINI()
				_makeINILists()
				_setValues()
				_content($directory)
				GUICtrlSetState($listview, $GUI_ENABLE)
				_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $ESB_DISABLE_BOTH)
			ElseIf GUICtrlRead($Tab1) = 4 Then
				GUICtrlDelete($listview1)
				GUICtrlSetData($dirCHK[3], $directory)
				$configini = "Metallurgy.ini"
				$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
				Scrollbar_Step(0, $Form1, $SB_VERT)
				_readINI()
				_makeINILists()
				_setValues()
				_content($directory)
				GUICtrlSetState($listview, $GUI_ENABLE)
				_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $ESB_DISABLE_BOTH)
			ElseIf GUICtrlRead($Tab1) = 5 Then
				GUICtrlDelete($listview1)
				GUICtrlSetData($dirCHK[4], $directory)
				$configini = "Fight.ini"
				_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $_SCROLLBARCONSTANTS_ESB_ENABLE_BOTH)
				$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
				Scrollbar_Step(20, $Form1, $SB_VERT)
				_readINI()
				_makeINILists()
				_setValues()
				_content($directory)
			ElseIf GUICtrlRead($Tab1) = 6 Then
				GUICtrlDelete($listview1)
				GUICtrlDelete($listview)
				$configini = "Clicker.ini"
				$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
				Scrollbar_Step(0, $Form1, $SB_VERT)
				_readINI()
				_setValues()
				_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $ESB_DISABLE_BOTH)
			ElseIf GUICtrlRead($Tab1) = 7 Then
				GUICtrlDelete($listview1)
				GUICtrlDelete($listview)
				$Mode = ""
				$iScrollPos = Scrollbar_GetPos($Form1, $SB_VERT)
				Scrollbar_Step(0, $Form1, $SB_VERT)
				$tolerancelbl1 = GUICtrlCreateLabel("Tolerance 1 = " & GUICtrlRead($toleranceSLD[0]), 10, 100, 120)
				GUICtrlSetBkColor(-1, $colorhex)
				$tolerancelbl2 = GUICtrlCreateLabel("Tolerance 2 = " & GUICtrlRead($toleranceSLD[1]), 10, 140, 120)
				GUICtrlSetBkColor(-1, $colorhex)
				$tolerancelbl3 = GUICtrlCreateLabel("Tolerance 3 = " & GUICtrlRead($toleranceSLD[2]), 10, 180, 120)
				GUICtrlSetBkColor(-1, $colorhex)
				_GUIScrollBars_EnableScrollBar($Form1, $SB_VERT, $ESB_DISABLE_BOTH)
			EndIf
		Case Else
			;MsgBox(0,"",$nMsg)
	EndSwitch
WEnd
#endregion Main Script
#region Core functions
;=======================================================================================
Func _setValues()
	Local $i2, $i3, $i4, $i5
	$MabiDir = $MabiPath & "\"
	IniWrite($MabiDir & "AutoBot\Frontend.ini", "Settings", "MabiDir", $MabiDir)
	For $n = 1 To IniRead($MabiDir & "AutoBot\Frontend.ini", "Settings", "FileCount", 0)
		$List_Name = IniRead($MabiDir & "AutoBot\Frontend.ini", "List Name", $n, "")
		$ModStatus = IniRead($MabiDir & "AutoBot\Frontend.ini", "Settings", $n, "")
		$File_Name1 = IniRead($MabiDir & "AutoBot\Frontend.ini", "File List", $n, "")
		If Not $File_Name1 = "" Then
			If FileExists($MabiDir & $File_Name1) = True Or FileExists($MabiDir & $File_Name1 & ".off") = True Then
				;if $ModStatus="0" Then
				If FileExists($MabiDir & $File_Name1) = True And FileExists($MabiDir & $File_Name1 & ".off") = True Then
					FileDelete($MabiDir & $File_Name1)
					IniWrite($MabiDir & "AutoBot\Frontend.ini", "Settings", $n, "0")
					;elseif FileExists($MabiDir & $File_Name1& ".off") =false and FileExists($MabiDir & $File_Name1) =true Then
					;filemove($MabiDir & $File_Name1,$MabiDir & $File_Name1 & ".off")
				EndIf
				;elseif $ModStatus="1" Then
				;	if FileExists($MabiDir & $File_Name1) =true and FileExists($MabiDir & $File_Name1 & ".off")=true Then
				;	filedelete($MabiDir & $File_Name1 & ".off")
				;	elseif FileExists($MabiDir & $File_Name1) =false and FileExists($MabiDir & $File_Name1 & ".off")=true Then
				;	filemove($MabiDir & $File_Name1 & ".off",$MabiDir & $File_Name1)
				;EndIF
				;EndIf
			Else
				IniWrite($MabiDir & "AutoBot\Frontend.ini", "Settings", $n, 0)
			EndIf
		EndIf
	Next
	;If FileExists($MabiPath & "\dbghelp.zep")=true Then
	;GUICtrlSetState($Patcher[0],1)
	;else
	;GUICtrlSetState($Patcher[1],1)
	;EndIf
	GUICtrlSetData($THREAD_DELAYINP, $THREAD_DELAY)
	GUICtrlSetState($UseDataFolderCHK, $UseDataFolder)
	GUICtrlSetState($THREAD_PROTECTCHK, $THREAD_PROTECT)
	GUICtrlSetState($THREAD_TARGETCHK, $THREAD_TARGET)
	GUICtrlSetState($Adver2PartyCHK, $Adver2Party)
	GUICtrlSetState($AdverToPartyCHK, $AdverToParty)
	GUICtrlSetState($BlockEndingAdsCHK, $BlockEndingAds)
	GUICtrlSetState($ClearDungeonFogCHK, $ClearDungeonFog)
	If $ControlDayTime = "0" Then
		$ControlDayTime = "off"
	ElseIf $ControlDayTime = "1" Then
		$ControlDayTime = "daylight"
	ElseIf $ControlDayTime = "2" Then
		$ControlDayTime = "night"
	ElseIf $ControlDayTime = "3" Then
		$ControlDayTime = "User Select"
	EndIf
	GUICtrlSetData($ControlDayTimeCMB, $ControlDayTime)
	GUICtrlSetData($TimeOfDayINP, $TimeOfDay)
	GUICtrlSetState($DeadlyHPShowCHK, $DeadlyHPShow)
	GUICtrlSetState($ElfLagCHK, $ElfLag)
	GUICtrlSetState($EnableNameColoringCHK, $EnableNameColoring)
	GUICtrlSetState($EnableSelfRightClickCHK, $EnableSelfRightClick)
	GUICtrlSetState($HotbarAnythingCHK, $HotbarAnything)
	GUICtrlSetState($InfinitePartyTimeCHK, $InfinitePartyTime)
	GUICtrlSetState($ModifyZoomLimitCHK, $ModifyZoomLimit)
	GUICtrlSetData($ZoomDefaultINP, $ZoomDefault)
	GUICtrlSetData($ZoomNearINP, $ZoomNear)
	GUICtrlSetData($ZoomFarINP, $ZoomFar)
	GUICtrlSetState($MoveToSameChannelCHK, $MoveToSameChannel)
	GUICtrlSetState($NaoSoonCHK, $NaoSoon)
	GUICtrlSetState($RemoveLoginDelayCHK, $RemoveLoginDelay)
	GUICtrlSetState($ShowCombatPowerCHK, $ShowCombatPower)
	GUICtrlSetState($ShowItemPriceCHK, $ShowItemPrice)
	GUICtrlSetState($ShowMinutesCHK, $ShowMinutes)
	GUICtrlSetState($ShowTrueDurabilityCHK, $ShowTrueDurability)
	GUICtrlSetState($ShowItemColorCHK, $ShowItemColor)
	GUICtrlSetState($ShowTrueFoodQualityCHK, $ShowTrueFoodQuality)
	GUICtrlSetState($TalkToUnequippedEgoCHK, $TalkToUnequippedEgo)
	GUICtrlSetState($TargetMimicsCHK, $TargetMimics)
	GUICtrlSetState($TargetSulfurGolemCHK, $TargetSulfurGolem)
	GUICtrlSetState($TargetPropsCHK, $TargetProps)
	If $UseBitmapFonts = "0" Then
		$UseBitmapFonts = "off"
	ElseIf $UseBitmapFonts = "1" Then
		$UseBitmapFonts = "Fantasia Bitmap fonts"
	ElseIf $UseBitmapFonts = "2" Then
		$UseBitmapFonts = "Experimental 1"
	ElseIf $UseBitmapFonts = "3" Then
		$UseBitmapFonts = "Experimental 2"
	ElseIf $UseBitmapFonts = "4" Then
		$UseBitmapFonts = "Asia bitmapfonts"
	ElseIf $UseBitmapFonts = "5" Then
		$UseBitmapFonts = "Experimental 3"
	EndIf
	GUICtrlSetData($UseBitmapFontsCMB, $UseBitmapFonts)
	GUICtrlSetState($ViewNpcEquipCHK, $ViewNpcEquip)
	If $DefaultRangeSwap = "0" Then
		$DefaultRangeSwap = "off"
	ElseIf $DefaultRangeSwap = "1" Then
		$DefaultRangeSwap = "Magnum"
	ElseIf $DefaultRangeSwap = "2" Then
		$DefaultRangeSwap = "Arrow Revolver"
	ElseIf $DefaultRangeSwap = "3" Then
		$DefaultRangeSwap = "Support Shot"
	ElseIf $DefaultRangeSwap = "4" Then
		$DefaultRangeSwap = "Fragment Shot"
	ElseIf $DefaultRangeSwap = "5" Then
		$DefaultRangeSwap = "Mirage Missle"
	EndIf
	GUICtrlSetData($DefaultRangeSwapCMB, $DefaultRangeSwap)
	GUICtrlSetData($searchmodeCHK, $searchmode, "Desktop")
	GUICtrlSetState($checkupdateCHK, $checkupdate)
	GUICtrlSetState($swapCHK, $swapsieves)
	GUICtrlSetState($dropitemsCHK, $dropitems)
	GUICtrlSetData($dropxoffsetINP, $dropxoffset, "")
	GUICtrlSetData($dropyoffsetINP, $dropyoffset, "")
	GUICtrlSetData($metalxoffsetINP, $metalxoffset, "")
	GUICtrlSetData($metalyoffsetINP, $metalyoffset, "")
	GUICtrlSetData($fossilxoffsetINP, $fossilxoffset, "")
	GUICtrlSetData($fossilyoffsetINP, $fossilyoffset, "")
	GUICtrlSetData($clickloopdelayINP, $clickloopdelay, "")
	GUICtrlSetData($clickdelayINP, $clickdelay, "")
	GUICtrlSetData($clickcountINP, $clickcount, "")
	GUICtrlSetState($holdaltCHK, $holdalt)
	GUICtrlSetState($holdctrlCHK, $holdctrl)
	GUICtrlSetData($toleranceSLD[0], $tolerance1)
	GUICtrlSetData($toleranceSLD[1], $tolerance2)
	GUICtrlSetData($toleranceSLD[2], $tolerance3)
	GUICtrlSetState($findpropsCHK, $findprops)
	GUICtrlSetTip($findpropsCHK, "Enable to search for props in [Prop List].")
	GUICtrlSetState($usemoverCHK[1], $usemover)
	GUICtrlSetTip($usemoverCHK, "Enable screen rotations before and/or after searches.")
	GUICtrlSetState($usemoverCHK[2], $usemover)
	GUICtrlSetTip($usemoverCHK, "Enable screen rotations before and/or after searches.")
	GUICtrlSetState($mobsearchCHK, $mobsearch)
	GUICtrlSetTip($mobsearchCHK, "Enable to search for mobs in [Mob List].")
	GUICtrlSetState($attackanythingCHK, $attackanything)
	GUICtrlSetTip($attackanythingCHK, "Enables 'ctrl+click' attacking.")
	GUICtrlSetState($selfclickCHK, $selfclick)
	GUICtrlSetTip($selfclickCHK, "Enable to click current mouse postion after skill loads.")
	GUICtrlSetState($centerclickCHK, $centerclick)
	GUICtrlSetTip($selfclickCHK, "Enable to click yourself or near you with x/y offsets after skill loads.")
	GUICtrlSetState($useskillCHK, $useskill)
	GUICtrlSetTip($useskillCHK, "Enable first skill. (Save Settings)")
	GUICtrlSetData($useskillusesINP, "", "")
	GUICtrlSetData($useskilldelayINP, "", "")
	GUICtrlSetTip($useskillhotkeyINP, "First skill hot key.")
	GUICtrlSetData($useskillusesINP, $skilluses, "5")
	GUICtrlSetTip($useskillusesINP, "First skill charge count.")
	GUICtrlSetData($useskilldelayINP, $skilldelay, "4000")
	GUICtrlSetTip($useskilldelayINP, "First skill delay after charge.")
	GUICtrlSetState($CancelSkill1CHK, $CancelSkill1)
	GUICtrlSetState($2xCtrlClickSkill1CHK,$2xCtrlClickSkill1)
	GUICtrlSetState($useskill2CHK, $useskill2)
	GUICtrlSetTip($useskill2CHK, "Enable second skill. (Save Settings)")
	GUICtrlSetData($useskillhotkey2INP, "", "")
	GUICtrlSetData($useskilluses2INP, "", "")
	GUICtrlSetData($useskilldelay2INP, "", "")
	GUICtrlSetData($useskillhotkey2INP, $secondskill, "F2")
	GUICtrlSetTip($useskillhotkey2INP, "Second skill hot key.")
	GUICtrlSetData($useskilluses2INP, $skill2uses, "5")
	GUICtrlSetTip($useskilluses2INP, "Second skill charge count.")
	GUICtrlSetData($useskilldelay2INP, $skill2delay, "4000")
	GUICtrlSetTip($useskilldelay2INP, "Second skill delay after charge.")
	GUICtrlSetState($CancelSkill2CHK, $CancelSkill2)
	GUICtrlSetState($2xCtrlClickSkill2CHK,$2xCtrlClickSkill2)
	GUICtrlSetState($useskill3CHK, $useskill3)
	GUICtrlSetTip($useskill3CHK, "Enable third skill. (Save Settings)")
	GUICtrlSetData($useskillhotkey3INP, "", "")
	GUICtrlSetData($useskilluses3INP, "", "")
	GUICtrlSetData($useskilldelay3INP, "", "")
	GUICtrlSetData($useskillhotkey3INP, $thirdskill, "F3")
	GUICtrlSetTip($useskillhotkey3INP, "Third skill hot key.")
	GUICtrlSetData($useskilluses3INP, $skill3uses, "5")
	GUICtrlSetTip($useskilluses3INP, "Third skill charge count.")
	GUICtrlSetData($useskilldelay3INP, $skill3delay, "4000")
	GUICtrlSetTip($useskilldelay3INP, "Third skill delay after charge.")
	GUICtrlSetState($CancelSkill3CHK, $CancelSkill3)
	GUICtrlSetState($2xCtrlClickSkill3CHK,$2xCtrlClickSkill3)
	GUICtrlSetData($selfclickdelayINP, "", "")
	If $selfclickafter <> "" Then
		_GUICtrlComboBox_SelectString ($selfclickCMB, $selfclickafter)
	EndIf
	GUICtrlSetTip($selfclickCMB, "Skill to use before clicking.")
	GUICtrlSetData($selfclickusesINP, "", "")
	GUICtrlSetData($selfclickusesINP, $selfclickuses, "5")
	GUICtrlSetTip($selfclickusesINP, "Times to click.")
	GUICtrlSetData($selfclickdelayINP, $selfclickdelay, "4000")
	GUICtrlSetTip($selfclickdelayINP, "Delay between clicking.")
	GUICtrlSetData($centerclickdelayINP, "", "")
	If $centerclickafter <> "" Then
		_GUICtrlComboBox_SelectString ($centerclickCMB, $centerclickafter)
	EndIf
	GUICtrlSetTip($centerclickCMB, "Skill to use before clicking.")
	GUICtrlSetData($centerclickusesINP, "", "")
	GUICtrlSetData($centerclickusesINP, $centerclickuses, "5")
	GUICtrlSetTip($centerclickusesINP, "Times to click.")
	GUICtrlSetData($centerclickdelayINP, $centerclickdelay, "4000")
	GUICtrlSetTip($centerclickdelayINP, "Delay between clicking.")
	GUICtrlSetData($centerxoffsetINP, "", "")
	GUICtrlSetData($centerxoffsetINP, $centerxoffset, "0")
	GUICtrlSetTip($centerxoffsetINP, "Enable to click near you with x offset.")
	GUICtrlSetData($centeryoffsetINP, "", "")
	GUICtrlSetData($centeryoffsetINP, $centeryoffset, "0")
	GUICtrlSetTip($centeryoffsetINP, "Enable to click near you with y offset.")
	GUICtrlSetData($hitcountINP, $hitcount)
	GUICtrlSetData($hitdelayINP, $hitdelay)

	For $i2 = 0 To 1
		GUICtrlSetData($useskillhotkeyINP[$i2], "", "")
		GUICtrlSetData($useskillhotkeyINP[$i2], $firstskill, "F1")
		GUICtrlSetState($autoscanCHK[$i2], $autoscan)
		GUICtrlSetTip($autoscanCHK[$i2], "Enable to auto scan for fossil windows." & @CRLF & "Works best with 'Use Items' Enabled.")
		GUICtrlSetState($completefossilCHK[$i2], $completefossil)
		GUICtrlSetTip($completefossilCHK[$i2], "Enable to click complete after fossil restoration.")
	Next
	For $i3 = 0 To 2

	Next
	For $i4 = 0 To 3
		If $boxarea = "center" Then
			GUICtrlSetState($centerscreenRDO[$i4], 1)
		ElseIf $boxarea = "fullscreen" Then
			GUICtrlSetState($fullscreenRDO[$i4], 1)
		Else
			GUICtrlSetState($fullcenterscreenRDO[$i4], 1)
		EndIf
		GUICtrlSetState($deathCHK[$i4], $deathcheck)
		GUICtrlSetTip($deathCHK[$i4], "Enable to click 'revive here' then 'ok' upon death.")
		GUICtrlSetState($finditemsCHK[$i4], $finditems)
		GUICtrlSetTip($finditemsCHK[$i4], "Enable to search for items in [Item List].")
		GUICtrlSetState($twoslotsCHK[$i4], $twoslots)
		GUICtrlSetTip($twoslotsCHK[$i4], "Enable to switch between both weapon slots.")
		GUICtrlSetTip($fullscreenRDO[$i4], "Enable to search full screen.")
		GUICtrlSetTip($centerscreenRDO[$i4], "Enable to search center screen.")
		GUICtrlSetTip($fullcenterscreenRDO[$i4], "Enable to search center screen first then full screen.")
	Next
	For $i5 = 0 To 4
		GUICtrlSetTip($ButtonS[$i5], "Start " & $Mode & " Bot")
		GUICtrlSetState($hidewindowsCHK[$i5], $hidewindows)
		GUICtrlSetTip($hidewindowsCHK[$i5], "Enable to hide windows with '\' key.")
		GUICtrlSetState($closewindowsCHK[$i5], $closewindows)
		GUICtrlSetTip($closewindowsCHK[$i5], "Enable to close most window types before searching.")
		GUICtrlSetState($useitemsCHK[$i5], $useitems)
		GUICtrlSetTip($useitemsCHK[$i5], "Enable to use items 'fossil.bmp' in [Use List].")
	Next
	If StringLen($firstskill) >= 4 Then
		If $Mode = "Restoration" Or $Mode = "Gathering" Or $Mode = "Mining" Then
		Else
			MsgBox(0, "Problem?", "Autobot noticed your skill hotkey/s are longer then the usual one or two alpahumeric." & @CRLF & "Please check if they are correct, without any quotes or special characters then click the Save button or the checkbox for that skill to save settings.")
		EndIf
	ElseIf StringLen($secondskill) >= 4 And $Mode = "Fight" Then
		MsgBox(0, "Problem?", "Autobot noticed your skill hotkey/s are longer then the usual one or two alpahumeric." & @CRLF & "Please check if they are correct, without any quotes or special characters then click the checkbox for that skill to save settings..")
	ElseIf StringLen($thirdskill) >= 4 And $Mode = "Fight" Then
		MsgBox(0, "Problem?", "Autobot noticed your skill hotkey/s are longer then the usual one or two alpahumeric." & @CRLF & "Please check if they are correct, without any quotes or special characters then click the checkbox for that skill to save settings..")
	EndIf
EndFunc   ;==>_setValues
;=======================================================================================
Func _content($directory)
	If Not $configini = "" Then
		GUICtrlCreateLabel("[" & $directory & " List]", 675, 3, 55, 14)
		GUICtrlSetBkColor(-1, $colorhex)
		GUICtrlDelete($listview)
		GUICtrlDelete($listview1)
		$FileList = _FileListToArray(@ScriptDir & "\Find\Images\" & $directory, "*.*", 1)
		$listview = GUICtrlCreateListView("File Name                    |ENABLED|Real Name INI", 585, 20, 300, 400)
		GUICtrlSetTip(-1, "Right Click to Enable/Disable images to search for.")
		GUICtrlSetBkColor(-1, $colorhex3)
		$listviewContext = GUICtrlCreateContextMenu($listview)
		$listviewContextItem = GUICtrlCreateMenuItem("Enable/Disable", $listviewContext)
		;$listviewContextTest = GUICtrlCreateMenuItem("Test", $listviewContext)
		GUIRegisterMsg($WM_CONTEXTMENU, "_WM_CONTEXTMENU")
		; Files
		For $n = 1 To UBound($FileList) - 1

			$File_Name = $FileList[$n]
			$File1 = StringReplace($File_Name, ".bmp", "")
			$File2 = StringTrimRight($File1, 1)
			$File3 = StringReplace($File1, $File2, "")
			If Not @error Then
				If _hasNum($File3) = False Then
					$Last_Name = $File1
					$Status = IniRead($configini, $directory & " List", $File1, "0")
					$items[$n] = GUICtrlCreateListViewItem($File_Name & "|" & $Status & "|" & $Last_Name, $listview)
					;If
					;GUICtrlSetImage(-1, @ScriptDir & "\Find\Images\" & $directory & "\" & $File_Name,-1, 0); = 0 Then GUICtrlSetImage($items[$n], "shell32.dll", 24)
				Else
					$Status = "^"
					$items[$n] = GUICtrlCreateListViewItem($File_Name & "|" & $Status & "|" & $Last_Name, $listview)
					;If GUICtrlSetImage(-1, @ScriptDir & "\Find\Images\" & $directory & "\" & $File_Name,-1, 0) = 0 Then GUICtrlSetImage($items[$n], "shell32.dll", 24)
				EndIf
			EndIf
		Next
	EndIf
EndFunc   ;==>_content
;=======================================================================================
Func _content2()
	If $configini = "Frontend" Then
		GUICtrlDelete($listview)
		GUICtrlDelete($listview1)
		$listview1 = GUICtrlCreateListView("Mod Name                                                            |Status|Filename", 10, 100, 855, 310, $LBS_MULTIPLESEL)
		GUICtrlSetTip(-1, "Right Click to Enable/Disable UO Tiara Mods.")
		GUICtrlSetBkColor(-1, $colorhex3)
		$listviewContext1 = GUICtrlCreateContextMenu($listview1)
		$listviewContextItem1 = GUICtrlCreateMenuItem("Enable/Disable", $listviewContext1)
		;$listviewContextTest = GUICtrlCreateMenuItem("Test", $listviewContext)
		GUIRegisterMsg($WM_CONTEXTMENU, "_WM_CONTEXTMENU1")
		; Files
		_GUICtrlListView_SetColumnWidth($listview1, 0, 330)
		_GUICtrlListView_SetColumnWidth($listview1, 1, 70)
		_GUICtrlListView_SetColumnWidth($listview1, 2, 400)
		$DelCount = IniRead($MabiDir & "AutoBot\Frontend.ini", "Delete", "FileCount", 0)
		For $n = 1 To $DelCount
			$DelCount1 = IniRead($MabiDir & "AutoBot\Frontend.ini", "Delete", "FileCount", 0)
			$File_Name = IniRead($MabiDir & "AutoBot\Frontend.ini", "Delete", $n, "")
			FileDelete($MabiDir & $File_Name)
			IniDelete($MabiDir & "AutoBot\Frontend.ini", "Delete", $n)
			IniWrite($MabiDir & "AutoBot\Frontend.ini", "Delete", "FileCount", $DelCount1 - 1)
		Next
		For $n = 1 To IniRead($MabiDir & "AutoBot\Frontend.ini", "Settings", "FileCount", 0)
			$List_Name = IniRead($MabiDir & "AutoBot\Frontend.ini", "List Name", $n, "")
			$ModStatus = IniRead($MabiDir & "AutoBot\Frontend.ini", "Settings", $n, "")
			$File_Name1 = IniRead($MabiDir & "AutoBot\Frontend.ini", "File List", $n, "")
			If $ModStatus = 1 Then
				$ModStatus = "Enabled"
				If FileExists($MabiDir & $File_Name1) = False Then
					$ModStatus = "Disabled"
					IniWrite($MabiDir & "AutoBot\Frontend.ini", "Settings", $n, "0")
				EndIf
			Else
				$ModStatus = "Disabled"
			EndIf
			If Not @error Then
				$items1[$n] = GUICtrlCreateListViewItem($List_Name & "|" & $ModStatus & "|" & $File_Name1, $listview1)
			EndIf
		Next
	EndIf
EndFunc   ;==>_content2
;=======================================================================================
Func _startUp()
	;If $runonce=1 Then Return 0
	If FileExists("ImageSearchDLL.dll") = False Then _errorHandler(1)
	$configini = $Mode & ".ini"
	_readINI()
	If $Mode = "Clicker" Then
	Else
		_makeINILists()
	EndIf
	_refreshScreen()
	Return (1)
	$runonce = 1
EndFunc   ;==>_startUp
;=======================================================================================
Func _refreshScreen()
	If $searchmode = "Client" Then
		If Not WinActive($mabititle) Then WinActivate($mabititle)
		WinWaitActive($mabititle)
		$box = WinGetPos($mabititle)
		If IsArray($box) = True Then
			$topleftcorner[0] = $box[0]
			$topleftcorner[1] = $box[1]
			$bottomrightcorner[0] = $box[2]
			$bottomrightcorner[1] = $box[3]
			$center[0] = ($topleftcorner[0] + $bottomrightcorner[0]) / 2
			$center[1] = ($topleftcorner[1] + $bottomrightcorner[1]) / 2
		ElseIf IsArray($box) = False Then
			_ImageSearch("Find\Images\buttons\F1.bmp", 0, $F1_x, $F1_y, $tolerance)
			$mabititle = WinGetTitle("[CLASS:Mabinogi]")
			If Not WinActive($mabititle) Then WinActivate($mabititle)
			$box = WinGetClientSize($mabititle)
			If IsArray($box) = True Then
				$topleftcorner[0] = $F1_x
				$topleftcorner[1] = $F1_y
				$bottomrightcorner[0] = $box[0]
				$bottomrightcorner[1] = $box[1]
				$center[0] = ($topleftcorner[0] + $bottomrightcorner[0]) / 2
				$center[1] = ($topleftcorner[1] + $bottomrightcorner[1]) / 2
			Else
				$topleftcorner[0] = 0
				$topleftcorner[1] = 0
				$bottomrightcorner[0] = @DesktopWidth
				$bottomrightcorner[1] = @DesktopHeight
				$center[0] = ($topleftcorner[0] + $bottomrightcorner[0]) / 2
				$center[1] = ($topleftcorner[1] + $bottomrightcorner[1]) / 2
			EndIf
		EndIf
	Else
		$mabititle = WinGetTitle("[CLASS:Mabinogi]")
		If Not WinActive($mabititle) Then WinActivate($mabititle)
		$topleftcorner[0] = 0
		$topleftcorner[1] = 0
		$bottomrightcorner[0] = @DesktopWidth
		$bottomrightcorner[1] = @DesktopHeight
		$center[0] = ($topleftcorner[0] + $bottomrightcorner[0]) / 2
		$center[1] = ($topleftcorner[1] + $bottomrightcorner[1]) / 2
	EndIf
	ToolTip($mabititle & " Position = TopLeftX: " & $topleftcorner[0] & " TopLeftY: " & $topleftcorner[1] & " BottomRightX: " & $bottomrightcorner[0] & " BottomRightY: " & $bottomrightcorner[1] & " CenterX: " & $center[0] & " CenterY: " & $center[1], 0, @DesktopHeight - 20)
	Sleep(2500)
EndFunc   ;==>_refreshScreen
;=======================================================================================
Func _readINI()
	$MabiDir = IniRead("Frontend.ini", "Settings", "MabiDir", "")
	$mabititle = IniRead("config.ini", "Settings", "mabititle", "Mabinogi")
	$debug = IniRead("config.ini", "Settings", "debug", "0")
	$clickerimage = IniRead("clicker.ini", "Settings", "clickimage", "")
	$clickerimage2 = IniRead("clicker.ini", "Settings", "clickimage2", "blue.bmp")
	$clickerimage3 = IniRead("clicker.ini", "Settings", "clickimage3", "red.bmp")
	$finditems = IniRead($configini, "Settings", "finditems", "0")
	$useitems = IniRead($configini, "Settings", "useitems", "0")
	$usemover = IniRead($configini, "Settings", "usemover", "0")
	$pause = IniRead($configini, "Settings", "pause", "10000")
	$mouse_speed = IniRead($configini, "Settings", "mousespeed", "1")
	$mousedelay = IniRead($configini, "Settings", "mousedelay", "105")
	$shortestdelay = IniRead($configini, "Settings", "shortestdelay", "250")
	$shortdelay = IniRead($configini, "Settings", "$shortdelay", "1000")
	$delay = IniRead($configini, "Settings", "delay", "2000")
	$longdelay = IniRead($configini, "Settings", "longdelay", "5000")
	$longestdelay = IniRead($configini, "Settings", "longestdelay", "7000")
	$autoscan = IniRead($configini, "Fossil Settings", "autoscan", "1")
	$completefossil = IniRead($configini, "Fossil Settings", "completefossil", "1")
	$hitdelay = IniRead($configini, "Settings", "hitdelay", "3000")
	$hitcount = IniRead($configini, "Settings", "hitcount", "10")
	$holdalt = IniRead("clicker.ini", "Settings", "holdalt", "")
	$holdctrl = IniRead("clicker.ini", "Settings", "holdctrl", "")
	$clickcount = IniRead("clicker.ini", "Settings", "clickcount", "10")
	$clickdelay = IniRead("clicker.ini", "Settings", "clickdelay", "1000")
	$clickloopdelay = IniRead("clicker.ini", "Settings", "clickloopdelay", "10000")
	$findprops = IniRead($configini, "Settings", "findprops", "1")
	$hidewindows = IniRead($configini, "Settings", "hidewindows", "0")
	$closewindows = IniRead($configini, "Settings", "closewindows", "0")
	$dropitems = IniRead("fight.ini", "Settings", "dropitems", "0")
	$dropxoffset = IniRead("fight.ini", "Settings", "dropxoffset", "0")
	$dropyoffset = IniRead("fight.ini", "Settings", "dropyoffset", "0")
	$metalxoffset = IniRead($configini, "Settings", "metalxoffset", "20")
	$metalyoffset = IniRead($configini, "Settings", "metalyoffset", "20")
	$fossilxoffset = IniRead("config.ini", "Settings", "fossilxoffset", "0")
	$fossilyoffset = IniRead("config.ini", "Settings", "fossilyoffset", "0")
	$summonpet = IniRead($configini, "Pet Settings", "summonpet", "0")
	$petinvkey = IniRead($configini, "Pet Settings", "petinvkey", "-")
	$petinvkey = StringReplace($petinvkey, "|", "")
	$twoslots = IniRead($configini, "Settings", "twoslots", "0")
	$mobsearch = IniRead($configini, "Settings", "mobsearch", "1")
	$attackanything = IniRead($configini, "Settings", "attackanything", "0")
	$selfclick = IniRead($configini, "Skill Settings", "selfclick", "0")
	$centerclick = IniRead($configini, "Skill Settings", "centerclick", "0")
	$firstskill = IniRead($configini, "Skill Settings", "firstskill", "F1")
	$firstskill = StringReplace($firstskill, "|", "")
	$skilldelay = IniRead($configini, "Skill Settings", "skilldelay", "4000")
	$useskill = IniRead($configini, "Skill Settings", "useskill", "0")
	$skilluses = IniRead($configini, "Skill Settings", "skilluses", "5")
	$CancelSkill1 = IniRead($configini, "Skill Settings", "CancelSkill1", "0")
	$2xCtrlClickSkill1 =  IniRead($configini, "Skill Settings", "2xCtrlClickSkill1", "0")
	$secondskill = IniRead($configini, "Skill Settings", "secondskill", "F2")
	$secondskill = StringReplace($secondskill, "|", "")
	$skill2delay = IniRead($configini, "Skill Settings", "skill2delay", "4000")
	$useskill2 = IniRead($configini, "Skill Settings", "useskill2", "0")
	$skill2uses = IniRead($configini, "Skill Settings", "skill2uses", "5")
	$CancelSkill2 = IniRead($configini, "Skill Settings", "CancelSkill2", "0")
	$2xCtrlClickSkill2 =  IniRead($configini, "Skill Settings", "2xCtrlClickSkill2", "0")
	$thirdskill = IniRead($configini, "Skill Settings", "thirdskill", "F3")
	$thirdskill = StringReplace($thirdskill, "|", "")
	$skill3delay = IniRead($configini, "Skill Settings", "skill3delay", "4000")
	$useskill3 = IniRead($configini, "Skill Settings", "useskill3", "0")
	$skill3uses = IniRead($configini, "Skill Settings", "skill3uses", "5")
	$CancelSkill3 = IniRead($configini, "Skill Settings", "CancelSkill3", "0")
	$2xCtrlClickSkill3 =  IniRead($configini, "Skill Settings", "2xCtrlClickSkill3", "0")
	$selfclickafter = IniRead($configini, "Skill Settings", "selfclickafter", "")
	$selfclickdelay = IniRead($configini, "Skill Settings", "selfclickdelay", "4000")
	$selfclickuses = IniRead($configini, "Skill Settings", "selfclickuses", "5")
	$centerclickafter = IniRead($configini, "Skill Settings", "centerclickafter", "")
	$centerclickdelay = IniRead($configini, "Skill Settings", "centerclickdelay", "4000")
	$centerclickuses = IniRead($configini, "Skill Settings", "centerclickuses", "5")
	$centerxoffset = IniRead($configini, "Skill Settings", "centerxoffset", "0")
	$centeryoffset = IniRead($configini, "Skill Settings", "centeryoffset", "0")
	$colorhex = IniRead("config.ini", "Settings", "colorhex", "0xFFFFFF")
	$colorhex2 = IniRead("config.ini", "Settings", "colorhex2", "0xFFFFFE")
	$colorhex3 = IniRead("config.ini", "Settings", "colorhex3", "0xFFFFFF")
	$swapsieves = IniRead($configini, "Settings", "swapsieves", "0")
	$deathcheck = IniRead($configini, "Settings", "deathcheck", "0")
	$tolerance1 = IniRead("config.ini", "Settings", "tolerance1", "30")
	$tolerance2 = IniRead("config.ini", "Settings", "tolerance2", "75")
	$tolerance3 = IniRead("config.ini", "Settings", "tolerance3", "100")
	$egg = IniRead("Restoration.ini", "Fossil Settings", "egg", "27")
	$searchmode = IniRead("config.ini", "Settings", "searchmode", "Desktop")
	$checkupdate = IniRead("config.ini", "Settings", "checkupdate", "1")
	$boxarea = IniRead($configini, "Settings", "boxarea", "fullscreen")
EndFunc   ;==>_readINI
;=======================================================================================
Func _makeINILists()
	;========================================================
	$temparray = IniReadSection($configini, "Mob List")
	If @error Then
		_errorHandler(2, "Mob List")
	EndIf
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$count += 1
		EndIf
	Next
	Global $MOBLISTING[$count + 1][2], $arrayitems
	$arrayitems = $count
	$count = 1
	$MOBLISTING[0][0] = $arrayitems
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$MOBLISTING[$count][0] = $temparray[$quantity][0]
			$MOBLISTING[$count][1] = $temparray[$quantity][1]
			$count += 1
		EndIf
	Next
	;========================================================
	$temparray = ""
	$temparray = IniReadSection($configini, "Prop List")

	If @error Then
		_errorHandler(2, "Prop List")
	EndIf
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$count += 1
		EndIf
	Next
	Global $PROPLISTING[$count + 1][2], $arrayitems
	$arrayitems = $count
	$count = 1
	$PROPLISTING[0][0] = $arrayitems
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$PROPLISTING[$count][0] = $temparray[$quantity][0]
			$PROPLISTING[$count][1] = $temparray[$quantity][1]
			$count += 1
		EndIf
	Next
	;========================================================
	$temparray = ""
	$temparray = IniReadSection($configini, "Item List")
	If @error Then
		_errorHandler(2, "Item List")
	EndIf
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$count += 1
		EndIf
	Next
	Global $ITEMLISTING[$count + 1][2]
	$arrayitems = $count
	$count = 1
	$ITEMLISTING[0][0] = $arrayitems
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$ITEMLISTING[$count][0] = $temparray[$quantity][0]
			$ITEMLISTING[$count][1] = $temparray[$quantity][1]
			$count += 1
		EndIf
	Next
	;========================================================
	$temparray = ""
	$temparray = IniReadSection($configini, "Use List")
	If @error Then
		_errorHandler(2, "Use List")
	EndIf
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$count += 1
		EndIf
	Next
	Global $USELISTING[$count + 1][2]
	$arrayitems = $count
	$count = 1
	$USELISTING[0][0] = $arrayitems
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$USELISTING[$count][0] = $temparray[$quantity][0]
			$USELISTING[$count][1] = $temparray[$quantity][1]
			$count += 1
		EndIf
	Next
	;========================================================
	$temparray = ""
	$temparray = IniReadSection($configini, "Drop List")
	If @error Then
		_errorHandler(2, "Drop List")
	EndIf
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$count += 1
		EndIf
	Next
	Global $DROPLISTING[$count + 1][2]
	$arrayitems = $count
	$count = 1
	$DROPLISTING[0][0] = $arrayitems
	For $quantity = 1 To $temparray[0][0] Step 1
		If $temparray[$quantity][1] = 1 Then
			$DROPLISTING[$count][0] = $temparray[$quantity][0]
			$DROPLISTING[$count][1] = $temparray[$quantity][1]
			$count += 1
		EndIf
	Next
EndFunc   ;==>_makeINILists
;=======================================================================================
Func _splashImage()
	;$_PngUrl = 'http://upload.wikimedia.org/wikipedia/fr/thumb/6/65/Logo_BMW.svg/564px-Logo_BMW.svg.png'
	$_PngPath = @ScriptDir & "\Find\Images\gui\splash.png"
	;If Not FileExists ( $_PngPath ) Then InetGet ( $_PngUrl, $_PngPath, 1 )
	_GDIPlus_Startup()
	$_Image = _GDIPlus_ImageLoadFromFile($_PngPath)
	$_Width = _GDIPlus_ImageGetWidth($_Image)
	$_Height = _GDIPlus_ImageGetHeight($_Image)
	$_Ratio = ($_Width / $_Height) * 2

	For $_Width = 50 To @DesktopWidth / 2 Step 20
		$_Gui = GUICreate("AutoBot", $_Width, $_Width / $_Ratio, -1, -1, -1, BitOR($WS_EX_LAYERED, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
		$_Image = _ImageResize($_PngPath, $_Width - $_Ratio, $_Height)
		_SetBitMap($_Gui, $_Image, 255, $_Width - $_Ratio, $_Height)
		;GUICtrlSetBkColor(-1,0xFFFFFE)
		;_WinAPI_SetLayeredWindowAttributes($_Gui, 0xFFFFFE, 255)
		GUISetState(@SW_SHOW)
	Next
	Sleep(3000)
	_GDIPlus_GraphicsDispose($_Image)
	_GDIPlus_Shutdown()
	While Not $_GuiDelete
		$_GuiDelete = Not GUIDelete(WinGetHandle("AutoBot"))
	WEnd
EndFunc   ;==>_splashImage
;=======================================================================================
Func _IsNum($strInput)
	$aInput = StringSplit($strInput, "")
	For $i = 1 To $aInput[0]
		If Not StringInStr("1234567890-", $aInput[$i]) Then
			Return False
		EndIf
	Next
	Return True
EndFunc   ;==>_IsNum
;=======================================================================================
Func _hasNum($strInput)
	$aInput = StringSplit($strInput, "")
	For $i = 1 To $aInput[0]
		If StringInStr("1234567890-", $aInput[$i]) Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>_hasNum
;=======================================================================================
Func _RTrim($sString, $sTrimChars = ' ')
	$sTrimChars = StringReplace($sTrimChars, "%%whs%%", " " & Chr(9) & Chr(11) & Chr(12) & @CRLF)
	Local $nCount, $nFoundChar
	Local $aStringArray = StringSplit($sString, "")
	Local $aCharsArray = StringSplit($sTrimChars, "")
	For $nCount = $aStringArray[0] To 1 Step -1
		$nFoundChar = 0
		For $i = 1 To $aCharsArray[0]
			If $aCharsArray[$i] = $aStringArray[$nCount] Then
				$nFoundChar = 1
			EndIf
		Next
		If $nFoundChar = 0 Then Return StringTrimRight($sString, ($aStringArray[0] - $nCount))
	Next
EndFunc   ;==>_RTrim
;=======================================================================================
Func _useMover()
	If Not $Mode = "" Then
		If $usemover = 1 Then
			Local $mouseorigin = MouseGetPos()
			Sleep($shortestdelay)
			$randomnumber = Random(50, 150, 1)
			MouseClickDrag("right", $center[0] - $randomnumber, $center[1], $center[0] + $randomnumber, $center[1], 10)
			Sleep($shortestdelay)
			MouseUp("right")
			MouseMove($mouseorigin[0], $mouseorigin[1], 1)
		EndIf
	EndIf
EndFunc   ;==>_useMover
;=======================================================================================
Func _forceMover()
	If Not $Mode = "" Then
		Local $mouseorigin = MouseGetPos()
		Sleep($shortestdelay)
		$randomnumber = Random(50, 150, 1)
		MouseClickDrag("right", $center[0] - $randomnumber, $center[1], $center[0] + $randomnumber, $center[1], 10)
		Sleep($shortestdelay)
		MouseUp("right")
		MouseMove($mouseorigin[0], $mouseorigin[1], 1)
	EndIf
EndFunc   ;==>_forceMover
;=======================================================================================
Func _complete()
	$toleranceold = $tolerance
	$tolerance = $tolerance2
	Local $mouseorigin = MouseGetPos()
	_setSearchCoords("fullscreen")
	Do
		$result = _ImageSearchArea("Find\Images\buttons\complete.bmp", 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
		If $result Then
			MouseMove($x1, $y1, $mouse_speed)
			Sleep($shortestdelay)
			MouseClick("left")
			Sleep($shortestdelay)
		EndIf
	Until $result = 0
	MouseMove($mouseorigin[0], $mouseorigin[1], 1)
	$tolerance = $toleranceold
EndFunc   ;==>_complete
;=======================================================================================
Func _close()
	$toleranceold = $tolerance
	$tolerance = $tolerance2
	If $closewindows = 1 Then
		_setSearchCoords("fullscreen")
		Local $mouseorigin = MouseGetPos()
		$file = _FileListToArray(@ScriptDir & "\Find\Images\buttons\", "close*.bmp", 1)
		If Not @error Then
			For $i = 1 To $file[0]
				Do
					If Not $Mode = "" Then
						Sleep($shortestdelay)
						$result = _ImageSearchArea(@ScriptDir & "\Find\Images\buttons\" & $file[$i], 0, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
						ToolTip($file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
						If $result = 1 Then
							MouseMove($x1, $y1, $mouse_speed)
							Sleep($shortestdelay)
							MouseClick("left")
							Sleep($shortestdelay)
						EndIf
					EndIf
				Until $result = 0
			Next
		Else
			Do
				If Not $Mode = "" Then
					$result = _ImageSearchArea("Find\Images\buttons\close.bmp", 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
					If $result Then
						MouseMove($x1, $y1, $mouse_speed)
						Sleep($shortestdelay)
						MouseClick("left")
						Sleep($shortestdelay)
					EndIf
				EndIf
			Until $result = 0
		EndIf
		MouseMove($mouseorigin[0], $mouseorigin[1], 1)
	EndIf
	$tolerance = $toleranceold
EndFunc   ;==>_close
;=======================================================================================
Func _ok()
	$toleranceold = $tolerance
	$tolerance = $tolerance2
	_setSearchCoords("fullscreen")
	Local $mouseorigin = MouseGetPos()
	$file = _FileListToArray(@ScriptDir & "\Find\Images\buttons\", "ok*.bmp", 1)
	If Not @error Then
		For $i = 1 To $file[0]
			Do
				If Not $Mode = "" Then
					Sleep($shortestdelay)
					$result = _ImageSearchArea(@ScriptDir & "\Find\Images\buttons\" & $file[$i], 0, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
					ToolTip($file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
					If $result = 1 Then
						MouseMove($x1, $y1, $mouse_speed)
						Sleep($shortestdelay)
						MouseClick("left")
						Sleep($shortestdelay)
					EndIf
				EndIf
			Until $result = 0
		Next
	EndIf
	MouseMove($mouseorigin[0], $mouseorigin[1], 1)
	$tolerance = $toleranceold
EndFunc   ;==>_ok
;=======================================================================================
Func _showWindows()
	$toleranceold = $tolerance
	$tolerance = $tolerance2
	$count = 0
	_setSearchCoords("fullscreen")
	Do
		$count = $count + 1
		If Not $Mode = "" Then
			$result = _ImageSearch("Find\Images\buttons\F1.bmp", 0, $F1_x, $F1_y, $tolerance)
			Sleep($shortestdelay + ($count * 10))
			ToolTip("F1.bmp = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
			If $result = 0 Then
				If _MathCheckDiv($count, 2) = 2 Then Send("{\}")
			EndIf
			$result = _ImageSearch("Find\Images\buttons\F1.bmp", 0, $F1_x, $F1_y, $tolerance)
		EndIf
		If $count >= 50 Then
			Exit
		ElseIf $count >= 10 Then
			ToolTip("Can not find 'F1.bmp'. Please re-take screen shot in Find\Images\Buttons\." & @CRLF & "Or move/resize Mabinogi window.  Press 'del' or 'esc' key.", 0, @DesktopHeight - 35)
			Sleep($longestdelay + ($count * 100))
			;_forceMover()
		EndIf
	Until $result = 1
	$tolerance = $toleranceold
EndFunc   ;==>_showWindows
;=======================================================================================
Func _hideWindows()
	$toleranceold = $tolerance
	$tolerance = $tolerance2
	If $hidewindows = 1 Then
		_setSearchCoords("fullscreen")
		$count = 0
		Do
			$count = $count + 1
			If Not $Mode = "" Then
				$result = _ImageSearch("Find\Images\buttons\F1.bmp", 0, $F1_x, $F1_y, $tolerance)
				Sleep($longestdelay + ($count * 100))
				ToolTip("F1.bmp = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
				If $result = 1 Then
					If _MathCheckDiv($count, 2) = 2 Then Send("{\}")
				Else
					Sleep($longestdelay + ($count * 100))
				EndIf
				$result = _ImageSearch("Find\Images\buttons\F1.bmp", 0, $F1_x, $F1_y, $tolerance)
			EndIf
			If $count >= 30 Then
				Exit
			ElseIf $count >= 10 Then
				ToolTip("Can not find 'F1.bmp'. Please re-take screen shot in Find\Images\Buttons\." & @CRLF & "Or move/resize Mabinogi window.  Press 'del' or 'esc' key.", 0, @DesktopHeight - 35)
				;_forceMover()
			EndIf
		Until $result = 0
	EndIf
	$tolerance = $toleranceold
EndFunc   ;==>_hideWindows
;=======================================================================================
Func _useItem()
	$tolerance = $tolerance2
	$quantity = 0
	Local $mouseorigin = MouseGetPos()
	_setSearchCoords("fullscreen")
	Sleep($shortdelay)
	Local $file = 0
	$result = 0
	_openItems()
	Sleep(1000)
	For $quantity = 1 To $USELISTING[0][0] Step 1
		If $USELISTING[$quantity][1] = 1 Then
			$file = _FileListToArray(@ScriptDir & "\Find\Images\use\", $USELISTING[$quantity][0] & "*.bmp", 1)
			If Not @error Then
				For $i = 1 To $file[0]
					Do
						$result = _ImageSearch(@ScriptDir & "\Find\Images\use\" & $file[$i], 1, $x, $y, $tolerance)
						ToolTip($file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
						Sleep($shortdelay)
						If $result = 1 Then
							_ctrlTarget($x, $y)
							If $USELISTING[$quantity][0] = "fossil" Or $USELISTING[$quantity][0] = "pumpkin" Then
								$usefossil = 1
							Else
								_useItem()
							EndIf
							MouseMove($mouseorigin[0], $mouseorigin[1], 1)
							$founditems = 0
							Return 1
						EndIf
					Until $result = 0
				Next
			EndIf
		EndIf
	Next
	If $usefossil = 1 Then
		MouseMove($mouseorigin[0], $mouseorigin[1], 1)
		$founditems = 0
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_useItem
;=======================================================================================
Func _dropItems()
If $dropitems = 1 then
	$tolerance = $tolerance2
	;_setSearchCoords("fullscreen")
	Local $mouseorigin = MouseGetPos()
	Local $file = 0
	$quantity = 0
	For $quantity = 1 To $DROPLISTING[0][0] Step 1
		If $DROPLISTING[$quantity][1] = 1 Then
			$file = _FileListToArray(@ScriptDir & "\Find\Images\drop\", $DROPLISTING[$quantity][0] & "*.bmp", 1)
			If Not @error Then
				For $i = 1 To $file[0]
					If $file[$i] <> "" Then
					Sleep($longestdelay)
					;$result = _ImageSearchArea(@ScriptDir & "\Find\Images\drop\" & $file[$i], 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
					$result = _ImageSearch(@ScriptDir & "\Find\Images\drop\" & $file[$i],1,$x1,$y1,$tolerance)
					ToolTip("Drop: " & $file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
					Sleep($shortestdelay)
					If $result = 1 Then
						MouseMove($x1, $y1, $mouse_speed)
						MouseClick("left", $x1, $y1, 2, $mouse_speed)
						Sleep($longdelay)
						MouseMove($center[0]+$dropxoffset, $center[1]+$dropyoffset, $mouse_speed)
						MouseClick("left",$center[0]+$dropxoffset, $center[1]+$dropyoffset,1,$mouse_speed)
						Sleep($delay)
						MouseMove($mouseorigin[0], $mouseorigin[1], $mouse_speed)
						Sleep($longestdelay)
					EndIf
					EndIf
				Next
			EndIf
		EndIf
	Next
	MouseMove($mouseorigin[0], $mouseorigin[1], 1)
EndIf
EndFunc
;===================
Func _closeItems()
	If Not WinActive($mabititle) And $searchmode = "Client" Then WinActivate($mabititle)
	If _itemsOpen() = 1 Then
		Send("{i}")
	EndIf
EndFunc   ;==>_closeItems
;=======================================================================================
Func _openItems()
	If Not WinActive($mabititle) And $searchmode = "Client" Then WinActivate($mabititle)
	If _itemsOpen() = 0 Then
		Send("{i}")
		If $summonpet = 1 Then
			If Not WinActive($mabititle) And $searchmode = "Client" Then WinActivate($mabititle)
			Send("{" & $petinvkey & "}")
		EndIf
	EndIf
EndFunc   ;==>_openItems
;=======================================================================================
Func _itemsOpen()
	$tolerance = $tolerance2
	If Not $Mode = "" Then
		$file = _FileListToArray(@ScriptDir & "\Find\Images\buttons\", "inv*.bmp", 1)
		If Not @error Then
			For $i = 1 To $file[0]
				$result = _ImageSearch(@ScriptDir & "\Find\Images\buttons\" & $file[$i], 0, $x1, $y1, $tolerance)
				ToolTip($file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
				Sleep($shortestdelay)
				If $result = 1 Then
					Return 1
				EndIf
			Next
		EndIf
		Return 0
	EndIf
EndFunc   ;==>_itemsOpen
;=======================================================================================
Func _findItems()
	$tolerance = $tolerance2
	If Not $Mode = "" Then
		If $finditems = 1 Then
			Local $mouseorigin = MouseGetPos()
			Local $file = 0
			$quantity = 0
			$result = 0
			$changearea = 0
			_close()
			Send("{ALTDOWN}")
			Sleep($shortdelay)
			For $quantity = 1 To $ITEMLISTING[0][0] Step 1
				If $ITEMLISTING[$quantity][1] = 1 Then
					$file = _FileListToArray(@ScriptDir & "\Find\Images\item\", $ITEMLISTING[$quantity][0] & "*.bmp", 1)
					If Not @error Then
						For $i = 1 To $file[0]
							If $boxarea = "centerfull" And $changearea = 1 Then
								$boxarea1 = "fullscreen"
							ElseIf $boxarea = "centerfull" And $changearea = 0 Then
								$boxarea1 = "center"
							Else
								$boxarea1 = $boxarea
							EndIf
							;msgbox(0,$boxarea,$boxarea1 & " - " & $changearea)
							_setSearchCoords($boxarea)
							If Not $file[$i] = "" Then
								Sleep($shortestdelay)
								$result = _ImageSearchArea(@ScriptDir & "\Find\Images\item\" & $file[$i], 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
								;$result = _ImageSearch(@ScriptDir & "\Find\Images\item\" & $file[$i],1,$x1,$y1,$tolerance)
								ToolTip("Find: " & $file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
								Sleep($shortestdelay)
								If $result = 1 Then
									If $boxarea = "centerfull" Then $changearea = 0
									$notdetected = 0
									Send("{ALTDOWN}")
									$founditems = $founditems + 1
									_target($x1, $y1)
									Sleep($shortestdelay)
									$result = _ImageSearchArea(@ScriptDir & "\Find\Images\item\" & $file[$i], 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
									Sleep($shortdelay)
									MouseMove($mouseorigin[0], $mouseorigin[1], 1)
									Sleep($longestdelay)
									_findItems()
								EndIf
							EndIf
						Next
					Else
					EndIf
				EndIf
			Next
			_cleanUp()
			If $founditems >= 1 Then
				MouseMove($mouseorigin[0], $mouseorigin[1], 1)
				Return 1
			Else
				If $usemover = 0 Then _forceMover()
				Sleep($shortestdelay)
				MouseMove($mouseorigin[0], $mouseorigin[1], 1)
				$notdetected = $notdetected + 1
				If $boxarea = "centerfull" Then
					$changearea = 1
				EndIf
				If $notdetected >= 5 Then
					ToolTip("Can't find item." & @CRLF & "You may need to move to another area Or retake your own Screen Shots in \Find\Images\.", 0, @DesktopHeight - 35)
				EndIf
				Return 0
			EndIf
		Else
			Return 0
		EndIf
	EndIf
EndFunc   ;==>_findItems
;=======================================================================================
Func _nameSearch($hitcount, $hitdelay, $x, $y, $tolerance = 75)
	If Not $Mode = "" Then
		If $findprops = 1 Then
			Local $mouseorigin = MouseGetPos()
			Local $file
			$quantity = 0
			$result = 0
			$changearea = 0
			_close()
			Send("{ALTDOWN}")
			Sleep($shortdelay)
			For $quantity = 1 To $PROPLISTING[0][0] Step 1
				If $PROPLISTING[$quantity][1] = 1 Then
					$file = _FileListToArray(@ScriptDir & "\Find\Images\prop\", $PROPLISTING[$quantity][0] & "*.bmp", 1)
					If Not @error Then
						For $i = 1 To $file[0]
							If $boxarea = "centerfull" And $changearea = 1 Then
								$boxarea1 = "fullscreen"
							ElseIf $boxarea = "centerfull" And $changearea = 0 Then
								$boxarea1 = "center"
							Else
								$boxarea1 = $boxarea
							EndIf
							;msgbox(0,$boxarea,$boxarea1 & " - " & $changearea)
							_setSearchCoords($boxarea1)
							Sleep($shortestdelay)
							$result = _ImageSearchArea(@ScriptDir & "\Find\Images\prop\" & $file[$i], 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
							ToolTip($file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
							Sleep($shortestdelay)
							If $result = 1 Then
								Sleep($shortdelay)
								If $boxarea = "centerfull" Then $changearea = 0
								If StringInStr($file[$i], "waypoint") = 1 Then
									_target($x1, $y1)
									Send("{ESC}")
								Else
									_autoClick(@ScriptDir & "\Find\Images\prop\" & $file[$i], $x, $y, $hitcount, $hitdelay, 0, $tolerance)
								EndIf
								Sleep($shortdelay)
								MouseMove($mouseorigin[0], $mouseorigin[1], 1)
								$notdetected = 0
								Return 1
							EndIf
						Next
					EndIf
				EndIf
			Next
			_cleanUp()
			If $usemover = 0 Then _forceMover()
			Sleep($shortestdelay)
			MouseMove($mouseorigin[0], $mouseorigin[1], 1)
			$notdetected = $notdetected + 1
			If $boxarea = "centerfull" Then
				$changearea = 1
			EndIf
			If $notdetected >= 5 Then
				ToolTip("Can't find prop" & @CRLF & "You may need to move to another area Or retake your own Screen Shots in \Find\Images\.", 0, @DesktopHeight - 35)
			EndIf
			Return 0
		EndIf
	EndIf
EndFunc   ;==>_nameSearch
;=======================================================================================
Func _mobSearch($tolerance = 75)

	If $Mode = "Fight" Then
		Local $mouseorigin = MouseGetPos()
		Local $file
		$quantity = 0
		$result = 0
		_setSearchCoords("fullscreen")
		_close()
		Send("{ALTDOWN}")
		For $quantity = 1 To $MOBLISTING[0][0] Step 1
			If $MOBLISTING[$quantity][1] = 1 Then
				$file = _FileListToArray(@ScriptDir & "\Find\Images\mob\", $MOBLISTING[$quantity][0] & "*.bmp", 1)
				If Not @error Then
					For $i = 1 To $file[0]
						Send("{ALTDOWN}")
						Sleep($shortdelay)
						$result = _ImageSearchArea(@ScriptDir & "\Find\Images\mob\" & $file[$i], 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
						ToolTip($file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
						Do
							If $result = 1 Then
								_target($x1, $y1)
								Sleep($shortdelay)
								Return 1
							EndIf
						Until $result = 0
					Next
				EndIf
			EndIf
		Next
		_cleanUp()
		If $usemover = 0 Then _forceMover()
		Sleep($shortestdelay)
		MouseMove($mouseorigin[0], $mouseorigin[1], 1)
		$notdetected = $notdetected + 1
		If $notdetected >= 5 Then
			ToolTip("Can't find mob." & @CRLF & "You may need to move to another area Or retake your own Screen Shots in \Find\Images\.", 0, @DesktopHeight - 35)
		EndIf
		Return 0
	EndIf
EndFunc   ;==>_mobSearch
;=======================================================================================
Func _cleanUp()
	ToolTip("", 0, @DesktopHeight - 20)
	_UnStuck()
	If $Mode = "" Then GUISetState(@SW_SHOW)
EndFunc   ;==>_cleanUp
;=======================================================================================
Func _UnStuck()
	Send("{CTRLUP}")
	Send("{LCTRL UP}")
	Send("{ALTUP}")
	;ControlSend("", "", "", "text", 0)
EndFunc  ;==>_UnStuck
;=======================================================================================
Func _attackAnything($2xCtrlClick)
	If Not WinActive($mabititle) And $searchmode = "Client" Then WinActivate($mabititle)
	Send("{CTRLDOWN}")
	Sleep($shortestdelay)
	MouseClick("left")
	Sleep($delay)
	If $2xCtrlClick = 1 Then MouseClick("left")
	_cleanUp()
EndFunc   ;==>_attackAnything
;=======================================================================================
Func _ctrlTarget($x1, $y1)
	MouseMove($x1, $y1, $mouse_speed)
	Sleep($delay)
	Send("{CTRLDOWN}")
	Sleep($shortdelay)
	MouseClick("left", $x1, $y1, 1, $mouse_speed)
	Sleep($shortdelay)
	_cleanUp()
	Sleep($shortestdelay)
EndFunc   ;==>_ctrlTarget
;=======================================================================================
Func _target($x1, $y1)
	If Not WinActive($mabititle) And $searchmode = "Client" Then WinActivate($mabititle)
	;Local $mouseorigin = MouseGetPos()
	MouseMove($x1, $y1, $mouse_speed)
	Sleep($shortestdelay)
	MouseClick("left")
	;Sleep($shortestdelay)
	;MouseMove($mouseorigin[0],$mouseorigin[1],1)
EndFunc   ;==>_target
;=======================================================================================
Func _selfClick($hitcount, $hitdelay, $usecurrentxy, $x, $y)
	If Not WinActive($mabititle) And $searchmode = "Client" Then WinActivate($mabititle)
	Local $mouseorigin = MouseGetPos()
	If $usecurrentxy = 1 Then
		$x1 = $mouseorigin[0]
		$y1 = $mouseorigin[1]
	Else
		$x1 = $center[0] + $x
		$y1 = $center[1] + $y
	EndIf
	For $i = 1 To $hitcount
		If Not $Mode = "" Then
			MouseMove($x1, $y1, $mouse_speed)
			Sleep($shortdelay)
			MouseClick("left")
			Sleep($shortdelay)
			MouseMove($mouseorigin[0], $mouseorigin[1], 1)
			Sleep($hitdelay)
		EndIf
	Next
EndFunc   ;==>_selfClick
;=======================================================================================
Func _autoClick($image, $x, $y, $hitcount, $hitdelay, $usecurrentxy, $tolerance = 75)
	;$num = number of hotkey,$time = delay between uses, $unit is a 1 to measure in minutes And 0 to measure in seconds, $times = times pressed,$usecurrentxy = don't use current x,y position
	Local $mouseorigin = MouseGetPos()
	Local $rndDir
	$rndDir = Int(Random(1, 4))
	If $usecurrentxy = 1 Then
		$x1 = $mouseorigin[0]
		$y1 = $mouseorigin[1]
	EndIf
	For $i = 1 To $hitcount
		_setSearchCoords($boxarea)
		Send("{ALTDOWN}")
		Sleep($shortestdelay)
		$result = _ImageSearchArea($image, 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x2, $y2, $tolerance)
		If $result = 1 Then
			If $rndDir = 1 Then
				MouseMove($x2 - Random($x / 2, $x * 1.5), $y2 + Random($y / 2, $y * 1.5), $mouse_speed)
			ElseIf $rndDir = 2 Then
				MouseMove($x2 + Random($x / 2, $x * 1.5), $y2 - Random($y / 2, $y * 1.5), $mouse_speed)
			ElseIf $rndDir = 3 Then
				MouseMove($x2 + Random($x / 2, $x * 1.5), $y2 + Random($y / 2, $y * 1.5), $mouse_speed)
			ElseIf $rndDir = 4 Then
				MouseMove($x2 - Random($x / 2, $x * 1.5), $y2 - Random($y / 2, $y * 1.5), $mouse_speed)
			EndIf
			If Not $Mode = "Mining" Then _cleanUp()
			Sleep($shortestdelay)
			MouseClick("left")
			Sleep($shortestdelay)
			MouseMove($mouseorigin[0], $mouseorigin[1], 1)
			_cleanUp()
			Sleep($hitdelay)
		EndIf
	Next
EndFunc   ;==>_autoClick
;=======================================================================================
Func _switchWeapon()
	If Not WinActive($mabititle) And $searchmode = "Client" Then WinActivate($mabititle)
	If Not $Mode = "" Then
		If IniRead("config.ini","Hotkeys","switchweapon","") = "" Then IniWrite("config.ini","Hotkeys","switchweapon","`text")
		$switchweapon = IniRead("config.ini","Hotkeys","$switchweapon","`")
		Send("{" & $switchweapon & "}")
		Sleep($delay)
	EndIf
EndFunc   ;==>_switchWeapon
;=======================================================================================
Func _useSkill($skill, $time, $times)
	;$skill = hotkey, $time = delay between uses, $times = times pressed
	If IniRead("config.ini","Hotkeys","movetargeting","") = "" Then IniWrite("config.ini","Hotkeys","movetargeting","TAB")
	$movetargeting = IniRead("config.ini","Hotkeys","movetargeting","TAB")
	Send("{" & $movetargeting & "}")
	ToolTip($skill & " = " & $time & " x " & $times, 0, @DesktopHeight - 20)
	For $i = 1 To $times
		If Not WinActive($mabititle) And $searchmode = "Client" Then WinActivate($mabititle)
		If Not $Mode = "" Then
			Send("{" & $skill & " down}")
			Sleep($time)
			Send("{" & $skill & " up}")
		EndIf
	Next
	_close()
EndFunc   ;==>_useSkill
;=======================================================================================
Func _advanceSkill()
	$tolerance = $tolerance2
	_setSearchCoords("fullscreen")
	$result = _ImageSearchArea("Find\Images\buttons\advance.bmp", 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
	If $result Then
		MouseMove($x1, $y1, $mouse_speed)
		MouseClick("left")
		Sleep($delay)
		$result = _ImageSearchArea("Find\Images\buttons\advance2.bmp", 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
		If $result Then
			MouseMove($x1, $y1, $mouse_speed)
			MouseClick("left")
			Sleep($delay)
		EndIf
		$result = _ImageSearchArea("Find\Images\buttons\ok.bmp", 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
		If $result Then
			MouseMove($x1, $y1, $mouse_speed)
			MouseClick("left")
			Sleep($delay)
		EndIf
		Return 1
	EndIf
	Return 0
EndFunc   ;==>_advanceSkill
;=======================================================================================
Func _metallurgyLoaded()
	$tolerance = $tolerance3
	If Not $Mode = "" Then
		$result = 0
		$file = _FileListToArray(@ScriptDir & "\Find\Images\buttons\", "metal*.bmp", 1)
		If Not @error Then
			For $i = 1 To $file[0]
				$result = _ImageSearchArea(@ScriptDir & "\Find\Images\buttons\" & $file[$i], 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
				Sleep($shortestdelay)
				ToolTip($file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
				If $result = 1 Then
					Return 1
				EndIf
			Next
		Else
			$result = _ImageSearchArea(@ScriptDir & "\Find\Images\buttons\metal.bmp", 1, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
			Sleep($shortestdelay)
			If $result = 1 Then
				Return 1
			EndIf
		EndIf
		$result = _ImageSearch(@ScriptDir & "\Find\Images\buttons\metal.bmp", 1, $x1, $y1, $tolerance)
		Sleep($shortestdelay)
		If $result = 1 Then
			Return 1
		EndIf
		Return 0
	EndIf
EndFunc   ;==>_metallurgyLoaded
;=======================================================================================
Func _brokenCheck()
	$tolerance = $tolerance3
	$result = 0
	$file = _FileListToArray(@ScriptDir & "\Find\Images\equip\", "broke*.bmp", 1)
	If Not @error Then
		For $i = 1 To $file[0]
			$result = _ImageSearch(@ScriptDir & "\Find\Images\equip\" & $file[$i], 1, $x1, $y1, $tolerance)
			Sleep($shortestdelay)
			If $result = 1 Then
				$broken = 0
				Return 1
			EndIf
		Next
		$broken = $broken + 1
		If $broken >= 3 Then
			_equip()
		ElseIf $broken = 4 Then
			_switchWeapon()
		ElseIf $broken >= 5 Then
			_cleanUp()
		EndIf
		Return 0
	EndIf
EndFunc   ;==>_brokenCheck
;=======================================================================================
Func _equip()
	$tolerance = $tolerance3
	Local $mouseorigin = MouseGetPos()
	Local $File1
	$result = 0
	$file = _FileListToArray(@ScriptDir & "\Find\Images\equip\", "good*.bmp", 1)
	If Not @error Then
		For $i = 1 To $file[0]
			$result = _ImageSearch(@ScriptDir & "\Find\Images\equip\" & $file[$i], 1, $x1, $y1, $tolerance)
			Sleep($shortestdelay)
			If $result = 1 Then
				$file = _FileListToArray(@ScriptDir & "\Find\Images\equip\", "broke*.bmp", 1)
				If Not @error Then
					For $i = 1 To $file[0]
						$result = _ImageSearch(@ScriptDir & "\Find\Images\equip\" & $file[$i], 1, $x2, $y2, $tolerance)
						Sleep($shortestdelay)
						If $result = 1 Then
							$broken = 0
							MouseMove($x1, $y1, $mouse_speed)
							Sleep($shortestdelay)
							MouseClick("left")
							Sleep($longestdelay)
							MouseMove($x2, $y2, $mouse_speed)
							Sleep($shortestdelay)
							MouseClick("left")
							Sleep($longestdelay)
							$File1 = StringReplace($file[$i], ".bmp", "")
							;$file1=stringreplace(_rtrim($file,"\"),".bmp","")
							If IniRead($configini, "Drop List", $File1, "0") = 0 Then
								MouseMove($x1, $y1, $mouse_speed)
							Else
								MouseMove($center[0] + 30, $center[1] + 30, $mouse_speed)
							EndIf
							Sleep($shortestdelay)
							MouseClick("left")
							Sleep($shortestdelay)
							MouseMove($mouseorigin[0], $mouseorigin[1], 1)
							Return 1
						EndIf
					Next
				EndIf
			EndIf
		Next
	EndIf
	Return 0
EndFunc   ;==>_equip
;=======================================================================================
Func _dialogue()
	;Click through Trefors dialogue If you bot near him. Some Credit goes to xsafx
	Local $coords, $colorhex = 0x896B75
	_setsearchcoords("three")
	Do
		$coords = PixelSearch($searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $colorhex, 0)
		If Not @error Then
			;found
			MouseMove($coords[0] + 50, $coords[1], 1)
			MouseClick("left")
			Sleep($shortestdelay)
		EndIf
	Until @error
EndFunc   ;==>_dialogue
;=======================================================================================
Func _lifeCheck()
	;needs rewrite
	Local $maxbar, $lIfebar[3], $damaged, $coords
	$colorhex = 0xCD398D
	$damaged = 0x630b25
	$lIfebar[0] = 0 ; 206 at 113 lIfe, 198 sub 66. 162-262 total bar.
	$lIfebar[1] = 1000
	$lIfebar[2] = 1000
	$coords = PixelSearch($lIfebar[0], $lIfebar[1], $lIfebar[2], $lIfebar[1], 0x000000, 0)
	If Not @error Then
		$maxbar = $coords
	Else
		$maxbar = $lIfebar[2]
	EndIf
	$coords = PixelSearch($lIfebar[0], $lIfebar[1], $lIfebar[2], $lIfebar[1], $damaged, 0)
	If Not @error Then
		$percent = 95 - ($maxbar - $coords)
		Return $percent
	Else
		$percent = (100 - ($lIfebar[2] - $maxbar))
		Return $percent
	EndIf
EndFunc   ;==>_lifeCheck
;=======================================================================================
Func _deathCheck()
	$tolerance = $tolerance2
	If $deathcheck = 1 Then
		Local $mouseorigin = MouseGetPos()
		_setSearchCoords("fullscreen")
		;$result = _ImageSearchArea("Find\Images\buttons\dead.bmp",1,$searchbox[0],$searchbox[1],$searchbox[2],$searchbox[3],$x1,$y1,80)
		;If $result=1 Then
		;_showWindows()
		$file = _FileListToArray(@ScriptDir & "\Find\Images\buttons\", "revivehere*.bmp", 1)
		For $i = 1 To $file[0]
			Sleep($shortestdelay)
			$result = _ImageSearchArea(@ScriptDir & "\Find\Images\buttons\" & $file[$i], 0, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $x1, $y1, $tolerance)
			ToolTip($file[$i] & " = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
			If $result = 1 Then
				MouseMove($x1, $y1, $mouse_speed)
				Sleep($shortestdelay)
				MouseClick("left")
				Sleep($longestdelay)
				_ok()
				MouseMove($mouseorigin[0], $mouseorigin[1], 1)
				Return 1
			EndIf
		Next
		;Send("{ESC}")
		;Else
		Return 0
		;EndIf
	EndIf
EndFunc   ;==>_deathCheck
;=======================================================================================
Func _logCheck()
	$tolerance = $tolerance2
	_setSearchCoords("fullscreen")
	;_showWindows()
	Sleep($longdelay)
	$result = _ImageSearch("Find\Images\buttons\F1.bmp", 0, $x1, $y1, $tolerance)
	ToolTip("F1.bmp = " & $result & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
	Sleep($shortdelay)
	If $result = 1 Then
		Return 1
	Else

	EndIf
	Return 0
EndFunc   ;==>_logCheck
;=======================================================================================
Func _login()
	;needs finished(again).
	$account = ""
	$password = ""
	$coords[0] = 550 ;account
	$coords[1] = 455 ;account
	$coords[2] = 550 ;password
	$coords[3] = 495 ;password
	$coords[4] = 520 ;login
	$coords[5] = 563 ;login
	;If $result Then
	MouseMove($coords[0], $coords[1], 1)
	Sleep($shortestdelay)
	MouseClick("left")
	Sleep($shortestdelay)
	Send($account)
	Sleep($shortestdelay)
	;EndIf
	;If $result Then
	MouseMove($coords[2], $coords[3], 1)
	Sleep($shortestdelay)
	MouseClick("left")
	Sleep($shortestdelay)
	Send($password)
	Sleep($shortestdelay)
	;EndIf
	MouseMove($coords[4], $coords[5], 1)
	MouseClick("left")
EndFunc   ;==>_login
;=======================================================================================
Func _restore()
	Local $mouseorigin = MouseGetPos()
	_setsearchcoords("fullscreen")
	$file = _FileListToArray(@ScriptDir & "\Find\Images\", "*.bmp", 1)
	For $i = 1 To $file[0]
		If $Mode = "" Or Not WinActive($mabititle) Then ExitLoop 1
		$tolerance = $tolerance1
		$fossil_x = ""
		$fossil_y = ""
		$fossil = _ImageSearchArea(@ScriptDir & "\Find\Images\" & $file[$i], 0, $searchbox[0], $searchbox[1], $searchbox[2], $searchbox[3], $fossil_x, $fossil_y, $tolerance)
		ToolTip($file[$i] & " = " & $fossil & " Tolerance = " & $tolerance, 0, @DesktopHeight - 20)
		Sleep($shortestdelay)
		If $fossil = 1 Then
			SoundPlay("found.wav")
			If _RestoreData(_rtrim($file[$i], ".bmp") & ".rst") = 1 Then
				$usefossil = 0
				If $completefossil = 1 Then MouseClick("left")
				Sleep($longestdelay)
				MouseMove($mouseorigin[0], $mouseorigin[1], 1)
				Return 1
			Else
				MsgBox(0, "", "Error")
				_UnStuck()
			EndIf
		EndIf
	Next
	If $fossil = 0 Then
		SoundPlay("error.wav")
		Sleep($shortestdelay)
		;_forceMover()
	EndIf
EndFunc   ;==>_restore
;=======================================================================================
Func _restoreData($afile)
	Local $mouseorigin = MouseGetPos()
	$file = @ScriptDir & "\Find\Macros\" & $afile
	If FileExists($file) = True Then
		FileOpen($file, 0)
		Local $i = 0
		If Not WinActive($mabititle) And $searchmode = "Client" Then WinActivate($mabititle)
		For $i = 0 To _FileCountLines($file)
			If $Mode = "" Or Not WinActive($mabititle) Then ExitLoop 1
				$line = FileReadLine($file, $i)
				$line = StringReplace($line, " ", "")
				If StringInStr($line, ",") Then
					$line = StringSplit($line, ",", 1)
					If _IsNum($line[1]) = True And _IsNum($line[2]) = True Then
						$fossil_x = $fossil_x + $fossilxoffset
						$fossil_y = $fossil_y + $fossilyoffset
						MouseMove($fossil_x + $line[1], $fossil_y + $line[2], $mouse_speed)
						ToolTip($afile & " - " & $i & "/" & _FileCountLines($file), 0, @DesktopHeight - 20)
					EndIf
				ElseIf $line = "D" Then
					MouseDown("left")
				ElseIf $line = "U" Then
					MouseUp("left")
				ElseIf $line = "!" Then
					MouseClick("left")
				Else

				EndIf
				If $afile = "egg.rst" Then
					Sleep($egg)
				Else
					Sleep($mousedelay)
				EndIf
		Next
		FileClose($file)
		If $completefossil = 1 Then MouseClick("left")
		MouseMove(100, 100, 1)
		Sleep($longdelay)
		Return 1
	Else
		MsgBox(0, "AutoBot v" & $version, $afile & " not found. Exiting...")
		Exit 5
	EndIf
EndFunc   ;==>_restoreData
;=======================================================================================
Func _errorHandler($msgs, $msgs1 = "the Lists")
	Switch $msgs
		Case 0
			MsgBox(0, "AutoBot v" & $version, "You don't appear to be an Administror; AutoBot may not function properly.")
			_UnStuck()
		Case 1
			MsgBox(0, "AutoBot v" & $version, "Error: Missing ImageSearchDLL.dll")
			ExitNow()
		Case 2
			MsgBox(0, "AutoBot v" & $version, "Error: Missing " & $configini & @CRLF & "or there is an array error with " & $msgs1 & ".")
			ExitNow()
		Case 3
			MsgBox(0, "AutoBot v" & $version, "Error: Missing " & $file & ".")
			ExitNow()
		Case 4
			MsgBox(0, "AutoBot v" & $version, "Mabinogi window not found..." & @CRLF & "AutoBot v" & $version & " will now exit.")
			ExitNow()
	EndSwitch
EndFunc   ;==>_errorHandler
;=======================================================================================
Func _setSearchCoords($box)
	; Define the coords For the search areas.
	If $box = "one" Then
		$searchbox[0] = $topleftcorner[0]
		$searchbox[1] = $topleftcorner[1]
		$searchbox[2] = $topleftcorner[0] + (($bottomrightcorner[0] - $topleftcorner[0]) / 2)
		$searchbox[3] = $topleftcorner[1] + (($bottomrightcorner[1] - $topleftcorner[1]) / 2)
	ElseIf $box = "two" Then
		$searchbox[0] = $topleftcorner[0] + (($bottomrightcorner[0] - $topleftcorner[0]) / 2)
		$searchbox[1] = $topleftcorner[1]
		$searchbox[2] = $bottomrightcorner[0]
		$searchbox[3] = $topleftcorner[1] + (($bottomrightcorner[1] - $topleftcorner[1]) / 2)
	ElseIf $box = "three" Then
		$searchbox[0] = $topleftcorner[0]
		$searchbox[1] = $topleftcorner[1] + (($bottomrightcorner[1] - $topleftcorner[1]) / 2)
		$searchbox[2] = $topleftcorner[0] + (($bottomrightcorner[0] - $topleftcorner[0]) / 2)
		$searchbox[3] = $bottomrightcorner[1]
	ElseIf $box = "four" Then
		$searchbox[0] = $topleftcorner[0] + (($bottomrightcorner[0] - $topleftcorner[0]) / 2)
		$searchbox[1] = $topleftcorner[1] + (($bottomrightcorner[1] - $topleftcorner[1]) / 2)
		$searchbox[2] = $bottomrightcorner[0]
		$searchbox[3] = $bottomrightcorner[1]
	ElseIf $box = "center" Then
		$searchbox[0] = $center[0] - 100
		$searchbox[1] = $center[1] - 100
		$searchbox[2] = $center[0] + 100
		$searchbox[3] = $center[1] + 100
	ElseIf $box = "fullscreen" Then
		$searchbox[0] = $topleftcorner[0]
		$searchbox[1] = $topleftcorner[1]
		$searchbox[2] = $bottomrightcorner[0]
		$searchbox[3] = $bottomrightcorner[1]
	ElseIf $box = "login" Then
		$searchbox[0] = 540
		$searchbox[1] = 425
		$searchbox[2] = 739
		$searchbox[3] = 604
	ElseIf $box = "connectmsg" Then
		$searchbox[0] = 522
		$searchbox[1] = 332
		$searchbox[2] = 756
		$searchbox[3] = 435
	EndIf
	If $debug = 1 Then
		_TestArea($searchbox[2] - $searchbox[0], $searchbox[3] - $searchbox[1], $searchbox[0], $searchbox[1], 5000)
		ToolTip($mabititle & " Search Area = TopLeftX: " & $searchbox[0] & " TopLeftY: " & $searchbox[1] & " BottomRightX: " & $searchbox[2] & " BottomRightY: " & $searchbox[3] & " CenterX: " & $center[0] & " CenterY: " & $center[1], 0, @DesktopHeight - 20)
	EndIf
EndFunc   ;==>_setSearchCoords
;=======================================================================================
Func _Updater()
	$ClearID = "8"
	Run("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess " & $ClearID)
	;If Not FileExists($MabiPath & "\dinput8.ini") Then Run (FileGetShortName(_RTRIM($MabiPath,"\AutoBot") & "\Update Autobot.exe"),_RTRIM($MabiPath,"\AutoBot"))
	If $checkupdate = 1 Then
		FileDelete($MabiPath & "\version.ini")
		FileDelete(_RTRIM(@ScriptDir, "\AutoBot") & "\version.ini")
		$mirror = IniRead($MabiPath & "\AutoBot\config.ini", "Settings", "mirror", "1")
		If $mirror = 1 Then
			$VersionsInfo = "http://uotiara.com/uotiara/version.ini"
		Else
			$VersionsInfo = "http://uotiara.com/shaggyze/version.ini"
		EndIf
		$VersionsInfo1 = "http://uotiara.com/shaggyze/version.ini"
		$oldVersion = IniRead($MabiPath & "\AutoBot\config.ini", "Settings", "version", "1")
		FileDelete($MabiPath & "\version.ini")
		$Ini = InetGet($VersionsInfo, $MabiPath & "\version.ini") ;download version.ini
		$newVersion = IniRead($MabiPath & "\version.ini", "version", "version", "999")
		If FileExists($MabiPath & "\version.ini") = False Then
			$Ini = InetGet($VersionsInfo1, $MabiPath & "\version.ini") ;download version.ini
		EndIf
		If FileExists($MabiPath & "\Update Autobot1.exe") Then
			FileDelete($MabiPath & "\Update Autobot.exe")
			FileMove($MabiPath & "\Update Autobot1.exe", $MabiPath & "\Update Autobot.exe")
		EndIf

		Sleep(2000)
		If Not $Ini = 0 Then ;was the download of version.ini successful?
			$newVersion = IniRead($MabiPath & "\version.ini", "version", "version", "999") ;reads the new version out of version.ini
			;msgbox(0,"",$NewVersion & " > " & $oldVersion)
			If $newVersion > $oldVersion Then ;compare old and new
				If $newVersion = "999" Then $newVersion = "Unknown"
				$msg = MsgBox(4, "Update", "There is a new AutoBot version " & $newVersion & "! You are using: " & $oldVersion & ". " & @CRLF & "Do you want to download the new version?")
				If $msg = 7 Then ;No was pressed
					FileDelete($MabiPath & "\version.ini")
				ElseIf $msg = 6 Then ;OK was pressed
					Run($MabiPath & "\Update Autobot.exe", $MabiPath)
					FileDelete($MabiPath & "\version.ini")
					Exit
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_Updater
;=======================================================================================
Func _KeyboardHook($nCode, $wParam, $lParam)
If $nCode < 0 Then Return _WinAPI_CallNextHookEx($hHookKeyboard, $nCode, $wParam, $lParam)
Local $KBDLLHOOKSTRUCT = DllStructCreate("dword vkCode;dword scanCode;dword flags;dword time;ptr dwExtraInfo", $lParam)
Local $vkCode = DllStructGetData($KBDLLHOOKSTRUCT, "vkCode")
    Switch $wParam
		Case $WM_KEYDOWN, $WM_SYSKEYDOWN
		ConsoleWrite($wParam & ": " & $vkCode & @CRLF)
		If Not $Mode = "" Then
            If $vkCode = IniRead("config.ini","Hotkeys","exit","46") Then
				IniWrite("config.ini","Hotkeys","exit",$vkCode)
				ExitNow()
			ElseIf $vkCode = IniRead("config.ini","Hotkeys","stop","36") Then
				IniWrite("config.ini","Hotkeys","stop",$vkCode)
				$Mode = ""
				_cleanUp()
			ElseIf $vkCode = IniRead("config.ini","Hotkeys","restore","88") Then
				IniWrite("config.ini","Hotkeys","restore",$vkCode)
				If $Mode = "Restoration" Or $Mode = "Mining" Then
					If _restore() = 1 Then
						If $completefossil = 1 Then MouseClick("left")
						Sleep($longestdelay)
					EndIf
				Else
					;find a use
				EndIf
			ElseIf $vkCode = IniRead("config.ini","Hotkeys","autoscan","90") Then
				IniWrite("config.ini","Hotkeys","autoscan",$vkCode)
				If $Mode = "Restoration" Or $Mode = "Mining" Then
					If $autoscan = 1 Then
						$autoscan = 4
						GUISetState(@SW_SHOW)
						ToolTip("Auto detect has been turned Off.", 0, @DesktopHeight - 20)
						Sleep($longestdelay)
						_cleanUp()
					Else
						$autoscan = 1
						GUISetState(@SW_HIDE)
						ToolTip( "Auto detect has been turned On.", 0, @DesktopHeight - 20)
						Sleep($longestdelay)
					EndIf
				Else
					;find a use
				EndIf
			ElseIf $vkCode = IniRead("config.ini","Hotkeys","pause","19") Then
				IniWrite("config.ini","Hotkeys","pause",$vkCode)
				MsgBox(262144, "Paused", "Paused for " & $pause / 1000 & " seconds or select the OK button.", $pause)
			EndIf
		EndIf
		EndSwitch
	Return _WinAPI_CallNextHookEx($hHookKeyboard, $nCode, $wParam, $lParam)
EndFunc   ;==>_KeyboardHook
;=======================================================================================
Func _keybd_event($vkCode, $Flag)
    DllCall('user32.dll', 'int', 'keybd_event', 'int', $vkCode, 'int', 0, 'int', $Flag, 'ptr', 0)
EndFunc   ;==>_keybd_event
;=======================================================================================
Func _SendEx($ss, $warn = "")
	Local $iT = TimerInit()

	While _IsPressed("10") Or _IsPressed("11") Or _IsPressed("12")
		If $warn <> "" And TimerDiff($iT) > 1000 Then
			MsgBox(262144, "Warning", $warn)
		EndIf
		Sleep(50)
	WEnd
	Send($ss)
EndFunc   ;==>_SendEx
;=======================================================================================
Func ExitNow()
	_cleanUp()
    Exit
EndFunc  ;==>ExitNow
;=======================================================================================
Func OnAutoITExit()
    DllCallbackFree($pStub_KeyProc)
    _WinAPI_UnhookWindowsHookEx($hHookKeyboard)
EndFunc   ;==>OnAutoITExit
;=======================================================================================
Func _GUICtrlListBox_ItemFromPoint($hWnd, $iX, $iY)
	Local $iRet

	If IsHWnd($hWnd) Then
		$iRet = _SendMessage($hWnd, $LB_ITEMFROMPOINT, 0, _WinAPI_MakeLong($iX, $iY))
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LB_ITEMFROMPOINT, 0, _WinAPI_MakeLong($iX, $iY))
	EndIf

	If _WinAPI_HiWord($iRet) <> 0 Then $iRet = -1
	Return $iRet
EndFunc   ;==>_GUICtrlListBox_ItemFromPoint
;=======================================================================================
Func _GUICtrlListBox_SetCurSel($hWnd, $iIndex)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SETCURSEL, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SETCURSEL, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetCurSel
;=======================================================================================
Func _WM_CONTEXTMENU($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	If $wParam <> GUICtrlGetHandle($listview) Then Return $GUI_RUNDEFMSG
	Local $cursor[2]
	$cursor = GUIGetCursorInfo($hGUI)
	Local $index = _GUICtrlListBox_ItemFromPoint($listview, $cursor[0] - 10 - 2, $cursor[1] - 10 - 2)
	If $index == -1 Then Return 0
	_GUICtrlListBox_SetCurSel($listview, $index)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_CONTEXTMENU
;=======================================================================================
Func _WM_CONTEXTMENU1($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	If $wParam <> GUICtrlGetHandle($listview1) Then Return $GUI_RUNDEFMSG
	Local $cursor[2]
	$cursor = GUIGetCursorInfo($hGUI)
	Local $index = _GUICtrlListBox_ItemFromPoint($listview1, $cursor[0] - 10 - 2, $cursor[1] - 10 - 2)
	If $index == -1 Then Return 0
	_GUICtrlListBox_SetCurSel($listview1, $index)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_CONTEXTMENU1
;=======================================================================================
Func _SetBitmap($hGUI, $hImage, $iOpacity, $n_width, $n_height)
	Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend
	$hScrDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	$hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
	$tSize = DllStructCreate($tagSIZE)
	$pSize = DllStructGetPtr($tSize)
	DllStructSetData($tSize, "X", $n_width)
	DllStructSetData($tSize, "Y", $n_height)
	$tSource = DllStructCreate($tagPOINT)
	$pSource = DllStructGetPtr($tSource)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	$pBlend = DllStructGetPtr($tBlend)
	DllStructSetData($tBlend, "Alpha", $iOpacity)
	DllStructSetData($tBlend, "Format", 1)
	_WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
	_WinAPI_ReleaseDC(0, $hScrDC)
	_WinAPI_SelectObject($hMemDC, $hOld)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>_SetBitmap
;=======================================================================================
Func _ImageResize($sInImage, $newW, $newH, $sOutImage = "")
	Local $oldImage, $GC, $newBmp, $newGC
	If $sOutImage = "" Then _GDIPlus_Startup()
	$oldImage = _GDIPlus_ImageLoadFromFile($sInImage)
	$GC = _GDIPlus_ImageGetGraphicsContext($oldImage)
	$newBmp = _GDIPlus_BitmapCreateFromGraphics($newW, $newH, $GC)
	$newGC = _GDIPlus_ImageGetGraphicsContext($newBmp)
	_GDIPlus_GraphicsDrawImageRect($newGC, $oldImage, 0, 0, $newW, $newH)
	_GDIPlus_GraphicsDispose($GC)
	_GDIPlus_GraphicsDispose($newGC)
	_GDIPlus_ImageDispose($oldImage)
	If $sOutImage = "" Then
		Return $newBmp
	Else
		_GDIPlus_ImageSaveToFile($newBmp, $sOutImage)
		_GDIPlus_BitmapDispose($newBmp)
		_GDIPlus_Shutdown()
		Return 1
	EndIf
EndFunc   ;==>_ImageResize
;=======================================================================================
Func _TestArea($x1, $y1, $x2, $y2, $delay)
	$SELECT_H = GUICreate("AU3SelectionBox", $x1, $y1, $x2, $y2, $WS_POPUP + $WS_BORDER, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW)
	GUISetBkColor(0xFF00FF, $SELECT_H)
	WinSetTrans("AU3SelectionBox", "", 60)
	GUISetState(@SW_SHOW, $SELECT_H)
	GUISetState(@SW_RESTORE, $SELECT_H)
	Sleep($delay)
	GUISetState(@SW_HIDE, $SELECT_H)
EndFunc   ;==>_TestArea
#endregion Core functions