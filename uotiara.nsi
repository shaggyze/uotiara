RequestExecutionLevel admin
!define UOSHORTVERSION        "446"
!define UOLONGVERSION         "0.58.77"
!define UOSHORTNAME           "UO Tiaras Moonshine Mod"
!define UOVERSION             "${UOSHORTVERSION}.${UOLONGVERSION}"
!define UOLONGNAME            "UO Tiaras Moonshine Mod V${UOVERSION}"
!define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UOSHORTNAME}"
!define InstFile "${UOLONGNAME}.exe"
!define AbyssEnable "False"
!define KananEnable "False"
!define KananUpdateEnable "True"
!define HyddwnEnable "True"
!define HyddwnUpdateEnable "True"
!define Lib-LoaderEnable "True"
!define mabi-pack2ForceInstall "True"
!define MUI_UI ".\bin\modern.exe"

!addincludedir ".\bin"
!addplugindir ".\bin"

Name "${UOSHORTNAME} ${UOVERSION}"
AllowRootDirInstall true
OutFile "${InstFile}"
XPStyle on
SetCompressor /SOLID /FINAL lzma
;ChangeUI all ".\bin\modern.exe"
VIAddVersionKey "ProductName" "${UOSHORTNAME}"
VIAddVersionKey "ProductVersion" ${UOVERSION}
VIAddVersionKey "Comments" "https://shaggyze.github.io/uotiara/"
VIAddVersionKey "CompanyName" "ShaggyZE"
VIAddVersionKey "LegalTrademarks" "${UOSHORTNAME} by ShaggyZE"
VIAddVersionKey "LegalCopyright" "ShaggyZE"
VIAddVersionKey "FileDescription" "${UOSHORTNAME} ${UOVERSION}"
VIAddVersionKey "FileVersion" ${UOVERSION}
VIProductVersion ${UOVERSION}
!define HWND_TOP              0
!define SWP_NOSIZE            0x0001
!define SWP_NOMOVE            0x0002
!define IDC_BITMAP            1500
!define LOGICLIB_SECTIONCMP
!define SECTION_ON             ${SF_SELECTED}
;!define SECTION_ON            0x80000000
;!define SECTION_OFF           0xFFFFFFFE
!define SF_UNSELECTED          128
!define SECTIONCOUNT           11
;!define LVM_GETITEMCOUNT 0x1004
;!define LVM_GETITEMTEXT 0x102D
!define screenimage            "misc\background.bmp"
!define srcdir                 "."
!define StrStr "!insertmacro StrStr"
!define StrContains '!insertmacro "_StrContainsConstructor"'

Var AbyssLoadKanan
Var LibLoaderLoadKanan

Var AR_SecFlags
Var AR_RegFlags
Var AR_RegFlags2

Var STR_HAYSTACK
Var STR_NEEDLE
Var STR_CONTAINS_VAR_1
Var STR_CONTAINS_VAR_2
Var STR_CONTAINS_VAR_3
Var STR_CONTAINS_VAR_4
Var STR_RETURN_VAR


!macro _StrContainsConstructor OUT NEEDLE HAYSTACK
  Push `${HAYSTACK}`
  Push `${NEEDLE}`
  Call StrContains
  Pop `${OUT}`
!macroend

!macro StrStr ResultVar String SubString
  Push `${String}`
  Push `${SubString}`
  Call StrStr
  Pop `${ResultVar}`
!macroend

!macro InitSection SecName
  ;  This macro reads component installed flag from the registry and
  ;changes checked state of the section on the components page.
  ;Input: section index constant name specified in Section command.

  ClearErrors
  ;Reading component status from registry
  ReadRegDWORD $AR_RegFlags HKLM \
    "${REG_UNINSTALL}\Components\${SecName}" "Installed"
  IfErrors "default_${SecName}"
    ;Status will stay default if registry value not found
    ;(component was never installed)
  IntOp $AR_RegFlags $AR_RegFlags & 0x0001  ;Turn off all other bits
  SectionGetFlags ${${SecName}} $AR_SecFlags  ;Reading default section flags
  IntOp $AR_SecFlags $AR_SecFlags & 0xFFFE  ;Turn lowest (enabled) bit off
  IntOp $AR_SecFlags $AR_RegFlags | $AR_SecFlags      ;Change lowest bit

  ;Writing MODified flags
  SectionSetFlags ${${SecName}} $AR_SecFlags

 "default_${SecName}:"
!macroend

!macro FinishSection SecName
  ;  This macro reads section flag set by user and removes the section
  ;if it is not selected.
  ;Then it writes component installed flag to registry
  ;Input: section index constant name specified in Section command.

  SectionGetFlags ${${SecName}} $AR_SecFlags ;Reading section flags
  ;Checking lowest bit:
  IntOp $AR_SecFlags $AR_SecFlags & 0x0001
  IntCmp $AR_SecFlags 1 "leave_${SecName}"
    ;Section is not selected:
    ;Calling Section uninstall macro and writing zero installed flag
    !insertmacro "Remove_${${SecName}}"
    WriteRegDWORD HKLM "${REG_UNINSTALL}\Components\${SecName}" \
  "Installed" 0
    Goto "exit_${SecName}"

 "leave_${SecName}:"
    ;Section is selected:
    WriteRegDWORD HKLM "${REG_UNINSTALL}\Components\${SecName}" \
  "Installed" 1

 "exit_${SecName}:"
!macroend


;--- End of Add/Remove macros ---
!define stRECT "(i, i, i, i) i"
!define FontBMPCreate "!insertmacro FontBMPCreate"
!define FontBMPChange "!insertmacro FontBMPChange"
;!include x64.nsh
;!include Sections.nsh
!include nsDialogs.nsh
!include WinMessages.nsh
;!include Image.nsh
;!include MUI2.nsh
  !include "MUI.nsh"
!include nsProcess.nsh
!include LogicLib.nsh
!include "FileFunc.nsh"
!include WinMessages.nsh
!insertmacro GetTime

SetDatablockOptimize on
CRCCheck on

AutoCloseWindow true
;ShowInstDetails hide
SetDateSave on
ShowInstDetails show
;Var MUI_HWND
Var Image
Var FontBMP
;Var Abyss
;Var Kanan
;Var AutoBot
Var NEWUOVERSION
Var NEWMABIVERSION

!ifdef icon
Icon "${icon}"
!endif
!ifdef screenimage

!macro FontBMPCreate File
  StrCpy $R7 "Begin FontBMPCreate"
  Call DumpLog1

  Push "${File}"
  Call FontBMPCreate

  StrCpy $R7 "End FontBMPCreate"
  Call DumpLog1
!macroend

!macro FontBMPChange File
  Push "${File}"
  Call FontBMPChange
!macroend

!macro DestroyWindow HWND IDC
  GetDlgItem $R9 ${HWND} ${IDC}
  System::Call `user32::DestroyWindow(i R9)`
!macroend

; Give window transparent background.
!macro SetTransparent HWND IDC
  GetDlgItem $R9 ${HWND} ${IDC}
  SetCtlColors $R9 0xFFFFFF transparent
!macroend

; Refresh window.
!macro RefreshWindow HWND IDC
  GetDlgItem $R9 ${HWND} ${IDC}
  ShowWindow $R9 ${SW_HIDE}
  ShowWindow $R9 ${SW_SHOW}

!macroend

;Save selected sections
!macro SaveSections VAR
  StrCpy ${VAR} 0
  ${ForEach} $R0 ${SECTIONCOUNT} 0 - 1
    IntOp ${VAR} ${VAR} << 1
    ${If} ${SectionIsSelected} $R0
      IntOp ${VAR} ${VAR} + 1
    ${EndIf}
  ${Next}
!macroend

!macro ShellExecWait verb app param workdir show exitoutvar ;only app and show must be != "", every thing else is optional
#define SEE_MASK_NOCLOSEPROCESS 0x40
System::Store S
!if "${NSIS_PTR_SIZE}" > 4
!define /ReDef /math SYSSIZEOF_SHELLEXECUTEINFO 14 * ${NSIS_PTR_SIZE}
!else ifndef SYSSIZEOF_SHELLEXECUTEINFO
!define SYSSIZEOF_SHELLEXECUTEINFO 60
!endif
System::Call '*(&i${SYSSIZEOF_SHELLEXECUTEINFO})i.r0'
System::Call '*$0(i ${SYSSIZEOF_SHELLEXECUTEINFO},i 0x40,p $hwndparent,t "${verb}",t $\'${app}$\',t $\'${param}$\',t "${workdir}",i ${show})p.r0'
System::Call 'shell32::ShellExecuteEx(t)(pr0)i.r1 ?e' ; (t) to trigger A/W selection
${If} $1 <> 0
	System::Call '*$0(is,i,p,p,p,p,p,p,p,p,p,p,p,p,p.r1)' ;stack value not really used, just a fancy pop ;)
	System::Call 'kernel32::WaitForSingleObject(pr1,i-1)'
	System::Call 'kernel32::GetExitCodeProcess(pr1,*i.s)'
	System::Call 'kernel32::CloseHandle(pr1)'
${EndIf}
System::Free $0
!if "${exitoutvar}" == ""
	pop $0
!endif
System::Store L
!if "${exitoutvar}" != ""
	pop ${exitoutvar}
!endif
!macroend


  !ifndef NOINSTTYPES # allow user to switch the usage of InstTypes
    InstType "Full"                   # This is INSTTYPE_1
    InstType "Typical"                # INSTTYPE_2
    InstType "Minimal"                # INSTTYPE_3
    InstType "None"                   # guess what? INSTTYPE_4!
  !endif

!define MUI_ABORTWARNING
!define MUI_ICON "misc\Tiaras Moonshine Icon.ico"
!define MUI_UNICON "misc\Tiaras Moonshine Icon.ico"
!define MUI_CUSTOMFUNCTION_GUIINIT myonguiinit
;!define MUI_LICENSEPAGE_TEXT_TOP "Information"
!insertmacro MUI_PAGE_LICENSE "README.md"
!define MUI_DIRECTORYPAGE_TEXT_TOP "Directory containing Client.exe to install ${UOLONGNAME} in:"
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Destination Folder Containing Client.exe"
!insertmacro MUI_PAGE_DIRECTORY
;!define MUI_COMPONENTSPAGE_CHECKBITMAP ${screenimage}
!define MUI_COMPONENTSPAGE_NODESC
ComponentText " Choose Mods to Install."
page components "" FontBMPChange
!define MUI_DIRECTORYPAGE_TEXT_TOP "Directory to install ${UOLONGNAME} in:"
;!define MUI_INSTFILESPAGE_COLORS "FFFFFF 000000" ;Multiple settings
!insertmacro MUI_PAGE_INSTFILES
  !define MUI_PAGE_CUSTOMFUNCTION_PRE fin_pre
  !define MUI_PAGE_CUSTOMFUNCTION_SHOW fin_show
  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE fin_leave
  !define MUI_FINISHPAGE_SHOWREADME "$TEMP\README.md"
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_FUNCTION Show_Config
  !define MUI_FINISHPAGE_RUN_TEXT "Show Config/s"
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

Function Trim
	Exch $R1 ; Original string
	Push $R2

Loop:
	StrCpy $R2 "$R1" 1
	StrCmp "$R2" " " TrimLeft
	StrCmp "$R2" "$\r" TrimLeft
	StrCmp "$R2" "$\n" TrimLeft
	StrCmp "$R2" "	" TrimLeft ; this is a tab.
	GoTo Loop2
TrimLeft:
	StrCpy $R1 "$R1" "" 1
	Goto Loop

Loop2:
	StrCpy $R2 "$R1" 1 -1
	StrCmp "$R2" " " TrimRight
	StrCmp "$R2" "$\r" TrimRight
	StrCmp "$R2" "$\n" TrimRight
	StrCmp "$R2" "	" TrimRight ; this is a tab
	GoTo Done
TrimRight:
	StrCpy $R1 "$R1" -1
	Goto Loop2

Done:
	Pop $R2
	Exch $R1
FunctionEnd

Function Show_Config
BgImage::Destroy
SetOutPath "$INSTDIR"
IfFileExists $INSTDIR\Abyss.ini AbyssFound4 AbyssNotFound4
AbyssFound4:
IfFileExists $INSTDIR\Kanan\Kanan.dll KananFound4 KananNotFound4
KananFound4:
${If} $AbyssLoadKanan == "1"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "LoadDLL" "Kanan\Kanan.dll"
${EndIf}
KananNotFound4:
Exec '"notepad.exe" "$INSTDIR\Abyss.ini"'
AbyssNotFound4:

IfFileExists $INSTDIR\Loader.cfg Lib-LoaderFound4 Lib-LoaderNotFound4
Lib-LoaderFound4:
IfFileExists $INSTDIR\Kanan\Kanan.dll KananFound41 KananNotFound41
KananFound41:
${If} $LibLoaderLoadKanan == "1"
WriteINIStr "$INSTDIR\Loader.cfg" "Loader" "Files" "Kanan.dll"
${EndIf}
KananNotFound41:
Lib-LoaderNotFound4:
IfFileExists $INSTDIR\Loader.cfg 0 +2
Exec '"notepad.exe" "$INSTDIR\Loader.cfg"'
IfFileExists $INSTDIR\Kanan\config.txt 0 +2
Exec '"notepad.exe" "$INSTDIR\Kanan\config.txt"'
IfFileExists $INSTDIR\UOTiaraPack.bat 0 +2
Exec '"notepad.exe" "$INSTDIR\UOTiaraPack.bat"'
FunctionEnd

Function fin_show
ReadINIStr $0 "$PLUGINSDIR\iospecial.ini" "Field 6" "HWND"
SetCtlColors $0 0x000000 0xFFFFFF
FunctionEnd

Function fin_pre
WriteINIStr "$PLUGINSDIR\iospecial.ini" "Settings" "NumFields" "6"
WriteINIStr "$PLUGINSDIR\iospecial.ini" "Field 6" "Type" "CheckBox"
;WriteINIStr "$PLUGINSDIR\iospecial.ini" "Field 6" "State" "1"
WriteINIStr "$PLUGINSDIR\iospecial.ini" "Field 6" "Text" "&Run UOTiaraPack.bat (Make uotiara_00001.it)"
WriteINIStr "$PLUGINSDIR\iospecial.ini" "Field 6" "Left" "120"
WriteINIStr "$PLUGINSDIR\iospecial.ini" "Field 6" "Right" "315"
WriteINIStr "$PLUGINSDIR\iospecial.ini" "Field 6" "Top" "130"
WriteINIStr "$PLUGINSDIR\iospecial.ini" "Field 6" "Bottom" "140"
IfFileExists $INSTDIR\Abyss.ini AbyssFound14 AbyssNotFound14
AbyssFound14:
IfFileExists $INSTDIR\Kanan\Kanan.dll KananFound14 KananNotFound14
KananFound14:
StrCpy $AbyssLoadKanan "0"
;MessageBox MB_YESNO "Would you like Abyss to run Kanan via LoadDLL=Kanan\Kanan.dll in Abyss.ini?$\r$\n(clicking yes can sometimes result in crashing before character select)" IDNO AbyssNotFound14
;StrCpy $AbyssLoadKanan "1"
AbyssNotFound14:
KananNotFound14:
IfFileExists $INSTDIR\Loader.cfg Lib-LoaderFound14 Lib-LoaderNotFound14
Lib-LoaderFound14:
IfFileExists $INSTDIR\Kanan\Kanan.dll KananFound15 KananNotFound15
KananFound15:
StrCpy $LibLoaderLoadKanan "0"
MessageBox MB_YESNO "Would you like Lib-Loader to run Kanan via Files=Kanan.dll in Loader.cfg?$\r$\n(clicking yes can sometimes result in crashing before character select)" IDNO Lib-LoaderNotFound14
StrCpy $LibLoaderLoadKanan "1"
Lib-LoaderNotFound14:
KananNotFound15:
FunctionEnd

Function fin_leave
ReadINIStr $0 "$PLUGINSDIR\iospecial.ini" "Field 6" "State"
StrCmp $0 "0" end
SetOutPath "$INSTDIR"
IfFileExists $INSTDIR\UOTiaraPack.bat mabi-pack2Found1 mabi-pack2NotFound1
mabi-pack2Found1:
IfFileExists $INSTDIR\mabi-pack2\mabi-pack2.exe mabi-pack2Found2 mabi-pack2NotFound1
mabi-pack2Found2:
StrCpy $R7 ".oninstsuccess Execute 1 $INSTDIR\UOTiaraPack.bat"
Call DumpLog1
!insertmacro ShellExecWait "" '"$INSTDIR\UOTiaraPack.bat"' '""' "" ${SW_SHOW} $1
goto end2
mabi-pack2NotFound1:
MessageBox MB_OK "Please reinstall and select mabi-pack2 to use this option."
end:
${If} ${mabi-pack2ForceInstall} == "True"
  !insertmacro ShellExecWait "" '"$INSTDIR\UOTiaraPack.bat"' '""' "" ${SW_SHOW} $1
${EndIf}
end2:
FunctionEnd


SectionGroup /e "Unofficial Tiara's Moonshine Mods" SECTION1
Section "Abyss Patcher" MOD432
${If} ${AbyssEnable} == "True"
SetOutPath "$INSTDIR"
  DetailPrint "Allowing Firewall..."
Call CreateAllowFirewall
ExecShell "" "$INSTDIR\AllowFirewall.bat" "" SW_HIDE
Sleep 5000
CreateDirectory $INSTDIR\Logs\Abyss
CreateDirectory $INSTDIR\Archived\Abyss
SetDetailsPrint both
  DetailPrint "Backing up Abyss.ini..."
IfFileExists "$INSTDIR\Abyss.ini" AbyssIniFound1 AbyssIniNotFound1
AbyssIniFound1:
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Abyss.ini" "$INSTDIR\Archived\Abyss\Abyss($2$1$0$4$5$6).ini"
Delete "$INSTDIR\Abyss.ini"
AbyssIniNotFound1:
  DetailPrint "Backing up Abyss_patchlog.txt"
IfFileExists "$INSTDIR\Abyss_patchlog.txt" AbyssLogFound1 AbyssLogNotFound1
AbyssLogFound1:
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Abyss_patchlog.txt" "$INSTDIR\Logs\Abyss\Abyss_patchlog($2$1$0$4$5$6).txt"
Delete "$INSTDIR\Abyss_patchlog.txt"
AbyssLogNotFound1:
  DetailPrint "Downloading Abyss..."
  inetc::get /NOCANCEL /SILENT "https://blade3575.com/Abyss/Abyss.7z" "Abyss.7z" /end
  inetc::get /NOCANCEL /SILENT "https://github.com/shaggyze/uotiara/raw/master/Tiara's%20Moonshine%20Mod/Tools/7za.exe" "7za.exe" /end
  inetc::get /NOCANCEL /SILENT "https://github.com/shaggyze/uotiara/raw/master/Tiara's%20Moonshine%20Mod/Tools/7za.dll" "7za.dll" /end
  inetc::get /NOCANCEL /SILENT "https://github.com/shaggyze/uotiara/raw/master/Tiara's%20Moonshine%20Mod/Tools/7zxa.dll" "7zxa.dll" /end
  DetailPrint "Extracting Abyss.7z..."
  nsExec::ExecToStack '7za.exe e Abyss.7z -aoa'
  Sleep 3000
  Delete "7za.exe"
  Delete "7za.dll"
  Delete "7zxa.dll"
  IfFileExists "$INSTDIR\CrashReporter.dat" AbyssFound1 AbyssNotFound1
AbyssNotFound1:
File "${srcdir}\Tiara's Moonshine Mod\Tools\Abyss\CrashReporter.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Abyss\Abyss.ini"
; comment out File for mediafire/google drive
File "${srcdir}\Tiara's Moonshine Mod\Tools\Abyss\CrashReporter.dll"
; inetc::get /NOCANCEL /SILENT "https://github.com/shaggyze/uotiara/raw/master/Tiara's%20Moonshine%20Mod/Tools/Abyss/CrashReporter.dll" "CrashReporter.dll" /end
File "${srcdir}\Tiara's Moonshine Mod\Tools\Abyss\README_Abyss.txt"
AbyssFound1:
Push "$INSTDIR\CrashReporter.dll"
Call FileSizeNew
Pop $0
${If} $0 < "400000"
${AndIf} $0 > "500000"
MessageBox MB_OKCANCEL "Abyss failed to download or extract and/or is being blocked by security.$\r$\nTry adding your Mabinogi folder to your Exclusion lists." IDOK AbyssNotFound1 IDCANCEL AbyssInstall
${EndIf}
Delete "Abyss.7z"
AbyssInstall:
DetailPrint "Installing Abyss..."
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "DataFolder" "1"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "EnableMultiClient" "1"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "BugleToSystemMessage" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "CutsceneSkip" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Scouter" "1"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ScouterWeakest" "<mini>Weakest</mini>"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ScouterWeak" "<mini>Weak</mini>"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ScouterSame" "<mini>Similar</mini>"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ScouterStrong" "<mini>Powerful</mini>"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ScouterAwful" "<mini>VeryPowerful</mini>"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ScouterBoss" "<mini>Boss</mini>"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ExtraThreads" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Debug" "1"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ZoomMax" "6000"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ChMoveDescCut" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ShowUnknownTitles" "0"

CreateShortCut "$SMPROGRAMS\Unofficial Tiara\Abyss.lnk" "$INSTDIR\Abyss.ini" "" "$INSTDIR\Abyss.ini" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F9" "Abyss.ini"
CreateShortCut "$DESKTOP\Abyss.lnk" "$INSTDIR\Abyss.ini" "" "$INSTDIR\Abyss.ini" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F9" "Abyss.ini"
SetOutPath "$INSTDIR"
;Call CreateDisableFirewall
Sleep 3000
${Else}
IfFileExists $INSTDIR\Abyss.ini 0 +3
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Abyss.ini" "$INSTDIR\Archived\Abyss\Abyss($2$1$0$4$5$6).ini"
DetailPrint "*** Removing Abyss..."
Delete "$INSTDIR\Abyss.ini"
IfFileExists $INSTDIR\Abyss.ini 0 +3
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Abyss_patchlog.txt" "$INSTDIR\Logs\Abyss\Abyss_patchlog($2$1$0$4$5$6).txt"
Delete "$INSTDIR\Abyss_patchlog.txt"
IfFileExists $INSTDIR\CrashReporter.dat 0 +2
Delete "$INSTDIR\CrashReporter.dll"
Rename "$INSTDIR\CrashReporter.dat" "$INSTDIR\CrashReporter.dll"
Delete "$INSTDIR\Hyddwn Launcher\patchignore.json"
Delete "$INSTDIR\README_Abyss.txt"
Delete "$SMPROGRAMS\Unofficial Tiara\Abyss.lnk"
Delete "$DESKTOP\Abyss.lnk"
${EndIf}
SectionIn 1 2
SectionEnd
!macro Remove_${MOD432}
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
IfFileExists $INSTDIR\Abyss.ini 0 +2
MessageBox MB_YESNO "Abyss is unchecked or your requesting uninstall, it has been found. Would you like to Remove Abyss?" IDNO no5
CopyFiles /SILENT "$INSTDIR\Abyss.ini" "$INSTDIR\Archived\Abyss\Abyss($2$1$0$4$5$6).ini"
DetailPrint "*** Removing Abyss..."
Delete "$INSTDIR\Abyss.ini"
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Abyss_patchlog.txt" "$INSTDIR\Logs\Abyss\Abyss_patchlog($2$1$0$4$5$6).txt"
Delete "$INSTDIR\Abyss_patchlog.txt"
IfFileExists $INSTDIR\CrashReporter.dat 0 +2
Delete "$INSTDIR\CrashReporter.dll"
Rename "$INSTDIR\CrashReporter.dat" "$INSTDIR\CrashReporter.dll"
Delete "$INSTDIR\README_Abyss.txt"
Delete "$SMPROGRAMS\Unofficial Tiara\Abyss.lnk"
Delete "$DESKTOP\Abyss.lnk"
no5:
!macroend

Section "Hyddwn Launcher" MOD395
${If} ${HyddwnEnable} == "True"
  DetailPrint "Copying Hyddwn Logs..."
CopyFiles /SILENT "$INSTDIR\Hyddwn Launcher\Logs" "$INSTDIR"
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Hyddwn Launcher\Update.log" "$INSTDIR\Logs\Hyddwn Launcher\Update($2$1$0$4$5$6).log"
  DetailPrint "Installing Hyddwn Launcher..."
Delete "$INSTDIR\Hyddwn Launcher\Update.log"
Delete "$INSTDIR\PatcherSettings.json"
Delete "$INSTDIR\Hyddwn Launcher\PatcherSettings.json"
Delete "$INSTDIR\Plugins\HyddwnLauncher.Patcher.dll"
Delete "$INSTDIR\Plugins\PatcherSettings.json"
;Call HyddwnDisableForceUpdates
Call HyddwnIgnoreAbyss
Call HyddwnIgnoreLib-Loader
SetOutPath "$INSTDIR\Hyddwn Launcher"

File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\DevIL.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\HyddwnLauncher.Extensibility.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\ImaBrokeDude.Controls.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Ionic.Zip.Reduced.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\MabinogiResource.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\MabinogiResource.net.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\MahApps.Metro.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\MahApps.Metro.SimpleChildWindow.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Microsoft.Win32.Primitives.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\netstandard.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Newtonsoft.Json.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Sentry.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Sentry.PlatformAbstractions.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Sentry.Protocol.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Swebs.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.AppContext.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Collections.Concurrent.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Collections.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Collections.Immutable.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Collections.NonGeneric.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Collections.Specialized.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.ComponentModel.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.ComponentModel.EventBasedAsync.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.ComponentModel.Primitives.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.ComponentModel.TypeConverter.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Console.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Data.Common.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Diagnostics.Contracts.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Diagnostics.Debug.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Diagnostics.FileVersionInfo.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Diagnostics.Process.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Diagnostics.StackTrace.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Diagnostics.TextWriterTraceListener.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Diagnostics.Tools.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Diagnostics.TraceSource.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Diagnostics.Tracing.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Drawing.Primitives.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Dynamic.Runtime.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Globalization.Calendars.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Globalization.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Globalization.Extensions.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.Compression.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.Compression.ZipFile.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.FileSystem.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.FileSystem.DriveInfo.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.FileSystem.Primitives.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.FileSystem.Watcher.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.IsolatedStorage.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.MemoryMappedFiles.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.Pipes.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.IO.UnmanagedMemoryStream.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Linq.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Linq.Expressions.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Linq.Parallel.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Linq.Queryable.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.Http.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.NameResolution.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.NetworkInformation.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.Ping.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.Primitives.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.Requests.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.Security.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.Sockets.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.WebHeaderCollection.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.WebSockets.Client.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Net.WebSockets.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.ObjectModel.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Reflection.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Reflection.Extensions.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Reflection.Primitives.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Resources.Reader.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Resources.ResourceManager.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Resources.Writer.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.CompilerServices.VisualC.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.Extensions.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.Handles.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.InteropServices.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.InteropServices.RuntimeInformation.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.Numerics.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.Serialization.Formatters.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.Serialization.Json.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.Serialization.Primitives.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Runtime.Serialization.Xml.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Security.Claims.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Security.Cryptography.Algorithms.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Security.Cryptography.Csp.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Security.Cryptography.Encoding.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Security.Cryptography.Primitives.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Security.Cryptography.X509Certificates.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Security.Principal.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Security.SecureString.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Text.Encoding.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Text.Encoding.Extensions.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Text.RegularExpressions.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Threading.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Threading.Overlapped.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Threading.Tasks.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Threading.Tasks.Parallel.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Threading.Thread.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Threading.ThreadPool.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Threading.Timer.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.ValueTuple.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Windows.Interactivity.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Xml.ReaderWriter.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Xml.XDocument.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Xml.XmlDocument.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Xml.XmlSerializer.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Xml.XPath.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Xml.XPath.XDocument.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Tao.DevIl.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Hyddwn Launcher.exe"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Hyddwn Launcher.pdb"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\HyddwnLauncher.Extensibility.pdb"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\System.Collections.Immutable.xml"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\Updater.exe"

SetOutPath "$INSTDIR\Hyddwn Launcher\ja-JP"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\ja-JP\Hyddwn Launcher.resources.dll"
SetOutPath "$INSTDIR\Hyddwn Launcher\web"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\web\captcha.cs"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Hyddwn\web\index.html"

  DetailPrint "Downloading Hyddwn Launcher Version..."
Call UpdateHyddwn
CreateShortCut "$DESKTOP\Hyddwn Launcher.exe.lnk" "$INSTDIR\Hyddwn Launcher\Hyddwn Launcher.exe" "" "$INSTDIR\Hyddwn Launcher\Hyddwn Launcher.exe" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F8" "Hyddwn Launcher.exe"
CreateShortCut "$SMPROGRAMS\Unofficial Tiara\Hyddwn Launcher.exe.lnk" "$INSTDIR\Hyddwn Launcher\Hyddwn Launcher.exe" "" "$INSTDIR\Hyddwn Launcher\Hyddwn Launcher.exe" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F8" "Hyddwn Launcher.exe"
SetRegView 64
WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers\" "$INSTDIR\Hyddwn Launcher\Hyddwn Launcher.exe" "RUNASADMIN"
SetRegView 32
SectionIn 1
${Else}
  DetailPrint "*** Removing Hyddwn Launcher..."

SetOutPath "$INSTDIR\Plugins"
Delete "$INSTDIR\Plugins\HyddwnLauncher.Patcher.dll"
Delete "$INSTDIR\Plugins\PatcherSettings.json"
RMDir "$INSTDIR\Plugins"
SetOutPath "$INSTDIR"
Delete "$INSTDIR\PatcherSettings.json"
Delete "$INSTDIR\HyddwnLauncher.Extensibility.dll"
Delete "$INSTDIR\ImaBrokeDude.Controls.dll"
Delete "$INSTDIR\Ionic.Zip.Reduced.dll"
Delete "$INSTDIR\MabinogiResource.dll"
Delete "$INSTDIR\MabinogiResource.net.dll"
Delete "$INSTDIR\DevIL.dll"
Delete "$INSTDIR\Tao.DevIl.dll"
Delete "$INSTDIR\MahApps.Metro.dll"
Delete "$INSTDIR\MahApps.Metro.SimpleChildWindow.dll"
Delete "$INSTDIR\Newtonsoft.Json.dll"
Delete "$INSTDIR\System.Windows.Interactivity.dll"
Delete "$INSTDIR\Hyddwn Launcher.exe"
Delete "$INSTDIR\Updater.exe"
SetOutPath "$INSTDIR\ja-JP"
Delete "$INSTDIR\ja-JP\Hyddwn Launcher.resources.dll"
RMDir "$INSTDIR\ja-JP"
RMDir "$INSTDIR\web"
Delete "$INSTDIR\patchignore.json"
Delete "$INSTDIR\unzip.exe"
Delete "$INSTDIR\HL.zip"
Delete "$DESKTOP\Hyddwn Launcher.exe.lnk"
Delete "$SMPROGRAMS\Unofficial Tiara\Hyddwn Launcher.exe.lnk"


SetOutPath "$INSTDIR\Hyddwn Launcher"
RMDir "$INSTDIR\Hyddwn Launcher\Plugins"
Delete "$INSTDIR\Hyddwn Launcher\PatcherSettings.json"
Delete "$INSTDIR\Hyddwn Launcher\HyddwnLauncher.Extensibility.dll"
Delete "$INSTDIR\Hyddwn Launcher\ImaBrokeDude.Controls.dll"
Delete "$INSTDIR\Hyddwn Launcher\Ionic.Zip.Reduced.dll"
Delete "$INSTDIR\Hyddwn Launcher\MabinogiResource.dll"
Delete "$INSTDIR\Hyddwn Launcher\MabinogiResource.net.dll"
Delete "$INSTDIR\Hyddwn Launcher\DevIL.dll"
Delete "$INSTDIR\Hyddwn Launcher\Tao.DevIl.dll"
Delete "$INSTDIR\Hyddwn Launcher\MahApps.Metro.dll"
Delete "$INSTDIR\Hyddwn Launcher\MahApps.Metro.SimpleChildWindow.dll"
Delete "$INSTDIR\Hyddwn Launcher\Newtonsoft.Json.dll"
Delete "$INSTDIR\Hyddwn Launcher\System.Windows.Interactivity.dll"
Delete "$INSTDIR\Hyddwn Launcher\Hyddwn Launcher.exe"
Delete "$INSTDIR\Hyddwn Launcher\Updater.exe"
Delete "$INSTDIR\Hyddwn Launcher\patchignore.json"
Delete "$INSTDIR\Hyddwn Launcher\unzip.exe"
Delete "$INSTDIR\Hyddwn Launcher\HL.zip"
Delete "$INSTDIR\Hyddwn Launcher\Swebs.dll"
Delete "$DESKTOP\Hyddwn Launcher\Hyddwn Launcher.exe.lnk"
Delete "$SMPROGRAMS\Unofficial Tiara\Hyddwn Launcher.exe.lnk"
SetOutPath "$INSTDIR\Hyddwn Launcher\ja-JP"
Delete "$INSTDIR\Hyddwn Launcher\ja-JP\Hyddwn Launcher.resources.dll"
RMDir "$INSTDIR\Hyddwn Launcher\ja-JP"
SetOutPath "$INSTDIR\Hyddwn Launcher\web"
Delete "$INSTDIR\Hyddwn Launcher\web\index.html"
Delete "$INSTDIR\Hyddwn Launcher\web\captcha.cs"
RMDir "$INSTDIR\Hyddwn Launcher\web"
RMDir "$INSTDIR\Hyddwn Launcher"
${EndIf}
SectionEnd
!macro Remove_${MOD395}
  DetailPrint "*** Removing Hyddwn Launcher..."
  SetOutPath "$INSTDIR\Hyddwn Launcher"
  IfFileExists "$INSTDIR\Hyddwn Launcher\Hyddwn Launcher.exe" 0 +2
MessageBox MB_YESNO "Hyddwn Launcher is unchecked or your requesting uninstall, it has been found. Would you like to Remove Hyddwn Launcher?" IDNO no4
  SetOutPath "$INSTDIR\Plugins"
Delete "$INSTDIR\Plugins\HyddwnLauncher.Patcher.dll"
Delete "$INSTDIR\Plugins\PatcherSettings.json"
RMDir "$INSTDIR\Plugins"
SetOutPath "$INSTDIR"
Delete "$INSTDIR\PatcherSettings.json"
Delete "$INSTDIR\HyddwnLauncher.Extensibility.dll"
Delete "$INSTDIR\ImaBrokeDude.Controls.dll"
Delete "$INSTDIR\Ionic.Zip.Reduced.dll"
Delete "$INSTDIR\MabinogiResource.dll"
Delete "$INSTDIR\MabinogiResource.net.dll"
Delete "$INSTDIR\DevIL.dll"
Delete "$INSTDIR\Tao.DevIl.dll"
Delete "$INSTDIR\MahApps.Metro.dll"
Delete "$INSTDIR\MahApps.Metro.SimpleChildWindow.dll"
Delete "$INSTDIR\Newtonsoft.Json.dll"
Delete "$INSTDIR\System.Windows.Interactivity.dll"
Delete "$INSTDIR\Hyddwn Launcher.exe"
Delete "$INSTDIR\Updater.exe"
Delete "$INSTDIR\patchignore.json"
Delete "$INSTDIR\unzip.exe"
Delete "$INSTDIR\HL.zip"
Delete "$DESKTOP\Hyddwn Launcher.exe.lnk"
Delete "$SMPROGRAMS\Unofficial Tiara\Hyddwn Launcher.exe.lnk"
Delete "$INSTDIR\ja-JP\Hyddwn Launcher.resources.dll"
RMDir "$INSTDIR\ja-JP"
RMDir "$INSTDIR\web"

SetOutPath "$INSTDIR\Hyddwn Launcher"
RMDir "$INSTDIR\Hyddwn Launcher\Plugins"
Delete "$INSTDIR\Hyddwn Launcher\PatcherSettings.json"
Delete "$INSTDIR\Hyddwn Launcher\HyddwnLauncher.Extensibility.dll"
Delete "$INSTDIR\Hyddwn Launcher\ImaBrokeDude.Controls.dll"
Delete "$INSTDIR\Hyddwn Launcher\Ionic.Zip.Reduced.dll"
Delete "$INSTDIR\Hyddwn Launcher\MabinogiResource.dll"
Delete "$INSTDIR\Hyddwn Launcher\MabinogiResource.net.dll"
Delete "$INSTDIR\Hyddwn Launcher\DevIL.dll"
Delete "$INSTDIR\Hyddwn Launcher\Tao.DevIl.dll"
Delete "$INSTDIR\Hyddwn Launcher\MahApps.Metro.dll"
Delete "$INSTDIR\Hyddwn Launcher\MahApps.Metro.SimpleChildWindow.dll"
Delete "$INSTDIR\Hyddwn Launcher\Newtonsoft.Json.dll"
Delete "$INSTDIR\Hyddwn Launcher\System.Windows.Interactivity.dll"
Delete "$INSTDIR\Hyddwn Launcher\Hyddwn Launcher.exe"
Delete "$INSTDIR\Hyddwn Launcher\Updater.exe"
Delete "$INSTDIR\Hyddwn Launcher\patchignore.json"
Delete "$INSTDIR\Hyddwn Launcher\unzip.exe"
Delete "$INSTDIR\Hyddwn Launcher\HL.zip"
Delete "$INSTDIR\Hyddwn Launcher\Swebs.dll"
Delete "$DESKTOP\Hyddwn Launcher\Hyddwn Launcher.exe.lnk"
Delete "$SMPROGRAMS\Unofficial Tiara\Hyddwn Launcher.exe.lnk"
Delete "$INSTDIR\Hyddwn Launcher\ja-JP\Hyddwn Launcher.resources.dll"
RMDir "$INSTDIR\Hyddwn Launcher\ja-JP"
SetOutPath "$INSTDIR\Hyddwn Launcher\web"
Delete "$INSTDIR\Hyddwn Launcher\web\index.html"
Delete "$INSTDIR\Hyddwn Launcher\web\captcha.cs"
RMDir "$INSTDIR\Hyddwn Launcher\web"
RMDir "$INSTDIR\Hyddwn Launcher"
no4:
!macroend

Section "mabi-pack2" MOD434
  DetailPrint "Installing mabi-pack2..."
SetOutPath "$INSTDIR\mabi-pack2"
File "${srcdir}\Tiara's Moonshine Mod\Tools\mabi-pack2\mabi-pack2.exe"
SetOutPath "$INSTDIR\"
Call UOTiaraPackBuild
WriteRegStr HKCR ".it "" "IT.it"
WriteRegStr HKCR "IT.it" "" "IT File"
WriteRegStr HKCR "IT.it\shell" "" "Open"
WriteRegStr HKCR "IT.it\shell\Open\command" "" '"$INSTDIR\mabi-pack2\mabi-pack2.exe" "%1"'
WriteRegStr HKCR "IT.it\DefaultIcon" "" "$INSTDIR\mabi-pack2\mabi-pack2.exe"
${If} ${mabi-pack2ForceInstall} == "True"
WriteINIStr "$PLUGINSDIR\iospecial.ini" "Field 6" "State" "1"
SectionIn RO
${Else}
SectionIn 1 2 3
${EndIf}
SectionEnd
!macro Remove_${MOD434}
  DetailPrint "*** Removing mabi-pack2..."
SetOutPath "$INSTDIR\mabi-pack2"
IfFileExists $INSTDIR\mabi-pack2\mabi-pack2.exe mabi-pack2Found3 mabi-pack2NotFound2
mabi-pack2Found3:
MessageBox MB_YESNO "mabi-pack2 is unchecked or your requesting uninstall, it has been found. Would you like to Remove mabi-pack2?" IDNO no2
Delete "$INSTDIR\mabi-pack2\mabi-pack2.exe"
RMDir "$INSTDIR\mabi-pack2"
no2:
mabi-pack2NotFound2:
!macroend

Section "Kanan" MOD435
${If} ${KananEnable} == "True"
CreateDirectory $INSTDIR\Logs\Kanan
SetOutPath "$INSTDIR"
Call KananShellBuild
  DetailPrint "Allowing PowerShell..."
File "${srcdir}\Tiara's Moonshine Mod\Tools\AllowPowerShell.exe"
Exec "$INSTDIR\AllowPowerShell.exe"
Sleep 10000
  DetailPrint "Allowing Firewall..."
Call CreateAllowFirewall
ExecShell "" "$INSTDIR\AllowFirewall.bat" "" SW_HIDE
Sleep 5000
  DetailPrint "Installing Kanan..."
SetOutPath "$INSTDIR\Kanan"
CreateShortCut "$SMPROGRAMS\Unofficial Tiara\Update Kanan.lnk" "$INSTDIR\Update_Kanan.ps1" "" "$INSTDIR\Kanan\Kanan.ico" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F10" "Update Kanan"
SetOutPath "$INSTDIR\Kanan"
CreateShortCut "$DESKTOP\Update Kanan.lnk" "$INSTDIR\Update_Kanan.ps1" "" "$INSTDIR\Kanan\Kanan.ico" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F10" "Update Kanan"
SetOutPath "$INSTDIR\Kanan"
CreateShortCut "$SMPROGRAMS\Unofficial Tiara\Launcher.exe.lnk" "$INSTDIR\Kanan\Launcher.exe" "" "$INSTDIR\Kanan\Kanan.ico" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F12" "Launcher.exe"
SetOutPath "$INSTDIR\Kanan"
CreateShortCut "$DESKTOP\Launcher.exe.lnk" "$INSTDIR\Kanan\Launcher.exe" "" "$INSTDIR\Kanan\Kanan.ico" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F12" "Launcher.exe"
SetOutPath "$INSTDIR\Kanan"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Kanan\Loader.txt"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Kanan\Loader.exe"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Kanan\Kanan.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Kanan\Patches.json"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Kanan\Kanan.ico"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Kanan\Launcher.exe"
WriteRegStr HKCR ".ps1" "" "PS.ps1"
WriteRegStr HKCR "PS.ps1" "" "PS1 File"
WriteRegStr HKCR "PS.ps1\shell" "" "Open"
WriteRegStr HKCR "PS.ps1\shell\Open\command" "" '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" "%1"'
WriteRegStr HKCR "PS.ps1\DefaultIcon" "" "$SYSDIR\WindowsPowerShell\v1.0\powershell.exe"
${If} ${KananUpdateEnable} == "True"
  DetailPrint "Downloading Kanan..."
  inetc::get /NOCANCEL /SILENT "https://github.com/cursey/kanan-new/releases/latest/download/kanan.zip" "kanan.zip" /end
  inetc::get /NOCANCEL /SILENT "https://github.com/shaggyze/uotiara/raw/master/Tiara's%20Moonshine%20Mod/Tools/unzip.exe" "unzip.exe" /end
  DetailPrint "Extracting kanan.zip..."
  nsExec::ExecToStack 'unzip.exe -o kanan.zip'
  Delete "unzip.exe"
  IfFileExists $INSTDIR\Kanan\Kanan.dll KananFound1 KananNotFound1
KananFound1:
  Delete "kanan.zip"
  goto KananDone
KananNotFound1:
  nsExec::Exec 'powershell -ExecutionPolicy ByPass -File $INSTDIR\Update_Kanan.ps1'
KananDone:
${EndIf}
Call KananEnableData
SetOutPath "$INSTDIR\Kanan"
CreateShortCut "$SMPROGRAMS\Unofficial Tiara\Loader.exe.lnk" "$INSTDIR\Kanan\Loader.exe" "" "$INSTDIR\Kanan\Kanan.ico" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F11" "Loader.exe"
SetOutPath "$INSTDIR\Kanan"
CreateShortCut "$DESKTOP\Loader.exe.lnk" "$INSTDIR\Kanan\Loader.exe" "" "$INSTDIR\Kanan\Kanan.ico" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F11" "Loader.exe"
SetOutPath "$INSTDIR"
Call CreateDisableFirewall
${Else}
DetailPrint "*** Removing Kanan..."
Delete "$INSTDIR\AllowPowerShell.exe"
Delete "$INSTDIR\Kanan\Loader.exe"
Delete "$INSTDIR\Kanan\Loader.txt"
Delete "$INSTDIR\Kanan\Kanan.dll"
Delete "$INSTDIR\Kanan\Patches.json"
Delete "$INSTDIR\Kanan.dll"
Delete "$INSTDIR\Patches.json"
Delete "$INSTDIR\Kanan.ico"
Delete "$INSTDIR\Update_Kanan.ps1"
Delete "$INSTDIR\log.txt"
Delete "$SMPROGRAMS\Unofficial Tiara\Loader.exe.lnk"
Delete "$DESKTOP\Loader.exe.lnk"
Delete "$SMPROGRAMS\Unofficial Tiara\Update Kanan.lnk"
Delete "$DESKTOP\Update Kanan.lnk"
Delete "$INSTDIR\Kanan\kanan.zip"
Delete "$INSTDIR\Kanan\Loader.txt.bak"
${EndIf}
SectionIn 1 2
SectionEnd
!macro Remove_${MOD435}
IfFileExists $INSTDIR\Kanan.dll 0 +2
MessageBox MB_YESNO "Kanan is unchecked, but has been found. Would you like to Remove Kanan?" IDNO no6
DetailPrint "*** Removing Kanan..."
Delete "$INSTDIR\AllowPowerShell.exe"
Delete "$INSTDIR\Kanan\Launcher.exe"
Delete "$INSTDIR\Kanan\Loader.exe"
Delete "$INSTDIR\Kanan\Loader.txt"
Delete "$INSTDIR\Kanan\Kanan.dll"
Delete "$INSTDIR\Kanan\Patches.json"
Delete "$INSTDIR\Patches.json"
Delete "$INSTDIR\Kanan.ico"
Delete "$INSTDIR\Update_Kanan.ps1"
Delete "$INSTDIR\log.txt"
Delete "$SMPROGRAMS\Unofficial Tiara\Loader.exe.lnk"
Delete "$DESKTOP\Loader.exe.lnk"
Delete "$SMPROGRAMS\Unofficial Tiara\Launcher.exe.lnk"
Delete "$DESKTOP\Launcher.exe.lnk"
Delete "$SMPROGRAMS\Unofficial Tiara\Update Kanan.lnk"
Delete "$DESKTOP\Update Kanan.lnk"
Delete "$INSTDIR\Kanan\Kanan.ico"
Delete "$INSTDIR\Kanan\kanan.zip"
Delete "$INSTDIR\Kanan\Launcher.exe"
Delete "$INSTDIR\Kanan\Loader.txt.bak"
Delete "$INSTDIR\Kanan\log.txt"
no6:
  MessageBox MB_YESNO "Would you like to Remove Kanan's settings?" IDNO SkipKSRemove
  ${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
  CopyFiles /SILENT "$INSTDIR\Kanan\config.txt" "$INSTDIR\Archived\Kanan\config($2$1$0$4$5$6).txt"
  Delete "$INSTDIR\config.txt"
  Delete "$INSTDIR\Kanan\config.txt"
  Delete "$INSTDIR\Kanan\profiles.dat"
  RMDir /r "$INSTDIR\Kanan"
SkipKSRemove:
!macroend
Section "Reduced Lag Font 1 (ydygo550)" MOD436
SetOutPath "$INSTDIR\data\gfx\font"
  DetailPrint "Installing ydygo550 font..."
  File "${srcdir}\Tiara's Moonshine Mod\optional data\ydygo550\NanumGothicBold.ttf"
  SetDetailsPrint both
IfFileExists "$INSTDIR\Abyss.ini" AbyssFound5 AbyssNotFound5
AbyssFound5:
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Bitmap" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "BitmapPositionFix" "0"
AbyssNotFound5:
SectionIn 1 3
SectionEnd
!macro Remove_${MOD436}

!macroend
Section "Reduced Lag Font 2 (whiterabbit)" MOD437
SetOutPath "$INSTDIR\data\gfx\font"
  DetailPrint "Installing whiterabbit font..."
  File "${srcdir}\Tiara's Moonshine Mod\optional data\whiterabbit\NanumGothicBold.ttf"
  SetDetailsPrint both
IfFileExists "$INSTDIR\Abyss.ini" AbyssFound6 AbyssNotFound6
AbyssFound6:
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Bitmap" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "BitmapPositionFix" "0"
AbyssNotFound6:
SectionIn 2
SectionEnd
!macro Remove_${MOD437}

!macroend
Section "Reduced Lag Font 3 (interstate)" MOD438
SetOutPath "$INSTDIR\data\gfx\font"
  DetailPrint "Installing interstate font..."
  File "${srcdir}\Tiara's Moonshine Mod\optional data\interstate\NanumGothicBold.ttf"
  SetDetailsPrint both
IfFileExists "$INSTDIR\Abyss.ini" AbyssFound7 AbyssNotFound7
AbyssFound7:
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Bitmap" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "BitmapPositionFix" "0"
AbyssNotFound7:
SectionEnd
!macro Remove_${MOD438}

!macroend
Section "Reduced Lag Font 4 (tiara)" MOD439
SetOutPath "$INSTDIR\data\gfx\font"
  DetailPrint "Installing tiara font..."
  File "${srcdir}\Tiara's Moonshine Mod\optional data\tiara\NanumGothicBold.ttf"
  SetDetailsPrint both
IfFileExists "$INSTDIR\Abyss.ini" AbyssFound8 AbyssNotFound8
AbyssFound8:
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Bitmap" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "BitmapPositionFix" "0"
AbyssNotFound8:
SectionEnd
!macro Remove_${MOD439}

!macroend
Section "Reduced Lag Font 5 (uotiara)" MOD440
SetOutPath "$INSTDIR\data\gfx\font"
  DetailPrint "Installing uotiara font..."
  File "${srcdir}\Tiara's Moonshine Mod\optional data\uotiara\NanumGothicBold.ttf"
  SetDetailsPrint both
IfFileExists "$INSTDIR\Abyss.ini" AbyssFound9 AbyssNotFound9
AbyssFound9:
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Bitmap" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "BitmapPositionFix" "0"
AbyssNotFound9:
SectionEnd
!macro Remove_${MOD440}

!macroend
Section "Reduced Lag Font 6 (fudd)" MOD441
SetOutPath "$INSTDIR\data\gfx\font"
  DetailPrint "Installing fudd font..."
  File "${srcdir}\Tiara's Moonshine Mod\optional data\fudd\NanumGothicBold.ttf"
  SetDetailsPrint both
IfFileExists "$INSTDIR\Abyss.ini" AbyssFound10 AbyssNotFound10
AbyssFound10:
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Bitmap" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "BitmapPositionFix" "0"
AbyssNotFound10:
SectionEnd
!macro Remove_${MOD441}

!macroend
Section "Reduced Lag Font 7 (powerred)" MOD452
SetOutPath "$INSTDIR\data\gfx\font"
  DetailPrint "Installing powerred font..."
  File "${srcdir}\Tiara's Moonshine Mod\optional data\powerred\NanumGothicBold.ttf"
  SetDetailsPrint both
IfFileExists "$INSTDIR\Abyss.ini" AbyssFound11 AbyssNotFound11
AbyssFound11:
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Bitmap" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "BitmapPositionFix" "0"
AbyssNotFound11:
SectionEnd
!macro Remove_${MOD452}

!macroend
SectionGroup "Tools"
Section "AutoBot (fossil restoration & updates Mods)" MOD431
  SetOutPath "$INSTDIR"
  Delete "$INSTDIR\Update AutoBot.exe"
  DetailPrint "Downloading AutoBot..."
  inetc::get /NOCANCEL /SILENT "https://github.com/shaggyze/uotiara/raw/master/Tiara's%20Moonshine%20Mod/Tools/AutoBot/AutoBotS.rar" "AutoBotS.rar" /end
  inetc::get /NOCANCEL /SILENT "https://github.com/shaggyze/uotiara/raw/master/Tiara's%20Moonshine%20Mod/Tools/UnRAR.exe" "UnRAR.exe" /end
  DetailPrint "Extracting AutoBotS.rar..."
  nsExec::ExecToStack 'UnRAR.exe x -o+ "AutoBotS.rar"'
  Delete "$INSTDIR\AutoBot\Tailor Minigame.exe"
  Delete "$INSTDIR\UnRAR.exe"
  IfFileExists $INSTDIR\AutoBot\AutoBot.exe AutoBotFound1 AutoBotNotFound1
AutoBotFound1:
  Delete "$INSTDIR\AutoBotS.rar"
  SetOutPath "$INSTDIR\AutoBot\"
  CreateShortCut "$SMPROGRAMS\Unofficial Tiara\AutoBot.lnk" "$INSTDIR\AutoBot\AutoBot.exe" "" "$INSTDIR\AutoBot\AutoBot.exe" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F6" "AutoBot.exe"
  CreateShortCut "$DESKTOP\AutoBot.lnk" "$INSTDIR\AutoBot\AutoBot.exe" "" "$INSTDIR\AutoBot\AutoBot.exe" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F6" "AutoBot.exe"
AutoBotNotFound1:
; install autobot another way

SetDetailsPrint both
SectionIn 1 2
SectionEnd
!macro Remove_${MOD431}
  DetailPrint "*** Removing AutoBot..."
RMDir /r "$INSTDIR\AutoBot"
Delete "$INSTDIR\AutoBotS.rar"
Delete "$INSTDIR\Uninstall AutoBot.exe"
Delete "$INSTDIR\Update AutoBot.exe"
Delete "$INSTDIR\Update AutoBot1.exe"
Delete "$INSTDIR\UnRAR.exe"
Delete "$SMPROGRAMS\Unofficial Tiara\AutoBot.lnk"
Delete "$DESKTOP\AutoBot.lnk"
!macroend
Section "MabiCooker2" MOD454
SetOutPath "$INSTDIR\MabiCooker2"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\cook.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\cook.en.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\cook.ja.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\favcook.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\favcook.en.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\favcook.ja.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\stuff.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\stuff.en.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\stuff.ja.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\CookImplement.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\MabiCooker2.exe"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\english.tag"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\japan.tag"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\readme.txt"
SetOutPath "$INSTDIR\MabiCooker2\en\"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\en\CookImplement.resources.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\en\MabiCooker2.resources.dll"
SetOutPath "$INSTDIR\MabiCooker2\ja\"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\ja\CookImplement.resources.dll"
File "${srcdir}\Tiara's Moonshine Mod\Tools\MabiCooker2\ja\MabiCooker2.resources.dll"
SetOutPath "$INSTDIR\MabiCooker2"
Delete "$DESKTOP\MabiCooker2.exe.lnk"
Delete "$$SMPROGRAMS\Unofficial Tiara\MabiCooker2.exe.lnk"
CreateShortCut "$DESKTOP\MabiCooker2.exe.lnk" "$INSTDIR\MabiCooker2\MabiCooker2.exe" "" "$INSTDIR\MabiCooker2\MabiCooker2.exe" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F5" "MabiCooker2.exe"
CreateShortCut "$SMPROGRAMS\Unofficial Tiara\MabiCooker2.exe.lnk" "$INSTDIR\MabiCooker2\MabiCooker2.exe" "" "$INSTDIR\MabiCooker2\MabiCooker2.exe" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F5" "MabiCooker2.exe"
SectionIn 1
SectionEnd
!macro Remove_${MOD454}
  DetailPrint "*** Removing MabiCooker2.exe..."
  Delete "$INSTDIR\MabiCooker2.exe.config"
  Delete "$INSTDIR\MabiCooker2.vshost.exe.config"
  Delete "$INSTDIR\cook.dat"
  Delete "$INSTDIR\cook.en.dat"
  Delete "$INSTDIR\favcook.dat"
  Delete "$INSTDIR\favcook.en.dat"
  Delete "$INSTDIR\stuff.dat"
  Delete "$INSTDIR\stuff.en.dat"
  Delete "$INSTDIR\CookImplement.dll"
  Delete "$INSTDIR\MabiCooker2.exe"
  Delete "$INSTDIR\MabiCooker2.vshost.exe"
  Delete "$INSTDIR\english.tag"
  Delete "$INSTDIR\readme.txt"
  Delete "$INSTDIR\en\CookImplement.resources.dll"
  Delete "$INSTDIR\en\MabiCooker2.resources.dll"
  Delete "$INSTDIR\ja\CookImplement.resources.dll"
  Delete "$INSTDIR\ja\MabiCooker2.resources.dll"
  Delete "$DESKTOP\MabiCooker2.exe.lnk"
  Delete "$SMPROGRAMS\Unofficial Tiara\MabiCooker2.exe.lnk"
  RMDir /r "$INSTDIR\en"
  RMDir /r "$INSTDIR\ja"

  Delete "$INSTDIR\MabiCooker2\MabiCooker2.exe.config"
  Delete "$INSTDIR\MabiCooker2\MabiCooker2.vshost.exe.config"
  Delete "$INSTDIR\MabiCooker2\cook.dat"
  Delete "$INSTDIR\MabiCooker2\cook.en.dat"
  Delete "$INSTDIR\MabiCooker2\favcook.dat"
  Delete "$INSTDIR\MabiCooker2\favcook.en.dat"
  Delete "$INSTDIR\MabiCooker2\stuff.dat"
  Delete "$INSTDIR\MabiCooker2\stuff.en.dat"
  Delete "$INSTDIR\MabiCooker2\CookImplement.dll"
  Delete "$INSTDIR\MabiCooker2\MabiCooker2.exe"
  Delete "$INSTDIR\MabiCooker2\MabiCooker2.vshost.exe"
  Delete "$INSTDIR\MabiCooker2\english.tag"
  Delete "$INSTDIR\MabiCooker2\readme.txt"
  Delete "$INSTDIR\MabiCooker2\en\CookImplement.resources.dll"
  Delete "$INSTDIR\MabiCooker2\en\MabiCooker2.resources.dll"
  Delete "$INSTDIR\MabiCooker2\ja\CookImplement.resources.dll"
  Delete "$INSTDIR\MabiCooker2\ja\MabiCooker2.resources.dll"
  Delete "$DESKTOP\MabiCooker2.exe.lnk"
  Delete "$SMPROGRAMS\Unofficial Tiara\MabiCooker2.exe.lnk"
  RMDir /r "$INSTDIR\MabiCooker2\en"
  RMDir /r "$INSTDIR\MabiCooker2\ja"
  RMDir /r "$INSTDIR\MabiCooker2"
!macroend

Section "Lib-Loader" MOD81
${If} ${Lib-LoaderEnable} == "True"
SetOutPath "$INSTDIR"
CreateDirectory $INSTDIR\Logs\Lib-Loader
CreateDirectory $INSTDIR\Archived\Lib-Loader
SetDetailsPrint both
  DetailPrint "Backing up Loader.cfg..."
IfFileExists "$INSTDIR\Loader.cfg" Lib-LoadercfgFound1 Lib-LoadercfgNotFound1
Lib-LoadercfgFound1:
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Loader.cfg" "$INSTDIR\Archived\Lib-Loader\Lib-Loader($2$1$0$4$5$6).cfg"
Delete "$INSTDIR\Loader.cfg"
Lib-LoadercfgNotFound1:
  DetailPrint "Backing up Loader.log"
IfFileExists "$INSTDIR\Loader.log" Lib-LoaderLogFound1 Lib-LoaderLogNotFound1
Lib-LoaderLogFound1:
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Loader.log" "$INSTDIR\Logs\Lib-Loader\Loader($2$1$0$4$5$6).log"
Delete "$INSTDIR\Loader.log"
Lib-LoaderLogNotFound1:
DetailPrint "Installing Lib-Loader..."
File "${srcdir}\Tiara's Moonshine Mod\Tools\Lib-Loader\nps64.dat"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Lib-Loader\Loader.cfg"
File "${srcdir}\Tiara's Moonshine Mod\Tools\Lib-Loader\nps64.dll"
  inetc::get /NOCANCEL /SILENT "https://github.com/riistar/LibLoader/releases/latest/download/nps64.dll" "nps64.dll" /end
  inetc::get /NOCANCEL /SILENT "https://github.com/riistar/LibLoader/releases/latest/download/Loader.cfg" "Loader.cfg" /end
WriteINIStr "$INSTDIR\Loader.cfg" "Debug" "Enabled" "1"
CreateShortCut "$SMPROGRAMS\Unofficial Tiara\Lib-Loader.lnk" "$INSTDIR\Loader.cfg" "" "$INSTDIR\Loader.cfg" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F10" "Loader.cfg"
CreateShortCut "$DESKTOP\Lib-Loader.lnk" "$INSTDIR\Loader.cfg" "" "$INSTDIR\Loader.cfg" "0" "SW_SHOWNORMAL" "ALT|CONTROL|F10" "Loader.cfg"
SetOutPath "$INSTDIR"
${Else}
IfFileExists $INSTDIR\Loader.cfg 0 +3
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Loader.cfg" "$INSTDIR\Archived\Lib-Loader\Loader$2$1$0$4$5$6).cfg"
DetailPrint "*** Removing Lib-Loader..."
Delete "$INSTDIR\Loader.cfg"
IfFileExists $INSTDIR\Loader.log 0 +3
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Loader.log" "$INSTDIR\Logs\Lib-Loader\Loader($2$1$0$4$5$6).log"
Delete "$INSTDIR\Loader.log"
IfFileExists $INSTDIR\nps64.dat 0 +2
Delete "$INSTDIR\nps64.dll"
Rename "$INSTDIR\nps64.dat" "$INSTDIR\nps64.dll"
Delete "$SMPROGRAMS\Unofficial Tiara\Lib-Loader.lnk"
Delete "$DESKTOP\Lib-Loader.lnk"
${EndIf}
SectionIn 1 2
SectionEnd
!macro Remove_${MOD81}
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
IfFileExists $INSTDIR\Loader.cfg 0 +2
MessageBox MB_YESNO "Lib-Loader is unchecked or your requesting uninstall, it has been found. Would you like to Remove Lib-Loader?" IDNO no51
CopyFiles /SILENT "$INSTDIR\Loader.cfg" "$INSTDIR\Archived\Lib-Loader\Loader($2$1$0$4$5$6).cfg"
DetailPrint "*** Removing Lib-Loader..."
Delete "$INSTDIR\Loader.cfg"
${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
CopyFiles /SILENT "$INSTDIR\Loader.log" "$INSTDIR\Logs\Lib-Loader\Loader($2$1$0$4$5$6).log"
Delete "$INSTDIR\Loader.log"
IfFileExists $INSTDIR\nps64.dat 0 +2
Delete "$INSTDIR\nps64.dll"
Rename "$INSTDIR\nps64.dat" "$INSTDIR\nps64.dll"
Delete "$SMPROGRAMS\Unofficial Tiara\Lib-Loader.lnk"
Delete "$DESKTOP\Lib-Loader.lnk"
no51:
!macroend
SectionGroupEnd
SectionGroup /e "Data Mods"
SectionGroup "code"
Section "Remove Window, Name, and Party Messages" MOD288
SetOutPath "$INSTDIR\data\code"
File "${srcdir}\Tiara's Moonshine Mod\data\code\interface.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD288}
  DetailPrint "*** Removing MOD288..."
  Delete "$INSTDIR\data\code\interface.english.txt"
!macroend
Section "Remove Window, Name, and Party Messages 2" MOD289
SetOutPath "$INSTDIR\data\code"
File "${srcdir}\Tiara's Moonshine Mod\data\code\interface.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD289}
  DetailPrint "*** Removing MOD289..."
  Delete "$INSTDIR\data\code\interface.english.txt"
!macroend
Section "Desc text for Cp Changersa" MOD290
SetOutPath "$INSTDIR\data\code"
File "${srcdir}\Tiara's Moonshine Mod\data\code\standard.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD290}
  DetailPrint "*** Removing MOD290..."
  Delete "$INSTDIR\data\code\standard.english.txt"
!macroend
Section "Desc text for Cp Changersb" MOD291
SetOutPath "$INSTDIR\data\code"
File "${srcdir}\Tiara's Moonshine Mod\data\code\standard.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD291}
  DetailPrint "*** Removing MOD291..."
  Delete "$INSTDIR\data\code\standard.english.txt"
!macroend
SectionGroupEnd
SectionGroup "db"
Section "Always noon sky 1" MOD85
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\renderer_resource.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD85}
  DetailPrint "*** Removing MOD85..."
  Delete "$INSTDIR\data\db\renderer_resource.xml"
!macroend
Section "Autoproduction Uncaps" MOD86
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\production.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD86}
  DetailPrint "*** Removing MOD86..."
  Delete "$INSTDIR\data\db\production.xml"
!macroend
Section "Bandit Spotter 1" MOD87
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\commercecommon.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD87}
  DetailPrint "*** Removing MOD87..."
  Delete "$INSTDIR\data\db\commercecommon.xml"
!macroend
Section "Bandit Spotter 2" MOD88
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\npcclientappearance.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD88}
  DetailPrint "*** Removing MOD88..."
  Delete "$INSTDIR\data\db\npcclientappearance.xml"
!macroend
Section "Dark Knight Sound" MOD89
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\animationevent.anievent"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD89}
  DetailPrint "*** Removing MOD89..."
  Delete "$INSTDIR\data\db\animationevent.anievent"
!macroend
Section "Dungeon Fog Removal 1" MOD90
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\dungeon_ruin.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD90}
  DetailPrint "*** Removing MOD90..."
  Delete "$INSTDIR\data\db\dungeon_ruin.xml"
!macroend
Section "Dungeon Fog Removal 2" MOD91
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\dungeondb.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD91}
  DetailPrint "*** Removing MOD91..."
  Delete "$INSTDIR\data\db\dungeondb.xml"
!macroend
Section "Dungeon Fog Removal 3" MOD92
SetOutPath "$INSTDIR\data\db"
  DetailPrint "Installing dungeondb2.xml..."
  File "${srcdir}\Tiara's Moonshine Mod\data\db\dungeondb2.xml"
  SetDetailsPrint both
SectionIn 1 2
SectionEnd
!macro Remove_${MOD92}
  DetailPrint "*** Removing MOD92..."
  Delete "$INSTDIR\data\db\dungeondb2.xml"
!macroend
Section "Fragmentation Autoproduction Uncap" MOD93
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\dissolution.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD93}
  DetailPrint "*** Removing MOD93..."
  Delete "$INSTDIR\data\db\dissolution.xml"
!macroend
Section "Iria Dungeon/Underground Tunnel Fog Removal" MOD94
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\minimapinfo.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD94}
  DetailPrint "*** Removing MOD94..."
  Delete "$INSTDIR\data\db\minimapinfo.xml"
!macroend
Section "Iria Underground Tunnel Field of View" MOD95
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\UndergroundMaze.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD95}
  DetailPrint "*** Removing MOD95..."
  Delete "$INSTDIR\data\db\UndergroundMaze.xml"
!macroend
Section "Show Prop Names 1" MOD96
SetOutPath "$INSTDIR\data\db"
  DetailPrint "Installing propdb.xml..."
  File "${srcdir}\Tiara's Moonshine Mod\data\db\propdb.xml"
  SetDetailsPrint both
SectionIn 1 2
SectionEnd
!macro Remove_${MOD96}
  DetailPrint "*** Removing MOD96..."
  Delete "$INSTDIR\data\db\propdb.xml"
!macroend
Section "Vertical Flight Speed" MOD97
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\aircraftdesc.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD97}
  DetailPrint "*** Removing MOD97..."
  Delete "$INSTDIR\data\db\aircraftdesc.xml"
!macroend
Section "View Deadly as Red Glow-Mana Shield as Blue Glow-etc" MOD98
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\charactercondition.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD98}
  DetailPrint "*** Removing MOD98..."
  Delete "$INSTDIR\data\db\charactercondition.xml"
!macroend
SectionGroup "cutscene"
Section "Paladin Cutscene Removal" MOD60
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_paladin_change.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD60}
  DetailPrint "*** Removing MOD60..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_paladin_change.xml"
!macroend
Section "Dark Knight Cutscene Removal" MOD61
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_darknight_change.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD61}
  DetailPrint "*** Removing MOD61..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_darknight_change.xml"
!macroend
Section "Waterfall Drop Cutscene Removal" MOD62
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_waterfall.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD62}
  DetailPrint "*** Removing MOD62..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_waterfall.xml"
!macroend
Section "Boss Cutscene Removals Group 1" MOD63
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_bossroom_event.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD63}
  DetailPrint "*** Removing MOD63..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_bossroom_event.xml"
!macroend
Section "Boss Cutscene Removals Group 2" MOD64
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_bossroom_event2.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD64}
  DetailPrint "*** Removing MOD64..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_bossroom_event2.xml"
!macroend
Section "Boss Cutscene Removals Group 3" MOD65
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_bossroom_event3.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD65}
  DetailPrint "*** Removing MOD65..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_bossroom_event3.xml"
!macroend
Section "Boss Cutscene Removals Group 4" MOD66
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_bossroom_event4.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD66}
  DetailPrint "*** Removing MOD66..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_bossroom_event4.xml"
!macroend
Section "Boss Cutscene Removals Group 5" MOD67
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_bossroom_event5.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD67}
  DetailPrint "*** Removing MOD67..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_bossroom_event5.xml"
!macroend
Section "Elven Fire Magic Missile Cutscene Removal" MOD68
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_elvenmissile_fire.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD68}
  DetailPrint "*** Removing MOD68..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_elvenmissile_fire.xml"
!macroend
Section "Elven Ice Magic Missile Cutscene Removal" MOD69
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_elvenmissile_ice.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD69}
  DetailPrint "*** Removing MOD69..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_elvenmissile_ice.xml"
!macroend
Section "Elven Lightning Magic Missile Cutscene Removal" MOD70
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_elvenmissile_light.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD70}
  DetailPrint "*** Removing MOD70..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_elvenmissile_light.xml"
!macroend
Section "Giant Full Swing Cutscene Removal" MOD71
SetOutPath "$INSTDIR\data\db\cutscene"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_giant_fullswing.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD71}
  DetailPrint "*** Removing MOD71..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_giant_fullswing.xml"
!macroend
Section "Peaca Dungeon Master Lich Cutscene Removal" MOD444
SetOutPath "$INSTDIR\data\db\cutscene\"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\bossroom_peaca_masterlich.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD444}
  DetailPrint "*** Removing MOD444..."
  Delete "$INSTDIR\data\db\cutscene\bossroom_peaca_masterlich.xml"
!macroend
Section "Peaca-Coil Abyss and G19 Boss Room Cutscene Removal" MOD445
SetOutPath "$INSTDIR\data\db\cutscene\"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_bossroom_event6.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD445}
  DetailPrint "*** Removing MOD445..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_bossroom_event6.xml"
!macroend
Section "G19 Renovation Cutscene Removal" MOD446
SetOutPath "$INSTDIR\data\db\cutscene\"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\cutscene_g19_renovation.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD446}
  DetailPrint "*** Removing MOD446..."
  Delete "$INSTDIR\data\db\cutscene\cutscene_g19_renovation.xml"
!macroend
SectionGroup "c2"
Section "Artifact Discovery Cutscene Removal" MOD1
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_finding.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD1}
  DetailPrint "*** Removing MOD1..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_finding.xml"
!macroend
Section "Elf Transformation Cutscene Removal" MOD405
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\cutscene_elf_transform.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD405}
  DetailPrint "*** Removing MOD405..."
  Delete "$INSTDIR\data\db\cutscene\c2\cutscene_elf_transform.xml"
!macroend
Section "Giant Transformation Cutscene Removal" MOD406
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\cutscene_giant_transform.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD406}
  DetailPrint "*** Removing MOD406..."
  Delete "$INSTDIR\data\db\cutscene\c2\cutscene_giant_transform.xml"
!macroend
Section "Alby Arachne Cutscene Removal" MOD2
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_albi_arachne.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD2}
  DetailPrint "*** Removing MOD2..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_albi_arachne.xml"
!macroend
Section "Alby Hard Mode Arachne Cutscene Removal" MOD447
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_hardmode_albi_arachne.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD447}
  DetailPrint "*** Removing MOD447..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_hardmode_albi_arachne.xml"
!macroend
Section "Golden Spider Cutscene Removal" MOD3
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_albi_golden_spider.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD3}
  DetailPrint "*** Removing MOD3..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_albi_golden_spider.xml"
!macroend
Section "Ghost Army Cutscene Removal" MOD4
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_ghostarmy.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD4}
  DetailPrint "*** Removing MOD4..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_ghostarmy.xml"
!macroend
Section "Giant Ice Sprite Cutscene Removal" MOD5
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_giant_ice_sprite.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD5}
  DetailPrint "*** Removing MOD5..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_giant_ice_sprite.xml"
!macroend
Section "Generic Incubus Cutscene Removal" MOD6
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_incubus.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD6}
  DetailPrint "*** Removing MOD6..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_incubus.xml"
!macroend
Section "Dugald Incubus Cutscene Removal" MOD7
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_incubus_dugald.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD7}
  DetailPrint "*** Removing MOD7..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_incubus_dugald.xml"
!macroend
Section "Dugald Incubus Transformation Cutscene Removal" MOD8
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_incubus_dugald_transform.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD8}
  DetailPrint "*** Removing MOD8..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_incubus_dugald_transform.xml"
!macroend
Section "Sen Mag Incubus Cutscene Removal" MOD9
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_incubus_senmag.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD9}
  DetailPrint "*** Removing MOD9..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_incubus_senmag.xml"
!macroend
Section "Sen Mag Incubus Transformation Cutscene Removal" MOD10
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_incubus_senmag_transform.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD10}
  DetailPrint "*** Removing MOD10..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_incubus_senmag_transform.xml"
!macroend
Section "Generic Incubus Transformation Cutscene Removal" MOD11
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\bossroom_incubus_transform.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD11}
  DetailPrint "*** Removing MOD11..."
  Delete "$INSTDIR\data\db\cutscene\c2\bossroom_incubus_transform.xml"
!macroend
Section "Bandersnatch Cutscene Removal" MOD12
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_bandersnatch.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD12}
  DetailPrint "*** Removing MOD12..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_bandersnatch.xml"
!macroend
Section "Desert Ruins Boss Cutscene Removal" MOD13
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_dersert_ruins.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD13}
  DetailPrint "*** Removing MOD13..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_dersert_ruins.xml"
!macroend
Section "Mirror Witch Cutscene Removal" MOD14
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_mirrorwitch.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD14}
  DetailPrint "*** Removing MOD14..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_mirrorwitch.xml"
!macroend
Section "Angry Mirror Witch Cutscene Removal" MOD15
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_mirrorwitch_angry.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD15}
  DetailPrint "*** Removing MOD15..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_mirrorwitch_angry.xml"
!macroend
Section "Mirror Witch Introduction Cutscene Removal" MOD16
SetOutPath "$INSTDIR\data\db\cutscene\c2\"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_mirrorwitch_intro.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD16}
  DetailPrint "*** Removing MOD16..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_mirrorwitch_intro.xml"
!macroend
Section "Pot Spider Cutscene Removal" MOD17
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_potspider.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD17}
  DetailPrint "*** Removing MOD17..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_potspider.xml"
!macroend
Section "Pot Spider Pincer Cutscene Removal" MOD18
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_potspider_claw.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD18}
  DetailPrint "*** Removing MOD18..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_potspider_claw.xml"
!macroend
Section "Pot Spider Leg Cutscene Removal" MOD19
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_potspider_leg.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD19}
  DetailPrint "*** Removing MOD19..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_potspider_leg.xml"
!macroend
Section "Pot Spider Molar Cutscene Removal" MOD20
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_potspider_molar.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD20}
  DetailPrint "*** Removing MOD20..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_potspider_molar.xml"
!macroend
Section "Pot Spider Venom Sac" MOD21
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_potspider_poisongland.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD21}
  DetailPrint "*** Removing MOD21..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_potspider_poisongland.xml"
!macroend
Section "Pot Spider Pot Belly Cutscene Removal" MOD22
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_potspider_pot.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD22}
  DetailPrint "*** Removing MOD22..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_potspider_pot.xml"
!macroend
Section "Shining Gargoyle Cutscene Removal" MOD23
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_shining_stonegargoyle.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD23}
  DetailPrint "*** Removing MOD23..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_shining_stonegargoyle.xml"
!macroend
Section "Stone Bison Cutscene Removal" MOD24
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonebison.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD24}
  DetailPrint "*** Removing MOD24..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonebison.xml"
!macroend
Section "Stone Bison Hoof Cutscene Removal" MOD25
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonebison_hoof.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD25}
  DetailPrint "*** Removing MOD25..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonebison_hoof.xml"
!macroend
Section "Stone Bison Horn Cutscene Removal" MOD26
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonebison_horn.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD26}
  DetailPrint "*** Removing MOD26..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonebison_horn.xml"
!macroend
Section "Stone Bison Tail Cutscene Removal" MOD27
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonebison_tail.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD27}
  DetailPrint "*** Removing MOD27..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonebison_tail.xml"
!macroend
Section "Stone Bison Teeth Cutscene Removal" MOD28
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonebison_teeth.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD28}
  DetailPrint "*** Removing MOD28..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonebison_teeth.xml"
!macroend
Section "Stone Gargoyle Cutscene Removal" MOD29
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonegargoyle.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD29}
  DetailPrint "*** Removing MOD29..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonegargoyle.xml"
!macroend
Section "Stone Gargoyle Boots Cutscene Removal" MOD30
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonegargoyle_boots.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD30}
  DetailPrint "*** Removing MOD30..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonegargoyle_boots.xml"
!macroend
Section "Stone Gargoyle Glove Cutscene Removal" MOD31
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonegargoyle_glove.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD31}
  DetailPrint "*** Removing MOD31..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonegargoyle_glove.xml"
!macroend
Section "Stone Gargoyle Shoulder Cutscene Removal" MOD32
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonegargoyle_shoulder.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD32}
  DetailPrint "*** Removing MOD32..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonegargoyle_shoulder.xml"
!macroend
Section "Stone Horse Cutscene Removal" MOD33
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonehorse.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD33}
  DetailPrint "*** Removing MOD33..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonehorse.xml"
!macroend
Section "Stone Hound Cutscene Removal" MOD34
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonehound.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD34}
  DetailPrint "*** Removing MOD34..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonehound.xml"
!macroend
Section "Stone Hound Anklet Cutscene Removal" MOD35
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonehound_anklet.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD35}
  DetailPrint "*** Removing MOD35..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonehound_anklet.xml"
!macroend
Section "Stone Hound Paw Cutscene Removal" MOD36
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonehound_claw.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD36}
  DetailPrint "*** Removing MOD36..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonehound_claw.xml"
!macroend
Section "Stone Hound Ear Cutscene Removal" MOD37
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonehound_ear.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD37}
  DetailPrint "*** Removing MOD37..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonehound_ear.xml"
!macroend
Section "Stone Hound Tail Cutscene Removal" MOD38
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonehound_tail.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD38}
  DetailPrint "*** Removing MOD38..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonehound_tail.xml"
!macroend
Section "Stone Hound Teeth Cutscene Removal" MOD39
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonehound_teeth.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD39}
  DetailPrint "*** Removing MOD39..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonehound_teeth.xml"
!macroend
Section "Stone Imp Cutscene Removal" MOD40
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stoneimp.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD40}
  DetailPrint "*** Removing MOD40..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stoneimp.xml"
!macroend
Section "Stone Imp Hat Cutscene Removal" MOD41
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stoneimp_cap.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD41}
  DetailPrint "*** Removing MOD41..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stoneimp_cap.xml"
!macroend
Section "Stone Imp Accessory Cutscene Removal" MOD42
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stoneimp_capaccessory.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD42}
  DetailPrint "*** Removing MOD42..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stoneimp_capaccessory.xml"
!macroend
Section "Stone Imp Ear Cutscene Removal" MOD43
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stoneimp_ear.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD43}
  DetailPrint "*** Removing MOD43..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stoneimp_ear.xml"
!macroend
Section "Stone Imp Jewel Cutscene Removal" MOD44
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stoneimp_jewel.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD44}
  DetailPrint "*** Removing MOD44..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stoneimp_jewel.xml"
!macroend
Section "Stone Imp Nose Cutscene Removal" MOD45
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stoneimp_nose.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD45}
  DetailPrint "*** Removing MOD45..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stoneimp_nose.xml"
!macroend
Section "Stone Imp Sandal Cutscene Removal" MOD46
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stoneimp_sandal.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD46}
  DetailPrint "*** Removing MOD46..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stoneimp_sandal.xml"
!macroend
Section "Stone Pot Spider Cutscene Removal" MOD47
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonepotspider.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD47}
  DetailPrint "*** Removing MOD47..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonepotspider.xml"
!macroend
Section "Stone Zombie Cutscene Removal" MOD48
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonezombie.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD48}
  DetailPrint "*** Removing MOD48..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonezombie.xml"
!macroend
Section "Stone Zombie Belt Cutscene Removal" MOD49
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonezombie_belt.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD49}
  DetailPrint "*** Removing MOD49..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonezombie_belt.xml"
!macroend
Section "Stone Zombie Circlet Cutscene Removal" MOD50
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonezombie_circlet.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD50}
  DetailPrint "*** Removing MOD50..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonezombie_circlet.xml"
!macroend
Section "Stone Zombie Eye Cutscene Removal" MOD51
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonezombie_eye.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD51}
  DetailPrint "*** Removing MOD51..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonezombie_eye.xml"
!macroend
Section "Stone Zombie Hair Cutscene Removal" MOD52
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonezombie_hair.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD52}
  DetailPrint "*** Removing MOD52..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonezombie_hair.xml"
!macroend
Section "Stone Zombie Shoulder Cutscene Removal" MOD53
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonezombie_shoulder.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD53}
  DetailPrint "*** Removing MOD53..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonezombie_shoulder.xml"
!macroend
Section "Stone Zombie Wristlet Cutscene Removal" MOD54
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_stonezombie_wristlet.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD54}
  DetailPrint "*** Removing MOD54..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_stonezombie_wristlet.xml"
!macroend
Section "Wendigo Cutscene Removal" MOD55
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_bossroom_wendigo.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD55}
  DetailPrint "*** Removing MOD55..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_bossroom_wendigo.xml"
!macroend
Section "Mark Discovery Cutscene Removal" MOD56
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_finding_mark.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD56}
  DetailPrint "*** Removing MOD56..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_finding_mark.xml"
!macroend
Section "Landmark Discovery Cutscene Removal" MOD57
SetOutPath "$INSTDIR\data\db\cutscene\c2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c2\iria_finding_landmark.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD57}
  DetailPrint "*** Removing MOD57..."
  Delete "$INSTDIR\data\db\cutscene\c2\iria_finding_landmark.xml"
!macroend
SectionGroupEnd
SectionGroup "c3"
Section "Awakening of Light Cutscene Removal" MOD58
SetOutPath "$INSTDIR\data\db\cutscene\c3"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c3\cutscene_c3g10_halfgod_transform.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD58}
  DetailPrint "*** Removing MOD58..."
  Delete "$INSTDIR\data\db\cutscene\c3\cutscene_c3g10_halfgod_transform.xml"
!macroend
Section "Abb Neagh Incubus Cutscene Removal" MOD407
SetOutPath "$INSTDIR\data\db\cutscene\c3"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c3\bossroom_incubus_abb.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD407}
  DetailPrint "*** Removing MOD407..."
  Delete "$INSTDIR\data\db\cutscene\c3\bossroom_incubus_abb.xml"
!macroend
Section "Abb Neagh Incubus Transformation Cutscene Removal" MOD408
SetOutPath "$INSTDIR\data\db\cutscene\c3"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c3\bossroom_incubus_abb_transform.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD408}
  DetailPrint "*** Removing MOD408..."
  Delete "$INSTDIR\data\db\cutscene\c3\bossroom_incubus_abb_transform.xml"
!macroend
Section "Cuilin Incubus Cutscene Removal" MOD409
SetOutPath "$INSTDIR\data\db\cutscene\c3"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c3\bossroom_incubus_cuilin.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD409}
  DetailPrint "*** Removing MOD409..."
  Delete "$INSTDIR\data\db\cutscene\c3\bossroom_incubus_cuilin.xml"
!macroend
Section "Cuilin Incubus Transformation Cutscene Removal" MOD410
SetOutPath "$INSTDIR\data\db\cutscene\c3"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c3\bossroom_incubus_cuilin_transform.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD410}
  DetailPrint "*** Removing MOD410..."
  Delete "$INSTDIR\data\db\cutscene\c3\bossroom_incubus_cuilin_transform.xml"
!macroend
SectionGroupEnd
SectionGroup "c4"
Section "Martial Arts-NPC Battle Cutscene Removal" MOD59
SetOutPath "$INSTDIR\data\db\cutscene\c4"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c4\cutscene_c4g15_npc_mission.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD59}
  DetailPrint "*** Removing MOD59..."
  Delete "$INSTDIR\data\db\cutscene\c4\cutscene_c4g15_npc_mission.xml"
!macroend
Section "Paris Proposal Cutscene Removal" MOD411
SetOutPath "$INSTDIR\data\db\cutscene\c4"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c4\cutscene_c4g14_1_2_propose_from_paris.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD411}
  DetailPrint "*** Removing MOD411..."
  Delete "$INSTDIR\data\db\cutscene\c4\cutscene_c4g14_1_2_propose_from_paris.xml"
!macroend
Section "SoulStream Purification Cutscene Removal" MOD412
SetOutPath "$INSTDIR\data\db\cutscene\c4"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c4\cutscene_c4g16_16_soulstream_purify.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD412}
  DetailPrint "*** Removing MOD412..."
  Delete "$INSTDIR\data\db\cutscene\c4\cutscene_c4g16_16_soulstream_purify.xml"
!macroend
Section "Bandit Hideout Entry Cutscene Removal" MOD413
SetOutPath "$INSTDIR\data\db\cutscene\c4"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c4\cutscene_crminalfarm_enter.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD413}
  DetailPrint "*** Removing MOD413..."
  Delete "$INSTDIR\data\db\cutscene\c4\cutscene_crminalfarm_enter.xml"
!macroend
Section "Bandit Hideout Exit Cutscene Removal" MOD414
SetOutPath "$INSTDIR\data\db\cutscene\c4"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c4\cutscene_crminalfarm_exit.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD414}
  DetailPrint "*** Removing MOD414..."
  Delete "$INSTDIR\data\db\cutscene\c4\cutscene_crminalfarm_exit.xml"
!macroend
Section "Grim Reaper Boss Cutscene Removal" MOD448
SetOutPath "$INSTDIR\data\db\cutscene\c4"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c4\cutscene_c4g13s2_bossroom_grimreaper.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD448}
  DetailPrint "*** Removing MOD448..."
  Delete "$INSTDIR\data\db\cutscene\c4\cutscene_c4g13s2_bossroom_grimreaper.xml"
!macroend
Section "Snow Troll Intro Cutscene Removal" MOD449
SetOutPath "$INSTDIR\data\db\cutscene\c4"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c4\cutscene_c4g13s2_ex_snowtroll.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD449}
  DetailPrint "*** Removing MOD449..."
  Delete "$INSTDIR\data\db\cutscene\c4\cutscene_c4g13s2_ex_snowtroll.xml"
!macroend
Section "Sailing Ship Cutscene Removals" MOD450
SetOutPath "$INSTDIR\data\db\cutscene\c4"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c4\cutscene_c4g15_ship.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD450}
  DetailPrint "*** Removing MOD450..."
  Delete "$INSTDIR\data\db\cutscene\c4\cutscene_c4g15_ship.xml"
!macroend
Section "Belvast Intro Cutscene Removal1" MOD451
SetOutPath "$INSTDIR\data\db\cutscene\c4"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\c4\cutscene_into_the_belfast.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD451}
  DetailPrint "*** Removing MOD451..."
  Delete "$INSTDIR\data\db\cutscene\c4\cutscene_into_the_belfast.xml"
!macroend
SectionGroupEnd
SectionGroup "drama"
SectionGroup "Saga 1 Ep 1 Cutscene Removals" MOD415
Section "Saga 1 Ep 1 Cutscene Removal ?1" MOD415?1
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_01.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?1}
  DetailPrint "*** Removing MOD415?1..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_01.xml"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?2" MOD415?2
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_02.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?2}
  DetailPrint "*** Removing MOD415?2..."
  Delete "$INSTDIR\"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?3" MOD415?3
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_03.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?3}
  DetailPrint "*** Removing MOD415?3..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_03.xml"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?4" MOD415?4
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_04.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?4}
  DetailPrint "*** Removing MOD415?4..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_04.xml"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?5" MOD415?5
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_05.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?5}
  DetailPrint "*** Removing MOD415?5..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_05.xml"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?6" MOD415?6
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_06.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?6}
  DetailPrint "*** Removing MOD415?6..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_06.xml"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?7" MOD415?7
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_06_1.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?7}
  DetailPrint "*** Removing MOD415?7..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_06_1.xml"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?8" MOD415?8
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_07.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?8}
  DetailPrint "*** Removing MOD415?8..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_07.xml"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?9" MOD415?9
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_ex_into_region.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?9}
  DetailPrint "*** Removing MOD415?9..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_ex_into_region.xml"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?10" MOD415?10
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_ex01.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?10}
  DetailPrint "*** Removing MOD415?10..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_ex01.xml"
!macroend
Section "Saga 1 Ep 1 Cutscene Removal ?11" MOD415?11
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep1_ex02.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD415?11}
  DetailPrint "*** Removing MOD415?11..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_ex02.xml"
!macroend
!macro Remove_${MOD415}
  DetailPrint "*** Removing MOD415..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_06.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_06_1.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_07.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_ex_into_region.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_ex01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep1_ex02.xml"
!macroend
SectionGroupEnd
Section "Saga 1 Ep 2 Cutscene Removals" MOD416
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep2_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep2_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep2_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep2_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep2_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep2_06.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep2_07.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep2_ex01.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD416}
  DetailPrint "*** Removing MOD416..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep2_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep2_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep2_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep2_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep2_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep2_06.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep2_07.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep2_ex01.xml"
!macroend
Section "Saga 1 Ep 3 Cutscene Removals" MOD417
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep3_00.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep3_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep3_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep3_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep3_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep3_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep3_06.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD417}
  DetailPrint "*** Removing MOD417..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep3_00.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep3_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep3_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep3_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep3_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep3_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep3_06.xml"
!macroend
Section "Saga 1 Ep 4 Cutscene Removals" MOD418
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep4_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep4_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep4_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep4_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep4_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep4_06.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD418}
  DetailPrint "*** Removing MOD418..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep4_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep4_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep4_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep4_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep4_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep4_06.xml"
!macroend
Section "Saga 1 Ep 5 Cutscene Removals" MOD419
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep5_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep5_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep5_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep5_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep5_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep5_sub_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep5_sub_02.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD419}
  DetailPrint "*** Removing MOD419..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep5_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep5_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep5_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep5_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep5_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep5_sub_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep5_sub_02.xml"
!macroend
Section "Saga 1 Ep 6 Cutscene Removals" MOD420
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep6_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep6_01_1.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep6_01_2.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep6_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep6_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep6_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep6_05.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD420}
  DetailPrint "*** Removing MOD420..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep6_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep6_01_1.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep6_01_2.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep6_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep6_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep6_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep6_05.xml"
!macroend
Section "Saga 1 Ep 7 Cutscene Removals" MOD421
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep7_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep7_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep7_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep7_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep7_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep7_06.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep7_ex_commentary.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD421}
  DetailPrint "*** Removing MOD421..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep7_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep7_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep7_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep7_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep7_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep7_06.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep7_ex_commentary.xml"
!macroend
Section "Saga 1 Ep 8 Cutscene Removals" MOD422
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep8_00.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep8_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep8_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep8_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep8_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep8_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep8_06.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep8_07.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep8_08.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD422}
  DetailPrint "*** Removing MOD422..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep8_00.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep8_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep8_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep8_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep8_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep8_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep8_06.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep8_07.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep8_08.xml"
!macroend
Section "Saga 1 Ep 9 Cutscene Removals" MOD423
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep9_00.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep9_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep9_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep9_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep9_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep9_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep9_06.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD423}
  DetailPrint "*** Removing MOD423..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep9_00.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep9_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep9_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep9_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep9_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep9_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep9_06.xml"
!macroend
Section "Saga 1 Ep 10 Cutscene Removals" MOD424
SetOutPath "$INSTDIR\data\db\cutscene\drama"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep10_00.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep10_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep10_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep10_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep10_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep10_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama\cutscene_dramairia_ep10_06.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD424}
  DetailPrint "*** Removing MOD424..."
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep10_00.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep10_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep10_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep10_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep10_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep10_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama\cutscene_dramairia_ep10_06.xml"
!macroend
SectionGroupEnd
SectionGroup "drama2"
Section "Saga 2 Ep 1 Cutscene Removals" MOD425
SetOutPath "$INSTDIR\data\db\cutscene\drama2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_06.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_07.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_08.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_09.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_10.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_11.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_12.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_13.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_14.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_14_1.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_15.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_16.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_17.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_18.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_19.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_20.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_21.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_22.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_23.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_24.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_25.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_26.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_27.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_28.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_29.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_30.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_31.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_start01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep1_start02.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD425}
  DetailPrint "*** Removing MOD425..."
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_06.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_07.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_08.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_09.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_10.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_11.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_12.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_13.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_14.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_14_1.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_15.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_16.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_17.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_18.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_19.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_20.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_21.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_22.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_23.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_24.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_25.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_26.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_27.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_28.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_29.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_30.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_31.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_start01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep1_start02.xml"
!macroend
Section "Saga 2 Ep 2 Cutscene Removals" MOD426
SetOutPath "$INSTDIR\data\db\cutscene\drama2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep2_start.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD426}
  DetailPrint "*** Removing MOD426..."
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep2_start.xml"
!macroend
Section "Saga 2 Ep 3 Cutscene Removals" MOD427
SetOutPath "$INSTDIR\data\db\cutscene\drama2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_06.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_07.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_08.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_09.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_10.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_11.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_12.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep3_start.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD427}
  DetailPrint "*** Removing MOD427..."
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_06.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_07.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_08.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_09.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_10.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_11.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_12.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep3_start.xml"
!macroend
Section "Saga 2 Ep 4 Cutscene Removals" MOD428
SetOutPath "$INSTDIR\data\db\cutscene\drama2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep4_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep4_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep4_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep4_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep4_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep4_06.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep4_07.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep4_08.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep4_start.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD428}
  DetailPrint "*** Removing MOD428..."
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep4_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep4_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep4_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep4_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep4_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep4_06.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep4_07.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep4_08.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep4_start.xml"
!macroend
Section "Saga 2 Ep 5 Cutscene Removals" MOD429
SetOutPath "$INSTDIR\data\db\cutscene\drama2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_06.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_07.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_08.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_09.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_10.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_11.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep5_start.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD429}
  DetailPrint "*** Removing MOD429..."
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_06.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_07.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_08.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_09.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_10.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_11.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep5_start.xml"
!macroend
Section "Saga 2 Ep 6 Cutscene Removals" MOD430
SetOutPath "$INSTDIR\data\db\cutscene\drama2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_06.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_07.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_08.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_09.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_10.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_start.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\cutscene\drama2\cutscene_dramairia2_ep6_start_2.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD430}
  DetailPrint "*** Removing MOD430..."
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_01.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_02.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_03.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_04.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_05.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_06.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_07.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_08.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_09.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_10.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_start.xml"
  Delete "$INSTDIR\data\db\cutscene\drama2\cutscene_dramairia2_ep6_start_2.xml"
!macroend
SectionGroupEnd
SectionGroupEnd
SectionGroupEnd
SectionGroup "gfx"
Section "Feth Indicator" MOD73
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\C5_doll_effect.xml"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD73}
  DetailPrint "*** Removing MOD73..."
  Delete "$INSTDIR\data\gfx\fx\effect\C5_doll_effect.xml"
!macroend
Section "Bandit Spotter 3" MOD299
SetOutPath "$INSTDIR\data\gfx\char\human\male\helmet"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\male\helmet\male_theater01_paper_h01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\male\helmet\male_theater03_paper_h01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\male\helmet\male_theater04_paper_h01.xml"
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\my_effect_52baka.xml"
SetOutPath "$INSTDIR\data\material\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\effect\common_effect_add_8_52baka.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\effect\common_effect_add_9_52baka.dds"
SetOutPath "$INSTDIR\data\material\_define\material\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\material\_define\material\effect\mat_effect_custom_52baka.xml"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD299}
  DetailPrint "*** Removing MOD299..."
  Delete "$INSTDIR\data\gfx\char\human\male\helmet\male_theater01_paper_h01.xml"
  Delete "$INSTDIR\data\gfx\char\human\male\helmet\male_theater03_paper_h01.xml"
  Delete "$INSTDIR\data\gfx\char\human\male\helmet\male_theater04_paper_h01.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\my_effect_52baka.xml"
  Delete "$INSTDIR\data\material\fx\effect\common_effect_add_8_52baka.dds"
  Delete "$INSTDIR\data\material\fx\effect\common_effect_add_9_52baka.dds"
  Delete "$INSTDIR\data\material\_define\material\effect\mat_effect_custom_52baka.xml"
!macroend
Section "Phantasmal Sight Color" MOD402
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\g23_specialization.xml"
SetOutPath "$INSTDIR\data\material\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\effect\Blue.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\effect\Metallurgy.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\effect\Yellow.dds"
SetOutPath "$INSTDIR\data\material\_define\material\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\material\_define\material\effect\Blue.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\material\_define\material\effect\Metallurgy.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\material\_define\material\effect\Yellow.xml"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD402}
  DetailPrint "*** Removing MOD402..."
  Delete "$INSTDIR\data\gfx\fx\effect\g23_specialization.xml"
  Delete "$INSTDIR\data\material\fx\effect\Blue.dds"
  Delete "$INSTDIR\data\material\fx\effect\Metallurgy.dds"
  Delete "$INSTDIR\data\material\fx\effect\Yellow.dds"
  Delete "$INSTDIR\data\material\_define\material\effect\Blue.xml"
  Delete "$INSTDIR\data\material\_define\material\effect\Metallurgy.xml"
  Delete "$INSTDIR\data\material\_define\material\effect\Yellow.xml"
!macroend
SectionGroup "Tech Duinn Fog Removal" MOD396
Section "Tech Duinn Fog Removal ?1" MOD396?1
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\gd1\prop\"
  DetailPrint "Installing Tech Duinn Fog Removal ?1..."
  File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\gd1\prop\dg_gd1_senmag_fog_01.xml"
SetDetailsPrint both
SectionIn 1 2
SectionEnd
!macro Remove_${MOD396?1}
  DetailPrint "*** Removing Tech Duinn Fog Removal ?1..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\gd1\prop\dg_gd1_senmag_fog_01.xml"
!macroend
Section "Tech Duinn Fog Removal ?2" MOD396?2
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\gd1\room\"
  DetailPrint "Installing Tech Duinn Fog Removal ?2..."
  File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\gd1\room\dg_gd1_balor_temple_lobby01_fog01.xml"
SetDetailsPrint both
SectionIn 1 2
SectionEnd
!macro Remove_${MOD396?2}
  DetailPrint "*** Removing Tech Duinn Fog Removal ?2..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\gd1\room\dg_gd1_balor_temple_lobby01_fog01.xml"
!macroend
SectionGroupEnd
!macro Remove_${MOD396}
  DetailPrint "*** Removing Tech Duinn Fog Removal..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\gd1\prop\dg_gd1_senmag_fog_01.xml"
  Delete "$INSTDIR\data\gfx\scene\dungeon\gd1\room\dg_gd1_balor_temple_lobby01_fog01.xml"
!macroend
Section "Simplified Baltane Squire Area" MOD453
  DetailPrint "Installing Simplified Baltane Squire Area..."
SetOutPath "$INSTDIR\data\gfx\scene\dgc\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_bridge_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_ladder.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_object01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_object02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_object03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_object04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_door01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_door02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_house.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_wall01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_wall02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_wall03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_wall04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_weapon01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_weapon02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_door01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_door02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_house.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_wall01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_wall02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_wall03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_wall04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_pillar01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_pillar02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_wall01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_wall02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_wall03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_wall04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_floor_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_statue_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_statue_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_tree_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_tree_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_wall_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_dog_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_entrance_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_firewood_01_collecting.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_firewood_01_empty.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_firewood_01_normal.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_floor01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_door.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_door_close_empty.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_fire.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stone01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stone02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stonestatue_left.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stonestatue_right.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_tree_left.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_tree_right.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left06.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left07.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left08.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right06.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right07.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right08.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_horse_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_horse_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_candle.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_flag01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_flag02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_house.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_object01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_table01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_wall01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_wall02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_wall03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_wall04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_readingdesk_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_horse.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_pillar01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_pillar02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_wall01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_wall02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_wall03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_statue01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_top_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_top_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_left_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_left_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_left_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_left_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_right_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_right_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_right_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_right_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_worktable_01_collectable.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_worktable_01_empty.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_bridge_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_floor_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_tree_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_tree_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_door_close_operation.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_fire.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stonestatue_left.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stonestatue_right.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_tree_left.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_tree_right.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right05.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_candle.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_table01.xml"
SetOutPath "$INSTDIR\data\gfx\scene\field\dgc"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_flower_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_flower_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_tree_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_tree_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_tree_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_tree_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_water_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_cliff_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_tree_03.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_tree_04.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\field_prop_dgc_water_01.xml"
SetOutPath "$INSTDIR\data\gfx\scene\field\dgc\tb"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\tb\tb_dgc_waterfall_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\tb\tb_dgc_cliff_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\tb\tb_dgc_cliff_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\dgc\tb\tb_dgc_waterfall_01.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD453}
  DetailPrint "*** Removing Simplified Baltane Squire Area..."
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_bridge_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_ladder.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_object01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_object02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_object03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace_object04.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_door01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_door02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_house.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_wall01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_wall02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_wall03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_wall04.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_weapon01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_left_weapon02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_door01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_door02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_house.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_wall01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_wall02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_wall03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace01_right_wall04.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_pillar01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_pillar02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_wall01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_wall02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_wall03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_characterspace02_left_wall04.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_floor_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_statue_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_statue_02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_tree_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_tree_02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_wall_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_dog_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_entrance_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_firewood_01_collecting.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_firewood_01_empty.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_firewood_01_normal.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_floor01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_door.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_door_close_empty.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_fire.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stone01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stone02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stonestatue_left.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stonestatue_right.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_tree_left.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_tree_right.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left04.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left05.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left06.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left07.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left08.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right04.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right05.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right06.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right07.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right08.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_horse_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_horse_02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_candle.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_flag01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_flag02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_house.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_object01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_table01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_wall01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_wall02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_wall03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_wall04.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_readingdesk_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_horse.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_pillar01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_pillar02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_wall01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_wall02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_stable_wall03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_statue01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_top_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_top_02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_left_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_left_02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_left_03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_left_04.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_right_01.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_right_02.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_right_03.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_wall_right_04.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_worktable_01_collectable.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_worktable_01_empty.pmg"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_bridge_01.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_floor_01.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_tree_01.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_conferencehall_tree_02.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_door_close_operation.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_fire.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stonestatue_left.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_stonestatue_right.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_tree_left.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_tree_right.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_left05.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_gate_wall_right05.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_candle.xml"
Delete "$INSTDIR\data\gfx\scene\dgc\prop\scene_prop_dgc_hospital_table01.xml"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_flower_01.pmg"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_flower_02.pmg"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_tree_01.pmg"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_tree_02.pmg"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_tree_03.pmg"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_tree_04.pmg"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_water_01.pmg"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_cliff_02.xml"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_tree_03.xml"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_tree_04.xml"
Delete "$INSTDIR\data\gfx\scene\field\dgc\field_prop_dgc_water_01.xml"
Delete "$INSTDIR\data\gfx\scene\field\dgc\tb\tb_dgc_waterfall_01.pmg"
Delete "$INSTDIR\data\gfx\scene\field\dgc\tb\tb_dgc_cliff_01.xml"
Delete "$INSTDIR\data\gfx\scene\field\dgc\tb\tb_dgc_cliff_02.xml"
Delete "$INSTDIR\data\gfx\scene\field\dgc\tb\tb_dgc_waterfall_01.xml"
!macroend
Section "Simplified Festia" MOD457
SetOutPath "$INSTDIR\data\gfx\scene\erinnland"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_couple_girl.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_couple_man.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_arch01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_arch01_ballon01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_backgate01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_backgate02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_backgate02_ballon01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_backgate03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_bed01_stand.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_bench_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_board_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_bunting01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_bush01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_catchtail01_single.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_cottoncandy01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_dungeongate01_single.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_fairy01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_fairy02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_fairy03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_fairy04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_fairy05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_food_store.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_fountain01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_garden01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_giantbed01_stand.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_glasgavelen_single.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_light01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_lorraine_single.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_lorraine_stone01_single.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_lorraine_stone02_single.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_mainegate01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_mainegate01_left01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_mainegate01_right01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_maingate01_ballon01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_monsterdefence01_single.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_punch_column01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_punch_column02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_punch_column03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_punch_column04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_punchgate01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_souvenir_store.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_store.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_streetlight.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tent01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tent02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tent03_single.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tree01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tree02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tree03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tree04_cross.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tree05_cross.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tree06_cross.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_wall01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_wall02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_catchtail01_single.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_dungeongate01_single.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_fountain01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_fountain01_floor.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_monsterdefence01_head01_single.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_monsterdefence01_single.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\erinnland\scene_prop_eld_tent02_object01.xml"
SetOutPath "$INSTDIR\data\gfx\scene\farm\prop\"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\farm\prop\farm_prop_13thanniversary_pinkrose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\farm\prop\farm_prop_13thanniversary_pinkrose02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\farm\prop\farm_prop_13thanniversary_redrose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\farm\prop\farm_prop_13thanniversary_redrose02.pmg"
SetOutPath "$INSTDIR\data\gfx\scene\productionprop\"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_10thanniversary_10garden_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_11thanniversary_11garden01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_11thanniversary_board_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_11thanniversary_gate_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_13garden_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_arch01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_archrose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_backgate02_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_bush01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_catchtail01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_floor01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_floor01_rose02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_landmark01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_landmark01_rose02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_landmark01_rose03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_lorraine01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_mainegate01_right01_rose02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_maingaterose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_monsterdefence01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_outdoorstage01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_punchgate01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_redcarpet01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_redcarpet02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_rose_wreath01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_seats_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_storerose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_storerose02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_tent_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_13thanniversary_tree_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_attraction01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_flowerpot01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_flowerpot02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_flowerpot03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_roseflower01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_event_13thattraction01_rose01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_11thanniversary_board_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_attraction01.xml"
SetOutPath "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_10garden01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_balloon_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_barrel_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_barrel_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_board_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_box01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_box02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_bunting_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_bush_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_cottoncandystrore01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_fingerfood.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_fingerfood02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_flower_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_flowerpot_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_flowerpot_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_garbagecan.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_gift_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_gift_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_icecreamstore_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_instrumentbox_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_ladder_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_lamp_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01_balloon.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01_tree.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01_tree_flag01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01_tree_inbisible.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_outdoorstage01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_outdoorstage02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_outdoorstage03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_popcornstrore01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_smallflag01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_smalltree_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_sttingmat01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_sttingmat02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_sttingmat03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_tent01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_board_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_board_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_campfire01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_candle01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_dungeongate_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_icecreamstore_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_outdoorstage01.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD457}
  DetailPrint "*** Removing Simplified Festia..."
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_couple_girl.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_couple_man.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_arch01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_arch01_ballon01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_backgate01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_backgate02.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_backgate02_ballon01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_backgate03.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_bed01_stand.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_bench_01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_board_03.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_bunting01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_bush01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_catchtail01_single.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_cottoncandy01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_dungeongate01_single.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_fairy01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_fairy02.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_fairy03.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_fairy04.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_fairy05.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_food_store.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_fountain01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_garden01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_giantbed01_stand.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_glasgavelen_single.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_light01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_lorraine_single.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_lorraine_stone01_single.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_lorraine_stone02_single.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_mainegate01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_mainegate01_left01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_mainegate01_right01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_maingate01_ballon01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_monsterdefence01_single.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_punch_column01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_punch_column02.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_punch_column03.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_punch_column04.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_punchgate01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_souvenir_store.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_store.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_streetlight.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tent01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tent02.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tent03_single.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tree01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tree02.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tree03.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tree04_cross.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tree05_cross.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tree06_cross.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_wall01.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_wall02.pmg"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_catchtail01_single.xml"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_dungeongate01_single.xml"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_fountain01.xml"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_fountain01_floor.xml"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_monsterdefence01_head01_single.xml"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_monsterdefence01_single.xml"
Delete "$INSTDIR\data\gfx\scene\erinnland\scene_prop_eld_tent02_object01.xml"
Delete "$INSTDIR\data\gfx\scene\farm\prop\farm_prop_13thanniversary_pinkrose01.pmg"
Delete "$INSTDIR\data\gfx\scene\farm\prop\farm_prop_13thanniversary_pinkrose02.pmg"
Delete "$INSTDIR\data\gfx\scene\farm\prop\farm_prop_13thanniversary_redrose01.pmg"
Delete "$INSTDIR\data\gfx\scene\farm\prop\farm_prop_13thanniversary_redrose02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_10thanniversary_10garden_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_11thanniversary_11garden01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_11thanniversary_board_02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_11thanniversary_gate_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_13garden_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_arch01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_archrose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_backgate02_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_bush01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_catchtail01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_floor01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_floor01_rose02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_landmark01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_landmark01_rose02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_landmark01_rose03.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_lorraine01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_mainegate01_right01_rose02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_maingaterose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_monsterdefence01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_outdoorstage01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_punchgate01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_redcarpet01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_redcarpet02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_rose_wreath01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_seats_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_storerose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_storerose02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_tent_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_13thanniversary_tree_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_attraction01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_flowerpot01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_flowerpot02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_flowerpot03.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_roseflower01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_event_13thattraction01_rose01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_11thanniversary_board_02.xml"
Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_event_13thanniversary_attraction01.xml"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_10garden01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_balloon_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_barrel_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_barrel_02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_board_02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_box01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_box02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_bunting_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_bush_04.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_cottoncandystrore01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_fingerfood.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_fingerfood02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_flower_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_flowerpot_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_flowerpot_02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_garbagecan.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_gift_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_gift_02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_icecreamstore_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_instrumentbox_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_ladder_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_lamp_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01_balloon.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01_tree.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01_tree_flag01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_landmark_01_tree_inbisible.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_outdoorstage01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_outdoorstage02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_outdoorstage03.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_popcornstrore01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_smallflag01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_smalltree_01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_sttingmat01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_sttingmat02.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_sttingmat03.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_tent01.pmg"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_board_01.xml"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_board_02.xml"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_campfire01.xml"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_candle01.xml"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_dungeongate_01.xml"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_icecreamstore_01.xml"
Delete "$INSTDIR\data\gfx\scene\productionprop\10th_themapark\prop\scene_prop_10thanniversary_outdoorstage01.xml"
!macroend
Section "Show Strange Book" MOD392
SetOutPath "$INSTDIR\data\gfx\chapter3\monster\mesh\picturebooks"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\chapter3\monster\mesh\picturebooks\c3_picturebooks_mesh.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD392}
  DetailPrint "*** Removing MOD392..."
  Delete "$INSTDIR\data\gfx\chapter3\monster\mesh\picturebooks\c3_picturebooks_mesh.pmg"
!macroend
Section "Simplify Crystal Deer" MOD99
SetOutPath "$INSTDIR\data\gfx\char\chapter4\pet\anim\crystal_rudolf"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\chapter4\pet\anim\crystal_rudolf\pet_crystal_rudolf_ice_storm.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD99}
  DetailPrint "*** Removing MOD99..."
  Delete "$INSTDIR\data\gfx\char\chapter4\pet\anim\crystal_rudolf\pet_crystal_rudolf_ice_storm.ani"
!macroend
Section "Simplify Fire Dragon" MOD100
SetOutPath "$INSTDIR\data\gfx\char\chapter4\pet\anim\dragon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\chapter4\pet\anim\dragon\pet_firedragon_summon.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD100}
  DetailPrint "*** Removing MOD100..."
  Delete "$INSTDIR\data\gfx\char\chapter4\pet\anim\dragon\pet_firedragon_summon.ani"
!macroend
Section "Simplify Ice Dragon 1" MOD101
SetOutPath "$INSTDIR\data\gfx\char\chapter4\pet\anim\dragon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\chapter4\pet\anim\dragon\pet_icedragon_summon.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD101}
  DetailPrint "*** Removing MOD101..."
  Delete "$INSTDIR\data\gfx\char\chapter4\pet\anim\dragon\pet_icedragon_summon.ani"
!macroend
Section "Simplify Thunder Dragon" MOD102
SetOutPath "$INSTDIR\data\gfx\char\chapter4\pet\anim\dragon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\chapter4\pet\anim\dragon\pet_thunderdragon_summon.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD102}
  DetailPrint "*** Removing MOD102..."
  Delete "$INSTDIR\data\gfx\char\chapter4\pet\anim\dragon\pet_thunderdragon_summon.ani"
!macroend
Section "Simplify Thunder Dragon (two seater)" MOD103
SetOutPath "$INSTDIR\data\gfx\char\chapter4\pet\anim\dragon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\chapter4\pet\anim\dragon\pet_thunderdragon_two_summon.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD103}
  DetailPrint "*** Removing MOD103..."
  Delete "$INSTDIR\data\gfx\char\chapter4\pet\anim\dragon\pet_thunderdragon_two_summon.ani"
!macroend
Section "Simplify Flamemare" MOD104
SetOutPath "$INSTDIR\data\gfx\char\chapter4\pet\anim\flamemare"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\chapter4\pet\anim\flamemare\pet_flamemare_firestorm.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD104}
  DetailPrint "*** Removing MOD104..."
  Delete "$INSTDIR\data\gfx\char\chapter4\pet\anim\flamemare\pet_flamemare_firestorm.ani"
!macroend
Section "Simplify Ice Dragon 2 (framework)" MOD105
SetOutPath "$INSTDIR\data\gfx\char\chapter4\pet\mesh\dragon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\chapter4\pet\mesh\dragon\pet_c4_icedragon_framework.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD105}
  DetailPrint "*** Removing MOD105..."
  Delete "$INSTDIR\data\gfx\char\chapter4\pet\mesh\dragon\pet_c4_icedragon_framework.xml"
!macroend
Section "Invisible Female Giant Minimization Fix 1" MOD106
SetOutPath "$INSTDIR\data\gfx\char\giant\female\mentle"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\giant\female\mentle\giant_female_dummy_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD106}
  DetailPrint "*** Removing MOD106..."
  Delete "$INSTDIR\data\gfx\char\giant\female\mentle\giant_female_dummy_01.pmg"
!macroend
Section "Invisible Female Giant Minimization Fix 2" MOD107
SetOutPath "$INSTDIR\data\gfx\char\giant\male\mentle"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\giant\male\mentle\giant_male_dummy_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD107}
  DetailPrint "*** Removing MOD107..."
  Delete "$INSTDIR\data\gfx\char\giant\male\mentle\giant_male_dummy_01.pmg"
!macroend
Section "Alternate Success Animation" MOD108
SetOutPath "$INSTDIR\data\gfx\char\human\anim\emotion"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_success.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD108}
  DetailPrint "*** Removing MOD108..."
  Delete "$INSTDIR\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_success.ani"
!macroend
Section "Alternate Fail Animation" MOD109
SetOutPath "$INSTDIR\data\gfx\char\human\anim\emotion"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_Fail_short.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD109}
  DetailPrint "*** Removing MOD109..."
  Delete "$INSTDIR\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_Fail_short.ani"
!macroend
Section "Alternate Success Animation File" MOD110
SetOutPath "$INSTDIR\data\gfx\char\human\anim\emotion"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_success.mov"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD110}
  DetailPrint "*** Removing MOD110..."
  Delete "$INSTDIR\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_success.mov"
!macroend
Section "Alternate Fail Animation File" MOD111
SetOutPath "$INSTDIR\data\gfx\char\human\anim\emotion"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_Fail_short.mov"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD111}
  DetailPrint "*** Removing MOD111..."
  Delete "$INSTDIR\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_Fail_short.mov"
!macroend
Section "Herb Gathering Animation Replacement" MOD112
SetOutPath "$INSTDIR\data\gfx\char\human\anim"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\anim\uni_natural_gathering_eggs.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD112}
  DetailPrint "*** Removing MOD112..."
  Delete "$INSTDIR\data\gfx\char\human\anim\uni_natural_gathering_eggs.ani"
!macroend
Section "Invisible Female Human Minimization Fix" MOD113
SetOutPath "$INSTDIR\data\gfx\char\human\female\mantle"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\female\mantle\female_dummy_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD113}
  DetailPrint "*** Removing MOD113..."
  Delete "$INSTDIR\data\gfx\char\human\female\mantle\female_dummy_01.pmg"
!macroend
Section "Invisible Male Human Minimization Fix" MOD114
SetOutPath "$INSTDIR\data\gfx\char\human\male\mantle"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\male\mantle\male_dummy_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD114}
  DetailPrint "*** Removing MOD114..."
  Delete "$INSTDIR\data\gfx\char\human\male\mantle\male_dummy_01.pmg"
!macroend
Section "3 Glow Enhancement 1" MOD115
SetOutPath "$INSTDIR\data\gfx\char\human\tool"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\tool\tool_lroad_01.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD115}
  DetailPrint "*** Removing MOD115..."
  Delete "$INSTDIR\data\gfx\char\human\tool\tool_lroad_01.xml"
!macroend
Section "L-rod Glow Enhancement 2" MOD116
SetOutPath "$INSTDIR\data\gfx\char\human\tool"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\tool\tool_lroad_02.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD116}
  DetailPrint "*** Removing MOD116..."
  Delete "$INSTDIR\data\gfx\char\human\tool\tool_lroad_02.xml"
!macroend
Section "L-rod Glow Enhancement 3" MOD117
SetOutPath "$INSTDIR\data\gfx\char\human\tool"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\human\tool\tool_lroad_03.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD117}
  DetailPrint "*** Removing MOD117..."
  Delete "$INSTDIR\data\gfx\char\human\tool\tool_lroad_03.xml"
!macroend
Section "Guns Glow FX Enhancement" MOD400
SetOutPath "$INSTDIR\data\gfx\char\chapter4\human\tool"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\chapter4\human\tool\weapon_c4_dualgun05.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD400}
  DetailPrint "*** Removing MOD400..."
  Delete "$INSTDIR\data\gfx\char\chapter4\human\tool\weapon_c4_dualgun05.xml"
!macroend
Section "Item Drop Animation Removal 1" MOD118
SetOutPath "$INSTDIR\data\gfx\char\item\anim"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\anim\item_appear.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD118}
  DetailPrint "*** Removing MOD118..."
  Delete "$INSTDIR\data\gfx\char\item\anim\item_appear.ani"
!macroend
Section "Item Drop Animation Removal 2" MOD119
SetOutPath "$INSTDIR\data\gfx\char\item\anim"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\anim\item_appear02.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD119}
  DetailPrint "*** Removing MOD119..."
  Delete "$INSTDIR\data\gfx\char\item\anim\item_appear02.ani"
!macroend
Section "Item Drop Animation Removal 3" MOD120
SetOutPath "$INSTDIR\data\gfx\char\item\anim"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\anim\item_appear_From_prop.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD120}
  DetailPrint "*** Removing MOD120..."
  Delete "$INSTDIR\data\gfx\char\item\anim\item_appear_From_prop.ani"
!macroend
Section "Item Drop Animation Removal 4" MOD121
SetOutPath "$INSTDIR\data\gfx\char\item\anim"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\anim\item_appear02_From_prop.ani"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD121}
  DetailPrint "*** Removing MOD121..."
  Delete "$INSTDIR\data\gfx\char\item\anim\item_appear02_From_prop.ani"
!macroend
Section "Huge Boss Keys 1" MOD122
SetOutPath "$INSTDIR\data\gfx\char\item\mesh"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\mesh\item_bosskey_001.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD122}
  DetailPrint "*** Removing MOD122..."
  Delete "$INSTDIR\data\gfx\char\item\mesh\item_bosskey_001.pmg"
!macroend
Section "Huge Boss Keys 2" MOD123
SetOutPath "$INSTDIR\data\gfx\char\item\mesh"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\mesh\item_bosskey_002.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD123}
  DetailPrint "*** Removing MOD123..."
  Delete "$INSTDIR\data\gfx\char\item\mesh\item_bosskey_002.pmg"
!macroend
Section "Huge Treasure Keys 1" MOD124
SetOutPath "$INSTDIR\data\gfx\char\item\mesh"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\mesh\item_boxkey_001.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD124}
  DetailPrint "*** Removing MOD124..."
  Delete "$INSTDIR\data\gfx\char\item\mesh\item_boxkey_001.pmg"
!macroend
Section "Huge Room Keys 2" MOD125
SetOutPath "$INSTDIR\data\gfx\char\item\mesh"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\mesh\item_roomkey_001.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD125}
  DetailPrint "*** Removing MOD125..."
  Delete "$INSTDIR\data\gfx\char\item\mesh\item_roomkey_001.pmg"
!macroend
Section "Huge Mushrooms" MOD126
SetOutPath "$INSTDIR\data\gfx\char\item\mesh"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\mesh\prop_mushroom01_i.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD126}
  DetailPrint "*** Removing MOD126..."
  Delete "$INSTDIR\data\gfx\char\item\mesh\prop_mushroom01_i.pmg"
!macroend
Section "Huge Gold Mushrooms" MOD127
SetOutPath "$INSTDIR\data\gfx\char\item\mesh"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\mesh\prop_mushroom02_i.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD127}
  DetailPrint "*** Removing MOD127..."
  Delete "$INSTDIR\data\gfx\char\item\mesh\prop_mushroom02_i.pmg"
!macroend
Section "Huge Poison Mushrooms" MOD128
SetOutPath "$INSTDIR\data\gfx\char\item\mesh"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\item\mesh\prop_mushroom03_i.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD128}
  DetailPrint "*** Removing MOD128..."
  Delete "$INSTDIR\data\gfx\char\item\mesh\prop_mushroom03_i.pmg"
!macroend
Section "Mimic Differentiation 1" MOD129
SetOutPath "$INSTDIR\data\gfx\char\monster\mesh\mimic"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\monster\mesh\mimic\mimic01_mesh.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD129}
  DetailPrint "*** Removing MOD129..."
  Delete "$INSTDIR\data\gfx\char\monster\mesh\mimic\mimic01_mesh.pmg"
!macroend
Section "Mimic Differentiation 2" MOD130
SetOutPath "$INSTDIR\data\gfx\char\monster\mesh\mimic"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\monster\mesh\mimic\mimic02_mesh.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD130}
  DetailPrint "*** Removing MOD130..."
  Delete "$INSTDIR\data\gfx\char\monster\mesh\mimic\mimic02_mesh.pmg"
!macroend
Section "Mimic Differentiation 3" MOD131
SetOutPath "$INSTDIR\data\gfx\char\monster\mesh\mimic"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\monster\mesh\mimic\mimic03_mesh.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD131}
  DetailPrint "*** Removing MOD131..."
  Delete "$INSTDIR\data\gfx\char\monster\mesh\mimic\mimic03_mesh.pmg"
!macroend
Section "Mimic Differentiation 4" MOD132
SetOutPath "$INSTDIR\data\gfx\char\monster\mesh\mimic"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\monster\mesh\mimic\mimic04_mesh.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD132}
  DetailPrint "*** Removing MOD132..."
  Delete "$INSTDIR\data\gfx\char\monster\mesh\mimic\mimic04_mesh.pmg"
!macroend
Section "Mimic Differentiation 5" MOD133
SetOutPath "$INSTDIR\data\gfx\char\monster\mesh\mimic"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\monster\mesh\mimic\mimic05_mesh.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD133}
  DetailPrint "*** Removing MOD133..."
  Delete "$INSTDIR\data\gfx\char\monster\mesh\mimic\mimic05_mesh.pmg"
!macroend
Section "Mimic Differentiation 6" MOD134
SetOutPath "$INSTDIR\data\gfx\char\monster\mesh\mimic"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\char\monster\mesh\mimic\mimic06_mesh.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD134}
  DetailPrint "*** Removing MOD134..."
  Delete "$INSTDIR\data\gfx\char\monster\mesh\mimic\mimic06_mesh.pmg"
!macroend
Section "Always noon sky 2" MOD135
SetOutPath "$INSTDIR\data\gfx\fx\atmosphere"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_clear.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_clear_taillteann.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_cloudy.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_cloudy_taillteann.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_iria_sandstorm.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_iria_snowstorm.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_iria_zardine.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_lightning.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_lightning_taillteann.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_otherworld_darkfog.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_physis_clear.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_physis_cloudy.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_physis_lightning.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_physis_rainy.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_rainy.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_rainy_taillteann.raw"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\atmosphere\timetable_skatha.raw"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD135}
  DetailPrint "*** Removing MOD135..."
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_clear.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_clear_taillteann.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_cloudy.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_cloudy_taillteann.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_iria_sandstorm.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_iria_snowstorm.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_iria_zardine.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_lightning.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_lightning_taillteann.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_otherworld_darkfog.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_physis_clear.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_physis_cloudy.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_physis_lightning.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_physis_rainy.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_rainy.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_rainy_taillteann.raw"
  Delete "$INSTDIR\data\gfx\fx\atmosphere\timetable_skatha.raw"
!macroend
Section "Alchemist FlameBurst Simplify" MOD136
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c3_g9_s2_fireflame.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD136}
  DetailPrint "*** Removing MOD136..."
  Delete "$INSTDIR\data\gfx\fx\effect\c3_g9_s2_fireflame.xml"
!macroend
Section "Rain Casting Range and Duration Indicator" MOD137
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c3_g10_s1_cloud.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD137}
  DetailPrint "*** Removing MOD137..."
  Delete "$INSTDIR\data\gfx\fx\effect\c3_g10_s1_cloud.xml"
!macroend
Section "Alchemist Shock Removal" MOD138
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c3_g11_s1_others.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD138}
  DetailPrint "*** Removing MOD138..."
  Delete "$INSTDIR\data\gfx\fx\effect\c3_g11_s1_others.xml"
!macroend
Section "Remove Rain, Sand and Snow 1" MOD139
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c2_g6_s1_snowfield.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\effect_weather_rain.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\effect_weather_snow.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\fx_g5_fieldeffect.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD139}
  DetailPrint "*** Removing MOD139..."
  Delete "$INSTDIR\data\gfx\fx\effect\c2_g6_s1_snowfield.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\effect_weather_rain.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\effect_weather_snow.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\fx_g5_fieldeffect.xml"
!macroend
Section "Enables L-rod Light Effect" MOD140
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\fx_c2_ruins.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD140}
  DetailPrint "*** Removing MOD140..."
  Delete "$INSTDIR\data\gfx\fx\effect\fx_c2_ruins.xml"
!macroend
Section "Pet Summon Effect Removals" MOD141
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c2_g6_pet_snowfield.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c4_g14_s3_fire_horse.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c4_g14_s3_fire_horse_black.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c4_g14_s3_fire_horse_cyan.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c4_g14_s3_fire_horse_white.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c4_g16_pet_ice_dragon.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\pet_dragon_fire.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\pet_dragon_thunder.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD141}
  DetailPrint "*** Removing MOD141..."
  Delete "$INSTDIR\data\gfx\fx\effect\c2_g6_pet_snowfield.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\c4_g14_s3_fire_horse.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\c4_g14_s3_fire_horse_black.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\c4_g14_s3_fire_horse_cyan.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\c4_g14_s3_fire_horse_white.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\c4_g16_pet_ice_dragon.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\pet_dragon_fire.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\pet_dragon_thunder.xml"
!macroend
Section "Nimbus Effects Removal" MOD391
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\pet_c4_cloud.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c5_pet_cloud.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD391}
  DetailPrint "*** Removing MOD391..."
  Delete "$INSTDIR\data\gfx\fx\effect\pet_c4_cloud.xml"
  Delete "$INSTDIR\data\gfx\fx\effect\c5_pet_cloud.xml"
!macroend
Section "Sulfur Spider Dust Removal" MOD142
SetOutPath "$INSTDIR\data\gfx\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\effect\c3_g9_s2_monster_spider12.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD142}
  DetailPrint "*** Removing MOD142..."
  Delete "$INSTDIR\data\gfx\fx\effect\c3_g9_s2_monster_spider12.xml"
!macroend
Section "Disable Fireball Shaking/Boost Ego Glow" MOD143
SetOutPath "$INSTDIR\data\gfx\fx\posteffect"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\fx\posteffect\blur.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD143}
  DetailPrint "*** Removing MOD143..."
  Delete "$INSTDIR\data\gfx\fx\posteffect\blur.xml"
!macroend
Section "Nexon Logo Change 1" MOD144
SetOutPath "$INSTDIR\data\gfx\gui\login_screen"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\login_screen\intro_nexon_logo_256x256.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD144}
  DetailPrint "*** Removing MOD144..."
  Delete "$INSTDIR\data\gfx\gui\login_screen\intro_nexon_logo_256x256.dds"
!macroend
Section "Nexon Logo Change 2" MOD145
SetOutPath "$INSTDIR\data\gfx\gui\login_screen\"
  DetailPrint "Installing Login Screens..."
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\login_screen\login_Logo_US.dds"
;  WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "LoginScreen" "0"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD145}
  DetailPrint "*** Removing MOD145..."
  Delete "$INSTDIR\data\gfx\gui\login_screen\login_Logo_US.dds"
!macroend
Section "Nexon Logo Change 3" MOD146
SetOutPath "$INSTDIR\data\gfx\gui\login_screen\"
  DetailPrint "Installing Login Screens..."
  File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\login_screen\login_copyright03_kr_w.dds"
;  WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "LoginScreen" "0"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD146}
  DetailPrint "*** Removing MOD145..."
  Delete "$INSTDIR\data\gfx\gui\login_screen\login_copyright03_kr_w.dds"
!macroend
Section "Modded Rano Map" MOD147
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
DetailPrint "Installing Modded Rano Map..."
  File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_Iria_Rano_new_mgFree_2021_kor.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD147}
  DetailPrint "*** Removing MOD147..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_Iria_Rano_new_mgFree_2021_kor.jpg"
!macroend
Section "Modded Solea North Map" MOD148
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_n_eng.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD148}
  DetailPrint "*** Removing MOD148..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_n_eng.jpg"
!macroend
Section "Modded Solea South Map" MOD149
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_s_eng.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD149}
  DetailPrint "*** Removing MOD149..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_s_eng.jpg"
!macroend
Section "Modded Connous Map" MOD150
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
DetailPrint "Installing Modded Connous Map..."
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_Iria_connous_mgFree_2021_kor.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD150}
  DetailPrint "*** Removing MOD150..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_Iria_connous_mgFree_2021_kor.jpg"
!macroend
Section "Modded Ant Hell Map" MOD151
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_iria_connous_underworld.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD151}
  DetailPrint "*** Removing MOD151..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_iria_connous_underworld.jpg"
!macroend
Section "Modded Courcle Map" MOD152
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
DetailPrint "Installing Modded Courcle Map..."
  File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_Iria_courcle_mgFree_2021_kor.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD152}
  DetailPrint "*** Removing MOD152..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_Iria_courcle_mgFree_2021_kor.jpg"
!macroend
Section "Modded Physis Map" MOD153
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
DetailPrint "Installing Modded Physis Map..."
  File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_Iria_Physis_mgFree_2021_kor.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD153}
  DetailPrint "*** Removing MOD153..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_Iria_Physis_mgFree_2021_kor.jpg"
!macroend
Section "Modded Shadow Realm Abb Neagh Map" MOD154
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_taillteann_abb_neagh_mgfree_eng.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD154}
  DetailPrint "*** Removing MOD154..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_taillteann_abb_neagh_mgfree_eng.jpg"
!macroend
Section "Modded Shadow Realm Taillteann Map" MOD155
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
DetailPrint "Installing Modded Shadow Realm Taillteann Map..."
  File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_taillteann_eng_rep.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD155}
  DetailPrint "*** Removing MOD155..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_taillteann_eng_rep.jpg"
!macroend
Section "Modded Shadow Realm Sliab Cuilin Map" MOD156
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_taillteann_sliab_cuilin_eng_rep.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD156}
  DetailPrint "*** Removing MOD156..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_taillteann_sliab_cuilin_eng_rep.jpg"
!macroend
Section "Modded Shadow Realm Corrib Glenn Map" MOD157
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_tara_n_field_eng_rep.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD157}
  DetailPrint "*** Removing MOD157..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_tara_n_field_eng_rep.jpg"
!macroend
Section "Modded Shadow Realm Tara Map" MOD158
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
DetailPrint "Installing Modded Shadow Realm Tara Map..."
  File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_tara_eng_rep.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD158}
  DetailPrint "*** Removing MOD158..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_tara_eng_rep.jpg"
!macroend
Section "Modded Rath Castle 1F Map" MOD159
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_tara_castle_1f_eng_rep.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD159}
  DetailPrint "*** Removing MOD159..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_tara_castle_1f_eng_rep.jpg"
!macroend
Section "Modded Qilla Beach Map" MOD160
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_iria_rano_qilla_mgfree_eng.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD160}
  DetailPrint "*** Removing MOD160..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_iria_rano_qilla_mgfree_eng.jpg"
!macroend
Section "Modded Sen Mag Map" MOD161
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_senmag_mgfree_eng.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD161}
  DetailPrint "*** Removing MOD161..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_senmag_mgfree_eng.jpg"
!macroend
Section "Modded Sen Mag Map 2" MOD162
SetOutPath "$INSTDIR\data\gfx\gui\map_jpg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\map_jpg\minimap_senmag_eng.jpg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD162}
  DetailPrint "*** Removing MOD162..."
  Delete "$INSTDIR\data\gfx\gui\map_jpg\minimap_senmag_eng.jpg"
!macroend
Section "Blacksmith Minigame Simplification" MOD163
SetOutPath "$INSTDIR\data\gfx\gui"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\blacksmith.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD163}
  DetailPrint "*** Removing MOD163..."
  Delete "$INSTDIR\data\gfx\gui\blacksmith.dds"
!macroend
Section "Tailoring Minigame Simplification 1" MOD164
SetOutPath "$INSTDIR\data\gfx\gui"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\tailoring.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD164}
  DetailPrint "*** Removing MOD164..."
  Delete "$INSTDIR\data\gfx\gui\tailoring.dds"
!macroend
Section "Tailoring Minigame Simplification 2" MOD165
SetOutPath "$INSTDIR\data\gfx\gui"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\tailoring_2.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD165}
  DetailPrint "*** Removing MOD165..."
  Delete "$INSTDIR\data\gfx\gui\tailoring_2.dds"
!macroend
Section "Bitmap Font Outline Fix" MOD166
SetOutPath "$INSTDIR\data\gfx\gui"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\font_eng.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\font_outline_eng.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD166}
  DetailPrint "*** Removing MOD166..."
  Delete "$INSTDIR\data\gfx\gui\font_eng.dds"
  Delete "$INSTDIR\data\gfx\gui\font_outline_eng.dds"
!macroend
Section "Trade Imp Removal 4" MOD167
SetOutPath "$INSTDIR\data\gfx\gui\trading_ui"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\trading_ui\gui_trading_state.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD167}
  DetailPrint "*** Removing MOD167..."
  Delete "$INSTDIR\data\gfx\gui\trading_ui\gui_trading_state.dds"
!macroend
Section "Bounty Hunting Interface Buttons Fix" MOD442
SetOutPath "$INSTDIR\data\gfx\gui\trading_ui"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\gui\trading_ui\gui_trading_state2.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD442}
  DetailPrint "*** Removing MOD442..."
  Delete "$INSTDIR\data\gfx\gui\trading_ui\gui_trading_state2.dds"
!macroend
Section "Screenshot Watermark Removal" MOD168
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\copyright_usa.raw"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD168}
  DetailPrint "*** Removing MOD168..."
  Delete "$INSTDIR\data\gfx\image\copyright_usa.raw"
!macroend
Section "Turquoise Mythril Ingots" MOD169
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_mythril_ingot.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD169}
  DetailPrint "*** Removing MOD169..."
  Delete "$INSTDIR\data\gfx\image\item_mythril_ingot.dds"
!macroend
Section "Turquoise Mythril Plates" MOD170
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_mythril_metalplate.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD170}
  DetailPrint "*** Removing MOD170..."
  Delete "$INSTDIR\data\gfx\image\item_mythril_metalplate.dds"
!macroend
Section "Turquoise Mythril Bars" MOD171
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_mythril_metalsolder.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD171}
  DetailPrint "*** Removing MOD171..."
  Delete "$INSTDIR\data\gfx\image\item_mythril_metalsolder.dds"
!macroend
Section "Turquoise Mythril Ore Fragments" MOD172
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_mythril_mineral_Fragment.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD172}
  DetailPrint "*** Removing MOD172..."
  Delete "$INSTDIR\data\gfx\image\item_mythril_mineral_Fragment.dds"
!macroend
Section "Turquoise Mythril Ore" MOD173
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_mythril_mineral_small.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD173}
  DetailPrint "*** Removing MOD173..."
  Delete "$INSTDIR\data\gfx\image\item_mythril_mineral_small.dds"
!macroend
Section "Purple Unknown Ore Fragments" MOD174
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_unknown_mineral_small.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD174}
  DetailPrint "*** Removing MOD174..."
  Delete "$INSTDIR\data\gfx\image\item_unknown_mineral_small.dds"
!macroend
SectionGroup "Easy View Dye Ampuoles" MOD401
Section "Easy View Dye Ampuoles ?1" MOD401?1
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_ampul.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD401?1}
  DetailPrint "*** Removing Easy View Dye Ampuoles ?1..."
  Delete "$INSTDIR\data\gfx\image\item_ampul.dds"
!macroend
Section "Easy View Dye Ampuoles ?2" MOD401?2
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_potionsteeldye.DDS"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD401?2}
  DetailPrint "*** Removing Easy View Dye Ampuoles ?2..."
  Delete "$INSTDIR\data\gfx\image\item_potionsteeldye.DDS"
!macroend
Section "Easy View Dye Ampuoles ?3" MOD401?3
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_potionsteeldye_egoweapon.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD401?3}
  DetailPrint "*** Removing Easy View Dye Ampuoles ?3..."
  Delete "$INSTDIR\data\gfx\image\item_potionsteeldye_egoweapon.dds"
!macroend
Section "Easy View Dye Ampuoles ?4" MOD401?4
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_potionsteeldye_wand.DDS"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD401?4}
  DetailPrint "*** Removing Easy View Dye Ampuoles ?4..."
  Delete "$INSTDIR\data\gfx\image\item_potionsteeldye_wand.DDS"
!macroend
Section "Easy View Dye Ampuoles ?5" MOD401?5
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_potioncolor_instr.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD401?5}
  DetailPrint "*** Removing Easy View Dye Ampuoles ?5..."
  Delete "$INSTDIR\data\gfx\image\item_potioncolor_instr.dds"
!macroend
Section "Easy View Dye Ampuoles ?6" MOD401?6
SetOutPath "$INSTDIR\data\gfx\image2\inven\item"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image2\inven\item\item_ampul_hair.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD401?6}
  DetailPrint "*** Removing Easy View Dye Ampuoles ?6..."
  Delete "$INSTDIR\data\gfx\image2\inven\item\item_ampul_hair.dds"
!macroend
Section "Easy View Dye Ampuoles ?7" MOD401?7
SetOutPath "$INSTDIR\data\gfx\image2\inven\item"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image2\inven\item\item_ampul_instrument.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD401?7}
  DetailPrint "*** Removing Easy View Dye Ampuoles ?7..."
  Delete "$INSTDIR\data\gfx\image2\inven\item\item_ampul_instrument.dds"
!macroend
Section "Easy View Dye Ampuoles ?8" MOD401?8
SetOutPath "$INSTDIR\data\gfx\image2\inven\item"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image2\inven\item\item_ampul_pet.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD401?8}
  DetailPrint "*** Removing Easy View Dye Ampuoles ?8..."
  Delete "$INSTDIR\data\gfx\image2\inven\item\item_ampul_pet.dds"
!macroend
SectionGroupEnd
!macro Remove_${MOD401}
  DetailPrint "*** Removing Easy View Dye Ampuoles..."
  Delete "$INSTDIR\data\gfx\image\item_ampul.dds"
  Delete "$INSTDIR\data\gfx\image\item_potionsteeldye.DDS"
  Delete "$INSTDIR\data\gfx\image\item_potionsteeldye_egoweapon.dds"
  Delete "$INSTDIR\data\gfx\image\item_potionsteeldye_wand.DDS"
!macroend
Section "Easy View Book Pages" MOD403
SetOutPath "$INSTDIR\data\gfx\image"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_book_p2.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_book_p3.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_book_p6.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_book_p7.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_book_p8.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\image\item_book_p9.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD403}
  DetailPrint "*** Removing Easy View Book Pages..."
  Delete "$INSTDIR\data\gfx\image\item_book_p2.dds"
  Delete "$INSTDIR\data\gfx\image\item_book_p3.dds"
  Delete "$INSTDIR\data\gfx\image\item_book_p6.dds"
  Delete "$INSTDIR\data\gfx\image\item_book_p7.dds"
  Delete "$INSTDIR\data\gfx\image\item_book_p8.dds"
  Delete "$INSTDIR\data\gfx\image\item_book_p9.dds"
!macroend
Section "Theater Dungeon Fog Removal" MOD175
SetOutPath "$INSTDIR\data\gfx\scene\avon\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\avon\dungeon\dg_avon_stage_fog_01.xml"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD175}
  DetailPrint "*** Removing MOD175..."
  Delete "$INSTDIR\data\gfx\scene\avon\dungeon\dg_avon_stage_fog_01.xml"
!macroend
Section "Belfast Delagger 1" MOD176
SetOutPath "$INSTDIR\data\gfx\scene\belfast\building"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_06.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_07.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_08.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_09.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\building\scene_building_belfast_wall01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD176}
  DetailPrint "*** Removing MOD176..."
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_04.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_05.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_06.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_07.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_08.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_09.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\building\scene_building_belfast_wall01.pmg"
!macroend
Section "Belfast Delagger 2" MOD177
SetOutPath "$INSTDIR\data\gfx\scene\belfast\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_building_belfast_bank_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_arch_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_ceiling_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_06.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_07.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_08.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_entrance_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_wall_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag01_rotate.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag02_rotate.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag03_rotate.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_light.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_rotate.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_bigsign_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_church00.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff06.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff07.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_cliffstone_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_cliffstone_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_flowerbed00.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_grassdry00.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_1.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_2.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_3.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_4.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_5.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_6.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house01_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_house01_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_lighthouse_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_06.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_07.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_08.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_09.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_10.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_11.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_12.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_13.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_14.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_15.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_16.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_bar02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_door01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_door02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_drugstore01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_drugstore02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_drugstore03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent01_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent02_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent03_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent04_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent05_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent06.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent06_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent07.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent07_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent08.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent08_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_weapon01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_weapon02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_market_weapon03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_ocean00.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_00.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_06.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_07.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_10.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_11.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_12.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_14.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_16.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_17.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_18.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_19.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_20.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_21.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_22.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_fountain.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_pirate ship_flagall.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_tombstone_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_cutscene00.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_flag01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_flag02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_flag03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_tradingpost_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_wrecked_obj.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\belfast\prop\scene_prop_belfast_wrecked_obj01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD177}
  DetailPrint "*** Removing MOD177..."
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_building_belfast_bank_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_arch_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_ceiling_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_04.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_05.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_06.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_07.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_08.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_entrance_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_wall_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag01_rotate.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag02_rotate.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag03_rotate.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_light.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_rotate.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_bigsign_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_church00.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff04.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff05.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff06.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff07.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_cliffstone_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_cliffstone_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_flowerbed00.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_grassdry00.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_1.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_2.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_3.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_4.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_5.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_6.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house01_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_house01_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_lighthouse_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_04.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_05.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_06.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_07.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_08.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_09.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_10.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_11.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_12.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_13.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_14.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_15.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_16.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_bar02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_door01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_door02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_drugstore01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_drugstore02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_drugstore03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent01_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent02_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent03_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent04.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent04_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent05.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent05_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent06.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent06_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent07.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent07_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent08.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent08_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_weapon01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_weapon02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_market_weapon03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_ocean00.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_00.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_04.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_05.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_06.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_07.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_10.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_11.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_12.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_14.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_16.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_17.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_18.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_19.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_20.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_21.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_22.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_fountain.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_pirate ship_flagall.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_tombstone_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_cutscene00.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_flag01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_flag02.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_flag03.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_tradingpost_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_wrecked_obj.pmg"
  Delete "$INSTDIR\data\gfx\scene\belfast\prop\scene_prop_belfast_wrecked_obj01.pmg"
!macroend
Section "Huge Mushroom 1" MOD178
SetOutPath "$INSTDIR\data\gfx\scene\productionprop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_mushroom_01_after.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD178}
  DetailPrint "*** Removing MOD178..."
  Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_mushroom_01_after.pmg"
!macroend
Section "Huge Mushroom 2" MOD179
SetOutPath "$INSTDIR\data\gfx\scene\productionprop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_mushroom_01_before.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD179}
  DetailPrint "*** Removing MOD179..."
  Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_mushroom_01_before.pmg"
!macroend
Section "Huge Gold Mushroom 1" MOD180
SetOutPath "$INSTDIR\data\gfx\scene\productionprop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_mushroom_02_after.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD180}
  DetailPrint "*** Removing MOD180..."
  Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_mushroom_02_after.pmg"
!macroend
Section "Huge Gold Mushroom 2" MOD181
SetOutPath "$INSTDIR\data\gfx\scene\productionprop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_mushroom_02_before.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD181}
  DetailPrint "*** Removing MOD181..."
  Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_mushroom_02_before.pmg"
!macroend
Section "Huge Poison Mushroom 1" MOD182
SetOutPath "$INSTDIR\data\gfx\scene\productionprop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_mushroom_03_after.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD182}
  DetailPrint "*** Removing MOD182..."
  Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_mushroom_03_after.pmg"
!macroend
Section "Huge Poison Mushroom 2" MOD183
SetOutPath "$INSTDIR\data\gfx\scene\productionprop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\productionprop\scene_prop_mushroom_03_before.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD183}
  DetailPrint "*** Removing MOD183..."
  Delete "$INSTDIR\data\gfx\scene\productionprop\scene_prop_mushroom_03_before.pmg"
!macroend
Section "Barri Hallway Wall Removal 1" MOD184
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_alley1_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD184}
  DetailPrint "*** Removing MOD184..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_alley1_01.pmg"
!macroend
Section "Barri Hallway Wall Removal 2" MOD185
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_alley2_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD185}
  DetailPrint "*** Removing MOD185..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_alley2_01.pmg"
!macroend
Section "Barri Hallway Wall Removal 3" MOD186
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_alley2_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD186}
  DetailPrint "*** Removing MOD186..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_alley2_02.pmg"
!macroend
Section "Barri Hallway Wall Removal 4" MOD187
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_alley3_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD187}
  DetailPrint "*** Removing MOD187..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_alley3_01.pmg"
!macroend
Section "Barri Hallway Wall Removal 5" MOD188
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_alley4_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD188}
  DetailPrint "*** Removing MOD188..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_alley4_01.pmg"
!macroend
Section "Barri Room Wall Removal 1" MOD189
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_room1_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD189}
  DetailPrint "*** Removing MOD189..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_room1_01.pmg"
!macroend
Section "Barri Room Wall Removal 2" MOD190
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_room2_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD190}
  DetailPrint "*** Removing MOD190..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_room2_01.pmg"
!macroend
Section "Barri Room Wall Removal 3" MOD191
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_room2_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD191}
  DetailPrint "*** Removing MOD191..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_room2_02.pmg"
!macroend
Section "Barri Room Wall Removal 4" MOD192
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_room3_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD192}
  DetailPrint "*** Removing MOD192..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_room3_01.pmg"
!macroend
Section "Barri Room Wall Removal 5" MOD193
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_room4_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD193}
  DetailPrint "*** Removing MOD193..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_room4_01.pmg"
!macroend
Section "Barri Boss Room Wall Removal" MOD194
SetOutPath "$INSTDIR\data\gfx\scene\bangor\dungeon"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\bangor\dungeon\dg_bangor_room_boss.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD194}
  DetailPrint "*** Removing MOD194..."
  Delete "$INSTDIR\data\gfx\scene\bangor\dungeon\dg_bangor_room_boss.pmg"
!macroend
Section "Fiodh-Coil Hallway Wall Removal 1" MOD195
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley1_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD195}
  DetailPrint "*** Removing MOD195..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley1_01.pmg"
!macroend
Section "Fiodh-Coil Hallway Wall Removal 2" MOD196
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley2_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD196}
  DetailPrint "*** Removing MOD196..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley2_01.pmg"
!macroend
Section "Fiodh-Coil Hallway Wall Removal 3" MOD197
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley2_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD197}
  DetailPrint "*** Removing MOD197..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley2_02.pmg"
!macroend
Section "Fiodh-Coil Hallway Wall Removal 4" MOD198
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley3_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD198}
  DetailPrint "*** Removing MOD198..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley3_01.pmg"
!macroend
Section "Fiodh-Coil Hallway Wall Removal 5" MOD199
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley4_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD199}
  DetailPrint "*** Removing MOD199..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley4_01.pmg"
!macroend
Section "Fiodh-Coil Room Wall Removal 1" MOD200
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room1_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD200}
  DetailPrint "*** Removing MOD200..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room1_01.pmg"
!macroend
Section "Fiodh-Coil Room Wall Removal 2" MOD201
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room2_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD201}
  DetailPrint "*** Removing MOD201..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room2_01.pmg"
!macroend
Section "Fiodh-Coil Room Wall Removal 3" MOD202
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room2_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD202}
  DetailPrint "*** Removing MOD202..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room2_02.pmg"
!macroend
Section "Fiodh-Coil Room Wall Removal 4" MOD203
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room3_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD203}
  DetailPrint "*** Removing MOD203..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room3_01.pmg"
!macroend
Section "Fiodh-Coil Room Wall Removal 5" MOD204
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room3_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD204}
  DetailPrint "*** Removing MOD204..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room3_01.pmg"
!macroend
Section "Fiodh-Coil Room Wall Removal 6" MOD443
SetOutPath "$INSTDIR\data\gfx\scene\dungeon\woodsruins"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room4_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD443}
  DetailPrint "*** Removing MOD443..."
  Delete "$INSTDIR\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room4_01.pmg"
!macroend
Section "Runda Hallway Wall Removal 1" MOD206
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley1_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD206}
  DetailPrint "*** Removing MOD206..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley1_01.pmg"
!macroend
Section "Runda Hallway Wall Removal 2" MOD207
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley2_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD207}
  DetailPrint "*** Removing MOD207..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley2_01.pmg"
!macroend
Section "Runda Hallway Wall Removal 3" MOD208
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley2_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD208}
  DetailPrint "*** Removing MOD208..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley2_02.pmg"
!macroend
Section "Runda Hallway Wall Removal 4" MOD209
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley3_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD209}
  DetailPrint "*** Removing MOD209..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley3_01.pmg"
!macroend
Section "Runda Hallway Wall Removal 5" MOD210
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley4_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD210}
  DetailPrint "*** Removing MOD210..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley4_01.pmg"
!macroend
Section "Runda Water Surface Removal" MOD211
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\room\dg_runda_watersurface.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD211}
  DetailPrint "*** Removing MOD211..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room\dg_runda_watersurface.pmg"
!macroend
Section "Runda Room Wall Removal 1" MOD212
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room1_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD212}
  DetailPrint "*** Removing MOD212..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room1_01.pmg"
!macroend
Section "Runda Room Wall Removal 2" MOD213
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room2_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD213}
  DetailPrint "*** Removing MOD213..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room2_01.pmg"
!macroend
Section "Runda Room Wall Removal 3" MOD214
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room2_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD214}
  DetailPrint "*** Removing MOD214..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room2_02.pmg"
!macroend
Section "Runda Room Wall Removal 4" MOD215
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room3_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD215}
  DetailPrint "*** Removing MOD215..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room3_01.pmg"
!macroend
Section "Runda Room Wall Removal 5" MOD216
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room4_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD216}
  DetailPrint "*** Removing MOD216..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room4_01.pmg"
!macroend
Section "Runda Boss Room Wall Removal" MOD217
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room_boss.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD217}
  DetailPrint "*** Removing MOD217..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room_boss.pmg"
!macroend
Section "Runda Siren Boss Room Wall Removal" MOD218
SetOutPath "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room_boss_siren.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD218}
  DetailPrint "*** Removing MOD218..."
  Delete "$INSTDIR\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room_boss_siren.pmg"
!macroend
Section "Rano Plains Tree Removal 1" MOD219
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD219}
  DetailPrint "*** Removing MOD219..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_01.pmg"
!macroend
Section "Rano Plains Tree Removal 2" MOD220
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD220}
  DetailPrint "*** Removing MOD220..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_02.pmg"
!macroend
Section "Rano Plains Tree Removal 3" MOD221
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_03.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD221}
  DetailPrint "*** Removing MOD221..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_03.pmg"
!macroend
Section "Rano Plains Tree Removal 4" MOD222
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_04.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD222}
  DetailPrint "*** Removing MOD222..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_04.pmg"
!macroend
Section "Rano Forest Tree Removal 1" MOD223
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_forest_tree_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD223}
  DetailPrint "*** Removing MOD223..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_forest_tree_01.pmg"
!macroend
Section "Rano Forest Tree Removal 2" MOD224
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_forest_tree_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD224}
  DetailPrint "*** Removing MOD224..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_forest_tree_02.pmg"
!macroend
Section "Rano Forest Tree Removal 3" MOD225
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_forest_tree_03.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD225}
  DetailPrint "*** Removing MOD225..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_forest_tree_03.pmg"
!macroend
Section "Rano Cactus Removal 1" MOD226
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_cactus_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD226}
  DetailPrint "*** Removing MOD226..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_cactus_01.pmg"
!macroend
Section "Rano Cactus Removal 2" MOD227
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_cactus_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD227}
  DetailPrint "*** Removing MOD227..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_cactus_02.pmg"
!macroend
Section "Rano Fence Removal" MOD228
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_fence_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD228}
  DetailPrint "*** Removing MOD228..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_fence_01.pmg"
!macroend
Section "Rano Gateway Removal" MOD229
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_gateway_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD229}
  DetailPrint "*** Removing MOD229..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_gateway_01.pmg"
!macroend
Section "Rano Grass Removal 1" MOD230
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD230}
  DetailPrint "*** Removing MOD230..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_01.pmg"
!macroend
Section "Rano Grass Removal 2" MOD231
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD231}
  DetailPrint "*** Removing MOD231..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_02.pmg"
!macroend
Section "Rano Grass Removal 3" MOD232
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_03.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD232}
  DetailPrint "*** Removing MOD232..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_03.pmg"
!macroend
Section "Rano Grass Removal 4" MOD233
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_04.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD233}
  DetailPrint "*** Removing MOD233..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_04.pmg"
!macroend
Section "Rano Grass Removal 5" MOD234
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_05.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD234}
  DetailPrint "*** Removing MOD234..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_05.pmg"
!macroend
Section "Rano Grass Removal 6" MOD235
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_06.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD235}
  DetailPrint "*** Removing MOD235..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_06.pmg"
!macroend
Section "Rano Grass Removal 7" MOD236
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_07.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD236}
  DetailPrint "*** Removing MOD236..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_07.pmg"
!macroend
Section "Rano Grass Removal 8" MOD237
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_08.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD237}
  DetailPrint "*** Removing MOD237..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_08.pmg"
!macroend
Section "Rano Grass Removal 9" MOD238
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_09.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD238}
  DetailPrint "*** Removing MOD238..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_09.pmg"
!macroend
Section "Rano Grass Removal 10" MOD239
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_10.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD239}
  DetailPrint "*** Removing MOD239..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_10.pmg"
!macroend
Section "Rano Grass Removal 11" MOD240
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_11.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD240}
  DetailPrint "*** Removing MOD240..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_11.pmg"
!macroend
Section "Rano Miscellaneous Removal 1" MOD241
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_intentgoods_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD241}
  DetailPrint "*** Removing MOD241..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_intentgoods_01.pmg"
!macroend
Section "Rano Miscellaneous Removal 2" MOD242
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_intentgoods_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD242}
  DetailPrint "*** Removing MOD242..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_intentgoods_02.pmg"
!macroend
Section "Rano Rock Removal" MOD243
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_rock_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD243}
  DetailPrint "*** Removing MOD243..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_rock_01.pmg"
!macroend
Section "Rano Shrub Removal" MOD244
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_shrub_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD244}
  DetailPrint "*** Removing MOD244..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_shrub_01.pmg"
!macroend
Section "Rano Stump Removal 1" MOD245
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_stump_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD245}
  DetailPrint "*** Removing MOD245..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_stump_01.pmg"
!macroend
Section "Rano Stump Removal 2" MOD246
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_stump_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD246}
  DetailPrint "*** Removing MOD246..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_stump_02.pmg"
!macroend
Section "Rano Tree Removal 1" MOD247
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD247}
  DetailPrint "*** Removing MOD247..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_01.pmg"
!macroend
Section "Rano Tree Removal 2" MOD248
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD248}
  DetailPrint "*** Removing MOD248..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_02.pmg"
!macroend
Section "Rano Tree Removal 3" MOD249
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_03.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD249}
  DetailPrint "*** Removing MOD249..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_03.pmg"
!macroend
Section "Rano Tree Removal 4" MOD250
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_04.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD250}
  DetailPrint "*** Removing MOD250..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_04.pmg"
!macroend
Section "Rano Tree Removal 5" MOD251
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_05.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD251}
  DetailPrint "*** Removing MOD251..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_05.pmg"
!macroend
Section "Rano Tree Removal 6" MOD252
SetOutPath "$INSTDIR\data\gfx\scene\iria\iria_sw\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_06.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD252}
  DetailPrint "*** Removing MOD252..."
  Delete "$INSTDIR\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_06.pmg"
!macroend
Section "Flower Taillteann Tree 1a" MOD253
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD253}
  DetailPrint "*** Removing MOD253..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a.pmg"
!macroend
Section "Flower Taillteann Tree 1a2" MOD254
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a_rep.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD254}
  DetailPrint "*** Removing MOD254..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a_rep.pmg"
!macroend
Section "Flower Taillteann Tree 1b" MOD255
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_b.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD255}
  DetailPrint "*** Removing MOD255..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_b.pmg"
!macroend
Section "Flower Taillteann Tree 2a" MOD256
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_a.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD256}
  DetailPrint "*** Removing MOD256..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_a.pmg"
!macroend
Section "Flower Taillteann Tree 2b" MOD257
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_b.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD257}
  DetailPrint "*** Removing MOD257..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_b.pmg"
!macroend
Section "Flower Taillteann Tree 2c" MOD258
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_c.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD258}
  DetailPrint "*** Removing MOD258..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_c.pmg"
!macroend
Section "Flower Taillteann Tree 3a" MOD259
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_a.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD259}
  DetailPrint "*** Removing MOD259..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_a.pmg"
!macroend
Section "Flower Taillteann Tree 3b" MOD260
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_b.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD260}
  DetailPrint "*** Removing MOD260..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_b.pmg"
!macroend
Section "Flower Taillteann Tree 4a" MOD261
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_02_a.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD261}
  DetailPrint "*** Removing MOD261..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_02_a.pmg"
!macroend
Section "Flower Taillteann Tree 4b" MOD262
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_02_b.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD262}
  DetailPrint "*** Removing MOD262..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_02_b.pmg"
!macroend
Section "Flower Taillteann Tree 5a" MOD263
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_a.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD263}
  DetailPrint "*** Removing MOD263..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_a.pmg"
!macroend
Section "Flower Taillteann Tree 5b" MOD264
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_b.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD264}
  DetailPrint "*** Removing MOD264..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_b.pmg"
!macroend
Section "Flower Taillteann Tree 1a Framework" MOD265
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD265}
  DetailPrint "*** Removing MOD265..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a.set"
!macroend
Section "Flower Taillteann Tree 1a2 Framework" MOD266
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a_rep.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD266}
  DetailPrint "*** Removing MOD266..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a_rep.set"
!macroend
Section "Flower Taillteann Tree 1b Framework" MOD267
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_b.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD267}
  DetailPrint "*** Removing MOD267..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_b.set"
!macroend
Section "Flower Taillteann Tree 2a Framework" MOD268
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_a.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD268}
  DetailPrint "*** Removing MOD268..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_a.set"
!macroend
Section "Flower Taillteann Tree 2b Framework" MOD269
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_b.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD269}
  DetailPrint "*** Removing MOD269..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_b.set"
!macroend
Section "Flower Taillteann Tree 2c Framework" MOD270
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_c.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD270}
  DetailPrint "*** Removing MOD270..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_c.set"
!macroend
Section "Flower Taillteann Tree 3a Framework" MOD271
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_a.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD271}
  DetailPrint "*** Removing MOD271..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_a.set"
!macroend
Section "Flower Taillteann Tree 3b Framework" MOD272
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_b.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD272}
  DetailPrint "*** Removing MOD272..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_b.set"
!macroend
Section "Flower Taillteann Tree 4b Framework" MOD273
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_02_b.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD273}
  DetailPrint "*** Removing MOD273..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_02_b.set"
!macroend
Section "Flower Taillteann Tree 5a Framework" MOD274
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_a.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD274}
  DetailPrint "*** Removing MOD274..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_a.set"
!macroend
Section "Flower Taillteann Tree 5b Framework" MOD275
SetOutPath "$INSTDIR\data\gfx\scene\field\taillteann"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_b.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD275}
  DetailPrint "*** Removing MOD275..."
  Delete "$INSTDIR\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_b.set"
!macroend
Section "Flower Taillteann Tree 6a" MOD277
SetOutPath "$INSTDIR\data\gfx\scene\taillteann\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_prop_taill_tree_01_a.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD277}
  DetailPrint "*** Removing MOD277..."
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_prop_taill_tree_01_a.pmg"
!macroend
Section "Flower Taillteann Tree 6a Framework" MOD278
SetOutPath "$INSTDIR\data\gfx\scene\taillteann\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_prop_taill_tree_01_a.set"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD278}
  DetailPrint "*** Removing MOD278..."
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_prop_taill_tree_01_a.set"
!macroend
Section "Flower Taillteann Tree 7a" MOD279
SetOutPath "$INSTDIR\data\gfx\scene\taillteann\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_prop_taill_bgmesh_tree_01_a.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD279}
  DetailPrint "*** Removing MOD279..."
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_prop_taill_bgmesh_tree_01_a.pmg"
!macroend
Section "Flower Taillteann Tree 7b" MOD280
SetOutPath "$INSTDIR\data\gfx\scene\taillteann\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_prop_taill_bgmesh_tree_01_b.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD280}
  DetailPrint "*** Removing MOD280..."
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_prop_taill_bgmesh_tree_01_b.pmg"
!macroend
Section "Taillteann houses into Ropes 1" MOD276
SetOutPath "$INSTDIR\data\gfx\scene\taillteann\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_alchemist-house_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_clothshop_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_02.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_building_taill_goods-store_01.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\taillteann\prop\scene_prop_taill_tree_01_b.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD276}
  DetailPrint "*** Removing MOD276..."
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_alchemist-house_01.xml"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_clothshop_01.xml"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_01.xml"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_02.xml"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_01.xml"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_02.xml"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_building_taill_goods-store_01.xml"
  Delete "$INSTDIR\data\gfx\scene\taillteann\prop\scene_prop_taill_tree_01_b.pmg"
!macroend
Section "Tara houses into Ropes 1" MOD281
SetOutPath "$INSTDIR\data\gfx\scene\tara\building"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_bank_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_bank_floor.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_church_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_church_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_church_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_church_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_church_05.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_church_06.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_church_07.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_church_08.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_church_09.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_a_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_a_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_a_02_rev.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_a_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_a_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_b_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_b_01_rev.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_b_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_b_02_rev.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_b_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\building\scene_building_tara_default_b_04.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD281}
  DetailPrint "*** Removing MOD281..."
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_bank_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_bank_floor.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_church_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_church_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_church_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_church_04.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_church_05.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_church_06.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_church_07.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_church_08.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_church_09.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_a_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_a_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_a_02_rev.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_a_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_a_04.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_b_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_b_01_rev.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_b_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_b_02_rev.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_b_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\building\scene_building_tara_default_b_04.pmg"
!macroend
Section "Tara houses into Ropes 2" MOD282
SetOutPath "$INSTDIR\data\gfx\scene\tara\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_building_tara_ departmententrance_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_building_tara_ department_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_building_tara_department_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_building_tara_department_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_building_tara_department_04.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_building_tara_department_clothshop_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_building_tara_department_functional_01.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_building_tara_department_functional_02.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_building_tara_department_functional_03.pmg"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_prop_tara_sub_largegate_03.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD282}
  DetailPrint "*** Removing MOD282..."
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_building_tara_ departmententrance_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_building_tara_ department_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_building_tara_department_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_building_tara_department_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_building_tara_department_04.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_building_tara_department_clothshop_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_building_tara_department_functional_01.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_building_tara_department_functional_02.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_building_tara_department_functional_03.pmg"
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_prop_tara_sub_largegate_03.pmg"
!macroend
Section "Tara Tree Removal 1" MOD283
SetOutPath "$INSTDIR\data\gfx\scene\tara\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_prop_tara_streettree_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD283}
  DetailPrint "*** Removing MOD283..."
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_prop_tara_streettree_01.pmg"
!macroend
Section "Tara Tree Removal 2" MOD284
SetOutPath "$INSTDIR\data\gfx\scene\tara\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_prop_tara_bgmash_tree_01.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD284}
  DetailPrint "*** Removing MOD284..."
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_prop_tara_bgmash_tree_01.pmg"
!macroend
Section "Tara Tree Removal 3" MOD285
SetOutPath "$INSTDIR\data\gfx\scene\tara\prop"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\scene\tara\prop\scene_prop_tara_bgmash_tree_02.pmg"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD285}
  DetailPrint "*** Removing MOD285..."
  Delete "$INSTDIR\data\gfx\scene\tara\prop\scene_prop_tara_bgmash_tree_02.pmg"
!macroend
Section "Show Ping in the Menu 2" MOD286
SetOutPath "$INSTDIR\data\gfx\style"
File "${srcdir}\Tiara's Moonshine Mod\data\gfx\style\systemmenu.style.xml"
IfFileExists "$INSTDIR\Abyss.ini" AbyssFound12 AbyssNotFound12
AbyssFound12:
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ShowPing" "0"
AbyssNotFound12:
SectionIn 1 2
SectionEnd
!macro Remove_${MOD286}
  DetailPrint "*** Removing MOD286..."
  Delete "$INSTDIR\data\gfx\style\systemmenu.style.xml"
!macroend
SectionGroupEnd

SectionGroup "locale"
Section "Unfiltered Chat" MOD287
SetOutPath "$INSTDIR\data\locale\usa\filter"
File "${srcdir}\Tiara's Moonshine Mod\data\locale\usa\filter\BlockChat.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD287}
  DetailPrint "*** Removing MOD287..."
  Delete "$INSTDIR\data\locale\usa\filter\BlockChat.txt"
!macroend
SectionGroupEnd

SectionGroup "layout2"
Section "Show Ping in the Menu 1" MOD84
SetOutPath "$INSTDIR\data\db\layout2"
File "${srcdir}\Tiara's Moonshine Mod\data\db\layout2\SystemMenu.xml"
File "${srcdir}\Tiara's Moonshine Mod\data\db\layout2\SystemMenu2.xml"
IfFileExists "$INSTDIR\Abyss.ini" AbyssFound11 AbyssNotFound11
AbyssFound11:
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "ShowPing" "0"
AbyssNotFound11:
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD84}
  DetailPrint "*** Removing MOD84..."
  Delete "$INSTDIR\data\db\layout2\SystemMenu.xml"
  Delete "$INSTDIR\data\db\layout2\SystemMenu2.xml"
!macroend
SectionGroup "commerce"
Section "Trade Imp Removal 1" MOD80
SetOutPath "$INSTDIR\data\db\layout2\commerce"
  Delete "$INSTDIR\data\db\layout2\commerce\ImpView.xml"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD80}
  DetailPrint "*** Removing MOD80..."
  Delete "$INSTDIR\data\db\layout2\commerce\ImpView.xml"
!macroend
SectionGroupEnd
SectionGroup "petinfo"
Section "Partner Skillbar Icon" MOD404
SetOutPath "$INSTDIR\data\db\layout2\petinfo"
File "${srcdir}\Tiara's Moonshine Mod\data\db\layout2\petinfo\PartnerTab.xml"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD404}
  DetailPrint "*** Removing MOD404..."
  Delete "$INSTDIR\data\db\layout2\petinfo\PartnerTab.xml"
!macroend
SectionGroupEnd
SectionGroup "skill"
Section "Doppel collection removal" MOD82
SetOutPath "$INSTDIR\data\db\layout2\skill"
File "${srcdir}\Tiara's Moonshine Mod\data\db\layout2\skill\SkillReadyView.xml"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD82}
  DetailPrint "*** Removing MOD82..."
  Delete "$INSTDIR\data\db\layout2\skill\SkillReadyView.xml"
!macroend
Section "Skill Sidebar Minimize" MOD83
SetOutPath "$INSTDIR\data\db\layout2\skill"
File "${srcdir}\Tiara's Moonshine Mod\data\db\layout2\skill\SkillSideBar.xml"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD83}
  DetailPrint "*** Removing MOD83..."
  Delete "$INSTDIR\data\db\layout2\skill\SkillSideBar.xml"
!macroend
SectionGroupEnd
SectionGroupEnd

SectionGroup "material"
Section "Tara Castle Wall Removal" MOD360
SetOutPath "$INSTDIR\data\material\interior\tara\town\"
File "${srcdir}\Tiara's Moonshine Mod\data\material\interior\tara\town\interior_tara_castle_room_01.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\interior\tara\town\interior_tara_castle_room_01_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\interior\tara\town\scene_int_tara_castle_gatehall_01.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\interior\tara\town\scene_int_tara_castle_gatehall_01_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\interior\tara\town\scene_int_tara_castle_gatehall_02.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\interior\tara\town\scene_int_tara_castle_gatehall_02_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\interior\tara\town\scene_prop_tara_castle_int_stuff_01.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\interior\tara\town\scene_prop_tara_castle_int_stuff_01_rep.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD360}
  DetailPrint "*** Removing MOD360..."
  Delete "$INSTDIR\data\material\interior\tara\town\interior_tara_castle_room_01.dds"
  Delete "$INSTDIR\data\material\interior\tara\town\interior_tara_castle_room_01_rep.dds"
  Delete "$INSTDIR\data\material\interior\tara\town\scene_int_tara_castle_gatehall_01.dds"
  Delete "$INSTDIR\data\material\interior\tara\town\scene_int_tara_castle_gatehall_01_rep.dds"
  Delete "$INSTDIR\data\material\interior\tara\town\scene_int_tara_castle_gatehall_02.dds"
  Delete "$INSTDIR\data\material\interior\tara\town\scene_int_tara_castle_gatehall_02_rep.dds"
  Delete "$INSTDIR\data\material\interior\tara\town\scene_prop_tara_castle_int_stuff_01.dds"
  Delete "$INSTDIR\data\material\interior\tara\town\scene_prop_tara_castle_int_stuff_01_rep.dds"
!macroend
Section "Remove Rain, Sand and Snow 2" MOD361
SetOutPath "$INSTDIR\data\material\fx\effect"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\effect\effect_add_dust_01.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\effect\effect_add_dust_02.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD361}
  DetailPrint "*** Removing MOD361..."
  Delete "$INSTDIR\data\material\fx\effect\effect_add_dust_01.dds"
  Delete "$INSTDIR\data\material\fx\effect\effect_add_dust_02.dds"
!macroend
Section "Remove Rain, Sand and Snow 3" MOD362
SetOutPath "$INSTDIR\data\material\fx\screenmask"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\screenmask\mask_sandstorm_alphablend_00.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\screenmask\mask_sandstorm_multiply_00.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD362}
  DetailPrint "*** Removing MOD362..."
  Delete "$INSTDIR\data\material\fx\screenmask\mask_sandstorm_alphablend_00.dds"
  Delete "$INSTDIR\data\material\fx\screenmask\mask_sandstorm_multiply_00.dds"
!macroend
Section "Always noon sky 3" MOD363
SetOutPath "$INSTDIR\data\material\fx\skydome"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\skydome\skygradation.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\skydome\skygradation_avon.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\skydome\skygradation_physis.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\skydome\skygradation_skatha.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\skydome\skygradation_taillteann.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\skydome\skygradation_cc.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\skydome\skygradation_falias.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\skydome\skygradation_tirnanog.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD363}
  DetailPrint "*** Removing MOD363..."
  Delete "$INSTDIR\data\material\fx\skydome\skygradation.dds"
  Delete "$INSTDIR\data\material\fx\skydome\skygradation_avon.dds"
  Delete "$INSTDIR\data\material\fx\skydome\skygradation_physis.dds"
  Delete "$INSTDIR\data\material\fx\skydome\skygradation_skatha.dds"
  Delete "$INSTDIR\data\material\fx\skydome\skygradation_taillteann.dds"
  Delete "$INSTDIR\data\material\fx\skydome\skygradation_cc.dds"
  Delete "$INSTDIR\data\material\fx\skydome\skygradation_falias.dds"
  Delete "$INSTDIR\data\material\fx\skydome\skygradation_tirnanog.dds"
!macroend
Section "Transparent Jungle Riverbed" MOD364
SetOutPath "$INSTDIR\data\material\fx\water"
File "${srcdir}\Tiara's Moonshine Mod\data\material\fx\water\water_bottomcolor_jungleriver.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD364}
  DetailPrint "*** Removing MOD364..."
  Delete "$INSTDIR\data\material\fx\water\water_bottomcolor_jungleriver.dds"
!macroend
Section "Tara Castle Wall Removal 2" MOD365
SetOutPath "$INSTDIR\data\material\obj\emainmacha\flat"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\emainmacha\flat\scene_build_emain_window_01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD365}
  DetailPrint "*** Removing MOD365..."
  Delete "$INSTDIR\data\material\obj\emainmacha\flat\scene_build_emain_window_01.dds"
!macroend
Section "Transparent Shadow Mission Wall 1" MOD366
SetOutPath "$INSTDIR\data\material\obj\taillteann\flat"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\taillteann\flat\dungeon_prop_taill_wall_01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD366}
  DetailPrint "*** Removing MOD366..."
  Delete "$INSTDIR\data\material\obj\taillteann\flat\dungeon_prop_taill_wall_01.dds"
!macroend
Section "Transparent Shadow Mission Wall 2" MOD367
SetOutPath "$INSTDIR\data\material\obj\taillteann\flat"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\taillteann\flat\dungeon_prop_taill_wall_02_a.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD367}
  DetailPrint "*** Removing MOD367..."
  Delete "$INSTDIR\data\material\obj\taillteann\flat\dungeon_prop_taill_wall_02_a.dds"
!macroend
Section "Transparent Shadow Mission Wall 3" MOD368
SetOutPath "$INSTDIR\data\material\obj\taillteann\flat"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\taillteann\flat\dungeon_prop_taill_wall_02_b.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD368}
  DetailPrint "*** Removing MOD368..."
  Delete "$INSTDIR\data\material\obj\taillteann\flat\dungeon_prop_taill_wall_02_b.dds"
!macroend
Section "Transparent Shadow Mission Wall 4" MOD369
SetOutPath "$INSTDIR\data\material\obj\taillteann\highgloss"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\taillteann\highgloss\dungeon_prop_taill_pattern_01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD369}
  DetailPrint "*** Removing MOD369..."
  Delete "$INSTDIR\data\material\obj\taillteann\highgloss\dungeon_prop_taill_pattern_01.dds"
!macroend
Section "Tara wall-window-floor reduction 1" MOD370
SetOutPath "$INSTDIR\data\material\obj\tara\flat"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_01.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_01_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_02.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_02_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_03.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_03_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_04.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_04_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_05.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_05_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_06.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_wall_06_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_window_01.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_window_01_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_window_02.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_window_02_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_window_03.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_window_03_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_window_04.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_build_tara_window_04_rep.dds"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_01.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_01_rep.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_02.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_02_rep.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_03.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_03_rep.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_04.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_04_rep.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_05.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\flat\scene_terrain_tara_floor_05_rep.DDS"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD370}
  DetailPrint "*** Removing MOD370..."
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_01.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_01_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_02.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_02_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_03.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_03_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_04.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_04_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_05.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_05_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_06.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_wall_06_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_window_01.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_window_01_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_window_02.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_window_02_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_window_03.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_window_03_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_window_04.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_build_tara_window_04_rep.dds"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_01.DDS"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_01_rep.DDS"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_02.DDS"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_02_rep.DDS"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_03.DDS"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_03_rep.DDS"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_04.DDS"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_04_rep.DDS"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_05.DDS"
  Delete "$INSTDIR\data\material\obj\tara\flat\scene_terrain_tara_floor_05_rep.DDS"
!macroend
Section "Tara wall-window-floor reduction 2" MOD371
SetOutPath "$INSTDIR\data\material\obj\tara\gloss"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_build_tara_railing01.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_build_tara_railing01_rep.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_build_tara_scene_fashion_chandelier_01.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_build_tara_scene_fashion_chandelier_01_rep.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_build_tara_weponhouse_01.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_build_tara_weponhouse_01_rep.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_prop_tara_glass_01.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_prop_tara_glass_01_rep.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_prop_tara_glass_02.DDS"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\tara\gloss\scene_prop_tara_glass_02_rep.DDS"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD371}
  DetailPrint "*** Removing MOD371..."
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_build_tara_railing01.DDS"
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_build_tara_railing01_rep.DDS"
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_build_tara_scene_fashion_chandelier_01.DDS"
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_build_tara_scene_fashion_chandelier_01_rep.DDS"
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_build_tara_weponhouse_01.DDS"
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_build_tara_weponhouse_01_rep.DDS"
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_prop_tara_glass_01.DDS"
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_prop_tara_glass_01_rep.DDS"
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_prop_tara_glass_02.DDS"
  Delete "$INSTDIR\data\material\obj\tara\gloss\scene_prop_tara_glass_02_rep.DDS"
!macroend
Section "Falias Delagger Texture 1" MOD372
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD372}
  DetailPrint "*** Removing MOD372..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_01.dds"
!macroend
Section "Falias Delagger Texture 2" MOD373
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_01_01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD373}
  DetailPrint "*** Removing MOD373..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_01_01.dds"
!macroend
Section "Falias Delagger Texture 3" MOD374
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_02.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD374}
  DetailPrint "*** Removing MOD374..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_02.dds"
!macroend
Section "Falias Delagger Texture 4" MOD375
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_02_01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD375}
  DetailPrint "*** Removing MOD375..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_02_01.dds"
!macroend
Section "Falias Delagger Texture 5" MOD376
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_03.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD376}
  DetailPrint "*** Removing MOD376..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_03.dds"
!macroend
Section "Falias Delagger Texture 6" MOD377
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_04.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD377}
  DetailPrint "*** Removing MOD377..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_04.dds"
!macroend
Section "Falias Delagger Texture 7" MOD378
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_04_01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD378}
  DetailPrint "*** Removing MOD378..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_04_01.dds"
!macroend
Section "Falias Delagger Texture 8" MOD379
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_05.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD379}
  DetailPrint "*** Removing MOD379..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_05.dds"
!macroend
Section "Falias Delagger Texture 9" MOD380
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_06.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD380}
  DetailPrint "*** Removing MOD380..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_06.dds"
!macroend
Section "Falias Delagger Texture 10" MOD381
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_07.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD381}
  DetailPrint "*** Removing MOD381..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_07.dds"
!macroend
Section "Falias Delagger Texture 11" MOD382
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_08.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD382}
  DetailPrint "*** Removing MOD382..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_08.dds"
!macroend
Section "Falias Delagger Texture 12" MOD383
SetOutPath "$INSTDIR\data\material\obj\falias"
File "${srcdir}\Tiara's Moonshine Mod\data\material\obj\falias\scene_prop_falias_bossstage_01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD383}
  DetailPrint "*** Removing MOD383..."
  Delete "$INSTDIR\data\material\obj\falias\scene_prop_falias_bossstage_01.dds"
!macroend
Section "Belfast Delagger 3" MOD384
SetOutPath "$INSTDIR\data\material\terrain\belfast02_belfastgrass01"
File "${srcdir}\Tiara's Moonshine Mod\data\material\terrain\belfast02_belfastgrass01\belfastgrass01_belfastsoil01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD384}
  DetailPrint "*** Removing MOD384..."
  Delete "$INSTDIR\data\material\terrain\belfast02_belfastgrass01\belfastgrass01_belfastsoil01.dds"
!macroend
Section "Belfast Delagger 4" MOD385
SetOutPath "$INSTDIR\data\material\terrain\belfastgrass01_belfastsoil01"
File "${srcdir}\Tiara's Moonshine Mod\data\material\terrain\belfastgrass01_belfastsoil01\belfastgrass01_only.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD385}
  DetailPrint "*** Removing MOD385..."
  Delete "$INSTDIR\data\material\terrain\belfastgrass01_belfastsoil01\belfastgrass01_only.dds"
!macroend
Section "Belfast Delagger 5" MOD386
SetOutPath "$INSTDIR\data\material\terrain\belfastgrass01_only"
File "${srcdir}\Tiara's Moonshine Mod\data\material\terrain\belfastgrass01_only\belfastgrass02_belfastgrass01.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD386}
  DetailPrint "*** Removing MOD386..."
  Delete "$INSTDIR\data\material\terrain\belfastgrass01_only\belfastgrass02_belfastgrass01.dds"
!macroend
Section "Belfast Delagger 6" MOD387
SetOutPath "$INSTDIR\data\material\terrain\belfastgrass02_only"
File "${srcdir}\Tiara's Moonshine Mod\data\material\terrain\belfastgrass02_only\belfastgrass02_only.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD387}
  DetailPrint "*** Removing MOD387..."
  Delete "$INSTDIR\data\material\terrain\belfastgrass02_only\belfastgrass02_only.dds"
!macroend
Section "Belfast Delagger 7" MOD388
SetOutPath "$INSTDIR\data\material\terrain\belfastsoil01_belfastgrass02"
File "${srcdir}\Tiara's Moonshine Mod\data\material\terrain\belfastsoil01_belfastgrass02\belfastsoil01_belfastgrass02.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD388}
  DetailPrint "*** Removing MOD388..."
  Delete "$INSTDIR\data\material\terrain\belfastsoil01_belfastgrass02\belfastsoil01_belfastgrass02.dds"
!macroend
Section "Belfast Delagger 8" MOD389
SetOutPath "$INSTDIR\data\material\terrain\belfastsoil01_only"
File "${srcdir}\Tiara's Moonshine Mod\data\material\terrain\belfastsoil01_only\belfastsoil01_only.dds"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD389}
  DetailPrint "*** Removing MOD389..."
  Delete "$INSTDIR\data\material\terrain\belfastsoil01_only\belfastsoil01_only.dds"
!macroend
SectionGroupEnd

SectionGroup "sound"
SectionGroup "Japari Bus Sound Removal" MOD72
Section "Japari Bus Sound Removal ?1" MOD72?1
SetOutPath "$INSTDIR\data\sound\kmn"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\kmn\2020_kmn_boost.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD72?1}
  DetailPrint "*** Removing Japari Bus Sound Removal ?1..."
  Delete "$INSTDIR\data\sound\kmn\2020_kmn_boost.wav"
!macroend
Section "Japari Bus Sound Removal ?2" MOD72?2
SetOutPath "$INSTDIR\data\sound\kmn"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\kmn\2020_kmn_run.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD72?2}
  DetailPrint "*** Removing Japari Bus Sound Removal ?2..."
  Delete "$INSTDIR\data\sound\kmn\2020_kmn_run.wav"
!macroend
Section "Japari Bus Sound Removal ?3" MOD72?3
SetOutPath "$INSTDIR\data\sound\kmn"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\kmn\2020_kmn_summon.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD72?3}
  DetailPrint "*** Removing Japari Bus Sound Removal ?3..."
  Delete "$INSTDIR\data\sound\kmn\2020_kmn_summon.wav"
!macroend
SectionGroupEnd
!macro Remove_${MOD72}
  DetailPrint "*** Removing Japari Bus Sound Removal..."
  Delete "$INSTDIR\data\sound\kmn\2020_kmn_boost.wav"
  Delete "$INSTDIR\data\sound\kmn\2020_kmn_run.wav"
  Delete "$INSTDIR\data\sound\kmn\2020_kmn_summon.wav"
!macroend
Section "Cow Sound Removal" MOD302
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cow_01.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD302}
  DetailPrint "*** Removing MOD302..."
  Delete "$INSTDIR\data\sound\cow_01.wav"
!macroend
Section "Cow Attack Sound Removal" MOD303
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cow_attack_01.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD303}
  DetailPrint "*** Removing MOD303..."
  Delete "$INSTDIR\data\sound\cow_attack_01.wav"
!macroend
Section "Edern Hammer Sound Removal 1" MOD304
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\repair_1p01.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD304}
  DetailPrint "*** Removing MOD304..."
  Delete "$INSTDIR\data\sound\repair_1p01.wav"
!macroend
Section "Edern Hammer Sound Removal 2" MOD305
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\repair_1p02.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD305}
  DetailPrint "*** Removing MOD305..."
  Delete "$INSTDIR\data\sound\repair_1p02.wav"
!macroend
Section "Edern Hammer Sound Removal 3" MOD306
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\repair_fail01.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD306}
  DetailPrint "*** Removing MOD306..."
  Delete "$INSTDIR\data\sound\repair_fail01.wav"
!macroend
Section "Edern Hammer Sound Removal 4" MOD307
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\repair_fail02.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD307}
  DetailPrint "*** Removing MOD307..."
  Delete "$INSTDIR\data\sound\repair_fail02.wav"
!macroend
Section "Edern Hammer Sound Removal 5" MOD308
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\repair_full01.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD308}
  DetailPrint "*** Removing MOD308..."
  Delete "$INSTDIR\data\sound\repair_full01.wav"
!macroend
Section "Edern Hammer Sound Removal 6" MOD309
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\repair_full02.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD309}
  DetailPrint "*** Removing MOD309..."
  Delete "$INSTDIR\data\sound\repair_full02.wav"
!macroend
Section "Pig Sound Removal" MOD310
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_01.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD310}
  DetailPrint "*** Removing MOD310..."
  Delete "$INSTDIR\data\sound\pig_01.wav"
!macroend
Section "Pig Attack Sound Removal" MOD311
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_attack_counter_01.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD311}
  DetailPrint "*** Removing MOD311..."
  Delete "$INSTDIR\data\sound\pig_attack_counter_01.wav"
!macroend
Section "Pig Knockback Sound Removal 1" MOD312
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_blowaway.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD312}
  DetailPrint "*** Removing MOD312..."
  Delete "$INSTDIR\data\sound\pig_blowaway.wav"
!macroend
Section "Pig Knockback Sound Removal 2" MOD313
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_blowaway_1.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD313}
  DetailPrint "*** Removing MOD313..."
  Delete "$INSTDIR\data\sound\pig_blowaway_1.wav"
!macroend
Section "Pig Hit Sound Removal 1" MOD314
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_hita.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD314}
  DetailPrint "*** Removing MOD314..."
  Delete "$INSTDIR\data\sound\pig_hita.wav"
!macroend
Section "Pig Hit Sound Removal 2" MOD315
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_hita_1.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD315}
  DetailPrint "*** Removing MOD315..."
  Delete "$INSTDIR\data\sound\pig_hita_1.wav"
!macroend
Section "Pig Hit Sound Removal 3" MOD316
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_hitb.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD316}
  DetailPrint "*** Removing MOD316..."
  Delete "$INSTDIR\data\sound\pig_hitb.wav"
!macroend
Section "Pig Passive Sound Removal 1" MOD317
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_stand_Friendly.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD317}
  DetailPrint "*** Removing MOD317..."
  Delete "$INSTDIR\data\sound\pig_stand_Friendly.wav"
!macroend
Section "Pig Passive Sound Removal 2" MOD318
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_stand_Friendly_02.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD318}
  DetailPrint "*** Removing MOD318..."
  Delete "$INSTDIR\data\sound\pig_stand_Friendly_02.wav"
!macroend
Section "Pig Combat Mode Sound Removal" MOD319
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pig_stand_offensive_1.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD319}
  DetailPrint "*** Removing MOD319..."
  Delete "$INSTDIR\data\sound\pig_stand_offensive_1.wav"
!macroend
Section "Sheep Sound Removal" MOD320
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\sheep.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD320}
  DetailPrint "*** Removing MOD320..."
  Delete "$INSTDIR\data\sound\sheep.wav"
!macroend
Section "Golem Attack Sound Removal" MOD321
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\golem01_walk.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD321}
  DetailPrint "*** Removing MOD321..."
  Delete "$INSTDIR\data\sound\golem01_walk.wav"
!macroend
Section "Golem Shout Sound Removal" MOD322
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\golem01_woo.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD322}
  DetailPrint "*** Removing MOD322..."
  Delete "$INSTDIR\data\sound\golem01_woo.wav"
!macroend
Section "Rain Sound Removal" MOD323
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\weather_raining.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD323}
  DetailPrint "*** Removing MOD323..."
  Delete "$INSTDIR\data\sound\weather_raining.wav"
!macroend
Section "Thunder Sound Removal 1" MOD324
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\weather_thunder_0.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD324}
  DetailPrint "*** Removing MOD324..."
  Delete "$INSTDIR\data\sound\weather_thunder_0.wav"
!macroend
Section "Thunder Sound Removal 2" MOD325
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\weather_thunder_1.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD325}
  DetailPrint "*** Removing MOD325..."
  Delete "$INSTDIR\data\sound\weather_thunder_1.wav"
!macroend
Section "Thunder Sound Removal 3" MOD326
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\weather_thunder_2.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD326}
  DetailPrint "*** Removing MOD326..."
  Delete "$INSTDIR\data\sound\weather_thunder_2.wav"
!macroend
Section "Thunder Sound Removal 4" MOD327
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\weather_thunder_3.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD327}
  DetailPrint "*** Removing MOD327..."
  Delete "$INSTDIR\data\sound\weather_thunder_3.wav"
!macroend
Section "Thunder Sound Removal 5" MOD328
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\weather_thunder_4.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD328}
  DetailPrint "*** Removing MOD328..."
  Delete "$INSTDIR\data\sound\weather_thunder_4.wav"
!macroend
Section "Tara Bell Removal" MOD329
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\tara_campanile.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD329}
  DetailPrint "*** Removing MOD329..."
  Delete "$INSTDIR\data\sound\tara_campanile.wav"
!macroend
Section "Fire Horse Sound Removal" MOD330
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\joust_horse.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD330}
  DetailPrint "*** Removing MOD330..."
  Delete "$INSTDIR\data\sound\joust_horse.wav"
!macroend
Section "Dragon Sound Removal 1" MOD331
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\fran_rattling.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD331}
  DetailPrint "*** Removing MOD331..."
  Delete "$INSTDIR\data\sound\fran_rattling.wav"
!macroend
Section "Dragon Sound Removal 2" MOD332
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\fran_roar.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD332}
  DetailPrint "*** Removing MOD332..."
  Delete "$INSTDIR\data\sound\fran_roar.wav"
!macroend
Section "Dragon Sound Removal 3" MOD333
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\fran_swing.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD333}
  DetailPrint "*** Removing MOD333..."
  Delete "$INSTDIR\data\sound\fran_swing.wav"
!macroend
Section "Dragon Sound Removal 4" MOD334
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\fran_offensive_swing.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD334}
  DetailPrint "*** Removing MOD334..."
  Delete "$INSTDIR\data\sound\fran_offensive_swing.wav"
!macroend
Section "Dragon Sound Removal 5" MOD335
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\fran_roar02.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD335}
  DetailPrint "*** Removing MOD335..."
  Delete "$INSTDIR\data\sound\fran_roar02.wav"
!macroend
Section "Dragon Sound Removal 6" MOD336
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\fran_stomp.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD336}
  DetailPrint "*** Removing MOD336..."
  Delete "$INSTDIR\data\sound\fran_stomp.wav"
!macroend
Section "Dragon Sound Removal 7" MOD337
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cromm_firebreath_wing.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD337}
  DetailPrint "*** Removing MOD337..."
  Delete "$INSTDIR\data\sound\cromm_firebreath_wing.wav"
!macroend
Section "Dragon Sound Removal 8" MOD338
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cromm_stonebreath_breath.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD338}
  DetailPrint "*** Removing MOD338..."
  Delete "$INSTDIR\data\sound\cromm_stonebreath_breath.wav"
!macroend
Section "Dragon Sound Removal 9" MOD339
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\Dragon_cough.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD339}
  DetailPrint "*** Removing MOD339..."
  Delete "$INSTDIR\data\sound\Dragon_cough.wav"
!macroend
Section "Dragon Sound Removal 10" MOD340
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\FireStorm.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD340}
  DetailPrint "*** Removing MOD340..."
  Delete "$INSTDIR\data\sound\FireStorm.wav"
!macroend
Section "Dragon Sound Removal 11-Golem Summoned" MOD341
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\golem_summoned.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD341}
  DetailPrint "*** Removing MOD341..."
  Delete "$INSTDIR\data\sound\golem_summoned.wav"
!macroend
Section "Dragon Sound Removal 12" MOD342
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\petdragon_flap.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD342}
  DetailPrint "*** Removing MOD342..."
  Delete "$INSTDIR\data\sound\petdragon_flap.wav"
!macroend
Section "Dragon Sound Removal 13" MOD343
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\PetDragon_Roar.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD343}
  DetailPrint "*** Removing MOD343..."
  Delete "$INSTDIR\data\sound\PetDragon_Roar.wav"
!macroend
Section "Dragon Sound Removal 14" MOD344
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\red_dragon_fear.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD344}
  DetailPrint "*** Removing MOD344..."
  Delete "$INSTDIR\data\sound\red_dragon_fear.wav"
!macroend
Section "Dragon Sound Removal 15" MOD345
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\petdragon_friendly.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD345}
  DetailPrint "*** Removing MOD345..."
  Delete "$INSTDIR\data\sound\petdragon_friendly.wav"
!macroend
Section "Elephant Walk Sound Removal" MOD346
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\elephant_walk.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD346}
  DetailPrint "*** Removing MOD346..."
  Delete "$INSTDIR\data\sound\elephant_walk.wav"
!macroend
Section "Handcart Move Sound Removal" MOD347
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\handcart_move.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD347}
  DetailPrint "*** Removing MOD347..."
  Delete "$INSTDIR\data\sound\handcart_move.wav"
!macroend
Section "Handcart Walk Sound Removal" MOD348
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\handcart_walk.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD348}
  DetailPrint "*** Removing MOD348..."
  Delete "$INSTDIR\data\sound\handcart_walk.wav"
!macroend
Section "Horse Carriage Move Sound Removal" MOD349
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_carriage_move.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD349}
  DetailPrint "*** Removing MOD349..."
  Delete "$INSTDIR\data\sound\horse_carriage_move.wav"
!macroend
Section "Horse Carriage Walk Sound Removal" MOD350
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_carriage_walk.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD350}
  DetailPrint "*** Removing MOD350..."
  Delete "$INSTDIR\data\sound\horse_carriage_walk.wav"
!macroend
Section "Horse Sound Removal 0" MOD351
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_dagadac0.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD351}
  DetailPrint "*** Removing MOD351..."
  Delete "$INSTDIR\data\sound\horse_dagadac0.wav"
!macroend
Section "Horse Sound Removal 1" MOD352
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_dagadac1.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD352}
  DetailPrint "*** Removing MOD352..."
  Delete "$INSTDIR\data\sound\horse_dagadac1.wav"
!macroend
Section "Horse Sound Removal 2" MOD353
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_dagadac2.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD353}
  DetailPrint "*** Removing MOD353..."
  Delete "$INSTDIR\data\sound\horse_dagadac2.wav"
!macroend
Section "Horse Sound Removal 3" MOD354
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_dagadac3.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD354}
  DetailPrint "*** Removing MOD354..."
  Delete "$INSTDIR\data\sound\horse_dagadac3.wav"
!macroend
Section "Horse Sound Removal 4" MOD355
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_dagadac4.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD355}
  DetailPrint "*** Removing MOD355..."
  Delete "$INSTDIR\data\sound\horse_dagadac4.wav"
!macroend
Section "Horse Sound Removal 5" MOD356
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_ihehehe0.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD356}
  DetailPrint "*** Removing MOD356..."
  Delete "$INSTDIR\data\sound\horse_ihehehe0.wav"
!macroend
Section "Horse Sound Removal 6" MOD357
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_ihehehe1.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD357}
  DetailPrint "*** Removing MOD357..."
  Delete "$INSTDIR\data\sound\horse_ihehehe1.wav"
!macroend
Section "Horse Sound Removal 7" MOD358
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\horse_work.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD358}
  DetailPrint "*** Removing MOD358..."
  Delete "$INSTDIR\data\sound\horse_work.wav"
!macroend
Section "Sound Removal (organize)" MOD359
SetOutPath "$INSTDIR\data\sound"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\bird_flap.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\bird_flap_run.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\chick.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\chicken_attack.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\chicken_down.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\chicken_fly.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\chicken_hit.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\chicken_kuku.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\colossus_catastrophe_rush.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\colossus_walking.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cow_blowaway.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cow_hita.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cow_hitb.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cow_stand_friendly.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cow_stand_offensive_0.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\cow_stand_offensive_1.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\dog01_natural_blowaway.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\dog01_natural_hit.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\dog01_natural_stand_friendly.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\dog01_natural_stand_offensive.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\dog02_natural_stand_friendly.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\fran_dash.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\Glasgavelen_blowaway_endure.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\golem01_downb_to_stand.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\lion_cry.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\lion_roar.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\penguin_call_0.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\penguin_cry_0.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\penguin_cry_1.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\penguin_cry_2.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pet_tiger_friendly.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\meditation_start.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\meditation_stop.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pet_crystal_air_run.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\pet_crystal_ice_storm.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\stove_dry.wav"
File "${srcdir}\Tiara's Moonshine Mod\data\sound\stove_wetness.wav"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD359}
  DetailPrint "*** Removing MOD359..."
  Delete "$INSTDIR\data\sound\bird_flap.wav"
  Delete "$INSTDIR\data\sound\bird_flap_run.wav"
  Delete "$INSTDIR\data\sound\chick.wav"
  Delete "$INSTDIR\data\sound\chicken_attack.wav"
  Delete "$INSTDIR\data\sound\chicken_down.wav"
  Delete "$INSTDIR\data\sound\chicken_fly.wav"
  Delete "$INSTDIR\data\sound\chicken_hit.wav"
  Delete "$INSTDIR\data\sound\chicken_kuku.wav"
  Delete "$INSTDIR\data\sound\colossus_catastrophe_rush.wav"
  Delete "$INSTDIR\data\sound\colossus_walking.wav"
  Delete "$INSTDIR\data\sound\cow_blowaway.wav"
  Delete "$INSTDIR\data\sound\cow_hita.wav"
  Delete "$INSTDIR\data\sound\cow_hitb.wav"
  Delete "$INSTDIR\data\sound\cow_stand_friendly.wav"
  Delete "$INSTDIR\data\sound\cow_stand_offensive_0.wav"
  Delete "$INSTDIR\data\sound\cow_stand_offensive_1.wav"
  Delete "$INSTDIR\data\sound\dog01_natural_blowaway.wav"
  Delete "$INSTDIR\data\sound\dog01_natural_hit.wav"
  Delete "$INSTDIR\data\sound\dog01_natural_stand_friendly.wav"
  Delete "$INSTDIR\data\sound\dog01_natural_stand_offensive.wav"
  Delete "$INSTDIR\data\sound\dog02_natural_stand_friendly.wav"
  Delete "$INSTDIR\data\sound\fran_dash.wav"
  Delete "$INSTDIR\data\sound\Glasgavelen_blowaway_endure.wav"
  Delete "$INSTDIR\data\sound\golem01_downb_to_stand.wav"
  Delete "$INSTDIR\data\sound\lion_cry.wav"
  Delete "$INSTDIR\data\sound\lion_roar.wav"
  Delete "$INSTDIR\data\sound\penguin_call_0.wav"
  Delete "$INSTDIR\data\sound\penguin_cry_0.wav"
  Delete "$INSTDIR\data\sound\penguin_cry_1.wav"
  Delete "$INSTDIR\data\sound\penguin_cry_2.wav"
  Delete "$INSTDIR\data\sound\pet_tiger_friendly.wav"
Delete "$INSTDIR\data\sound\meditation_start.wav"
Delete "$INSTDIR\data\sound\meditation_stop.wav"
Delete "$INSTDIR\data\sound\pet_crystal_air_run.wav"
Delete "$INSTDIR\data\sound\pet_crystal_ice_storm.wav"
Delete "$INSTDIR\data\sound\stove_dry.wav"
Delete "$INSTDIR\data\sound\stove_wetness.wav"
!macroend
SectionGroupEnd

SectionGroup "xml"
Section "Blacksmith Tailor Manual Tooltip" MOD433
SetOutPath "$INSTDIR\data\xml"
  DetailPrint "Installing local\xml\manualform.english.txt..."
  File "${srcdir}\Tiara's Moonshine Mod\data\xml\manualform.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD433}
  DetailPrint "*** Removing MOD433..."
  Delete "$INSTDIR\data\xml\manualform.english.txt"
!macroend
Section "Quest Interface Abbreviated 1" MOD455
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\questcategory.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD455}
  DetailPrint "*** Removing MOD455..."
  Delete "$INSTDIR\data\xml\questcategory.english.txt"
!macroend
Section "Quest Interface Abbreviated 2" MOD456
SetOutPath "$INSTDIR\data\db"
File "${srcdir}\Tiara's Moonshine Mod\data\db\questcategory.xml"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD456}
  DetailPrint "*** Removing MOD456..."
  Delete "$INSTDIR\data\db\questcategory.xml"
!macroend
Section "Show Talent Level by Number" MOD292
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\talenttitle.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD292}
  DetailPrint "*** Removing MOD292..."
  Delete "$INSTDIR\data\xml\talenttitle.english.txt"
!macroend
Section "Show Talent Level by Number 2" MOD293
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\talenttitle.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD293}
  DetailPrint "*** Removing MOD293..."
  Delete "$INSTDIR\data\xml\talenttitle.english.txt"
!macroend
Section "Show Prop Names 2" MOD294
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\propdb.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD294}
  DetailPrint "*** Removing MOD294..."
  Delete "$INSTDIR\data\xml\propdb.english.txt"
!macroend
Section "Show Prop Names 3" MOD295
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\propdb.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD295}
  DetailPrint "*** Removing MOD295..."
  Delete "$INSTDIR\data\xml\propdb.english.txt"
!macroend
Section "Skeleton Squad Name Mod" MOD296
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\race.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD296}
  DetailPrint "*** Removing MOD296..."
  Delete "$INSTDIR\data\xml\race.english.txt"
!macroend
Section "Skeleton Squad Name Mod 2" MOD297
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\race.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD297}
  DetailPrint "*** Removing MOD297..."
  Delete "$INSTDIR\data\xml\race.english.txt"
!macroend

Section "True Fossil Names" MOD300
SetOutPath "$INSTDIR\data\xml"
  DetailPrint "Installing True Fossil Names..."
  File "${srcdir}\Tiara's Moonshine Mod\data\xml\itemdb.english.txt"
  SetDetailsPrint both
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD300}
  DetailPrint "*** Removing MOD300..."
  Delete "$INSTDIR\data\xml\itemdb.english.txt"
!macroend
Section "True Fossil Names 2" MOD301
SetOutPath "$INSTDIR\data\db"
  DetailPrint "Installing True Fossil Names 2..."
  File "${srcdir}\Tiara's Moonshine Mod\data\db\itemdb.xml"
  SetDetailsPrint both
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD301}
  DetailPrint "*** Removing MOD301..."
  Delete "$INSTDIR\data\db\itemdb.xml"
!macroend
Section "Huge Ancient Names 1" MOD393
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\title.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD393}
  DetailPrint "*** Removing MOD393..."
  Delete "$INSTDIR\data\xml\title.english.txt"
!macroend
Section "Huge Ancient Names 2" MOD390
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\title.english.txt"
SectionIn 1 2 3
SectionEnd
!macro Remove_${MOD390}
  DetailPrint "*** Removing MOD390..."
  Delete "$INSTDIR\data\xml\title.english.txt"
!macroend
SectionGroupEnd
SectionGroup "world"
Section "Shadow Mission Boards" MOD74
SetOutPath "$INSTDIR\data\world\taillteann_main_field"
File "${srcdir}\Tiara's Moonshine Mod\data\world\taillteann_main_field\_taillteann_main_field_0018.area"
SetOutPath "$INSTDIR\data\world\Tara_main_field"
File "${srcdir}\Tiara's Moonshine Mod\data\world\Tara_main_field\_Tara_main_field_0013.area"
SectionIn 1 2
SectionEnd
!macro Remove_${MOD74}
  DetailPrint "*** Removing MOD74..."
  Delete "$INSTDIR\data\world\taillteann_main_field\_taillteann_main_field_0018.area"
  Delete "$INSTDIR\data\world\Tara_main_field\_Tara_main_field_0013.area"
!macroend
SectionGroupEnd
SectionGroupEnd

SectionGroup "Optional Mods"
Section "Unofficial Tiaras Moonshine Mod Readme" MOD205
SetOutPath "$INSTDIR"
File "${srcdir}\README.md"
Delete "$INSTDIR\data\README.md"
SectionIn 1
SectionEnd
!macro Remove_${MOD205}
  DetailPrint "*** Removing MOD205..."
  Delete "$INSTDIR\README.md"
!macroend
Section "Realistic Rain" MOD394
SetOutPath "$INSTDIR\data\sound"
DetailPrint "Installing Realistic Rain..."
File "${srcdir}\Tiara's Moonshine Mod\data\sound\weather_raining.wav"
SetDetailsPrint both
SectionIn 1
SectionEnd
!macro Remove_${MOD394}
  DetailPrint "*** Removing Realistic Rain..."
  Delete "$INSTDIR\data\sound\weather_raining.wav"
!macroend
SectionGroupEnd

SectionGroup "Risky Mods (add)"
Section "Enable MultiClient & Show Visual Chat" MOD298
SetOutPath "$INSTDIR\data"
DetailPrint "Installing features.xml.compiled..."
  File "${srcdir}\Tiara's Moonshine Mod\data\features.xml.compiled"
SetOutPath "$INSTDIR\data\db"
DetailPrint "Installing urls.xml..."
File "${srcdir}\Tiara's Moonshine Mod\data\db\urls.xml"
SetDetailsPrint both
SectionIn 1
SectionEnd
!macro Remove_${MOD298}
  DetailPrint "*** Removing Enable MultiClient & Show Visual Chat..."
  Delete "$INSTDIR\data\db\urls.xml"
!macroend

SectionGroup "Show Hidden Skill Flown Hot-Air Balloon" MOD398
Section "Show Hidden Skill Flown Hot-Air Balloon ?1" MOD398?1
SetOutPath "$INSTDIR\data\db\skill"
File "${srcdir}\Tiara's Moonshine Mod\data\db\skill\skillinfo.xml"
SectionIn 1
SectionEnd
!macro Remove_${MOD398?1}
  DetailPrint "*** Removing Show Hidden Skill Flown Hot-Air Balloon ?1..."
  Delete "$INSTDIR\data\db\skill\skillinfo.xml"
!macroend
Section "Show Hidden Skill Flown Hot-Air Balloon ?2" MOD398?2
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\skillinfo.english.txt"
SectionIn 1
SectionEnd
!macro Remove_${MOD398?2}
  DetailPrint "*** Removing Show Hidden Skill Flown Hot-Air Balloon ?2..."
  Delete "$INSTDIR\data\xml\skillinfo.english.txt"
!macroend
Section "Show Hidden Skill Flown Hot-Air Balloon ?3" MOD398?3
SetOutPath "$INSTDIR\data\xml"
File "${srcdir}\Tiara's Moonshine Mod\data\xml\skillinfo.english.txt"
SectionIn 1
SectionEnd
!macro Remove_${MOD398?3}
  DetailPrint "*** Removing Show Hidden Skill Flown Hot-Air Balloon ?3..."
  Delete "$INSTDIR\data\xml\skillinfo.english.txt"
!macroend
SectionGroupEnd

!macro Remove_${MOD398}
  DetailPrint "*** Removing Show Hidden Skill Flown Hot-Air Balloon..."
  Delete "$INSTDIR\data\db\skill\skillinfo.xml"
  Delete "$INSTDIR\data\xml\skillinfo.english.txt"
  Delete "$INSTDIR\data\xml\skillinfo.english.txt"
!macroend
;Section "Doll Bag AI Enhancements" MOD399
;SetOutPath "$INSTDIR\data\db\ai\local"
;File "${srcdir}\Tiara's Moonshine Mod\data\db\ai\local\aidescdata_autobot_vocaloid.xml"
;SectionIn 1
;SectionEnd
;!macro Remove_${MOD399}
;  DetailPrint "*** Removing Doll Bag AI Enhancements..."
;  Delete "$INSTDIR\data\db\ai\local\aidescdata_autobot_vocaloid.xml"
;!macroend
SectionGroupEnd


SectionGroup "Risky Mods (remove)"
Section "Remove Font Changes"
DetailPrint "*** Removing Font Changes..."
Delete "$INSTDIR\data\gfx\font\NanumGothicBold.ttf"
Delete "$INSTDIR\data\gfx\gui\font_outline_eng.dds"
Delete "$INSTDIR\data\gfx\gui\font_eng.dds"
; edit for "if exists"
DetailPrint "*** Removing Abyss's Bitmap Font..."
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "Bitmap" "0"
WriteINIStr "$INSTDIR\Abyss.ini" "PATCH" "BitmapPositionFix" "0"
SectionIn 3
SectionEnd
Section "Remove Hidden Skill Flown Hot-Air Balloon"
  DetailPrint "*** Removing Show Hidden Skill Flown Hot-Air Balloon..."
Delete "$INSTDIR\data\db\skill\skillinfo.xml"
Delete "$INSTDIR\data\xml\skillinfo.english.txt"
Delete "$INSTDIR\data\xml\skillinfo.english.txt"
SectionIn 3
SectionEnd
SectionGroupEnd

Section "Required (Writing info to registry)"
SectionIn RO
Call ModInfo
SectionEnd
SectionGroupEnd

!macro SectionList MacroName
  ;This macro used to perform operation on multiple sections.
  ;List all of your components in following manner here.

;"Unofficial Tiara's Moonshine Mods"
!insertmacro "${MacroName}" "MOD432"
!insertmacro "${MacroName}" "MOD433"
!insertmacro "${MacroName}" "MOD434"
!insertmacro "${MacroName}" "MOD435"
!insertmacro "${MacroName}" "MOD436"
!insertmacro "${MacroName}" "MOD437"
!insertmacro "${MacroName}" "MOD438"
!insertmacro "${MacroName}" "MOD439"
!insertmacro "${MacroName}" "MOD440"
!insertmacro "${MacroName}" "MOD441"
!insertmacro "${MacroName}" "MOD452"
!insertmacro "${MacroName}" "MOD431"
!insertmacro "${MacroName}" "MOD453"
;"Tools
!insertmacro "${MacroName}" "MOD454"
;"Data Mods"
!insertmacro "${MacroName}" "MOD1"
!insertmacro "${MacroName}" "MOD405"
!insertmacro "${MacroName}" "MOD406"
!insertmacro "${MacroName}" "MOD2"
!insertmacro "${MacroName}" "MOD447"
!insertmacro "${MacroName}" "MOD3"
!insertmacro "${MacroName}" "MOD4"
!insertmacro "${MacroName}" "MOD5"
!insertmacro "${MacroName}" "MOD6"
!insertmacro "${MacroName}" "MOD7"
!insertmacro "${MacroName}" "MOD8"
!insertmacro "${MacroName}" "MOD9"
!insertmacro "${MacroName}" "MOD10"
!insertmacro "${MacroName}" "MOD11"
!insertmacro "${MacroName}" "MOD12"
!insertmacro "${MacroName}" "MOD13"
!insertmacro "${MacroName}" "MOD14"
!insertmacro "${MacroName}" "MOD15"
!insertmacro "${MacroName}" "MOD16"
!insertmacro "${MacroName}" "MOD17"
!insertmacro "${MacroName}" "MOD18"
!insertmacro "${MacroName}" "MOD19"
!insertmacro "${MacroName}" "MOD20"
!insertmacro "${MacroName}" "MOD21"
!insertmacro "${MacroName}" "MOD22"
!insertmacro "${MacroName}" "MOD23"
!insertmacro "${MacroName}" "MOD24"
!insertmacro "${MacroName}" "MOD25"
!insertmacro "${MacroName}" "MOD26"
!insertmacro "${MacroName}" "MOD27"
!insertmacro "${MacroName}" "MOD28"
!insertmacro "${MacroName}" "MOD29"
!insertmacro "${MacroName}" "MOD30"
!insertmacro "${MacroName}" "MOD31"
!insertmacro "${MacroName}" "MOD32"
!insertmacro "${MacroName}" "MOD33"
!insertmacro "${MacroName}" "MOD34"
!insertmacro "${MacroName}" "MOD35"
!insertmacro "${MacroName}" "MOD36"
!insertmacro "${MacroName}" "MOD37"
!insertmacro "${MacroName}" "MOD38"
!insertmacro "${MacroName}" "MOD39"
!insertmacro "${MacroName}" "MOD40"
!insertmacro "${MacroName}" "MOD41"
!insertmacro "${MacroName}" "MOD42"
!insertmacro "${MacroName}" "MOD43"
!insertmacro "${MacroName}" "MOD44"
!insertmacro "${MacroName}" "MOD45"
!insertmacro "${MacroName}" "MOD46"
!insertmacro "${MacroName}" "MOD47"
!insertmacro "${MacroName}" "MOD48"
!insertmacro "${MacroName}" "MOD49"
!insertmacro "${MacroName}" "MOD50"
!insertmacro "${MacroName}" "MOD51"
!insertmacro "${MacroName}" "MOD52"
!insertmacro "${MacroName}" "MOD53"
!insertmacro "${MacroName}" "MOD54"
!insertmacro "${MacroName}" "MOD55"
!insertmacro "${MacroName}" "MOD56"
!insertmacro "${MacroName}" "MOD57"
!insertmacro "${MacroName}" "MOD58"
!insertmacro "${MacroName}" "MOD407"
!insertmacro "${MacroName}" "MOD408"
!insertmacro "${MacroName}" "MOD409"
!insertmacro "${MacroName}" "MOD410"
!insertmacro "${MacroName}" "MOD59"
!insertmacro "${MacroName}" "MOD411"
!insertmacro "${MacroName}" "MOD412"
!insertmacro "${MacroName}" "MOD413"
!insertmacro "${MacroName}" "MOD414"
!insertmacro "${MacroName}" "MOD448"
!insertmacro "${MacroName}" "MOD449"
!insertmacro "${MacroName}" "MOD450"
!insertmacro "${MacroName}" "MOD451"
!insertmacro "${MacroName}" "MOD415?1"
!insertmacro "${MacroName}" "MOD415?2"
!insertmacro "${MacroName}" "MOD415?3"
!insertmacro "${MacroName}" "MOD415?4"
!insertmacro "${MacroName}" "MOD415?5"
!insertmacro "${MacroName}" "MOD415?6"
!insertmacro "${MacroName}" "MOD415?7"
!insertmacro "${MacroName}" "MOD415?8"
!insertmacro "${MacroName}" "MOD415?9"
!insertmacro "${MacroName}" "MOD415?10"
!insertmacro "${MacroName}" "MOD415?11"
!insertmacro "${MacroName}" "MOD415"
!insertmacro "${MacroName}" "MOD416"
!insertmacro "${MacroName}" "MOD417"
!insertmacro "${MacroName}" "MOD418"
!insertmacro "${MacroName}" "MOD419"
!insertmacro "${MacroName}" "MOD420"
!insertmacro "${MacroName}" "MOD421"
!insertmacro "${MacroName}" "MOD422"
!insertmacro "${MacroName}" "MOD423"
!insertmacro "${MacroName}" "MOD424"
!insertmacro "${MacroName}" "MOD425"
!insertmacro "${MacroName}" "MOD426"
!insertmacro "${MacroName}" "MOD427"
!insertmacro "${MacroName}" "MOD428"
!insertmacro "${MacroName}" "MOD429"
!insertmacro "${MacroName}" "MOD430"
!insertmacro "${MacroName}" "MOD60"
!insertmacro "${MacroName}" "MOD61"
!insertmacro "${MacroName}" "MOD62"
!insertmacro "${MacroName}" "MOD63"
!insertmacro "${MacroName}" "MOD64"
!insertmacro "${MacroName}" "MOD65"
!insertmacro "${MacroName}" "MOD66"
!insertmacro "${MacroName}" "MOD67"
!insertmacro "${MacroName}" "MOD68"
!insertmacro "${MacroName}" "MOD69"
!insertmacro "${MacroName}" "MOD70"
!insertmacro "${MacroName}" "MOD71"
!insertmacro "${MacroName}" "MOD72"
!insertmacro "${MacroName}" "MOD72?1"
!insertmacro "${MacroName}" "MOD72?2"
!insertmacro "${MacroName}" "MOD72?3"
!insertmacro "${MacroName}" "MOD73"
!insertmacro "${MacroName}" "MOD74"
!insertmacro "${MacroName}" "MOD444"
!insertmacro "${MacroName}" "MOD445"
!insertmacro "${MacroName}" "MOD446"
!insertmacro "${MacroName}" "MOD80"
!insertmacro "${MacroName}" "MOD81"
!insertmacro "${MacroName}" "MOD404"
!insertmacro "${MacroName}" "MOD82"
!insertmacro "${MacroName}" "MOD83"
!insertmacro "${MacroName}" "MOD84"
!insertmacro "${MacroName}" "MOD85"
!insertmacro "${MacroName}" "MOD86"
!insertmacro "${MacroName}" "MOD87"
!insertmacro "${MacroName}" "MOD88"
!insertmacro "${MacroName}" "MOD89"
!insertmacro "${MacroName}" "MOD90"
!insertmacro "${MacroName}" "MOD91"
!insertmacro "${MacroName}" "MOD92"
!insertmacro "${MacroName}" "MOD93"
!insertmacro "${MacroName}" "MOD94"
!insertmacro "${MacroName}" "MOD95"
!insertmacro "${MacroName}" "MOD96"
!insertmacro "${MacroName}" "MOD97"
!insertmacro "${MacroName}" "MOD98"
;!insertmacro "${MacroName}" "MOD98?1"
;!insertmacro "${MacroName}" "MOD98?2"
!insertmacro "${MacroName}" "MOD392"
!insertmacro "${MacroName}" "MOD99"
!insertmacro "${MacroName}" "MOD100"
!insertmacro "${MacroName}" "MOD101"
!insertmacro "${MacroName}" "MOD102"
!insertmacro "${MacroName}" "MOD103"
!insertmacro "${MacroName}" "MOD104"
!insertmacro "${MacroName}" "MOD105"
!insertmacro "${MacroName}" "MOD106"
!insertmacro "${MacroName}" "MOD107"
!insertmacro "${MacroName}" "MOD108"
!insertmacro "${MacroName}" "MOD109"
!insertmacro "${MacroName}" "MOD110"
!insertmacro "${MacroName}" "MOD111"
!insertmacro "${MacroName}" "MOD112"
!insertmacro "${MacroName}" "MOD113"
!insertmacro "${MacroName}" "MOD114"
!insertmacro "${MacroName}" "MOD115"
!insertmacro "${MacroName}" "MOD116"
!insertmacro "${MacroName}" "MOD117"
!insertmacro "${MacroName}" "MOD400"
!insertmacro "${MacroName}" "MOD118"
!insertmacro "${MacroName}" "MOD119"
!insertmacro "${MacroName}" "MOD120"
!insertmacro "${MacroName}" "MOD121"
!insertmacro "${MacroName}" "MOD122"
!insertmacro "${MacroName}" "MOD123"
!insertmacro "${MacroName}" "MOD124"
!insertmacro "${MacroName}" "MOD125"
!insertmacro "${MacroName}" "MOD126"
!insertmacro "${MacroName}" "MOD127"
!insertmacro "${MacroName}" "MOD128"
!insertmacro "${MacroName}" "MOD129"
!insertmacro "${MacroName}" "MOD130"
!insertmacro "${MacroName}" "MOD131"
!insertmacro "${MacroName}" "MOD132"
!insertmacro "${MacroName}" "MOD133"
!insertmacro "${MacroName}" "MOD134"
!insertmacro "${MacroName}" "MOD135"
!insertmacro "${MacroName}" "MOD136"
!insertmacro "${MacroName}" "MOD137"
!insertmacro "${MacroName}" "MOD138"
!insertmacro "${MacroName}" "MOD139"
!insertmacro "${MacroName}" "MOD140"
!insertmacro "${MacroName}" "MOD141"
!insertmacro "${MacroName}" "MOD391"
!insertmacro "${MacroName}" "MOD142"
!insertmacro "${MacroName}" "MOD143"
!insertmacro "${MacroName}" "MOD144"
!insertmacro "${MacroName}" "MOD145"
!insertmacro "${MacroName}" "MOD146"
!insertmacro "${MacroName}" "MOD147"
!insertmacro "${MacroName}" "MOD148"
!insertmacro "${MacroName}" "MOD149"
!insertmacro "${MacroName}" "MOD150"
!insertmacro "${MacroName}" "MOD151"
!insertmacro "${MacroName}" "MOD152"
!insertmacro "${MacroName}" "MOD153"
!insertmacro "${MacroName}" "MOD154"
!insertmacro "${MacroName}" "MOD155"
!insertmacro "${MacroName}" "MOD156"
!insertmacro "${MacroName}" "MOD157"
!insertmacro "${MacroName}" "MOD158"
!insertmacro "${MacroName}" "MOD159"
!insertmacro "${MacroName}" "MOD160"
!insertmacro "${MacroName}" "MOD161"
!insertmacro "${MacroName}" "MOD162"
!insertmacro "${MacroName}" "MOD163"
!insertmacro "${MacroName}" "MOD164"
!insertmacro "${MacroName}" "MOD165"
!insertmacro "${MacroName}" "MOD166"
!insertmacro "${MacroName}" "MOD167"
!insertmacro "${MacroName}" "MOD442"
!insertmacro "${MacroName}" "MOD168"
!insertmacro "${MacroName}" "MOD169"
!insertmacro "${MacroName}" "MOD170"
!insertmacro "${MacroName}" "MOD171"
!insertmacro "${MacroName}" "MOD172"
!insertmacro "${MacroName}" "MOD173"
!insertmacro "${MacroName}" "MOD174"
!insertmacro "${MacroName}" "MOD401"
!insertmacro "${MacroName}" "MOD401?1"
!insertmacro "${MacroName}" "MOD401?2"
!insertmacro "${MacroName}" "MOD401?3"
!insertmacro "${MacroName}" "MOD401?4"
!insertmacro "${MacroName}" "MOD401?5"
!insertmacro "${MacroName}" "MOD401?6"
!insertmacro "${MacroName}" "MOD401?7"
!insertmacro "${MacroName}" "MOD401?8"
!insertmacro "${MacroName}" "MOD403"
!insertmacro "${MacroName}" "MOD175"
!insertmacro "${MacroName}" "MOD176"
!insertmacro "${MacroName}" "MOD177"
!insertmacro "${MacroName}" "MOD178"
!insertmacro "${MacroName}" "MOD179"
!insertmacro "${MacroName}" "MOD180"
!insertmacro "${MacroName}" "MOD181"
!insertmacro "${MacroName}" "MOD182"
!insertmacro "${MacroName}" "MOD183"
!insertmacro "${MacroName}" "MOD184"
!insertmacro "${MacroName}" "MOD185"
!insertmacro "${MacroName}" "MOD186"
!insertmacro "${MacroName}" "MOD187"
!insertmacro "${MacroName}" "MOD188"
!insertmacro "${MacroName}" "MOD189"
!insertmacro "${MacroName}" "MOD190"
!insertmacro "${MacroName}" "MOD191"
!insertmacro "${MacroName}" "MOD192"
!insertmacro "${MacroName}" "MOD193"
!insertmacro "${MacroName}" "MOD194"
!insertmacro "${MacroName}" "MOD195"
!insertmacro "${MacroName}" "MOD196"
!insertmacro "${MacroName}" "MOD197"
!insertmacro "${MacroName}" "MOD198"
!insertmacro "${MacroName}" "MOD199"
!insertmacro "${MacroName}" "MOD200"
!insertmacro "${MacroName}" "MOD201"
!insertmacro "${MacroName}" "MOD202"
!insertmacro "${MacroName}" "MOD203"
!insertmacro "${MacroName}" "MOD204"
!insertmacro "${MacroName}" "MOD443"
!insertmacro "${MacroName}" "MOD206"
!insertmacro "${MacroName}" "MOD207"
!insertmacro "${MacroName}" "MOD208"
!insertmacro "${MacroName}" "MOD209"
!insertmacro "${MacroName}" "MOD210"
!insertmacro "${MacroName}" "MOD211"
!insertmacro "${MacroName}" "MOD212"
!insertmacro "${MacroName}" "MOD213"
!insertmacro "${MacroName}" "MOD214"
!insertmacro "${MacroName}" "MOD215"
!insertmacro "${MacroName}" "MOD216"
!insertmacro "${MacroName}" "MOD217"
!insertmacro "${MacroName}" "MOD218"
!insertmacro "${MacroName}" "MOD219"
!insertmacro "${MacroName}" "MOD220"
!insertmacro "${MacroName}" "MOD221"
!insertmacro "${MacroName}" "MOD222"
!insertmacro "${MacroName}" "MOD223"
!insertmacro "${MacroName}" "MOD224"
!insertmacro "${MacroName}" "MOD225"
!insertmacro "${MacroName}" "MOD226"
!insertmacro "${MacroName}" "MOD227"
!insertmacro "${MacroName}" "MOD228"
!insertmacro "${MacroName}" "MOD229"
!insertmacro "${MacroName}" "MOD230"
!insertmacro "${MacroName}" "MOD231"
!insertmacro "${MacroName}" "MOD232"
!insertmacro "${MacroName}" "MOD233"
!insertmacro "${MacroName}" "MOD234"
!insertmacro "${MacroName}" "MOD235"
!insertmacro "${MacroName}" "MOD236"
!insertmacro "${MacroName}" "MOD237"
!insertmacro "${MacroName}" "MOD238"
!insertmacro "${MacroName}" "MOD239"
!insertmacro "${MacroName}" "MOD240"
!insertmacro "${MacroName}" "MOD241"
!insertmacro "${MacroName}" "MOD242"
!insertmacro "${MacroName}" "MOD243"
!insertmacro "${MacroName}" "MOD244"
!insertmacro "${MacroName}" "MOD245"
!insertmacro "${MacroName}" "MOD246"
!insertmacro "${MacroName}" "MOD247"
!insertmacro "${MacroName}" "MOD248"
!insertmacro "${MacroName}" "MOD249"
!insertmacro "${MacroName}" "MOD250"
!insertmacro "${MacroName}" "MOD251"
!insertmacro "${MacroName}" "MOD252"
!insertmacro "${MacroName}" "MOD253"
!insertmacro "${MacroName}" "MOD254"
!insertmacro "${MacroName}" "MOD255"
!insertmacro "${MacroName}" "MOD256"
!insertmacro "${MacroName}" "MOD257"
!insertmacro "${MacroName}" "MOD258"
!insertmacro "${MacroName}" "MOD259"
!insertmacro "${MacroName}" "MOD260"
!insertmacro "${MacroName}" "MOD261"
!insertmacro "${MacroName}" "MOD262"
!insertmacro "${MacroName}" "MOD263"
!insertmacro "${MacroName}" "MOD264"
!insertmacro "${MacroName}" "MOD265"
!insertmacro "${MacroName}" "MOD266"
!insertmacro "${MacroName}" "MOD267"
!insertmacro "${MacroName}" "MOD268"
!insertmacro "${MacroName}" "MOD269"
!insertmacro "${MacroName}" "MOD270"
!insertmacro "${MacroName}" "MOD271"
!insertmacro "${MacroName}" "MOD272"
!insertmacro "${MacroName}" "MOD273"
!insertmacro "${MacroName}" "MOD274"
!insertmacro "${MacroName}" "MOD275"
!insertmacro "${MacroName}" "MOD276"
!insertmacro "${MacroName}" "MOD277"
!insertmacro "${MacroName}" "MOD278"
!insertmacro "${MacroName}" "MOD279"
!insertmacro "${MacroName}" "MOD280"
!insertmacro "${MacroName}" "MOD281"
!insertmacro "${MacroName}" "MOD282"
!insertmacro "${MacroName}" "MOD283"
!insertmacro "${MacroName}" "MOD284"
!insertmacro "${MacroName}" "MOD285"
!insertmacro "${MacroName}" "MOD286"
!insertmacro "${MacroName}" "MOD287"
!insertmacro "${MacroName}" "MOD288"
!insertmacro "${MacroName}" "MOD289"
!insertmacro "${MacroName}" "MOD290"
!insertmacro "${MacroName}" "MOD291"
!insertmacro "${MacroName}" "MOD292"
!insertmacro "${MacroName}" "MOD293"
!insertmacro "${MacroName}" "MOD294"
!insertmacro "${MacroName}" "MOD295"
!insertmacro "${MacroName}" "MOD296"
!insertmacro "${MacroName}" "MOD297"
!insertmacro "${MacroName}" "MOD298"
!insertmacro "${MacroName}" "MOD299"
!insertmacro "${MacroName}" "MOD300"
!insertmacro "${MacroName}" "MOD301"
!insertmacro "${MacroName}" "MOD393"
!insertmacro "${MacroName}" "MOD390"
!insertmacro "${MacroName}" "MOD302"
!insertmacro "${MacroName}" "MOD303"
!insertmacro "${MacroName}" "MOD304"
!insertmacro "${MacroName}" "MOD305"
!insertmacro "${MacroName}" "MOD306"
!insertmacro "${MacroName}" "MOD307"
!insertmacro "${MacroName}" "MOD308"
!insertmacro "${MacroName}" "MOD309"
!insertmacro "${MacroName}" "MOD310"
!insertmacro "${MacroName}" "MOD311"
!insertmacro "${MacroName}" "MOD312"
!insertmacro "${MacroName}" "MOD313"
!insertmacro "${MacroName}" "MOD314"
!insertmacro "${MacroName}" "MOD315"
!insertmacro "${MacroName}" "MOD316"
!insertmacro "${MacroName}" "MOD317"
!insertmacro "${MacroName}" "MOD318"
!insertmacro "${MacroName}" "MOD319"
!insertmacro "${MacroName}" "MOD320"
!insertmacro "${MacroName}" "MOD321"
!insertmacro "${MacroName}" "MOD322"
!insertmacro "${MacroName}" "MOD323"
!insertmacro "${MacroName}" "MOD324"
!insertmacro "${MacroName}" "MOD325"
!insertmacro "${MacroName}" "MOD326"
!insertmacro "${MacroName}" "MOD327"
!insertmacro "${MacroName}" "MOD328"
!insertmacro "${MacroName}" "MOD329"
!insertmacro "${MacroName}" "MOD330"
!insertmacro "${MacroName}" "MOD331"
!insertmacro "${MacroName}" "MOD332"
!insertmacro "${MacroName}" "MOD333"
!insertmacro "${MacroName}" "MOD334"
!insertmacro "${MacroName}" "MOD335"
!insertmacro "${MacroName}" "MOD336"
!insertmacro "${MacroName}" "MOD337"
!insertmacro "${MacroName}" "MOD338"
!insertmacro "${MacroName}" "MOD339"
!insertmacro "${MacroName}" "MOD340"
!insertmacro "${MacroName}" "MOD341"
!insertmacro "${MacroName}" "MOD342"
!insertmacro "${MacroName}" "MOD343"
!insertmacro "${MacroName}" "MOD344"
!insertmacro "${MacroName}" "MOD345"
!insertmacro "${MacroName}" "MOD346"
!insertmacro "${MacroName}" "MOD347"
!insertmacro "${MacroName}" "MOD348"
!insertmacro "${MacroName}" "MOD349"
!insertmacro "${MacroName}" "MOD350"
!insertmacro "${MacroName}" "MOD351"
!insertmacro "${MacroName}" "MOD352"
!insertmacro "${MacroName}" "MOD353"
!insertmacro "${MacroName}" "MOD354"
!insertmacro "${MacroName}" "MOD355"
!insertmacro "${MacroName}" "MOD356"
!insertmacro "${MacroName}" "MOD357"
!insertmacro "${MacroName}" "MOD358"
!insertmacro "${MacroName}" "MOD359"
!insertmacro "${MacroName}" "MOD360"
!insertmacro "${MacroName}" "MOD361"
!insertmacro "${MacroName}" "MOD362"
!insertmacro "${MacroName}" "MOD363"
!insertmacro "${MacroName}" "MOD364"
!insertmacro "${MacroName}" "MOD365"
!insertmacro "${MacroName}" "MOD366"
!insertmacro "${MacroName}" "MOD367"
!insertmacro "${MacroName}" "MOD368"
!insertmacro "${MacroName}" "MOD369"
!insertmacro "${MacroName}" "MOD370"
!insertmacro "${MacroName}" "MOD371"
!insertmacro "${MacroName}" "MOD372"
!insertmacro "${MacroName}" "MOD373"
!insertmacro "${MacroName}" "MOD374"
!insertmacro "${MacroName}" "MOD375"
!insertmacro "${MacroName}" "MOD376"
!insertmacro "${MacroName}" "MOD377"
!insertmacro "${MacroName}" "MOD378"
!insertmacro "${MacroName}" "MOD379"
!insertmacro "${MacroName}" "MOD380"
!insertmacro "${MacroName}" "MOD381"
!insertmacro "${MacroName}" "MOD382"
!insertmacro "${MacroName}" "MOD383"
!insertmacro "${MacroName}" "MOD384"
!insertmacro "${MacroName}" "MOD385"
!insertmacro "${MacroName}" "MOD386"
!insertmacro "${MacroName}" "MOD387"
!insertmacro "${MacroName}" "MOD388"
!insertmacro "${MacroName}" "MOD389"
!insertmacro "${MacroName}" "MOD455"
!insertmacro "${MacroName}" "MOD456"
;"Optional Mods"
!insertmacro "${MacroName}" "MOD205"
!insertmacro "${MacroName}" "MOD395"
!insertmacro "${MacroName}" "MOD394"
;"Risky Mods (add)"
!insertmacro "${MacroName}" "MOD396"
!insertmacro "${MacroName}" "MOD396?1"
!insertmacro "${MacroName}" "MOD396?2"
;!insertmacro "${MacroName}" "MOD397"
!insertmacro "${MacroName}" "MOD398"
!insertmacro "${MacroName}" "MOD398?1"
!insertmacro "${MacroName}" "MOD398?2"
!insertmacro "${MacroName}" "MOD398?3"
;!insertmacro "${MacroName}" "MOD399"
!insertmacro "${MacroName}" "MOD457"
!insertmacro "${MacroName}" "MOD402"
!macroend



Function ModInfo
;This section is required. It can't be removed.

;Writing uninstall info to registry:
  WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayName" "${UOSHORTNAME}"
  WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayIcon" "$INSTDIR\Unofficial Tiaras Uninstaller.exe"
  WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayVersion" "${UOVERSION}"
  WriteRegStr HKLM "${REG_UNINSTALL}" "Publisher" "ShaggyZE"
  WriteRegStr HKLM "${REG_UNINSTALL}" "InstallSource" "$EXEDIR\"
  WriteRegStr HKLM "${REG_UNINSTALL}" "MODS" "457"

WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD1" "" "Artifact Discovery Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD1" "FILE1" "\data\db\cutscene\c2\iria_finding.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD1" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD1" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD1" "DESCRIPTION" "Removes Artifact Discovery Cutscene"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD405" "" "Elf Transformation Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD405" "FILE1" "\data\db\cutscene\c2\cutscene_elf_transform.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD405" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD405" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD405" "DESCRIPTION" "Removes Elf Transformation Cutscene"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD406" "" "Giant Transformation Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD406" "FILE1" "\data\db\cutscene\c2\cutscene_giant_transform.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD406" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD406" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD406" "DESCRIPTION" "Removes Giant Transformation Cutscene"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD2" "" "Alby Hard Mode Arachne Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD2" "FILE1" "\data\db\cutscene\c2\bossroom_hardmode_albi_arachne.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD2" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD2" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD2" "DESCRIPTION" "Removes Alby Hard Mode Arachne Cutscene"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD3" "" "Golden Spider Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD3" "FILE1" "\data\db\cutscene\c2\bossroom_albi_golden_spider.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD3" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD3" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD3" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD4" "" "Ghost Army Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD4" "FILE1" "\data\db\cutscene\c2\bossroom_ghostarmy.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD4" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD4" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD4" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD5" "" "Giant Ice Sprite Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD5" "FILE1" "\data\db\cutscene\c2\bossroom_giant_ice_sprite.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD5" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD5" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD5" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD6" "" "Generic Incubus Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD6" "FILE1" "\data\db\cutscene\c2\bossroom_incubus.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD6" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD6" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD6" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD7" "" "Dugald Incubus Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD7" "FILE1" "\data\db\cutscene\c2\bossroom_incubus_dugald.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD7" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD7" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD7" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD8" "" "Dugald Incubus Transformation Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD8" "FILE1" "\data\db\cutscene\c2\bossroom_incubus_dugald_transform.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD8" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD8" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD8" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD9" "" "Sen Mag Incubus Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD9" "FILE1" "\data\db\cutscene\c2\bossroom_incubus_senmag.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD9" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD9" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD9" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD10" "" "Sen Mag Incubus Transformation Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD10" "FILE1" "\data\db\cutscene\c2\bossroom_incubus_senmag_transform.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD10" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD10" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD10" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD11" "" "Generic Incubus Transformation Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD11" "FILE1" "\data\db\cutscene\c2\bossroom_incubus_transform.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD11" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD11" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD11" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD12" "" "Bandersnatch Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD12" "FILE1" "\data\db\cutscene\c2\iria_bossroom_bandersnatch.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD12" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD12" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD12" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD13" "" "Desert Ruins Boss Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD13" "FILE1" "\data\db\cutscene\c2\iria_bossroom_dersert_ruins.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD13" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD13" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD13" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD14" "" "Mirror Witch Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD14" "FILE1" "\data\db\cutscene\c2\iria_bossroom_mirrorwitch.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD14" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD14" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD14" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD15" "" "Angry Mirror Witch Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD15" "FILE1" "\data\db\cutscene\c2\iria_bossroom_mirrorwitch_angry.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD15" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD15" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD15" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD16" "" "Mirror Witch Introduction Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD16" "FILE1" "\data\db\cutscene\c2\iria_bossroom_mirrorwitch_intro.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD16" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD16" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD16" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD17" "" "Pot Spider Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD17" "FILE1" "\data\db\cutscene\c2\iria_bossroom_potspider.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD17" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD17" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD17" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD18" "" "Pot Spider Pincer Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD18" "FILE1" "\data\db\cutscene\c2\iria_bossroom_potspider_claw.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD18" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD18" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD18" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD19" "" "Pot Spider Leg Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD19" "FILE1" "\data\db\cutscene\c2\iria_bossroom_potspider_leg.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD19" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD19" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD19" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD20" "" "Pot Spider Molar Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD20" "FILE1" "\data\db\cutscene\c2\iria_bossroom_potspider_molar.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD20" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD20" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD20" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD21" "" "Pot Spider Venom Sac"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD21" "FILE1" "\data\db\cutscene\c2\iria_bossroom_potspider_poisongland.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD21" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD21" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD21" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD22" "" "Pot Spider Pot Belly Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD22" "FILE1" "\data\db\cutscene\c2\iria_bossroom_potspider_pot.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD22" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD22" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD22" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD23" "" "Shining Gargoyle Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD23" "FILE1" "\data\db\cutscene\c2\iria_bossroom_shining_stonegargoyle.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD23" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD23" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD23" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD24" "" "Stone Bison Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD24" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonebison.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD24" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD24" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD24" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD25" "" "Stone Bison Hoof Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD25" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonebison_hoof.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD25" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD25" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD25" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD26" "" "Stone Bison Horn Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD26" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonebison_horn.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD26" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD26" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD26" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD27" "" "Stone Bison Tail Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD27" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonebison_tail.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD27" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD27" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD27" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD28" "" "Stone Bison Teeth Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD28" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonebison_teeth.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD28" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD28" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD28" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD29" "" "Stone Gargoyle Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD29" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonegargoyle.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD29" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD29" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD29" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD30" "" "Stone Gargoyle Boots Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD30" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonegargoyle_boots.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD30" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD30" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD30" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD31" "" "Stone Gargoyle Glove Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD31" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonegargoyle_glove.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD31" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD31" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD31" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD32" "" "Stone Gargoyle Shoulder Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD32" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonegargoyle_shoulder.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD32" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD32" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD32" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD33" "" "Stone Horse Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD33" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonehorse.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD33" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD33" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD33" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD34" "" "Stone Hound Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD34" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonehound.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD34" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD34" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD34" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD35" "" "Stone Hound Anklet Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD35" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonehound_anklet.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD35" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD35" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD35" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD36" "" "Stone Hound Paw Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD36" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonehound_claw.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD36" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD36" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD36" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD37" "" "Stone Hound Ear Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD37" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonehound_ear.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD37" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD37" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD37" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD38" "" "Stone Hound Tail Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD38" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonehound_tail.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD38" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD38" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD38" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD39" "" "Stone Hound Teeth Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD39" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonehound_teeth.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD39" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD39" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD39" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD40" "" "Stone Imp Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD40" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stoneimp.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD40" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD40" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD40" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD41" "" "Stone Imp Hat Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD41" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stoneimp_cap.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD41" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD41" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD41" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD42" "" "Stone Imp Accessory Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD42" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stoneimp_capaccessory.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD42" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD42" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD42" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD43" "" "Stone Imp Ear Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD43" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stoneimp_ear.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD43" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD43" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD43" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD44" "" "Stone Imp Jewel Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD44" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stoneimp_jewel.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD44" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD44" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD44" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD45" "" "Stone Imp Nose Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD45" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stoneimp_nose.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD45" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD45" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD45" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD46" "" "Stone Imp Sandal Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD46" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stoneimp_sandal.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD46" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD46" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD46" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD47" "" "Stone Pot Spider Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD47" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonepotspider.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD47" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD47" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD47" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD48" "" "Stone Zombie Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD48" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonezombie.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD48" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD48" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD48" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD49" "" "Stone Zombie Belt Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD49" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonezombie_belt.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD49" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD49" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD49" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD50" "" "Stone Zombie Circlet Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD50" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonezombie_circlet.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD50" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD50" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD50" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD51" "" "Stone Zombie Eye Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD51" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonezombie_eye.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD51" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD51" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD51" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD52" "" "Stone Zombie Hair Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD52" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonezombie_hair.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD52" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD52" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD52" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD53" "" "Stone Zombie Shoulder Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD53" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonezombie_shoulder.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD53" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD53" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD53" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD54" "" "Stone Zombie Wristlet Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD54" "FILE1" "\data\db\cutscene\c2\iria_bossroom_stonezombie_wristlet.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD54" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD54" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD54" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD55" "" "Wendigo Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD55" "FILE1" "\data\db\cutscene\c2\iria_bossroom_wendigo.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD55" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD55" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD55" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD56" "" "Mark Discovery Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD56" "FILE1" "\data\db\cutscene\c2\iria_finding_mark.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD56" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD56" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD56" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD57" "" "Landmark Discovery Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD57" "FILE1" "\data\db\cutscene\c2\iria_finding_landmark.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD57" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD57" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD57" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD58" "" "Awakening of Light Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD58" "FILE1" "\data\db\cutscene\c3\cutscene_c3g10_halfgod_transform.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD58" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD58" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD58" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD407" "" "Abb Neagh Incubus Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD407" "FILE1" "\data\db\cutscene\c3\bossroom_incubus_abb.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD407" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD407" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD407" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD408" "" "Abb Neagh Incubus Transformation Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD408" "FILE1" "\data\db\cutscene\c3\bossroom_incubus_abb_transform.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD408" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD408" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD408" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD409" "" "Cuilin Incubus Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD409" "FILE1" "\data\db\cutscene\c3\bossroom_incubus_cuilin.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD409" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD409" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD409" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD410" "" "Cuilin Incubus Transformation Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD410" "FILE1" "\data\db\cutscene\c3\bossroom_incubus_cuilin_transform.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD410" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD410" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD410" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD59" "" "Martial Arts-NPC Battle Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD59" "FILE1" "\data\db\cutscene\c4\cutscene_c4g15_npc_mission.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD59" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD59" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD59" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD411" "" "Paris Proposal Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD411" "FILE1" "\data\db\cutscene\c4\cutscene_c4g14_1_2_propose_from_paris.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD411" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD411" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD411" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD412" "" "SoulStream Purification Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD412" "FILE1" "\data\db\cutscene\c4\cutscene_c4g16_16_soulstream_purify.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD412" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD412" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD412" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD413" "" "Bandit Hideout Entry Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD413" "FILE1" "\data\db\cutscene\c4\cutscene_crminalfarm_enter.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD413" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD413" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD413" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD414" "" "Bandit Hideout Exit Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD414" "FILE1" "\data\db\cutscene\c4\cutscene_crminalfarm_exit.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD414" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD414" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD414" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD448" "" "Grim Reaper Boss Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD448" "FILE1" "\data\db\cutscene\c4\cutscene_c4g13s2_bossroom_grimreaper.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD448" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD448" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD448" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD449" "" "Snow Troll Intro Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD449" "FILE1" "\data\db\cutscene\c4\cutscene_c4g13s2_ex_snowtroll.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD449" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD449" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD449" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD450" "" "Sailing Ship Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD450" "FILE1" "\data\db\cutscene\c4\cutscene_c4g15_ship.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD450" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD450" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD450" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD451" "" "Belvast Intro Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD451" "FILE1" "\data\db\cutscene\c4\cutscene_into_the_belfast.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD451" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD451" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD451" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "" "Saga 1 Ep 1 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep1_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep1_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep1_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep1_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep1_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep1_06_1.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE8" "\data\db\cutscene\drama\cutscene_dramairia_ep1_07.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE9" "\data\db\cutscene\drama\cutscene_dramairia_ep1_ex_into_region.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE10" "\data\db\cutscene\drama\cutscene_dramairia_ep1_ex01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILE11" "\data\db\cutscene\drama\cutscene_dramairia_ep1_ex02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "FILES" "11"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?1" "" "Saga 1 Ep 1 Cutscene Removal ?1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?1" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?1" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?1" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?1" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?2" "" "Saga 1 Ep 1 Cutscene Removal ?2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?2" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?2" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?2" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?2" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?3" "" "Saga 1 Ep 1 Cutscene Removal ?3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?3" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?3" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?3" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?3" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?4" "" "Saga 1 Ep 1 Cutscene Removal ?4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?4" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?4" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?4" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?4" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?5" "" "Saga 1 Ep 1 Cutscene Removal ?5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?5" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?5" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?5" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?5" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?6" "" "Saga 1 Ep 1 Cutscene Removal ?6"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?6" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?6" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?6" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?6" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?6"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?7" "" "Saga 1 Ep 1 Cutscene Removal ?7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?7" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_06_1.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?7" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?7" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?7" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?8" "" "Saga 1 Ep 1 Cutscene Removal ?8"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?8" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_07.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?8" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?8" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?8" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?8"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?9" "" "Saga 1 Ep 1 Cutscene Removal ?9"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?9" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_ex_into_region.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?9" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?9" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?9" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?9"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?10" "" "Saga 1 Ep 1 Cutscene Removal ?10"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?10" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_ex01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?10" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?10" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?10" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?10"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?11" "" "Saga 1 Ep 1 Cutscene Removal ?11"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?11" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_ex02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?11" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?11" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD415?11" "DESCRIPTION" "Saga 1 Ep 1 Cutscene Removal ?11"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "" "Saga 1 Ep 2 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep2_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep2_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep2_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep2_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep2_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep2_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep2_07.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "FILE8" "\data\db\cutscene\drama\cutscene_dramairia_ep2_ex01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "FILES" "8"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD416" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "" "Saga 1 Ep 3 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep3_00.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "FILE2" "\cutscene\drama\cutscene_dramairia_ep3_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep3_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep3_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep3_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep3_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep3_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "FILES" "7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD417" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "" "Saga 1 Ep 4 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep4_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep4_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep4_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep4_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep4_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep4_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "FILES" "6"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD418" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "" "Saga 1 Ep 5 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep5_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep5_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep5_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep5_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep5_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep5_sub_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep5_sub_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "FILES" "7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD419" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "" "Saga 1 Ep 6 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep6_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep6_01_1.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep6_01_2.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep6_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep6_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep6_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep6_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "FILES" "7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD420" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "" "Saga 1 Ep 7 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep7_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep7_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep7_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep7_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep7_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep7_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep7_ex_commentary.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "FILES" "7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD421" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "" "Saga 1 Ep 8 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep8_00.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep8_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep8_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep8_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep8_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep8_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep8_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILE8" "\data\db\cutscene\drama\cutscene_dramairia_ep8_07.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILE9" "\data\db\cutscene\drama\cutscene_dramairia_ep8_08.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "FILES" "9"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD422" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "" "Saga 1 Ep 9 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep9_00.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep9_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep9_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep9_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep9_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep9_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep9_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "FILES" "7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD423" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "" "Saga 1 Ep 10 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep10_00.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep10_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep10_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep10_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep10_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep10_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep10_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "FILES" "7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD424" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "" "Saga 2 Ep 1 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE1" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE2" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE3" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE4" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE5" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE6" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE7" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_07.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE8" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_08.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE9" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_09.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE10" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_10.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE11" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_11.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE12" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_12.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE13" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_13.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE14" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_14.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE15" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_14_1.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE16" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_15.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE17" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_16.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE18" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_17.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE19" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_18.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE20" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_19.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE21" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_20.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE22" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_21.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE23" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_22.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE24" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_23.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE25" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_24.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE26" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_25.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE27" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_26.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE28" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_27.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE29" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_28.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE30" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_29.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE31" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_30.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE32" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_31.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE33" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_start01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILE34" "\data\db\cutscene\drama\cutscene_dramairia_ep1_1_start02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "FILES" "34"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD425" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD426" "" "Saga 2 Ep 2 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD426" "FILE1" "\data\db\cutscene\drama2\cutscene_dramairia2_ep2_start.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD426" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD426" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD426" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "" "Saga 2 Ep 3 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE1" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE2" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE3" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE4" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE5" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE6" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE7" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_07.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE8" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_08.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE9" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_09.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE10" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_10.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE11" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_11.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE12" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_12.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILE13" "\data\db\cutscene\drama2\cutscene_dramairia2_ep3_start.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "FILES" "13"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD427" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "" "Saga 2 Ep 4 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILE1" "\data\db\cutscene\drama2\cutscene_dramairia2_ep4_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILE2" "\data\db\cutscene\drama2\cutscene_dramairia2_ep4_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILE3" "\data\db\cutscene\drama2\cutscene_dramairia2_ep4_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILE4" "\data\db\cutscene\drama2\cutscene_dramairia2_ep4_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILE5" "\data\db\cutscene\drama2\cutscene_dramairia2_ep4_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILE6" "\data\db\cutscene\drama2\cutscene_dramairia2_ep4_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILE7" "\data\db\cutscene\drama2\cutscene_dramairia2_ep4_07.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILE8" "\data\db\cutscene\drama2\cutscene_dramairia2_ep4_08.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILE9" "\data\db\cutscene\drama2\cutscene_dramairia2_ep4_start.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "FILES" "9"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD428" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "" "Saga 2 Ep 5 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE1" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE2" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE3" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE4" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE5" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE6" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE7" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_07.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE8" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_08.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE9" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_09.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE10" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_10.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE11" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_11.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILE12" "\data\db\cutscene\drama2\cutscene_dramairia2_ep5_start.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "FILES" "12"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD429" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "" "Saga 2 Ep 6 Cutscene Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE1" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE2" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE3" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE4" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_04.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE5" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_05.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE6" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_06.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE7" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_07.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE8" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_08.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE9" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_09.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE10" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_10.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE11" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_start.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILE12" "\data\db\cutscene\drama2\cutscene_dramairia2_ep6_start_2.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "FILES" "12"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD430" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD60" "" "Paladin Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD60" "FILE1" "\data\db\cutscene\cutscene_paladin_change.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD60" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD60" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD60" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD61" "" "Dark Knight Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD61" "FILE1" "\data\db\cutscene\cutscene_darknight_change.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD61" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD61" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD61" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD62" "" "Waterfall Drop Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD62" "FILE1" "\data\db\cutscene\cutscene_waterfall.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD62" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD62" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD62" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD63" "" "Boss Cutscene Removals Group 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD63" "FILE1" "\data\db\cutscene\cutscene_bossroom_event.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD63" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD63" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD63" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD64" "" "Boss Cutscene Removals Group 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD64" "FILE1" "\data\db\cutscene\cutscene_bossroom_event2.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD64" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD64" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD64" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD65" "" "Boss Cutscene Removals Group 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD65" "FILE1" "\data\db\cutscene\cutscene_bossroom_event3.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD65" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD65" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD65" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD66" "" "Boss Cutscene Removals Group 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD66" "FILE1" "\data\db\cutscene\cutscene_bossroom_event4.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD66" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD66" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD66" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD67" "" "Boss Cutscene Removals Group 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD67" "FILE1" "\data\db\cutscene\cutscene_bossroom_event5.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD67" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD67" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD67" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD68" "" "Elven Fire Magic Missile Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD68" "FILE1" "\data\db\cutscene\cutscene_elvenmissile_fire.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD68" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD68" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD68" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD69" "" "Elven Ice Magic Missile Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD69" "FILE1" "\data\db\cutscene\cutscene_elvenmissile_ice.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD69" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD69" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD69" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD70" "" "Elven Lightning Magic Missile Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD70" "FILE1" "\data\db\cutscene\cutscene_elvenmissile_light.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD70" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD70" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD70" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD71" "" "Giant Full Swing Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD71" "FILE1" "\data\db\cutscene\cutscene_giant_fullswing.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD71" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD71" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD71" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72" "" "Japari Bus Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72" "FILE1" "\data\sound\kmn\2020_kmn_boost.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72" "FILE2" "\data\sound\kmn\2020_kmn_run.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72" "FILE3" "\data\sound\kmn\2020_kmn_summon.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72" "FILES" "3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72" "DESCRIPTION" " Mute Japari Bus Sound"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?1" "" "Japari Bus Sound Removal ?1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?1" "FILE1" "\data\sound\kmn\2020_kmn_boost.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?1" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?1" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?1" "DESCRIPTION" "Mute data\sound\kmn\2020_kmn_boost.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?2" "" "Japari Bus Sound Removal ?2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?2" "FILE1" "\data\sound\kmn\2020_kmn_run.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?2" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?2" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?2" "DESCRIPTION" "Mute data\sound\kmn\2020_kmn_run.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?3" "" "Japari Bus Sound Removal ?3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?3" "FILE1" "\data\sound\kmn\2020_kmn_summon.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?3" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?3" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD72?3" "DESCRIPTION" "Mute data\sound\kmn\2020_kmn_summon.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD73" "" "Feth Indicator"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD73" "FILE1" "\data\gfx\fx\effect\C5_doll_effect.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD73" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD73" "CREATOR" "Pot & extraterrestrial"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD73" "DESCRIPTION" "Changes the color of the indicator to bright yellow and raises y-axis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD74" "" "Shadow Mission Boards"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD74" "FILE1" "\data\world\taillteann_main_field\_taillteann_main_field_0018.area"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD74" "FILE2" "\data\world\Tara_main_field\_Tara_main_field_0013.area"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD74" "FILES" "2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD74" "CREATOR" "poidoe"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD74" "DESCRIPTION" "Adds boards closer to shadow missions"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD444" "" "Peaca Dungeon Master Lich Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD444" "FILE1" "\data\db\cutscene\bossroom_peaca_masterlich.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD444" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD444" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD444" "DESCRIPTION" "Removes Master Lich Cutscene"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD445" "" "Peaca-Coil Abyss and G19 Boss Room Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD445" "FILE1" "\data\db\cutscene\bossroom_peaca_masterlich.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD445" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD445" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD445" "DESCRIPTION" "Removes Peaca-Coil Abyss and G19 Boss Room Cutscenes"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD446" "" "G19 Renovation Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD446" "FILE1" "\data\db\cutscene\cutscene_g19_renovation.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD446" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD446" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD446" "DESCRIPTION" "Removes G19 Renovation Cutscenes"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD447" "" "Alby Hard Mode Arachne Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD447" "FILE1" "\data\db\cutscene\c2\bossroom_hardmode_albi_arachne.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD447" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD447" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD447" "DESCRIPTION" "Removes Alby Hard Mode Arachne Cutscene Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD80" "" "Trade Imp Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD80" "FILE1" "\data\db\layout2\commerce\ImpView.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD80" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD80" "CREATOR" "Trivaloso"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD80" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD81" "" "Lib-Loader"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD81" "FILE1" "nps64.dll"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD81" "FILE2" "nps64.dat"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD81" "FILE3" "Loader.cfg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD81" "FILES" "3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD81" "CREATOR" "Rii"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD81" "DESCRIPTION" "Chain load multiple DLL when starting mabinogi"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD82" "" "Doppel collection removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD82" "FILE1" "\data\db\layout2\skill\SkillReadyView.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD82" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD82" "CREATOR" "hiesavel"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD82" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD83" "" "Skill Sidebar Minimize"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD83" "FILE1" "\data\db\layout2\skill\SkillSideBar.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD83" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD83" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD83" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD84" "" "Show Ping in the Menu 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD84" "FILE1" "\data\db\layout2\SystemMenu.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD84" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD84" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD84" "DESCRIPTION" "Shows Ping in Menu Green, Yellow, Red Box"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD85" "" "Always noon sky 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD85" "FILE1" "\data\db\renderer_resource.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD85" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD85" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD85" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD86" "" "Autoproduction Uncaps"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD86" "FILE1" "\data\db\production.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD86" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD86" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD86" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD87" "" "Bandit Spotter 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD87" "FILE1" "\data\db\commercecommon.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD87" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD87" "CREATOR" "Fl0rn, ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD87" "DESCRIPTION" "Increases volume of Bandit Detection"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD88" "" "Bandit Spotter 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD88" "FILE1" "\data\db\npcclientappearance.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD88" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD88" "CREATOR" "Fl0rn, Draconis, poidoe"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD88" "DESCRIPTION" "Makes Bandits appear on the minimap"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "" "Bandit Spotter 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "FILE1" "\data\gfx\char\human\male\helmet\male_theater01_paper_h01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "FILE2" "\data\gfx\char\human\male\helmet\male_theater03_paper_h01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "FILE3" "\data\gfx\char\human\male\helmet\male_theater04_paper_h01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "FILE4" "\data\gfx\fx\effect\my_effect_52baka.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "FILE5" "\data\material\fx\effect\common_effect_add_8_52baka.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "FILE6" "\data\material\fx\effect\common_effect_add_9_52baka.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "FILE7" "\data\material\_define\material\effect\mat_effect_custom_52baka.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "FILES" "7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "CREATOR" "hodgepodge, poidoe"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD299" "DESCRIPTION" "Makes Bandits easier to see"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD89" "" "Dark Knight Sound"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD89" "FILE1" "\data\db\animationevent.anievent"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD89" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD89" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD89" "DESCRIPTION" "Dark Knight Sound"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD90" "" "Dungeon Fog Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD90" "FILE1" "\data\db\dungeon_ruin.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD90" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD90" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD90" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD91" "" "Dungeon Fog Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD91" "FILE1" "\data\db\dungeondb.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD91" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD91" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD91" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD92" "" "Dungeon Fog Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD92" "FILE1" "\data\db\dungeondb2.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD92" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD92" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD92" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD93" "" "Fragmentation Autoproduction Uncap"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD93" "FILE1" "\data\db\dissolution.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD93" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD93" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD93" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD94" "" "Iria Dungeon/Underground Tunnel Fog Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD94" "FILE1" "\data\db\minimapinfo.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD94" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD94" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD94" "DESCRIPTION" "Removes Iria Dungeon/Underground Tunnel fog from minimap"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD95" "" "Iria Underground Tunnel Field of View"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD95" "FILE1" "\data\db\UndergroundMaze.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD95" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD95" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD95" "DESCRIPTION" "Increases Iria Underground Tunnel Field of View"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD96" "" "Show Prop Names 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD96" "FILE1" "\data\db\propdb.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD96" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD96" "CREATOR" "Amaretto & ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD96" "DESCRIPTION" "Show Crop, Metallurgy, and Sulfur Names; Remove Statue Names"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD97" "" "Vertical Flight Speed"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD97" "FILE1" "\data\db\aircraftdesc.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD97" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD97" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD97" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98" "" "View Deadly as Red Glow-Mana Shield as Blue Glow-etc"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98" "FILE1" "\data\db\charactercondition.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98" "CREATOR" "Phy, Marck, ShaggyZE, Draconis, Fl0rn, Chacha & more"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98" "DESCRIPTION" "Changes several character condition colors when performing skills"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?1" "" "View Deadly as Red Glow-Mana Shield as Blue Glow-etc ?1"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?1" "FILE1" "\data\db\charactercondition.xml"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?1" "FILES" "1"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?1" "CREATOR" "Marck, ShaggyZE, Draconis, Fl0rn, Chacha & Xeme"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?1" "DESCRIPTION" "Changes several character condition colors and icons when performing skills"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?2" "" "View Deadly as Red Glow-Mana Shield as Blue Glow-etc ?2"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?2" "FILE1" "\data\gfx\image\gui_condition_custom.dds"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?2" "FILES" "1"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?2" "CREATOR" "Chacha"
;WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD98?2" "DESCRIPTION" "Adds chain burst character condition icon"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD99" "" "Simplify Crystal Deer"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD99" "FILE1" "\data\gfx\char\chapter4\pet\anim\crystal_rudolf\pet_crystal_rudolf_ice_storm.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD99" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD99" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD99" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD100" "" "Simplify Fire Dragon"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD100" "FILE1" "\data\gfx\char\chapter4\pet\anim\dragon\pet_firedragon_summon.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD100" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD100" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD100" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD101" "" "Simplify Ice Dragon 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD101" "FILE1" "\data\gfx\char\chapter4\pet\anim\dragon\pet_icedragon_summon.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD101" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD101" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD101" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD102" "" "Simplify Thunder Dragon"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD102" "FILE1" "\data\gfx\char\chapter4\pet\anim\dragon\pet_thunderdragon_summon.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD102" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD102" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD102" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD103" "" "Simplify Thunder Dragon (two seater)"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD103" "FILE1" "\data\gfx\char\chapter4\pet\anim\dragon\pet_thunderdragon_two_summon.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD103" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD103" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD103" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD104" "" "Simplify Flamemare"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD104" "FILE1" "\data\gfx\char\chapter4\pet\anim\flamemare\pet_flamemare_firestorm.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD104" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD104" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD104" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD105" "" "Simplify Ice Dragon 2 (framework)"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD105" "FILE1" "\data\gfx\char\chapter4\pet\mesh\dragon\pet_c4_icedragon_framework.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD105" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD105" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD105" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD106" "" "Invisible Female Giant Minimization Fix 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD106" "FILE1" "\data\gfx\char\giant\female\mentle\giant_female_dummy_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD106" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD106" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD107" "DESCRIPTION" "Turn Robes Transparent when Character Minimization is On"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD107" "" "Invisible Female Giant Minimization Fix 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD107" "FILE1" "\data\gfx\char\giant\male\mentle\giant_male_dummy_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD107" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD107" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD107" "DESCRIPTION" "Turn Robes Transparent when Character Minimization is On"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD108" "" "Alternate Success Animation"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD108" "FILE1" "\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_success.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD108" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD108" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD108" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD109" "" "Alternate Fail Animation"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD109" "FILE1" "\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_Fail_short.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD109" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD109" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD109" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD110" "" "Alternate Success Animation File"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD110" "FILE1" "\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_success.mov"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD110" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD110" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD110" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD111" "" "Alternate Fail Animation File"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD111" "FILE1" "\data\gfx\char\human\anim\emotion\uni_natural_emotion_skill_Fail_short.mov"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD111" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD111" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD111" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD112" "" "Herb Gathering Animation Replacement"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD112" "FILE1" "\data\gfx\char\human\anim\uni_natural_gathering_eggs.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD112" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD112" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD112" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD113" "" "Invisible Female Human Minimization Fix"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD113" "FILE1" "\data\gfx\char\human\female\mantle\female_dummy_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD113" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD113" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD114" "DESCRIPTION" "Turn Robes Transparent when Character Minimization is On"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD114" "" "Invisible Male Human Minimization Fix"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD114" "FILE1" "\data\gfx\char\human\male\mantle\male_dummy_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD114" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD114" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD114" "DESCRIPTION" "Turn Robes Transparent when Character Minimization is On"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD115" "" "L-rod Glow Enhancement 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD115" "FILE1" "\data\gfx\char\human\tool\tool_lroad_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD115" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD115" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD115" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD116" "" "L-rod Glow Enhancement 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD116" "FILE1" "\data\gfx\char\human\tool\tool_lroad_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD116" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD116" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD116" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD117" "" "L-rod Glow Enhancement 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD117" "FILE1" "\data\gfx\char\human\tool\tool_lroad_03.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD117" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD117" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD117" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD118" "" "Item Drop Animation Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD118" "FILE1" "\data\gfx\char\item\anim\item_appear.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD118" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD118" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD118" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD119" "" "Item Drop Animation Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD119" "FILE1" "\data\gfx\char\item\anim\item_appear02.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD119" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD119" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD119" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD120" "" "Item Drop Animation Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD120" "FILE1" "\data\gfx\char\item\anim\item_appear_From_prop.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD120" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD120" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD120" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD121" "" "Item Drop Animation Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD121" "FILE1" "\data\gfx\char\item\anim\item_appear02_From_prop.ani"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD121" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD121" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD121" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD122" "" "Huge Boss Keys 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD122" "FILE1" "\data\gfx\char\item\mesh\item_bosskey_001.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD122" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD122" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD122" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD123" "" "Huge Boss Keys 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD123" "FILE1" "\data\gfx\char\item\mesh\item_bosskey_002.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD123" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD123" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD123" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD124" "" "Huge Treasure Keys 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD124" "FILE1" "\data\gfx\char\item\mesh\item_boxkey_001.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD124" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD124" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD124" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD125" "" "Huge Room Keys 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD125" "FILE1" "\data\gfx\char\item\mesh\item_roomkey_001.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD125" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD125" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD125" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD126" "" "Huge Mushrooms"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD126" "FILE1" "\data\gfx\char\item\mesh\prop_mushroom01_i.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD126" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD126" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD126" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD127" "" "Huge Gold Mushrooms"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD127" "FILE1" "\data\gfx\char\item\mesh\prop_mushroom02_i.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD127" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD127" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD127" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD128" "" "Huge Poison Mushrooms"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD128" "FILE1" "\data\gfx\char\item\mesh\prop_mushroom03_i.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD128" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD128" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD128" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD129" "" "Mimic Differentiation 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD129" "FILE1" "\data\gfx\char\monster\mesh\mimic\mimic01_mesh.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD129" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD129" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD129" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD130" "" "Mimic Differentiation 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD130" "FILE1" "\data\gfx\char\monster\mesh\mimic\mimic02_mesh.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD130" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD130" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD130" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD131" "" "Mimic Differentiation 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD131" "FILE1" "\data\gfx\char\monster\mesh\mimic\mimic03_mesh.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD131" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD131" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD131" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD132" "" "Mimic Differentiation 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD132" "FILE1" "\data\gfx\char\monster\mesh\mimic\mimic04_mesh.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD132" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD132" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD132" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD133" "" "Mimic Differentiation 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD133" "FILE1" "\data\gfx\char\monster\mesh\mimic\mimic05_mesh.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD133" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD133" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD133" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD134" "" "Mimic Differentiation 6"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD134" "FILE1" "\data\gfx\char\monster\mesh\mimic\mimic06_mesh.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD134" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD134" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD134" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "" "Always noon sky 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE1" "\data\gfx\fx\atmosphere\timetable_clear.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE2" "\data\gfx\fx\atmosphere\timetable_clear_taillteann.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE3" "\data\gfx\fx\atmosphere\timetable_cloudy.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE4" "\data\gfx\fx\atmosphere\timetable_cloudy_taillteann.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE5" "\data\gfx\fx\atmosphere\timetable_iria_sandstorm.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE6" "\data\gfx\fx\atmosphere\timetable_iria_snowstorm.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE7" "\data\gfx\fx\atmosphere\timetable_iria_zardine.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE8" "\data\gfx\fx\atmosphere\timetable_lightning.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE9" "\data\gfx\fx\atmosphere\timetable_lightning_taillteann.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE10" "\data\gfx\fx\atmosphere\timetable_otherworld_darkfog.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE11" "\data\gfx\fx\atmosphere\timetable_physis_clear.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE12" "\data\gfx\fx\atmosphere\timetable_physis_cloudy.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE13" "\data\gfx\fx\atmosphere\timetable_physis_lightning.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE14" "\data\gfx\fx\atmosphere\timetable_physis_rainy.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE15" "\data\gfx\fx\atmosphere\timetable_rainy.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE16" "\data\gfx\fx\atmosphere\timetable_rainy_taillteann.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILE17" "\data\gfx\fx\atmosphere\timetable_skatha.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "FILES" "17"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD135" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD136" "" "Alchemist FlameBurst Simplify"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD136" "FILE1" "\data\gfx\fx\effect\c3_g9_s2_fireflame.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD136" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD136" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD136" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD137" "" "Rain Casting Range and Duration Indicator"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD137" "FILE1" "\data\gfx\fx\effect\c3_g10_s1_cloud.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD137" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD137" "CREATOR" "Tekashi, Chocobubba & poidoe"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD137" "DESCRIPTION" "removes clouds/rain/snow effect and draws a large circle on the ground."
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD138" "" "Alchemist Shock Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD138" "FILE1" "\data\gfx\fx\effect\c3_g11_s1_others.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD138" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD138" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD138" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD139" "" "Remove Rain, Sand and Snow 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD139" "FILE1" "\data\gfx\fx\effect\c2_g6_s1_snowfield.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD139" "FILE2" "\data\gfx\fx\effect\effect_weather_rain.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD139" "FILE3" "\data\gfx\fx\effect\effect_weather_snow.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD139" "FILE4" "\data\gfx\fx\effect\fx_g5_fieldeffect.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD139" "FILES" "4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD139" "CREATOR" "Halfslashed"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD139" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD140" "" "Enables L-rod Light Effect"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD140" "FILE1" "\data\gfx\fx\effect\fx_c2_ruins.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD140" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD140" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD140" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "" "Pet Summon Effect Removals"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "FILE1" "\data\gfx\fx\effect\c2_g6_pet_snowfield.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "FILE2" "\data\gfx\fx\effect\c4_g14_s3_fire_horse.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "FILE3" "\data\gfx\fx\effect\c4_g14_s3_fire_horse_black.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "FILE4" "\data\gfx\fx\effect\c4_g14_s3_fire_horse_cyan.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "FILE5" "\data\gfx\fx\effect\c4_g14_s3_fire_horse_white.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "FILE6" "\data\gfx\fx\effect\c4_g16_pet_ice_dragon.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "FILE7" "\data\gfx\fx\effect\pet_dragon_fire.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "FILE8" "\data\gfx\fx\effect\pet_dragon_thunder.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "FILES" "8"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD141" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD142" "" "Sulfur Spider Dust Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD142" "FILE1" "\data\gfx\fx\effect\c3_g9_s2_monster_spider12.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD142" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD142" "CREATOR" "Tekashi"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD142" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD143" "" "Disable Fireball Shaking and Increase Ego Glow Effect"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD143" "FILE1" "\data\gfx\fx\posteffect\blur.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD143" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD143" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD143" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD144" "" "Nexon Logo Change 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD144" "FILE1" "\data\gfx\gui\login_screen\intro_nexon_logo_256x256.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD144" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD144" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD144" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD145" "" "Nexon Logo Change 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD145" "FILE1" "\data\gfx\gui\login_screen\login_Logo_US.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD145" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD145" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD145" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD146" "FILE1" "\data\gfx\gui\login_screen\login_Logo_US.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD146" "" "Nexon Logo Change 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD146" "FILE1" "\data\gfx\gui\login_screen\login_copyright03_kr_w.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD146" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD146" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD146" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD147" "" "Modded Rano Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD147" "FILE1" "\data\gfx\gui\map_jpg\minimap_Iria_Rano_new_mgFree_2021_kor.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD147" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD147" "CREATOR" "Arcane & kirbysama"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD147" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD148" "" "Modded Solea North Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD148" "FILE1" "\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_n_eng.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD148" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD148" "CREATOR" "Tera"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD148" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD149" "" "Modded Solea South Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD149" "FILE1" "\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_s_eng.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD149" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD149" "CREATOR" "Tera"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD149" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD150" "" "Modded Connous Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD150" "FILE1" "\data\gfx\gui\map_jpg\minimap_Iria_connous_mgFree_2021_kor.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD150" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD150" "CREATOR" "Arcane & kirbysama"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD150" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD151" "" "Modded Ant Hell Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD151" "FILE1" "\data\gfx\gui\map_jpg\minimap_iria_connous_underworld.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD151" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD151" "CREATOR" "Arcane & kirbysama"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD151" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD152" "" "Modded Courcle Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD152" "FILE1" "\data\gfx\gui\map_jpg\minimap_Iria_courcle_mgFree_2021_kor.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD152" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD152" "CREATOR" "Arcane & kirbysama"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD152" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD153" "" "Modded Physis Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD153" "FILE1" "\data\gfx\gui\map_jpg\minimap_Iria_Physis_mgFree_2021_kor.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD153" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD153" "CREATOR" "Arcane & kirbysama"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD153" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD154" "" "Modded Shadow Realm Abb Neagh Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD154" "FILE1" "\data\gfx\gui\map_jpg\minimap_taillteann_abb_neagh_mgfree_eng.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD154" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD154" "CREATOR" "Rydian"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD154" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD155" "" "Modded Shadow Realm Taillteann Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD155" "FILE1" "\data\gfx\gui\map_jpg\minimap_taillteann_eng_rep.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD155" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD155" "CREATOR" "Rydian"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD155" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD156" "" "Modded Shadow Realm Sliab Cuilin Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD156" "FILE1" "\data\gfx\gui\map_jpg\minimap_taillteann_sliab_cuilin_eng_rep.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD156" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD156" "CREATOR" "Rydian"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD156" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD157" "" "Modded Shadow Realm Corrib Glenn Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD157" "FILE1" "\data\gfx\gui\map_jpg\minimap_tara_n_field_eng_rep.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD157" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD157" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD157" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD158" "" "Modded Shadow Realm Tara Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD158" "FILE1" "\data\gfx\gui\map_jpg\minimap_tara_eng_rep.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD158" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD158" "CREATOR" "Rydian"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD158" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD159" "" "Modded Rath Castle 1F Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD159" "FILE1" "\data\gfx\gui\map_jpg\minimap_tara_castle_1f_eng_rep.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD159" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD159" "CREATOR" "Rydian"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD159" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD160" "" "Modded Qilla Beach Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD160" "FILE1" "\data\gfx\gui\map_jpg\minimap_iria_rano_qilla_mgfree_eng.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD160" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD160" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD160" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD161" "" "Modded Sen Mag Map"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD161" "FILE1" "\data\gfx\gui\map_jpg\minimap_senmag_mgfree_eng.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD161" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD161" "CREATOR" "Arcane & kirbysama"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD161" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD162" "" "Modded Sen Mag Map 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD162" "FILE1" "\data\gfx\gui\map_jpg\minimap_senmag_eng.jpg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD162" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD162" "CREATOR" "Arcane & kirbysama"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD162" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD163" "" "Blacksmith Minigame Simplification"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD163" "FILE1" "\data\gfx\gui\blacksmith.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD163" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD163" "CREATOR" "CLY"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD163" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD164" "" "Tailoring Minigame Simplification 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD164" "FILE1" "\data\gfx\gui\tailoring.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD164" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD164" "CREATOR" "CLY"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD164" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD165" "" "Tailoring Minigame Simplification 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD165" "FILE1" "\data\gfx\gui\tailoring_2.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD165" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD165" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD165" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD166" "" "Bitmap Font Outline Fix"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD166" "FILE1" "\data\gfx\gui\font_eng.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD166" "FILE2" "\data\gfx\gui\font_outline_eng.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD166" "FILES" "2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD166" "CREATOR" "Rydian"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD166" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD167" "" "Trade Imp Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD167" "FILE1" "\data\gfx\gui\trading_ui\gui_trading_state.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD167" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD167" "CREATOR" "akeno"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD167" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD442" "" "Bounty Hunting Interface Buttons Fix"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD442" "FILE1" "\data\gfx\gui\trading_ui\gui_trading_state2.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD442" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD442" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD442" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD168" "" "Screenshot Watermark Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD168" "FILE1" "\data\gfx\image\copyright_usa.raw"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD168" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD168" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD168" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD169" "" "Turquoise Mythril Ingots"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD169" "FILE1" "\data\gfx\image\item_mythril_ingot.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD169" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD169" "CREATOR" "The Proffessor"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD169" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD170" "" "Turquoise Mythril Plates"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD170" "FILE1" "\data\gfx\image\item_mythril_metalplate.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD170" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD170" "CREATOR" "The Proffessor"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD170" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD171" "" "Turquoise Mythril Bars"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD171" "FILE1" "\data\gfx\image\item_mythril_metalsolder.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD171" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD171" "CREATOR" "The Proffessor"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD171" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD172" "" "Turquoise Mythril Ore Fragments"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD172" "FILE1" "\data\gfx\image\item_mythril_mineral_Fragment.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD172" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD172" "CREATOR" "The Proffessor"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD172" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD173" "" "Turquoise Mythril Ore"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD173" "FILE1" "\data\gfx\image\item_mythril_mineral_small.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD173" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD173" "CREATOR" "The Proffessor"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD173" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD174" "" "Purple Unknown Ore Fragments"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD174" "FILE1" "\data\gfx\image\item_unknown_mineral_small.dds"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD174" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD174" "CREATOR" "The Proffessor"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD174" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD175" "" "Theater Dungeon Fog Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD175" "FILE1" "\data\gfx\scene\avon\dungeon\dg_avon_stage_fog_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD175" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD175" "CREATOR" "Synesthesia"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD175" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "" "Belfast Delagger 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE1" "\data\gfx\scene\belfast\building\scene_building_belfast_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE2" "\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE3" "\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE4" "\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE5" "\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_05.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE6" "\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_06.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE7" "\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_07.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE8" "\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_08.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE9" "\data\gfx\scene\belfast\building\scene_building_belfast_lawcourt_09.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILE10" "\data\gfx\scene\belfast\building\scene_building_belfast_wall01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "FILES" "10"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD176" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "" "Belfast Delagger 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE1" "\data\gfx\scene\belfast\prop\scene_building_belfast_bank_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE2" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_arch_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE3" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_ceiling_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE4" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE5" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE6" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE7" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE8" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_05.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE9" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_06.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE10" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_07.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE11" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_column_08.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE12" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_entrance_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE13" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bank_wall_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE14" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE15" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE16" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag01_rotate.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE17" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE18" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag02_rotate.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE19" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE20" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_flag03_rotate.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE21" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_light.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE22" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigship_rotate.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE23" "\data\gfx\scene\belfast\prop\scene_prop_belfast_bigsign_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE24" "\data\gfx\scene\belfast\prop\scene_prop_belfast_church00.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE25" "\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE26" "\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE27" "\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE28" "\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE29" "\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff05.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE30" "\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff06.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE31" "\data\gfx\scene\belfast\prop\scene_prop_belfast_cliff07.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE32" "\data\gfx\scene\belfast\prop\scene_prop_belfast_cliffstone_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE33" "\data\gfx\scene\belfast\prop\scene_prop_belfast_cliffstone_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE34" "\data\gfx\scene\belfast\prop\scene_prop_belfast_flowerbed00.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE35" "\data\gfx\scene\belfast\prop\scene_prop_belfast_grassdry00.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE36" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE37" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_1.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE38" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_2.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE39" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_3.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE40" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_4.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE41" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_5.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE42" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house_02_6.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE43" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE44" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house01_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE45" "\data\gfx\scene\belfast\prop\scene_prop_belfast_house01_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE46" "\data\gfx\scene\belfast\prop\scene_prop_belfast_lighthouse_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE47" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE48" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE49" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE50" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE51" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_05.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE52" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_06.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE53" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_07.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE54" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_08.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE55" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_09.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE56" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_10.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE57" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_11.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE58" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_12.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE59" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_13.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE60" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_14.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE61" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_15.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE62" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_16.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE63" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_bar02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE64" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_door01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE65" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_door02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE66" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_drugstore01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE67" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_drugstore02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE68" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_drugstore03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE69" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE70" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent01_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE71" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE72" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent02_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE73" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent03_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE74" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE75" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent04_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE76" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent05.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE77" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent05_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE78" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent06.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE79" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent06_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE80" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent07.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE81" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent07_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE82" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent08.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE83" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_tent08_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE84" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_weapon01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE85" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_weapon02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE86" "\data\gfx\scene\belfast\prop\scene_prop_belfast_market_weapon03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE87" "\data\gfx\scene\belfast\prop\scene_prop_belfast_ocean00.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE88" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_00.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE89" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE90" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE91" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE92" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE93" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_05.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE94" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_06.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE95" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_07.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE96" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_10.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE97" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_11.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE98" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_12.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE99" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_14.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE100" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_16.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE101" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_17.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE102" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_18.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE103" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_19.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE104" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_20.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE105" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_21.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE106" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_22.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE107" "\data\gfx\scene\belfast\prop\scene_prop_belfast_owenhouse_fountain.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE108" "\data\gfx\scene\belfast\prop\scene_prop_belfast_pirate ship_flagall.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE109" "\data\gfx\scene\belfast\prop\scene_prop_belfast_tombstone_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE110" "\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_cutscene00.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE111" "\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_flag01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE112" "\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_flag02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE113" "\data\gfx\scene\belfast\prop\scene_prop_belfast_tradeship_flag03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE114" "\data\gfx\scene\belfast\prop\scene_prop_belfast_tradingpost_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE115" "\data\gfx\scene\belfast\prop\scene_prop_belfast_wrecked_obj.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILE116" "\data\gfx\scene\belfast\prop\scene_prop_belfast_wrecked_obj01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "FILES" "116"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD177" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD178" "" "Huge Mushroom 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD178" "FILE1" "\data\gfx\scene\productionprop\scene_prop_mushroom_01_after.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD178" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD178" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD178" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD179" "" "Huge Mushroom 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD179" "FILE1" "\data\gfx\scene\productionprop\scene_prop_mushroom_01_before.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD179" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD179" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD179" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD180" "" "Huge Gold Mushroom 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD180" "FILE1" "\data\gfx\scene\productionprop\scene_prop_mushroom_02_after.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD180" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD180" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD180" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD181" "" "Huge Gold Mushroom 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD181" "FILE1" "\data\gfx\scene\productionprop\scene_prop_mushroom_02_before.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD181" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD181" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD181" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD182" "" "Huge Poison Mushroom 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD182" "FILE1" "\data\gfx\scene\productionprop\scene_prop_mushroom_03_after.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD182" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD182" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD182" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD183" "" "Huge Poison Mushroom 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD183" "FILE1" "\data\gfx\scene\productionprop\scene_prop_mushroom_03_before.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD183" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD183" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD183" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD184" "" "Barri Hallway Wall Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD184" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_alley1_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD184" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD184" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD184" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD185" "" "Barri Hallway Wall Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD185" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_alley2_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD185" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD185" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD185" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD186" "" "Barri Hallway Wall Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD186" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_alley2_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD186" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD186" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD186" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD187" "" "Barri Hallway Wall Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD187" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_alley3_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD187" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD187" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD187" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD188" "" "Barri Hallway Wall Removal 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD188" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_alley4_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD188" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD188" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD188" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD189" "" "Barri Room Wall Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD189" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_room1_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD189" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD189" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD189" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD190" "" "Barri Room Wall Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD190" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_room2_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD190" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD190" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD190" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD191" "" "Barri Room Wall Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD191" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_room2_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD191" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD191" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD191" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD192" "" "Barri Room Wall Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD192" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_room3_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD192" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD192" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD192" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD193" "" "Barri Room Wall Removal 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD193" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_room4_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD193" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD193" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD193" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD194" "" "Barri Boss Room Wall Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD194" "FILE1" "\data\gfx\scene\bangor\dungeon\dg_bangor_room_boss.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD194" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD194" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD194" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD195" "" "Fiodh-Coil Hallway Wall Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD195" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley1_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD195" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD195" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD195" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD196" "" "Fiodh-Coil Hallway Wall Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD196" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley2_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD196" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD196" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD196" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD197" "" "Fiodh-Coil Hallway Wall Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD197" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley2_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD197" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD197" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD197" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD198" "" "Fiodh-Coil Hallway Wall Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD198" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley3_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD198" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD198" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD198" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD199" "" "Fiodh-Coil Hallway Wall Removal 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD199" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_alley4_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD199" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD199" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD199" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD200" "" "Fiodh-Coil Room Wall Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD200" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room1_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD200" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD200" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD200" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD201" "" "Fiodh-Coil Room Wall Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD201" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room2_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD201" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD201" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD201" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD202" "" "Fiodh-Coil Room Wall Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD202" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room2_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD202" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD202" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD202" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD203" "" "Fiodh-Coil Room Wall Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD203" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room3_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD203" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD203" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD203" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD204" "" "Fiodh-Coil Boss Room Wall Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD204" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room_boss.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD204" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD204" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD204" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD443" "" "Fiodh-Coil Room Wall Removal 6"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD443" "FILE1" "\data\gfx\scene\dungeon\woodsruins\dg_woodsruins_room4_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD443" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD443" "CREATOR" "Draconis"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD443" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD205" "" "Unofficial Tiaras Moonshine Mod Readme"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD205" "FILE1" "\README.md"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD205" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD205" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD205" "DESCRIPTION" "Unofficial Tiaras Moonshine Mod Readme"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD206" "" "Runda Hallway Wall Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD206" "FILE1" "\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley1_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD206" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD206" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD206" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD207" "" "Runda Hallway Wall Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD207" "FILE1" "\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley2_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD207" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD207" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD207" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD208" "" "Runda Hallway Wall Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD208" "FILE1" "\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley2_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD208" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD208" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD208" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD209" "" "Runda Hallway Wall Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD209" "FILE1" "\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley3_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD209" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD209" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD209" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD210" "" "Runda Hallway Wall Removal 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD210" "FILE1" "\data\gfx\scene\emainmacha\dungeon\alley\dg_runda_alley4_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD210" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD210" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD210" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD211" "" "Runda Water Surface Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD211" "FILE1" "\data\gfx\scene\emainmacha\dungeon\room\dg_runda_watersurface.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD211" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD211" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD211" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD212" "" "Runda Room Wall Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD212" "FILE1" "\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room1_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD212" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD212" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD212" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD213" "" "Runda Room Wall Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD213" "FILE1" "\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room2_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD213" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD213" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD213" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD214" "" "Runda Room Wall Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD214" "FILE1" "\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room2_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD214" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD214" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD214" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD215" "" "Runda Room Wall Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD215" "FILE1" "\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room3_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD215" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD215" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD215" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD216" "" "Runda Room Wall Removal 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD216" "FILE1" "\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room4_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD216" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD216" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD216" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD217" "" "Runda Boss Room Wall Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD217" "FILE1" "\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room_boss.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD217" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD217" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD217" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD218" "" "Runda Siren Boss Room Wall Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD218" "FILE1" "\data\gfx\scene\emainmacha\dungeon\room\dg_runda_room_boss_siren.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD218" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD218" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD218" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD219" "" "Rano Plains Tree Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD219" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD219" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD219" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD219" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD220" "" "Rano Plains Tree Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD220" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD220" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD220" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD220" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD221" "" "Rano Plains Tree Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD221" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD221" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD221" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD221" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD222" "" "Rano Plains Tree Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD222" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_billboard_tree_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD222" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD222" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD222" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD223" "" "Rano Forest Tree Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD223" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_forest_tree_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD223" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD223" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD223" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD224" "" "Rano Forest Tree Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD224" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_forest_tree_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD224" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD224" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD224" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD225" "" "Rano Forest Tree Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD225" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_forest_tree_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD225" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD225" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD225" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD226" "" "Rano Cactus Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD226" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_cactus_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD226" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD226" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD226" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD227" "" "Rano Cactus Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD227" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_cactus_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD227" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD227" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD227" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD228" "" "Rano Fence Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD228" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_fence_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD228" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD228" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD228" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD229" "" "Rano Gateway Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD229" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_gateway_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD229" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD229" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD229" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD230" "" "Rano Grass Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD230" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD230" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD230" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD230" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD231" "" "Rano Grass Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD231" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD231" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD231" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD231" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD232" "" "Rano Grass Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD232" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD232" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD232" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD232" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD233" "" "Rano Grass Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD233" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD233" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD233" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD233" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD234" "" "Rano Grass Removal 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD234" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_05.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD234" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD234" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD234" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD235" "" "Rano Grass Removal 6"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD235" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_06.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD235" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD235" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD235" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD236" "" "Rano Grass Removal 7"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD236" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_07.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD236" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD236" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD236" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD237" "" "Rano Grass Removal 8"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD237" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_08.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD237" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD237" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD237" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD238" "" "Rano Grass Removal 9"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD238" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_09.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD238" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD238" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD238" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD239" "" "Rano Grass Removal 10"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD239" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_10.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD239" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD239" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD239" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD240" "" "Rano Grass Removal 11"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD240" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_grass_11.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD240" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD240" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD240" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD241" "" "Rano Miscellaneous Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD241" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_intentgoods_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD241" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD241" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD241" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD242" "" "Rano Miscellaneous Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD242" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_intentgoods_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD242" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD242" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD242" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD243" "" "Rano Rock Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD243" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_rock_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD243" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD243" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD243" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD244" "" "Rano Shrub Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD244" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_shrub_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD244" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD244" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD244" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD245" "" "Rano Stump Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD245" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_stump_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD245" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD245" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD245" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD246" "" "Rano Stump Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD246" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_stump_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD246" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD246" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD246" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD247" "" "Rano Tree Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD247" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD247" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD247" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD247" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD248" "" "Rano Tree Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD248" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD248" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD248" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD248" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD249" "" "Rano Tree Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD249" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD249" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD249" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD249" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD250" "" "Rano Tree Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD250" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD250" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD250" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD250" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD251" "" "Rano Tree Removal 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD251" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_05.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD251" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD251" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD251" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD252" "" "Rano Tree Removal 6"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD252" "FILE1" "\data\gfx\scene\iria\iria_sw\prop\scene_prop_iria_sw_tree_06.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD252" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD252" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD252" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD253" "" "Flower Taillteann Tree 1a"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD253" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD253" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD253" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD253" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD254" "" "Flower Taillteann Tree 1a2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD254" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a_rep.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD254" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD254" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD254" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD255" "" "Flower Taillteann Tree 1b"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD255" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_b.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD255" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD255" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD255" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD256" "" "Flower Taillteann Tree 2a"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD256" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_a.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD256" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD256" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD256" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD257" "" "Flower Taillteann Tree 2b"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD257" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_b.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD257" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD257" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD257" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD258" "" "Flower Taillteann Tree 2c"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD258" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_c.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD258" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD258" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD258" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD259" "" "Flower Taillteann Tree 3a"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD259" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_a.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD259" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD259" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD259" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD260" "" "Flower Taillteann Tree 3b"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD260" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_b.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD260" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD260" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD260" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD261" "" "Flower Taillteann Tree 4a"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD261" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_02_a.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD261" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD261" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD261" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD262" "" "Flower Taillteann Tree 4b"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD262" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_02_b.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD262" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD262" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD262" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD263" "" "Flower Taillteann Tree 5a"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD263" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_a.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD263" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD263" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD263" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD264" "" "Flower Taillteann Tree 5b"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD264" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_b.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD264" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD264" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD264" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD265" "" "Flower Taillteann Tree 1a Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD265" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD265" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD265" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD265" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD266" "" "Flower Taillteann Tree 1a2 Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD266" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_a_rep.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD266" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD266" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD266" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD267" "" "Flower Taillteann Tree 1b Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD267" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_01_b.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD267" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD267" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD267" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD268" "" "Flower Taillteann Tree 2a Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD268" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_a.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD268" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD268" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD268" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD269" "" "Flower Taillteann Tree 2b Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD269" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_b.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD269" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD269" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD269" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD270" "" "Flower Taillteann Tree 2c Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD270" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_02_c.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD270" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD270" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD270" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD271" "" "Flower Taillteann Tree 3a Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD271" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_a.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD271" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD271" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD271" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD272" "" "Flower Taillteann Tree 3b Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD272" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_tree_03_b.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD272" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD272" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD272" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD273" "" "Flower Taillteann Tree 4b Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD273" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_02_b.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD273" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD273" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD273" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD274" "" "Flower Taillteann Tree 5a Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD274" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_a.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD274" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD274" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD274" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD275" "" "Flower Taillteann Tree 5b Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD275" "FILE1" "\data\gfx\scene\field\taillteann\field_prop_taill_bgmash_tree_03_b.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD275" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD275" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD275" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "" "Taillteann houses into Ropes 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE1" "\data\gfx\scene\taillteann\prop\scene_building_taill_alchemist-house_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE2" "\data\gfx\scene\taillteann\prop\scene_building_taill_clothshop_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE3" "\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE4" "\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE5" "\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE6" "\data\gfx\scene\taillteann\prop\scene_building_taill_default_a_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE7" "\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE8" "\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE9" "\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE10" "\data\gfx\scene\taillteann\prop\scene_building_taill_default_b_02.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE11" "\data\gfx\scene\taillteann\prop\scene_building_taill_goods-store_01.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILE12" "\data\gfx\scene\taillteann\prop\scene_prop_taill_tree_01_b.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "FILES" "12"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "CREATOR" "mabiassist"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD276" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD277" "" "Flower Taillteann Tree 6a"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD277" "FILE1" "\data\gfx\scene\taillteann\prop\scene_prop_taill_tree_01_a.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD277" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD277" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD277" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD278" "" "Flower Taillteann Tree 6a Framework"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD278" "FILE1" "\data\gfx\scene\taillteann\prop\scene_prop_taill_tree_01_a.set"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD278" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD278" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD278" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD279" "" "Flower Taillteann Tree 7a"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD279" "FILE1" "\data\gfx\scene\taillteann\prop\scene_prop_taill_bgmesh_tree_01_a.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD279" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD279" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD279" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD280" "" "Flower Taillteann Tree 7b"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD280" "FILE1" "\data\gfx\scene\taillteann\prop\scene_prop_taill_bgmesh_tree_01_b.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD280" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD280" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD280" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "" "Tara houses into Ropes 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE1" "\data\gfx\scene\tara\building\scene_building_tara_bank_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE2" "\data\gfx\scene\tara\building\scene_building_tara_bank_floor.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE3" "\data\gfx\scene\tara\building\scene_building_tara_church_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE4" "\data\gfx\scene\tara\building\scene_building_tara_church_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE5" "\data\gfx\scene\tara\building\scene_building_tara_church_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE6" "\data\gfx\scene\tara\building\scene_building_tara_church_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE7" "\data\gfx\scene\tara\building\scene_building_tara_church_05.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE8" "\data\gfx\scene\tara\building\scene_building_tara_church_06.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE9" "\data\gfx\scene\tara\building\scene_building_tara_church_07.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE10" "\data\gfx\scene\tara\building\scene_building_tara_church_08.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE11" "\data\gfx\scene\tara\building\scene_building_tara_church_09.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE12" "\data\gfx\scene\tara\building\scene_building_tara_default_a_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE13" "\data\gfx\scene\tara\building\scene_building_tara_default_a_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE14" "\data\gfx\scene\tara\building\scene_building_tara_default_a_02_rev.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE15" "\data\gfx\scene\tara\building\scene_building_tara_default_a_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE16" "\data\gfx\scene\tara\building\scene_building_tara_default_a_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE17" "\data\gfx\scene\tara\building\scene_building_tara_default_b_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE18" "\data\gfx\scene\tara\building\scene_building_tara_default_b_01_rev.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE19" "\data\gfx\scene\tara\building\scene_building_tara_default_b_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE20" "\data\gfx\scene\tara\building\scene_building_tara_default_b_02_rev.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE21" "\data\gfx\scene\tara\building\scene_building_tara_default_b_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILE22" "\data\gfx\scene\tara\building\scene_building_tara_default_b_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "FILES" "22"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "CREATOR" "mabiassist"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD281" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "" "Tara houses into Ropes 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE1" "\data\gfx\scene\tara\prop\scene_building_tara_ departmententrance_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE2" "\data\gfx\scene\tara\prop\scene_building_tara_ department_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE3" "\data\gfx\scene\tara\prop\scene_building_tara_department_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE4" "\data\gfx\scene\tara\prop\scene_building_tara_department_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE5" "\data\gfx\scene\tara\prop\scene_building_tara_department_04.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE6" "\data\gfx\scene\tara\prop\scene_building_tara_department_clothshop_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE7" "\data\gfx\scene\tara\prop\scene_building_tara_department_functional_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE8" "\data\gfx\scene\tara\prop\scene_building_tara_department_functional_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE9" "\data\gfx\scene\tara\prop\scene_building_tara_department_functional_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILE10" "\data\gfx\scene\tara\prop\scene_prop_tara_sub_largegate_03.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "FILES" "10"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "CREATOR" "mabiassist"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD282" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD283" "" "Tara Tree Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD283" "FILE1" "\data\gfx\scene\tara\prop\scene_prop_tara_streettree_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD283" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD283" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD283" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD284" "" "Tara Tree Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD284" "FILE1" "\data\gfx\scene\tara\prop\scene_prop_tara_bgmash_tree_01.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD284" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD284" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD284" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD285" "" "Tara Tree Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD285" "FILE1" "\data\gfx\scene\tara\prop\scene_prop_tara_bgmash_tree_02.pmg"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD285" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD285" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD285" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD286" "" "Show Ping in the Menu 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD286" "FILE1" "\data\gfx\style\systemmenu.style.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD286" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD286" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD286" "DESCRIPTION" "Shows Ping in Menu Green, Yellow, Red Box"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD287" "" "Unfiltered Chat"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD287" "FILE1" "\data\locale\usa\filter\BlockChat.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD287" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD287" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD287" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD288" "" "Remove Window, Name, and Party Messages"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD288" "FILE1" "\data\code\interface.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD288" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD288" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD288" "DESCRIPTION" "Hide Window, Name, and Party Messages in Top Right Screen+See who is requesting Duel-Trade"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD289" "" "Remove Window, Name, and Party Messages 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD289" "FILE1" "\data\code\interface.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD289" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD289" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD289" "DESCRIPTION" "Hide Window, Name, and Party Messages in Top Right Screen+See who is requesting Duel-Trade"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD290" "" "Desc text for Cp Changersa"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD290" "FILE1" "\data\code\standard.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD290" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD290" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD290" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD291" "" "Desc text for Cp Changersb"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD291" "FILE1" "\data\code\standard.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD291" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD291" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD291" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD292" "" "Show Talent Level by Number"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD292" "FILE1" "\data\xml\talenttitle.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD292" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD292" "CREATOR" "step29"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD292" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD293" "" "Show Talent Level by Number 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD293" "FILE1" "\data\xml\talenttitle.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD293" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD293" "CREATOR" "step29"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD293" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD294" "" "Show Prop Names 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD294" "FILE1" "\data\xml\propdb.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD294" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD294" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD294" "DESCRIPTION" "Show Crop, Metallurgy, and Sulfur Names; Remove Statue Names"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD295" "" "Show Prop Names 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD295" "FILE1" "\data\xml\propdb.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD295" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD295" "CREATOR" "ShaggyZE"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD295" "DESCRIPTION" "Show Crop, Metallurgy, and Sulfur Names; Remove Statue Names"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD296" "" "Skeleton Squad Name Mod"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD296" "FILE1" "\data\xml\race.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD296" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD296" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD296" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD297" "" "Skeleton Squad Name Mod 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD297" "FILE1" "\data\xml\race.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD297" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD297" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD297" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD300" "" "True Fossil Names"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD300" "FILE1" "\data\xml\itemdb.english.txt"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD300" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD300" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD300" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD301" "" "True Fossil Names 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD301" "FILE1" "\data\db\itemdb.xml"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD301" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD301" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD301" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD302" "" "Cow Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD302" "FILE1" "\data\sound\cow_01.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD302" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD302" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD302" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD303" "" "Cow Attack Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD303" "FILE1" "\data\sound\cow_attack_01.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD303" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD303" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD303" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD304" "" "Edern Hammer Sound Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD304" "FILE1" "\data\sound\repair_1p01.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD304" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD304" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD304" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD305" "" "Edern Hammer Sound Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD305" "FILE1" "\data\sound\repair_1p02.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD305" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD305" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD305" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD306" "" "Edern Hammer Sound Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD306" "FILE1" "\data\sound\repair_fail01.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD306" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD306" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD306" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD307" "" "Edern Hammer Sound Removal 4"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD307" "FILE1" "\data\sound\repair_fail02.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD307" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD307" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD307" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD308" "" "Edern Hammer Sound Removal 5"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD308" "FILE1" "\data\sound\repair_full01.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD308" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD308" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD308" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD309" "" "Edern Hammer Sound Removal 6"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD309" "FILE1" "\data\sound\repair_full02.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD309" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD309" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD309" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD310" "" "Pig Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD310" "FILE1" "\data\sound\pig_01.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD310" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD310" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD310" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD311" "" "Pig Attack Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD311" "FILE1" "\data\sound\pig_attack_counter_01.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD311" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD311" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD311" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD312" "" "Pig Knockback Sound Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD312" "FILE1" "\data\sound\pig_blowaway.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD312" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD312" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD312" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD313" "" "Pig Knockback Sound Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD313" "FILE1" "\data\sound\pig_blowaway_1.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD313" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD313" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD313" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD314" "" "Pig Hit Sound Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD314" "FILE1" "\data\sound\pig_hita.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD314" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD314" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD314" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD315" "" "Pig Hit Sound Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD315" "FILE1" "\data\sound\pig_hita_1.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD315" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD315" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD315" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD316" "" "Pig Hit Sound Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD316" "FILE1" "\data\sound\pig_hitb.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD316" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD316" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD316" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD317" "" "Pig Passive Sound Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD317" "FILE1" "\data\sound\pig_stand_Friendly.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD317" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD317" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD317" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD318" "" "Pig Passive Sound Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD318" "FILE1" "\data\sound\pig_stand_Friendly_02.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD318" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD318" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD318" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD319" "" "Pig Combat Mode Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD319" "FILE1" "\data\sound\pig_stand_offensive_1.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD319" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD319" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD319" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD320" "" "Sheep Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD320" "FILE1" "\data\sound\sheep.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD320" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD320" "CREATOR" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD320" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD321" "" "Golem Attack Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD321" "FILE1" "\data\sound\golem01_walk.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD321" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD321" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD321" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD322" "" "Golem Shout Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD322" "FILE1" "\data\sound\golem01_woo.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD322" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD322" "CREATOR" "Amaretto"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD322" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD323" "" "Rain Sound Removal"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD323" "FILE1" "\data\sound\weather_raining.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD323" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD323" "CREATOR" "Bergauk"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD323" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD324" "" "Thunder Sound Removal 1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD324" "FILE1" "\data\sound\weather_thunder_0.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD324" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD324" "CREATOR" "Bergauk"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD324" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD325" "" "Thunder Sound Removal 2"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD325" "FILE1" "\data\sound\weather_thunder_1.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD325" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD325" "CREATOR" "Bergauk"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD325" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD326" "" "Thunder Sound Removal 3"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD326" "FILE1" "\data\sound\weather_thunder_2.wav"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD326" "FILES" "1"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD326" "CREATOR" "Bergauk"
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD326" "DESCRIPTION" ""
WriteRegStr HKLM "${REG_UNINSTALL}\Components\MOD327" "" "Thunder Sound Removal 4"
