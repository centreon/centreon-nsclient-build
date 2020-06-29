ECHO OFF
COLOR 1E
CLS

VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
IF ERRORLEVEL 1 ( 
	ECHO Unable to enable extensions
)

CHDIR /d %~dp0

SET ZIP=..\bin\7zip\7za.exe
SET NSIS=.\bin\nsis\makensis.exe
SET RESSOURCES=.\ressources
SET SETUP32=builddef-Win32.nsi
SET SETUP64=builddef-x64.nsi

:: Win32
RMDIR /S /Q build 2> NUL
MKDIR build
MKDIR build\scripts
XCOPY resources\scripts\Win32 build\scripts /E /S /Y 2> NUL
COPY resources\nsclient.ini build\nsclient.ini /Y 2> NUL
COPY resources\centreon.ico build\centreon.ico /Y 2> NUL

DEL /F /Q resources\resources* 2> NUL
CHDIR build
%ZIP% a -tzip ..\resources\resources.zip .\ -r
CHDIR ..

%NSIS% /V2 !SETUP32!

RMDIR /S /Q build 2> NUL
DEL /F /Q resources\resources.zip

:: x64
RMDIR /S /Q build 2> NUL
MKDIR build
MKDIR build\scripts
XCOPY resources\scripts\x64 build\scripts /E /S /Y 2> NUL
COPY resources\nsclient.ini build\nsclient.ini /Y 2> NUL
COPY resources\centreon.ico build\centreon.ico /Y 2> NUL

DEL /F /Q resources\resources* 2> NUL
CHDIR build
%ZIP% a -tzip ..\resources\resources.zip .\ -r
CHDIR ..

%NSIS% /V2 !SETUP64!

RMDIR /S /Q build 2> NUL
DEL /F /Q resources\resources.zip
