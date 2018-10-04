# Centreon
# Goal: Meta-package
# Context:
# Environment: NSIS 2.46, Notepad++

# Includes
# #####################################################################

;Multi-User Header File (MultiUser.nsh)
;The MultiUser.nsh header files provides the features to automatically handle all the aspects related to user accounts and installer privileges
;Initialization and Execution Level (admin, user...) and Installation Mode (install for all uers, current user).
!define MULTIUSER_EXECUTIONLEVEL Admin ;needs to be set first
!include MultiUser.nsh
!include Registry.nsh
!include StrFunc.nsh
# Declare used functions
;${StrStr}
${StrStrAdv}
;${unStrStr}
${unStrStrAdv}

!define MULTIUSER_INIT_TEXT_ADMINREQUIRED "The user has not enough privileges. Aborting the operation." ;

# Constants
# #####################################################################

;These constants specify the installer
!define INSTALLER_LOGO "logo.bmp"
!define INSTALLER_ICON "favicon_centreon.ico"

;These constants specify the program
!define PRODUCT_NAME "centreon-nsclient"
!define PRODUCT_VERSION "1.0"
!define PACKAGE_VERSION "2"
!define NSCLIENT_VERSION "052"
!define PRODUCT_ICON "favicon_centreon.ico"
!define MSI_NSCLIENT "NSCP-0.5.2.35-Win32.msi"

;These constants specify the installation directories
!define INSTALL_DIR "$PROGRAMFILES\${PRODUCT_NAME}" ;$PROGRAMFILES is a constant: no ${}

;These constant specify the Windows uninstall key for your application.
!define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall"
!define REG_CININSTALL "Software\Centreon"

;These constants specify the installer file name.
!define INSTALLER_FILE "${PRODUCT_NAME}-${NSCLIENT_VERSION}-${PRODUCT_VERSION}-${PACKAGE_VERSION}-Win32.exe"

;These constant specify the uninstaller file name.
!define UNINSTALLER_FILE "Uninst.exe"

# Variables
# #####################################################################

;Var StartMenuFolder
Var Application
Var UninstallNSClientID
Var option_nouninstall
Var PrereqDir

# Installer parameters
# #####################################################################

Name "${PRODUCT_NAME} v${PRODUCT_VERSION}"
;Caption "My Legend"
OutFile "${INSTALLER_FILE}"
InstallDir "${INSTALL_DIR}"

# Header file
!include MUI2.nsh

# Interface configuration
;interface settings to change the look and feel of the installer. These settings apply to all pages.

;Page header
!define MUI_ICON "${INSTALLER_ICON}"
!define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "${INSTALLER_LOGO}" ;recommended size: 150x57 pixels

;Installer and Uninstaller finish page
!define MUI_FINISHPAGE_NOAUTOCLOSE ;Do not automatically jump to the finish page, to allow the user to check the install log.
!define MUI_UNFINISHPAGE_NOAUTOCLOSE ;Do not automatically jump to the finish page, to allow the user to check the uninstall log.

;Installer and Uninstaller Abort warning
!define MUI_ABORTWARNING ;Show a message box with a warning when the user wants to close the installer.
  !define MUI_ABORTWARNING_CANCEL_DEFAULT
!define MUI_UNABORTWARNING ;Show a message box with a warning when the user wants to close the uninstaller.
  !define MUI_UNABORTWARNING_CANCEL_DEFAULT ;Set the Cancel button as the default button on the message box.

# Pages
;Page settings apply to a single page and should be set before inserting a page macro.

# Installer Pages
!insertmacro MUI_PAGE_WELCOME
;!insertmacro MUI_PAGE_LICENSE "license.rtf"
;!insertmacro MUI_PAGE_COMPONENTS
;!insertmacro MUI_PAGE_DIRECTORY
;!define MUI_STARTMENUPAGE_NODISABLE
;!insertmacro MUI_PAGE_STARTMENU "${PRODUCT_NAME}" $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
;!insertmacro MUI_PAGE_FINISH

# Uninstaller Pages
;!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
;!insertmacro MUI_UNPAGE_LICENSE "license.rtf"
!insertmacro MUI_UNPAGE_COMPONENTS
;!insertmacro MUI_UNPAGE_DIRECTORY
!insertmacro MUI_UNPAGE_INSTFILES
;!insertmacro MUI_UNPAGE_FINISH

# Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"

!insertmacro GetParameters
!insertmacro GetOptions

# Sections
# #####################################################################

;Steps to INSTALL the programs needed by the "target" application
;----------------------------------------------------------------------
  
Section "-Prerequisites" seq_Prereq
  
  DetailPrint "$EXEDIR"
  DetailPrint "$TEMP"
  
  StrCpy $PrereqDir "$INSTDIR\Prerequisites"
  
  SetOutPath "$PrereqDir"
  WriteUninstaller "$PrereqDir\${UNINSTALLER_FILE}" ;we create right now, in case of if something goes wrong during the install (?)
  
  StrCmp $option_nouninstall 1 0 Uninstall
  DetailPrint "- Prerequisites of ${PRODUCT_NAME}: Test if already installed..."
  ClearErrors
  ReadRegDWORD $0 HKLM "${REG_CININSTALL}" "install"
  ; La cle existe. Il faut donc aller a la fin
  IfErrors 0 End
  
  Uninstall:
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Try to uninstall NRPE_NT
  ;StrCpy $Application "NRPE_NT"
  ;DetailPrint "- $Application service stop."
  ;nsExec::ExecToLog 'net stop NRPE_NT'
  ;Pop $0
  ;DetailPrint "Some program returned $0"
  ;DetailPrint "- $Application: Windows service: Delete..."
  ;nsExec::ExecToLog '"$SYSDIR\sc.exe" delete "NRPE_NT"'
  ;Pop $0
  ;DetailPrint "Some program returned $0"
  ;RMDir /r "$PROGRAMFILES\Nagios\"
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Find nsclient install
  StrCpy $UninstallNSClientID ''
  
  StrCpy $Application "NSClient++"
  DetailPrint "Find NSClient to uninstall it..."
  nsExec::ExecToStack "wmic product where $\"Name like 'NSClient%'$\" get IdentifyingNumber"
  Pop $0
  Pop $1
  DetailPrint "Some program returned $0 $1"
  
  ${StrStrAdv} $9 $1 "{" "<" ">" "0" "0" "0"
  StrCpy $UninstallNSClientID $9
  ${StrStrAdv} $9 $UninstallNSClientID "}" "<" "<" "0" "0" "0"
  StrCpy $UninstallNSClientID $9
  
  StrCmp $UninstallNSClientID '' NSClient_install
  
  StrCpy $Application "NSClient++"
  DetailPrint "- $Application: Uninstall..."
  ExecWait "msiexec /qn /x {$UninstallNSClientID}" $0 ;would work anyway how it was installed
  DetailPrint "Some program returned $0"

  NSClient_install:
	;install nsclient++
	;--------------
	DetailPrint "- $Application installation."
	File "Prerequisites\${MSI_NSCLIENT}"
	ExecWait 'msiexec /norestart /qr /i "$PrereqDir\${MSI_NSCLIENT}" /quiet INSTALLLOCATION="$INSTDIR\NSClient++\" CONF_CHECKS=1 CONF_NRPE=1 CONF_CAN_CHANGE=1' $0
	DetailPrint "Some program returned $0"
  
	;install files
	;--------------
	StrCpy $Application "NSClient++ Resources"
	DetailPrint "- $Application unzip."
	File "Prerequisites\nsclient-resource.zip"
	ZipDLL::extractall "$PrereqDir\nsclient-resource.zip" "$INSTDIR\NSClient++\"
	Pop $0
	DetailPrint "Some program returned $0"
  
	StrCpy $Application "NSClient"
	DetailPrint "- $Application service stop."
	nsExec::ExecToLog 'net stop nscp'
	Pop $0
	DetailPrint "Some program returned $0"
	DetailPrint "- $Application service start."
	nsExec::ExecToLog 'net start nscp'
	Pop $0
	DetailPrint "Some program returned $0"

	DetailPrint "- $Application: Delete installation files and directories..."
	
	Delete "$PrereqDir\nsclient-resource.zip"
	Delete "$PrereqDir\${MSI_NSCLIENT}"
  End:
		
SectionEnd

;Steps to INSTALL the "target" application
;----------------------------------------------------------------------
Section "${PRODUCT_NAME}" sec_App

  SetOutPath "$INSTDIR"
  WriteUninstaller "$INSTDIR\${UNINSTALLER_FILE}"

  StrCmp $option_nouninstall 1 0 +4
  ClearErrors
  ReadRegDWORD $0 HKLM "${REG_CININSTALL}" "install"
  ; La cle existe. On a déjà écrit donc
  IfErrors 0 centreon_end
  
  ;install monitoring
  ;----------------------------
  StrCpy $Application "monitoring"
    
  DetailPrint "- $Application: Write uninstall info to the registry..."
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "DisplayName" "${PRODUCT_NAME}" ;mandatory
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "UninstallString" "$\"$INSTDIR\${UNINSTALLER_FILE}$\"" ;mandatory
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "QuietUninstallString" "$\"$INSTDIR\${UNINSTALLER_FILE}$\" /S"
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "Publisher" "Centreon"
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "DisplayIcon" "$INSTDIR\${PRODUCT_ICON}"
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "DisplayVersion" "${NSCLIENT_VERSION}-${PRODUCT_VERSION}-${PACKAGE_VERSION}"
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "URLInfoAbout" "http://www.centreon.com/"
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "Comments" "Meta-package for NSClient++"
  WriteRegDWORD HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "NoModify" "1"
  WriteRegDWORD HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "NoRepair" "1"
  ;WriteRegDWORD HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "EstimatedSize" "25"
  WriteRegStr HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}" "Package version" "${PACKAGE_VERSION}" ;not standard
  WriteRegDWORD HKLM "${REG_CININSTALL}" "install" "1" ;not standard

  ;;;;;;;;;;;;;;;
  ; End install service
  ;;;;;;;;;;;;;;;
  Goto end
  
  centreon_end:

  end:
	
SectionEnd

;Steps to UNINSTALL the programs needed by the "target" application
;----------------------------------------------------------------------

SectionGroup /e "un.Prerequisites" sec_Prereq_uninstall ;e = expand by default
;in uninstaller code, $INSTDIR contains the directory where the uninstaller lies. It does not necessarily contain the same value it contained in the installer.

Section "-un.Prerequisites_start"
  ;initialisation of $INSTDIR: maybe with InstallDirRegKey HKLM "Software\ACME\Thingy" InstallLocation
  StrCpy $Application "Prerequisites of ${PRODUCT_NAME}"
  DetailPrint "- $Application: Uninstall..."
SectionEnd

Section "un.nsclient" un.nsclient
  ;uninstall nsclient++
  ;----------------------------
  StrCpy $Application "NSClient++"

  StrCpy $UninstallNSClientID ''  
  DetailPrint "Find NSClient to uninstall it..."
  nsExec::ExecToStack "wmic product where $\"Name like 'NSClient%'$\" get IdentifyingNumber"
  Pop $0
  Pop $1
  DetailPrint "Some program returned $0 $1"
  
  ${unStrStrAdv} $9 $1 "{" "<" ">" "0" "0" "0"
  StrCpy $UninstallNSClientID $9
  ${unStrStrAdv} $9 $UninstallNSClientID "}" "<" "<" "0" "0" "0"
  StrCpy $UninstallNSClientID $9

  StrCmp $UninstallNSClientID '' 0 NSClient_uninstall
  DetailPrint "- $Application: Cannot find product id for uninstall..."
  Goto End
  
  NSClient_uninstall:
     DetailPrint "- $Application: Uninstall..."
     ExecWait "msiexec /qn /x {$UninstallNSClientID}" $0 ;would work anyway how it was installed
     DetailPrint "Some program returned $0"
  
  End:

SectionEnd

SectionGroupEnd

;Steps to UNINSTALL the "target" application
;----------------------------------------------------------------------

Section "un.${PRODUCT_NAME}" sec_App_uninstall
;in uninstaller code, $INSTDIR contains the directory where the uninstaller lies. It does not necessarily contain the same value it contained in the installer.

  ;initialisation of $INSTDIR: maybe with InstallDirRegKey HKLM "Software\ACME\Thingy" InstallLocation
  
  StrCpy $Application "${PRODUCT_NAME}"
  
  DetailPrint "- $Application: Delete the uninstaller file"
  ;Delete "$INSTDIR\${UNINSTALLER_FILE}"
  Delete "$INSTDIR\${UNINSTALLER_FILE}"
  
  DetailPrint "- $Application: Delete files and directories..."
  ;RMDir /r "$INSTDIR" may be dangerous!
  Delete "$INSTDIR\${PRODUCT_ICON}"
  
  RMDir /r "$INSTDIR"
  
  DetailPrint "- $Application: Remove the uninstall info from the registry..."
  DeleteRegKey HKLM "${REG_UNINSTALL}\${PRODUCT_NAME}"
  DeleteRegKey HKLM "${REG_CININSTALL}"
  
  ;;;
  ; Fin desintallation
  ;;;
SectionEnd


# Functions
# #####################################################################

Function parseParameters
	; /nouninstall
    ${GetOptions} $cmdLineParams '/nouninstall' $R0
    IfErrors +2 0
    StrCpy $option_nouninstall 1

FunctionEnd

;Initialization tests, etc.
Function .onInit
  ;Test if the user has enough rights, using the MultiUser.nsh
  !insertmacro MULTIUSER_INIT
  
  ;Prevent multiple instances of the installer
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex${PRODUCT_NAME}") i .r1 ?e'
  Pop $R0 
  StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running."
    Abort

  Var /GLOBAL cmdLineParams
  Push $R0
   
  ${GetParameters} $cmdLineParams
  ${GetOptions} $cmdLineParams '/?' $R0

  IfErrors +3 0
    MessageBox MB_OK "Options: /S = silent installation, /nouninstall = Don't uninstall if already installed"
    Abort
	
  Pop $R0
  StrCpy $option_nouninstall 0

  ; Parse Parameters
  Push $R0
  Call parseParameters
  Pop $R0
 
FunctionEnd

Function un.onInit
  ;Test if the user has enough rights, using the MultiUser.nsh
  !insertmacro MULTIUSER_UNINIT
  
  ;SectionSetFlags ${un.klnagent} 0 ;don't uninstall by default

FunctionEnd
