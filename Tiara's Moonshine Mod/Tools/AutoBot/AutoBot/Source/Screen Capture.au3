#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Find\Images\gui\splash.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_LegalCopyright=ShaggyZE
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;==============================================
; Author: Toady
;
; Purpose: Takes screenshot of
; a user selected region and saves
; the screenshot in \Find\Images\ directory.
;
; Rewrite by Ashaman42 for latest UDF's
; Modified by ShaggyZE for Mabinogi/AutoBot
;
; How to use:
; Press "a" key to select region corners.
; NOTE: Must select top-left of region
; first, then select bottom-right of region.
;=============================================

#include <ScreenCapture.au3>
#include <misc.au3>
#include <GuiConstants.au3>
#include <WinAPI.au3>
#Include <GuiListBox.au3>
#Include <GuiStatusBar.au3>
#include <GDIPlus.au3>
#include <WindowsConstants.au3>
#include <ImageSearch2015.au3>
Global $x1,$y1
_Singleton("cap")
Opt("TrayAutoPause",0)

Global $format = ".bmp"
Global $filename = "Image"
Global $title = "Screen Region Capture"
Global $width
Global $height
Global $hwndd
$GUI = GUICreate($title,610,210)
$GUI1 = GuiCtrlCreatePic("Find\Images\gui\gui.bmp",0,0,610,210)
GuiCtrlSetState(-1,$GUI_DISABLE)
GUICtrlCreateGroup ("",-99,-99,1,1)
GUICtrlCreateLabel("Name of image",20,0)
GUICtrlSetBkColor(-1, 0x000000)
GUICtrlSetColor(-1, 0xFFFFFF)
$gui_img_input = GUICtrlCreateInput("",20,20,200,20)
GUICtrlSetData($gui_img_input,$filename)
GUICtrlCreateLabel("Directory of image",20,40)
GUICtrlSetBkColor(-1, 0x000000)
GUICtrlSetColor(-1, 0xFFFFFF)
$gui_dir_combo = GUICtrlCreateCombo("",20,60,200,20)
GUICtrlSetData($gui_dir_combo,"Prop|Item|Use|Mob|Equip|Drop|Npc|Buttons|Clicker","Prop")
GUICtrlCreateLabel("Tolerance",20,85)
GUICtrlSetBkColor(-1, 0x000000)
GUICtrlSetColor(-1, 0xFFFFFF)
$gui_tol_input = GUICtrlCreateInput("",20,105,200,20)
GUICtrlSetData($gui_tol_input,75)
$go_button = GUICtrlCreateButton("Select region",20,140,200,30)
$list = GUICtrlCreateList("",240,20,150,150)
$testbutton = GUICtrlCreateButton("Test", 400,20,40)
$editbutton = GUICtrlCreateButton("Edit", 400,60,40)
$deletebutton = GUICtrlCreateButton("Delete", 400,100,40)
$exitbutton = GUICtrlCreateButton("Exit", 400,140,40)
Global $a_PartsRightEdge[5] = [240,320,400,480,-1]
Global $a_PartsText[5] = [@TAB & "ShaggyZE","","","",""]
Global $hImage
$statusbar = _GUICtrlStatusBar_Create($GUI,$a_PartsRightEdge,$a_PartsText)
GUISetState(@SW_SHOW,$GUI)

$GUI3 = GUICreate("", 0 , 0 , 0,0 ,  BitOR($WS_POPUP,$WS_BORDER), BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
GUISetBkColor(0xFF0000,$GUI3)
GUISetState(@SW_HIDE)

$SELECT_H =  GUICreate( "AU3SelectionBox", 0 , 0 , 0, 0,  $WS_POPUP + $WS_BORDER, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW)
GUISetBkColor(0x00FFFF,$SELECT_H)
WinSetTrans("AU3SelectionBox","",60)
GUISetState(@SW_SHOW,$SELECT_H)

Global $box[4], $file = @ScriptDir & "\tmp.bmp"

_ListFiles()

While 1
    $msg = GUIGetMsg()
    Select

        Case $msg = $GUI_EVENT_CLOSE
            Exit
        Case $msg = $GUI_EVENT_RESTORE
            _ListFiles()
		Case $msg = $editbutton
		 			$filename =  StringTrimRight(_GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)),4)
			If $filename <> "" Then
			GUICtrlSetData($gui_img_input,$filename)
			EndIf
            ShellExecute(_GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)),"",@ScriptDir & "\Find\Images\" & guictrlread($gui_dir_combo) & "\","edit")
        Case $msg = $deletebutton
            Local $msgbox = MsgBox(4,"Delete image","Are you sure?")
            If $msgbox = 6 Then
                FileDelete(@ScriptDir & "\Find\Images\" & guictrlread($gui_dir_combo) & "\" & _GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)))
                _ListFiles()
            EndIf
        Case $msg = $exitbutton
            Exit
        Case $msg = $list
            _ListClick()
		Case $msg = $gui_dir_combo
			_ListFiles()
        Case $msg = $go_button
            $filename = GUICtrlRead($gui_img_input)
            If $filename <> "" Then
                Local $msgbox = 6
				if $filename = "Image" then
					MsgBox(0,"Error","Enter a filename other then 'Image'")
				Else
					If FileExists(@ScriptDir & "\Find\Images\"  & guictrlread($gui_dir_combo) & "\" & $filename & $format) Then
						$msgbox = MsgBox(4,"Already Exists","File name already exists, do you want to overwrite it?")
					endif
					If $msgbox = 6 Then
						GUISetState(@SW_HIDE,$GUI)
						Local $box[4]
						If Not WinActive("[CLASS:Mabinogi]") Then WinActivate("[CLASS:Mabinogi]")
							$box= WinGetClientSize(WinGetTitle("[CLASS:Progman]"))
							$width=$box[0]
							$height=$box[1]
							$hwndd=WinGetHandle("[CLASS:Progman]")

					sleep(2000)
					Send ("{ALTDOWN}")
					sleep(2000)
					_ScreenCapture_CaptureWnd($file, $hwndd, 0, 0, $width+5, $height+30, 0)
					sleep(2000)
					Send ("{ALTUP}")
					;Run('mspaint "'&$file&'"')
					;WinWaitActive("[CLASS:MSPaintApp]")
					Local $n
					$GUI2 = GUICreate("Screen Capture", $width+5, $height+30, -1, -1, $WS_SIZEBOX + $WS_SYSMENU) ; will create a dialog box that when displayed is centered
					 GUISetBkColor(0xE0FFFF)
					$n = GUICtrlCreatePic($file, 0, 0, $width, $height)
					GUICtrlSetImage($n, $file)
					 $n = GUICtrlSetPos($n, 0, 0, $width, $height)
					GUISetState(@SW_SHOW,$GUI2)
                    ;_WinAPI_MoveWindow($SELECT_H,1,1,2,2)
                    GUISetState(@SW_RESTORE,$SELECT_H)
                    GUISetState(@SW_SHOW,$SELECT_H)
					GUISetState(@SW_SHOW,$GUI3)
                    _TakeScreenShot()
					GUISetState(@SW_HIDE,$GUI2)
                    GUISetState(@SW_SHOW,$GUI)
					sleep(2000)
                    _ListFiles()
					Local $checklist
					For $checklist=0 to _GUICtrlListBox_GetCount($list)-1
					if _GUICtrlListBox_GetText($list,$checklist)=guictrlread($gui_img_input) & ".bmp" then _GUICtrlListBox_SetCurSel($list,$checklist)
					next
					;GUICtrlSetData($gui_img_input,"Image")
					_ListClick()
					EndIf
				EndIf
			Else
                MsgBox(0,"Error","Enter a filename")
			EndIf
		Case $msg = $testbutton
			$filename =  StringTrimRight(_GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)),4)
			If $filename <> "" Then
			GUICtrlSetData($gui_img_input,$filename)
			EndIf
				WinActivate("[CLASS:Mabinogi]")
				sleep(2000)
				Send ("{ALTDOWN}")
				sleep(1000)
				$result=_ImageSearch(@ScriptDir & "\Find\Images\" & guictrlread($gui_dir_combo) & "\" & guictrlread($gui_img_input) & ".bmp",1,$x1,$y1,guictrlread($gui_tol_input))
				if $result=1 Then
					MouseMove($x1,$y1)
					msgbox(0,"Test Image","Found " & guictrlread($gui_img_input) & ".bmp")
				Else
					msgbox(0,"Test Image",guictrlread($gui_img_input) & ".bmp Not Found.")
				endif
				Send ("{ALTUP}")

    EndSelect
WEnd

Func _ConvertSize($size_bytes)
    If $size_bytes < 1024*1024 Then
        Return Round($size_bytes/1024,2) & " KB"
    Else
        Return Round($size_bytes/1024/1024,2) & " MB"
    EndIf
EndFunc

Func _ConvertTime($time)
    Local $time_converted = $time
    Local $time_data = StringSplit($time, ":")
    If $time_data[1] > 12 Then
        $time_converted = $time_data[1] - 12 & ":" & $time_data[2] & " PM"
    ElseIf $time_data[1] = 12 Then
        $time_converted = $time & " PM"
    Else
        $time_converted &= " AM"
    EndIf
    Return $time_converted
EndFunc

Func _ListClick()
    If _GUICtrlListBox_GetCurSel($list) = -1 Then ;List clicked but nothing selected
        Return
    EndIf
    GUICtrlSetState($deletebutton, $GUI_ENABLE)
    GUICtrlSetState($editbutton, $GUI_ENABLE)
    Local $date = FileGetTime(@ScriptDir & "\Find\Images\" & guictrlread($gui_dir_combo) & "\" & _GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)))
    _GUICtrlStatusBar_SetText($statusbar,@tab & "Size: " & _ConvertSize(FileGetSize(@ScriptDir & "\Find\Images\" & guictrlread($gui_dir_combo) & "\" & _GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)))),1)
    _GUICtrlStatusBar_SetText($statusbar,@tab & "Date: " & $date[1] & "/" & $date[2] & "/" & StringTrimLeft($date[0],2) & " " & _ConvertTime($date[3] & ":" & $date[4]),4)
    _GDIPlus_StartUp()
    $hImage  = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\Find\Images\" & guictrlread($gui_dir_combo) & "\" & _GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)))
    $hGraphic = _GDIPlus_GraphicsCreateFromHWND($gui)
    $iWidth  = _GDIPlus_ImageGetWidth ($hImage)
    $iHeight = _GDIPlus_ImageGetHeight($hImage)
    _GUICtrlStatusBar_SetText($statusbar,@tab & "Width: " & $iWidth,2)
    _GUICtrlStatusBar_SetText($statusbar,@tab & "Height: " & $iHeight,3)
    Local $destW = 150
    Local $destH = 150
    _GDIPlus_GraphicsDrawImageRectRect($hGraphic, $hImage, 0, 0,$iWidth,$iHeight,450,20,$destW ,$destH)
    _GDIPlus_GraphicsSetSmoothingMode($hGraphic, 0)
    _GDIPlus_GraphicsDrawRect($hGraphic, 450, 20, $destW, $destH)
    _GDIPlus_GraphicsDispose($hGraphic)
    _GDIPlus_ImageDispose($hImage)
    _GDIPlus_ShutDown()
EndFunc

Func _TakeScreenShot()

    Local $x, $y
    HotKeySet("a","_DoNothing")
    While Not _IsPressed('41')
        Local $currCoord = MouseGetPos()
		WinMove($GUI3,"",$currCoord[0]-2.5,$currCoord[1]-2.5,5,5)
        Sleep(10)
        ToolTip("Select top-left coord with 'a' key" & @CRLF & "First coord: " & $currCoord[0] & "," & $currCoord[1])
        If _IsPressed('41') Then
            While _IsPressed('41')
                Sleep(10)
            WEnd
            ExitLoop 1
        EndIf
    WEnd
    Local $firstCoord = MouseGetPos()
    _WinAPI_MoveWindow($SELECT_H,$firstCoord[0],$firstCoord[1],1,1)
    While Not _IsPressed('41')
        Local $currCoord = MouseGetPos()
		WinMove($GUI3,"",$currCoord[0]-2.5,$currCoord[1]-2.5,5,5)
        Sleep(10)
        ToolTip("Select bottom-right coord with 'a' key" & @CRLF & "First coord: " & $firstCoord[0] & "," & $firstCoord[1] _
        & @CRLF & "Second coord: " & $currCoord[0] & "," & $currCoord[1] & @CRLF & "Image size: " & _
        Abs($currCoord[0]-$firstCoord[0]) & "x" & Abs($currCoord[1]-$firstCoord[1]))
        $x = _RubberBand_Select_Order($firstCoord[0],$currCoord[0])
        $y = _RubberBand_Select_Order($firstCoord[1],$currCoord[1])
        _WinAPI_MoveWindow($SELECT_H,$x[0],$y[0],$x[1],$y[1])
        If _IsPressed('41') Then
            While _IsPressed('41')
                Sleep(10)
            WEnd
            ExitLoop 1
        EndIf
    WEnd
    ToolTip("")
    Local $secondCoord = MouseGetPos()
    _WinAPI_MoveWindow($SELECT_H,1,1,2,2)
    GUISetState(@SW_HIDE,$SELECT_H)
	GUISetState(@SW_HIDE,$GUI3)
    Sleep(100)
    ;_ScreenCapture_SetJPGQuality(100)
	_ScreenCapture_SetBMPFormat(2)

	_ScreenCapture_Capture(@ScriptDir & "\Find\Images\"  & guictrlread($gui_dir_combo) & "\" & $filename & $format, $x[0], $y[0], $x[1]+$x[0], $y[1]+$y[0], 0)
ProcessClose("mspaint.exe")
FileDelete($file)
    HotKeySet("a")
EndFunc

Func _ListFiles()

    _GUICtrlListBox_ResetContent($list)
    $search = FileFindFirstFile(@ScriptDir & "\Find\Images\" & guictrlread($gui_dir_combo) & "\*.bmp")
    If $search <> -1 Then
        While 1
            Local $file = FileFindNextFile($search)
            If @error Then ExitLoop
            If StringRegExp($file,"(.bmp)") Then
                $test_error = _GUICtrlListBox_AddFile($list, @ScriptDir & "\Find\Images\" & guictrlread($gui_dir_combo) & "\" & $file)
            EndIf
        WEnd
    EndIf
    FileClose($search)
    If _GUICtrlListBox_GetCurSel($list) = -1 Then  ; No selection
        GUICtrlSetState($deletebutton, $GUI_DISABLE)
        GUICtrlSetState($editbutton, $GUI_DISABLE)
        _GUICtrlStatusBar_SetText($statusbar,"",1)
        _GUICtrlStatusBar_SetText($statusbar,"",2)
        _GUICtrlStatusBar_SetText($statusbar,"",3)
        _GUICtrlStatusBar_SetText($statusbar,"",4)
        _GDIPlus_Startup()
        $hGraphicss = _GDIPlus_GraphicsCreateFromHWND($GUI)
        _GDIPlus_GraphicsFillRect($hGraphicss, 450, 20, 150, 150)
        _GDIPlus_GraphicsDispose($hGraphicss)
        _GDIPlus_Shutdown()
        _DrawText("Preview",495, 80)
    Else
        GUICtrlSetState($deletebutton, $GUI_ENABLE)
        GUICtrlSetState($editbutton, $GUI_ENABLE)
        _GUICtrlListBox_GetCurSel($list)
        WinWaitActive("Screen Region Capture")
        _ListClick()
    EndIf
EndFunc

Func _DrawText($text,$x, $y)
    _GDIPlus_Startup()
    $hGraphic = _GDIPlus_GraphicsCreateFromHWND($GUI)
    $hBrush   = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
    $hFormat  = _GDIPlus_StringFormatCreate()
    $hFamily  = _GDIPlus_FontFamilyCreate("Arial")
    $hFont    = _GDIPlus_FontCreate($hFamily, 12, 2)
    $tLayout  = _GDIPlus_RectFCreate($x, $y, 0, 0)
    $aInfo    = _GDIPlus_GraphicsMeasureString($hGraphic, $text, $hFont, $tLayout, $hFormat)
    _GDIPlus_GraphicsDrawStringEx($hGraphic, $text, $hFont, $aInfo[0], $hFormat, $hBrush)
    _GDIPlus_FontDispose        ($hFont   )
    _GDIPlus_FontFamilyDispose  ($hFamily )
    _GDIPlus_StringFormatDispose($hFormat )
    _GDIPlus_BrushDispose       ($hBrush  )
    _GDIPlus_GraphicsDispose    ($hGraphic)
    _GDIPlus_Shutdown()
EndFunc

Func _RubberBand_Select_Order($a,$b)
    Dim $res[2]
    If $a < $b Then
        $res[0] = $a
        $res[1] = $b - $a
    Else
        $res[0] = $b
        $res[1] = $a - $b
    EndIf
    Return $res
EndFunc

Func _DoNothing()
EndFunc