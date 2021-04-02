; ########################################
; #      Graphical Installer for NSIS    #
; #        Version 3.2.01 (Julka)        #
; #       Copyright (c) 2006 - 2013      #
; #          unSigned Softworks          #
; #  http://www.graphical-installer.com  #
; #   http://www.unsigned-softworks.sk   #
; #      info@unsigned-softworks.sk      #
; ########################################

; Script generated with Graphical Installer Wizard

; Unique identifier of project
!define GRAPHICAL_INSTALLER_PROJECT_UID "{GraphicalInstaller-v2Example}"

; Include files for Graphical Installer functions
!include "${NSISDIR}\Graphical Installer\GraphicalInstaller_functions.nsh"

; Include files for Modern UI 2
!include "MUI2.nsh"

; Copyright message - Please do not remove it!
; This message will NOT be visible in created installer
!echo "Graphical Installer, v3.2.01 (Julka), Copyright (c) 2006 - 2013 unSigned Softworks. Wizard generated script file."

; HM NIS Edit Wizard common defines
!define PRODUCT_NAME "Graphical Installer RTL Languages Example"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_PUBLISHER "unSigned Softworks"
!define PRODUCT_WEB_SITE "http://www.unsigned-softworks.sk"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; ================================================================ 
;  Graphical settings are defined in file > Graphical Installer-v2Example.graphics.nsh <  
; ================================================================ 

Name "${PRODUCT_NAME}"
OutFile "RTLLanguagesExample.exe"
InstallDir "$PROGRAMFILES\Graphical Installer RTL Languages Example"
Caption "${PRODUCT_NAME}"
ShowInstDetails show
ShowUnInstDetails show
; Branding text
BrandingText " " ; No branding text

; ===================
;  Installer pages    
; ===================

; Comment out this line if You do not want to show confirm dialog when Cancel button is pressed
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE_3LINES
; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!define MUI_PAGE_CUSTOMFUNCTION_SHOW GraphicalInstallerRedraw
!insertmacro MUI_PAGE_LICENSE "..\..\readme.txt"
; UI for Installer and Uninstaller
ChangeUI all "${NSISDIR}\Graphical Installer\GraphicalInstaller_UI.exe"
XPStyle on
; Components page
!define MUI_PAGE_CUSTOMFUNCTION_SHOW GraphicalInstallerRedraw
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!define MUI_PAGE_CUSTOMFUNCTION_SHOW GraphicalInstallerRedraw
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!define MUI_PAGE_CUSTOMFUNCTION_SHOW GraphicalInstallerRedraw
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\GraphicalInstallerManual.chm"
!define FINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_PAGE_FINISH

; ===================
;  unInstaller pages 
; ===================
!define MUI_WELCOMEPAGE_TITLE_3LINES
!insertmacro MUI_UNPAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_SHOW un.GraphicalInstallerRedraw
!insertmacro MUI_UNPAGE_CONFIRM
!define MUI_PAGE_CUSTOMFUNCTION_SHOW un.GraphicalInstallerRedraw
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; ======================
;  Language settings       
; ======================
  !insertmacro MUI_LANGUAGE "English" ;first language is the default language
  !insertmacro MUI_LANGUAGE "French"
  !insertmacro MUI_LANGUAGE "German"
  !insertmacro MUI_LANGUAGE "Spanish"
  !insertmacro MUI_LANGUAGE "SpanishInternational"
  !insertmacro MUI_LANGUAGE "SimpChinese"
  !insertmacro MUI_LANGUAGE "TradChinese"
  !insertmacro MUI_LANGUAGE "Japanese"
  !insertmacro MUI_LANGUAGE "Korean"
  !insertmacro MUI_LANGUAGE "Italian"
  !insertmacro MUI_LANGUAGE "Dutch"
  !insertmacro MUI_LANGUAGE "Danish"
  !insertmacro MUI_LANGUAGE "Swedish"
  !insertmacro MUI_LANGUAGE "Norwegian"
  !insertmacro MUI_LANGUAGE "NorwegianNynorsk"
  !insertmacro MUI_LANGUAGE "Finnish"
  !insertmacro MUI_LANGUAGE "Greek"
  !insertmacro MUI_LANGUAGE "Russian"
  !insertmacro MUI_LANGUAGE "Portuguese"
  !insertmacro MUI_LANGUAGE "PortugueseBR"
  !insertmacro MUI_LANGUAGE "Polish"
  !insertmacro MUI_LANGUAGE "Ukrainian"
  !insertmacro MUI_LANGUAGE "Czech"
  !insertmacro MUI_LANGUAGE "Slovak"
  !insertmacro MUI_LANGUAGE "Croatian"
  !insertmacro MUI_LANGUAGE "Bulgarian"
  !insertmacro MUI_LANGUAGE "Hungarian"
  !insertmacro MUI_LANGUAGE "Thai"
  !insertmacro MUI_LANGUAGE "Romanian"
  !insertmacro MUI_LANGUAGE "Latvian"
  !insertmacro MUI_LANGUAGE "Macedonian"
  !insertmacro MUI_LANGUAGE "Estonian"
  !insertmacro MUI_LANGUAGE "Turkish"
  !insertmacro MUI_LANGUAGE "Lithuanian"
  !insertmacro MUI_LANGUAGE "Slovenian"
  !insertmacro MUI_LANGUAGE "Serbian"
  !insertmacro MUI_LANGUAGE "SerbianLatin"
  !insertmacro MUI_LANGUAGE "Arabic"
  !insertmacro MUI_LANGUAGE "Farsi"
  !insertmacro MUI_LANGUAGE "Hebrew"
  !insertmacro MUI_LANGUAGE "Indonesian"
  !insertmacro MUI_LANGUAGE "Mongolian"
  !insertmacro MUI_LANGUAGE "Luxembourgish"
  !insertmacro MUI_LANGUAGE "Albanian"
  !insertmacro MUI_LANGUAGE "Breton"
  !insertmacro MUI_LANGUAGE "Belarusian"
  !insertmacro MUI_LANGUAGE "Icelandic"
  !insertmacro MUI_LANGUAGE "Malay"
  !insertmacro MUI_LANGUAGE "Bosnian"
  !insertmacro MUI_LANGUAGE "Kurdish"
  !insertmacro MUI_LANGUAGE "Irish"
  !insertmacro MUI_LANGUAGE "Uzbek"
  !insertmacro MUI_LANGUAGE "Galician"
  !insertmacro MUI_LANGUAGE "Afrikaans"
  !insertmacro MUI_LANGUAGE "Catalan"
  !insertmacro MUI_LANGUAGE "Esperanto"

; sHOW ALL LANGUAGE
!define MUI_LANGDLL_ALWAYSSHOW
!define MUI_LANGDLL_ALLLANGUAGES

; Reserve files
!insertmacro MUI_RESERVEFILE_LANGDLL

; Include file for Graphical Installer language strings
!include "${NSISDIR}\Graphical Installer\GraphicalInstaller_translation.nsh"

;  Installers properties
VIProductVersion "3.0.0.1"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${PRODUCT_NAME}" 
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Graphical Installer. Copyright (c) 2006 - 2013 unSigned Softworks. All rights reserved. www.unsigned-softworks.sk/installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${PRODUCT_PUBLISHER}"  
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright (c) 2013 ${PRODUCT_PUBLISHER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${PRODUCT_NAME}" 
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${PRODUCT_VERSION}" 
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${PRODUCT_VERSION}" 
VIAddVersionKey /LANG=${LANG_ENGLISH} "InternalName" "Setup.exe"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Copyright (c) 2013 ${PRODUCT_PUBLISHER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "OriginalFilename" "Setup.exe"

; Language strings - captions of sections
LangString DESC_Section00 ${LANG_ENGLISH} " " ; No description
LangString DESC_Section01 ${LANG_ENGLISH} "RTL Languages Example"

; Show language selection dialog
Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd

; =================
;  Install Data
; =================

; Invisible section - required for proper initialization, do not delete this section!
Section "" Section00
  SectionIn RO
  SetDetailsPrint both
  DetailPrint "$(GraphicalInstallerInstallProgress)"
  SetDetailsView show

; Initialization of Install page
  !insertmacro GRAPHICAL_INSTALLER_INST_PAGE_INIT
SectionEnd

Section "MainSection" Section01
  SetOutPath "$INSTDIR"
  SetOverwrite on
  File "..\..\GraphicalInstallerManual.chm"
  File "Readme.txt"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function .onGUIEnd
; Unloading of GraphicalInstaller plug-in
  GraphicalInstaller::UnInitButtons
FunctionEnd


; Macro for components descriptions
!insertmacro GRAPHICAL_INSTALLER_FUNCTION_DESCRIPTION_BEGIN
  FindWindow $R0 "#32770" "" $HWNDPARENT
  GetDlgItem $R0 $R0 1043 ; Description item (must be added to the UI)
  ShowWindow $R0 ${SW_HIDE}
  ShowWindow $R0 ${SW_SHOW}
  !insertmacro GRAPHICAL_INSTALLER_DESCRIPTION_TEXT ${Section01} $(DESC_Section01)
  ShowWindow $R0 ${SW_HIDE}
!insertmacro GRAPHICAL_INSTALLER_FUNCTION_DESCRIPTION_END

; =============
; UnInstaller     
; =============

Section Uninstall
  SetDetailsPrint both
  DetailPrint "$(GraphicalInstallerUninstallProgress)"
  SetDetailsView show

; Initialization of Uninstall page
  !insertmacro GRAPHICAL_INSTALLER_INST_PAGE_INIT
  
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\GraphicalInstallerManual.chm"
  Delete "$INSTDIR\Readme.txt"

  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
  SetOutPath "$INSTDIR"
SectionEnd

Function un.onGUIEnd
; Unloading of GraphicalInstaller plug-in
  GraphicalInstaller::UnInitButtons
FunctionEnd
