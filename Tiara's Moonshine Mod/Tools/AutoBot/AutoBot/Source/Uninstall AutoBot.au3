#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=AutoBot\Find\Images\gui\splash.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_LegalCopyright=ShaggyZE
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
if ProcessExists("client.exit") Then
msgbox(0,"AutoBot","Please close Mabinogi before Uninstalling")
Exit
endif
Local $var
$var=msgbox(4,"AutoBot","Uninstall AutoBot?")
if $var=6 then
$var=msgbox(4,"AutoBot","Remove ZE Patcher?")
if $var=6 then
If FileExists("C:\Nexon\Mabinogi\Mss32.zep") then
FileDelete("C:\Nexon\Mabinogi\Mss32.dll")
FileDelete("C:\Nexon\Mabinogi\ZEP.ini")
FileMove("C:\Nexon\Mabinogi\Mss32.zep","C:\Nexon\Mabinogi\Mss32.dll")
endif
If FileExists("C:\Nexon\Mabinogi\dbghelp.zep") then
FileDelete("C:\Nexon\Mabinogi\dbghelp.dll")
FileDelete("C:\Nexon\Mabinogi\ZEP.ini")
FileMove("C:\Nexon\Mabinogi\dbghelp.zep","C:\Nexon\Mabinogi\dbghelp.dll")
endif
EndIF
FileDelete("C:\Nexon\Mabinogi\Shortcut.vbs")
FileDelete("C:\Nexon\Mabinogi\version.ini")
FileDelete("C:\Nexon\Mabinogi\zep.log")
FileDelete("C:\Nexon\Mabinogi\zep_startuplog.txt")
FileDelete("C:\Nexon\Mabinogi\Patcher.ini")
do
ProcessClose("AutoBot.exe")
sleep(100)
until ProcessExists("AutoBot.exe")=False
DirRemove("C:\Nexon\Mabinogi\AutoBot",1)
DirRemove("C:\Nexon\Mabinogi\Support",1)
DirRemove("C:\Nexon\Mabinogi\ZEP-Vista",1)
DirRemove("C:\Nexon\Mabinogi\ZEP-ReleaseWindows7",1)
DirRemove("C:\Nexon\Mabinogi\ZEP-PreWin7",1)
$var=msgbox(4,"AutoBot","Delete data packer?")
if $var=6 then
FileDelete("C:\Nexon\Mabinogi\DATA packer.exe")
EndIf
FileDelete(@DesktopDir & "\AutoBot.lnk")
msgbox(0,"AutoBot","Uninstall Complete.")
SuiCide()
Exit
EndIf
Func SuiCide()
    $SC_File = @ScriptDir & "\suicide.bat"
    FileDelete($SC_File)
    $SC_batch = ':loop' & @CRLF & 'del "' & @SCRIPTFULLPATH & '"'  & @CRLF & _
         'ping -n 1 -w 250 127.0.0.1' & @CRLF & 'if exist "' & @SCRIPTFULLPATH & _
        '" goto loop' & @CRLF & 'del suicide.bat' & @CRLF

    FileWrite($SC_File,$SC_batch)
    Run($SC_File,@ScriptDir,@SW_HIDE)
    Exit
EndFunc