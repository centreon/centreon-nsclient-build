@ECHO ON

SET PERL_INSTALL_DIR=C:\Strawberry32
SET PAR_VERBATIM=1

CMD /C %PERL_INSTALL_DIR%\perl\bin\perl check_logfiles\winconfig.pl --with-perl=%PERL_INSTALL_DIR%\perl\bin\perl

CMD /C %PERL_INSTALL_DIR%\perl\site\bin\pp --lib=check_logfiles\plugins-scripts\ ^
-o resources\scripts\win32\centreon\check_logfiles.exe check_logfiles\plugins-scripts\check_logfiles.pl ^
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
--verbose
