@ECHO OFF

SET PERL_INSTALL_DIR=C:\Strawberry32
SET PAR_VERBATIM=1

CD check_logfiles
CMD /C %PERL_INSTALL_DIR%\perl\bin\perl winconfig.pl --with-perl=%PERL_INSTALL_DIR%\perl\bin\perl

CD plugins-scripts
CMD /C %PERL_INSTALL_DIR%\perl\site\bin\pp ^
-o check_logfiles_x86.exe check_logfiles ^
-M PerlIO ^
-M Digest::MD5 ^
-M Encode::Encoding ^
-M Encode::Unicode ^
-M Encode::Unicode::UTF7 ^
-M Net::Domain ^
-M Win32::NetResource ^
-M Win32::Daemon ^
-M Time::Piece ^
-M Time::Local ^
-M Win32::EventLog ^
-M Win32::TieRegistry ^
-M Win32::WinError ^
-M Date::Manip ^
-M Win32::OLE ^
-M Win32::Service ^
--verbose
