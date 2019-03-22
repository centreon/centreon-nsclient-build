@echo off

set PERL_INSTALL_DIR=C:\Strawberry
set ICO_FILE=centreon.ico
set RC_FILE=centreon.rc

chdir /d %~dp0

for /f "tokens=4 delims= " %%i in ('type centreon-plugins\centreon\plugins\script.pm ^| findstr global_version ^| findstr my') do set "VERSION_PLUGIN=%%i"
set VERSION_PLUGIN=%VERSION_PLUGIN:~0,8%

(
echo #define PP_MANIFEST_FILEFLAGS 0
echo #include ^<windows.h^>
echo.
echo CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST "winres\\pp.manifest"
echo.
echo VS_VERSION_INFO VERSIONINFO
echo    FILEVERSION        0,0,0,0
echo    PRODUCTVERSION     0,0,0,0
echo    FILEFLAGSMASK      VS_FFI_FILEFLAGSMASK
echo    FILEFLAGS          PP_MANIFEST_FILEFLAGS
echo    FILEOS             VOS_NT_WINDOWS32
echo    FILETYPE           VFT_APP
echo    FILESUBTYPE        VFT2_UNKNOWN
echo BEGIN
echo    BLOCK "StringFileInfo"
echo    BEGIN
echo        BLOCK "000004B0"
echo        BEGIN
echo            VALUE "CompanyName", "Centreon\0"
echo            VALUE "FileDescription", " \0"
echo            VALUE "FileVersion", "1.0.0.0\0"
echo            VALUE "InternalName", " \0"
echo            VALUE "LegalCopyright", " \0"
echo            VALUE "LegalTrademarks", " \0"
echo            VALUE "OriginalFilename", " \0"
echo            VALUE "ProductName", "centreon-plugins\0"
echo            VALUE "ProductVersion", "%VERSION_PLUGIN%.0\0"
echo        END
echo    END
echo    BLOCK "VarFileInfo"
echo    BEGIN
echo        VALUE "Translation", 0x00, 0x04B0
echo    END
echo END
echo.
echo WINEXE ICON winres\\pp.ico
)> %RC_FILE%

for /f "delims=" %%i in ('dir /ad /B %PERL_INSTALL_DIR%\cpan\build\PAR-Packer-*') do set "PAR_PACKER_DIRNAME=%%i"
SET PAR_PACKER_SRC=%PERL_INSTALL_DIR%\cpan\build\%PAR_PACKER_DIRNAME%

copy /Y %ICO_FILE% %PAR_PACKER_SRC%\myldr\winres\pp.ico
copy /Y centreon.rc %PAR_PACKER_SRC%\myldr\winres\pp.rc
if exist %PAR_PACKER_SRC%\myldr\ppresource.coff del %PAR_PACKER_SRC%\myldr\ppresource.coff
cd /D %PAR_PACKER_SRC%\myldr\ && perl Makefile.PL
cd /D %PAR_PACKER_SRC%\myldr\ && gmake boot.exe
cd /D %PAR_PACKER_SRC%\myldr\ && gmake Static.pm
attrib -R %PERL_INSTALL_DIR%\perl\site\lib\PAR\StrippedPARL\Static.pm
copy /Y %PAR_PACKER_SRC%\myldr\Static.pm %PERL_INSTALL_DIR%\perl\site\lib\PAR\StrippedPARL\Static.pm

chdir /d %~dp0
set PAR_VERBATIM=1

cmd /C %PERL_INSTALL_DIR%\perl\site\bin\pp --lib=centreon-plugins\ -o centreon_plugins.exe centreon-plugins\centreon_plugins.pl ^
--unicode ^
-X IO::Socket::INET6 ^
--link=%PERL_INSTALL_DIR%\c\bin\libxml2-2__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\libiconv-2__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\liblzma-5__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\zlib1__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\libcrypto-1_1-x64__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\libssl-1_1-x64__.dll ^
-M IO::Socket::SSL ^
-M Win32::Job ^
-M Email::Send::SMTP::Gmail ^
-M HTTP::ProxyPAC ^
-M JE ^
-M Tie::RefHash::Weak ^
-M XML::LibXML::SAX ^
-M Net::FTPSSL ^
-M Authen::NTLM ^
-M JSON::XS ^
-M centreon::plugins::script ^
-M centreon::plugins::alternative::Getopt ^
-M centreon::common::powershell::functions ^
-M apps::backup::netbackup::local::plugin ^
-M apps::backup::netbackup::local::mode::dedupstatus ^
-M apps::backup::netbackup::local::mode::drivecleaning ^
-M apps::backup::netbackup::local::mode::drivestatus ^
-M apps::backup::netbackup::local::mode::jobstatus ^
-M apps::backup::netbackup::local::mode::listpolicies ^
-M apps::backup::netbackup::local::mode::tapeusage ^
-M apps::backup::veeam::local::plugin ^
-M apps::backup::veeam::local::mode::jobstatus ^
-M apps::backup::veeam::local::mode::listjobs ^
-M apps::activedirectory::local::plugin ^
-M apps::activedirectory::local::mode::dcdiag ^
-M apps::activedirectory::local::mode::dfsrbacklog ^
-M apps::activedirectory::local::mode::netdom ^
-M apps::citrix::local::plugin ^
-M apps::citrix::local::mode::license ^
-M apps::citrix::local::mode::session ^
-M apps::citrix::local::mode::zone ^
-M apps::citrix::local::mode::folder ^
-M apps::iis::local::plugin ^
-M apps::iis::local::mode::listapplicationpools ^
-M apps::iis::local::mode::applicationpoolstate ^
-M apps::iis::local::mode::listsites ^
-M apps::iis::local::mode::webservicestatistics ^
-M apps::exchange::2010::local::plugin ^
-M apps::exchange::2010::local::mode::activesyncmailbox ^
-M apps::exchange::2010::local::mode::databases ^
-M apps::exchange::2010::local::mode::listdatabases ^
-M apps::exchange::2010::local::mode::imapmailbox ^
-M apps::exchange::2010::local::mode::mapimailbox ^
-M apps::exchange::2010::local::mode::outlookwebservices ^
-M apps::exchange::2010::local::mode::owamailbox ^
-M apps::exchange::2010::local::mode::queues ^
-M apps::exchange::2010::local::mode::replicationhealth ^
-M apps::exchange::2010::local::mode::services ^
-M centreon::common::powershell::exchange::2010::powershell ^
-M apps::cluster::mscs::local::plugin ^
-M apps::cluster::mscs::local::mode::listnodes ^
-M apps::cluster::mscs::local::mode::listresources ^
-M apps::cluster::mscs::local::mode::networkstatus ^
-M apps::cluster::mscs::local::mode::nodestatus ^
-M apps::cluster::mscs::local::mode::resourcestatus ^
-M apps::cluster::mscs::local::mode::resourcegroupstatus ^
-M os::windows::local::plugin ^
-M os::windows::local::mode::cmdreturn ^
-M os::windows::local::mode::ntp ^
-M os::windows::local::mode::pendingreboot ^
-M os::windows::local::mode::sessions ^
-M os::windows::local::mode::liststorages ^
-M centreon::common::powershell::windows::liststorages ^
-M storage::dell::compellent::local::plugin ^
-M storage::dell::compellent::local::mode::hbausage ^
-M storage::dell::compellent::local::mode::volumeusage ^
-M hardware::devices::safenet::hsm::protecttoolkit::plugin ^
-M hardware::devices::safenet::hsm::protecttoolkit::mode::hardware ^
-M hardware::devices::safenet::hsm::protecttoolkit::mode::components::temperature ^
-M hardware::devices::safenet::hsm::protecttoolkit::mode::components::hwstatus ^
-M hardware::devices::safenet::hsm::protecttoolkit::mode::components::memory ^
-M apps::centreon::local::plugin ^
-M apps::centreon::local::mode::downtimetrap ^
-M apps::centreon::local::mode::centreonpluginsversion ^
-M apps::hyperv::2012::local::plugin ^
-M apps::hyperv::2012::local::mode::listnodevms ^
-M apps::hyperv::2012::local::mode::scvmmintegrationservice ^
-M apps::hyperv::2012::local::mode::scvmmsnapshot ^
-M apps::hyperv::2012::local::mode::scvmmvmstatus ^
-M apps::hyperv::2012::local::mode::nodeintegrationservice ^
-M apps::hyperv::2012::local::mode::nodereplication ^
-M apps::hyperv::2012::local::mode::nodesnapshot ^
-M apps::hyperv::2012::local::mode::nodevmstatus ^
-M centreon::common::powershell::hyperv::2012::listnodevms ^
-M centreon::common::powershell::hyperv::2012::nodeintegrationservice ^
-M centreon::common::powershell::hyperv::2012::nodereplication ^
-M centreon::common::powershell::hyperv::2012::nodesnapshot ^
-M centreon::common::powershell::hyperv::2012::nodevmstatus ^
-M centreon::common::powershell::hyperv::2012::scvmmintegrationservice ^
-M centreon::common::powershell::hyperv::2012::scvmmsnapshot ^
-M centreon::common::powershell::hyperv::2012::scvmmvmstatus ^
-M apps::protocols::http::plugin ^
-M apps::protocols::http::mode::expectedcontent ^
-M apps::protocols::http::mode::response ^
-M apps::protocols::tcp::plugin ^
-M apps::protocols::tcp::mode::responsetime ^
-M apps::protocols::ftp::plugin ^
-M apps::protocols::ftp::mode::commands ^
-M apps::protocols::ftp::mode::date ^
-M apps::protocols::ftp::mode::filescount ^
-M apps::protocols::ftp::mode::login ^
-M apps::backup::veeam::local::plugin ^
-M apps::backup::veeam::local::mode::jobstatus ^
-M apps::backup::veeam::local::mode::listjobs ^
-M centreon::common::powershell::veeam::jobstatus ^
-M centreon::common::powershell::veeam::listjobs ^
-M apps::wsus::local::plugin ^
-M apps::wsus::local::mode::computersstatus ^
-M apps::wsus::local::mode::updatesstatus ^
-M apps::wsus::local::mode::synchronisationstatus ^
-M apps::wsus::local::mode::serverstatistics ^
-M centreon::common::powershell::wsus::computersstatus ^
-M centreon::common::powershell::wsus::updatesstatus ^
-M centreon::common::powershell::wsus::synchronisationstatus ^
-M centreon::common::powershell::wsus::serverstatistics ^
--verbose

pause