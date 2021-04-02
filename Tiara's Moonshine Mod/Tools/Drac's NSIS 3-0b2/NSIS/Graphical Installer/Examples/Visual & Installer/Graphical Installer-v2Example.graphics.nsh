; ########################################
; #      Graphical Installer for NSIS    #
; #         Version 3.2.01 (Julka)       #
; #       Copyright (c) 2006 - 2013      #
; #          unSigned Softworks          #
; #  http://www.graphical-installer.com  #
; #   http://www.unsigned-softworks.sk   #
; #      info@unsigned-softworks.sk      #
; ########################################
; #           Graphics file              #
; ########################################
 
; *********************************************
; * This file contains setting for graphical  *
; * interface. Modify them freerly.           *
; ********************************************* 
 
; Script generated with Graphical Installer Wizard
 
!echo "Graphical Installer, v3.2.01 (Julka), Copyright (c) 2006 - 2013 unSigned Softworks. Graphics file."
 
; This file was generated from Script file with this GRAPHICAL_INSTALLER_PROJECT_UID: {GraphicalInstaller-v2Example}
 
; Compression
SetCompressor bzip2

!define MUI_LICENSEPAGE_RADIOBUTTONS true
 
; Installer icon
!define MUI_ICON "..\graphical-installer.ico"
; unInstaller icon
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
 
; Installer graphic resources
; Splash image - comment out this line if you wish not to show a splash
!define GRAPHICAL_INSTALLER_SPLASH_BITMAP "splash.bmp"
!define GRAPHICAL_INSTALLER_SPLASH_BITMAP_TIME 5000 # miliseconds
 
!define GRAPHICAL_INSTALLER_BACKGROUND_BITMAP "background.jpg" ; 690x496 px
!define GRAPHICAL_INSTALLER_SMALL_BITMAP "background-inner.jpg" ; 450x228 px
 
; Color of labels
!define GRAPHICAL_INSTALLER_LABELS_TEXT_COLOR "0xFFFFFF" ; as CSS colors
; Color of texts  
!define GRAPHICAL_INSTALLER_HEADER_TEXT_COLOR "0xFFFFFF" ; as CSS colors 
 
; See definition of this image in GraphicalInstaller plug-in or in included pdf documentation
!define GRAPHICAL_INSTALLER_BUTTON_BITMAP "button.bmp" ; 47x15 px
; Color of button text for Normal and Down state
!define GRAPHICAL_INSTALLER_BUTTONS_TEXT_COLOR "0x000000" ; as CSS colors   
!define GRAPHICAL_INSTALLER_BUTTONS_TEXT_COLOR_DOWN "0x000000" ; as CSS colors   
 
; End of file (EOF)
