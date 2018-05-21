Echo Off
COLOR 1E
cls
::===============================================::
:: Script de génération des paquets NSCLIENT++   ::
::                                               ::
::              01/07/2016                       ::
::===============================================::

:: Activation des fonctionnalités DOS evoluées
VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
IF ERRORLEVEL 1 ( 
	echo Unable to enable extensions
)

:: Se mettre dans le bon répertoire
chdir /d %~dp0

:: Définition des variables
SET LOGFILE=%~n0.log
SET ZIP=..\bin\7zip\7za.exe
SET NSIS=.\bin\nsis\makensis.exe
SET RESSOURCES=.\ressources
SET SETUP32_044=builddef-Win32-052.nsi
SET SETUP64_044=builddef-x64-052.nsi

:: Copie scripts 32
xcopy scripts\win32 build\scripts /E /S /Y

:: Génération 32 bits
Echo. 
Echo -----------------------------------
Echo ^|     32 bits generation        ^|
Echo -----------------------------------
Echo.

del /F /Q Prerequisites\nsclient-resource*
copy resources\nsclient-051.ini build\nsclient.ini /Y
chdir build
%ZIP% a -tzip ..\Prerequisites\nsclient-resource.zip .\ -r
chdir ..

%NSIS% /V2 !SETUP32_044!

:: Copie scripts 32
rmdir /S /Q build\scripts\centreon
xcopy scripts\x64 build\scripts /E /S /Y

:: Génération 64 bits
Echo. 
Echo -----------------------------------
Echo ^|    64 bits generation         ^|
Echo -----------------------------------
Echo.

del /F /Q Prerequisites\nsclient-resource*
copy resources\nsclient-051.ini build\nsclient.ini /Y
chdir build
%ZIP% a -tzip ..\Prerequisites\nsclient-resource.zip .\ -r
chdir ..

%NSIS% /V2 !SETUP64_044!

:: Clean
rmdir /S /Q build\scripts\centreon
del /F /Q Prerequisites\nsclient-resource.zip
del /F /Q build\nsclient.ini

:: Fin de la génération
Echo. 
Echo ----------------------------------------
Echo ^|      ^End of binaries generation      ^|
Echo ----------------------------------------
Echo.
PAUSE
