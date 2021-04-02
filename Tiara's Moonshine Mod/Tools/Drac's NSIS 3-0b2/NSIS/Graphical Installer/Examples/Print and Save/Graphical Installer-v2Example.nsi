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
!echo "Graphical Installer, v3.01  , Copyright (c) 2006 - 2013 unSigned Softworks. Wizard generated script file."

; HM NIS Edit Wizard common defines
!define PRODUCT_NAME "Graphical Installer Print and Save Example"
!define PRODUCT_VERSION "3.01  "
!define PRODUCT_PUBLISHER "unSigned Softworks"
!define PRODUCT_WEB_SITE "http://www.graphical-installer.com"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; ================================================================ 
;  Graphical settings are defined in file > Graphical Installer-v2Example.graphics.nsh <  
; ================================================================ 

Name "${PRODUCT_NAME}"
OutFile "PrintSaveExample.exe"
InstallDir "$PROGRAMFILES\Graphical Installer Print and Save Example"
Caption "${PRODUCT_NAME}"
ShowInstDetails show
ShowUnInstDetails show
BrandingText " " ; No branding text

; ===================
;  Installer pages    
; ===================

; Comment out this line if You do not want to show confirm dialog when Cancel button is pressed
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE_3LINES
; Welcome page
!define MUI_PAGE_CUSTOMFUNCTION_SHOW GraphicalInstallerRedrawLicenseLeave
!insertmacro MUI_PAGE_WELCOME
; License page
!define MUI_PAGE_CUSTOMFUNCTION_SHOW GraphicalInstallerRedraw
!insertmacro MUI_PAGE_LICENSE "../../readme.txt"
; UI for Installer and Uninstaller
ChangeUI all "${NSISDIR}\Graphical Installer\GraphicalInstaller_UI.exe"
XPStyle on
; Components page
!define MUI_PAGE_CUSTOMFUNCTION_SHOW GraphicalInstallerRedraw
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!define MUI_PAGE_CUSTOMFUNCTION_SHOW GraphicalInstallerRedraw
!insertmacro MUI_PAGE_DIRECTORY
; InstFiles page
!define MUI_PAGE_CUSTOMFUNCTION_SHOW GraphicalInstallerRedraw
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define FINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_PAGE_FINISH

; ===================
;  Uninstaller pages 
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
!insertmacro MUI_LANGUAGE "English"
; Reserve files
!insertmacro MUI_RESERVEFILE_LANGDLL

; Include file for Graphical Installer language strings
!include "${NSISDIR}\Graphical Installer\GraphicalInstaller_translation.nsh"

;  Installer properties
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
LangString DESC_Section01 ${LANG_ENGLISH} "Print and Save Example"

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
; Uninstaller     
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
SectionEnd

Function un.onGUIEnd
; Unloading of GraphicalInstaller plug-in
  GraphicalInstaller::UnInitButtons
FunctionEnd
