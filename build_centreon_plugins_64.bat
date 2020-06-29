@ECHO OFF

SET VERSION_PLUGIN=20200602

set PERL_INSTALL_DIR=C:\Strawberry
SET ICO_FILE=resources\centreon.ico
SET RC_FILE=centreon.rc

CHDIR /d %~dp0

(
ECHO #define PP_MANIFEST_FILEFLAGS 0
ECHO #include ^<windows.h^>
ECHO.
ECHO CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST "winres\\pp.manifest"
ECHO.
ECHO VS_VERSION_INFO VERSIONINFO
ECHO    FILEVERSION        0,0,0,0
ECHO    PRODUCTVERSION     0,0,0,0
ECHO    FILEFLAGSMASK      VS_FFI_FILEFLAGSMASK
ECHO    FILEFLAGS          PP_MANIFEST_FILEFLAGS
ECHO    FILEOS             VOS_NT_WINDOWS32
ECHO    FILETYPE           VFT_APP
ECHO    FILESUBTYPE        VFT2_UNKNOWN
ECHO BEGIN
ECHO    BLOCK "StringFileInfo"
ECHO    BEGIN
ECHO        BLOCK "000004B0"
ECHO        BEGIN
ECHO            VALUE "CompanyName", "Centreon\0"
ECHO            VALUE "FileDescription", " \0"
ECHO            VALUE "FileVersion", "1.0.0.0\0"
ECHO            VALUE "InternalName", " \0"
ECHO            VALUE "LegalCopyright", " \0"
ECHO            VALUE "LegalTrademarks", " \0"
ECHO            VALUE "OriginalFilename", " \0"
ECHO            VALUE "ProductName", "centreon-plugins\0"
ECHO            VALUE "ProductVersion", "%VERSION_PLUGIN%\0"
ECHO        END
ECHO    END
ECHO    BLOCK "VarFileInfo"
ECHO    BEGIN
ECHO        VALUE "Translation", 0x00, 0x04B0
ECHO    END
ECHO END
ECHO.
ECHO WINEXE ICON winres\\pp.ico
)> %RC_FILE%

FOR /f "delims=" %%i IN ('DIR /ad /B %PERL_INSTALL_DIR%\cpan\build\PAR-Packer-*') DO SET "PAR_PACKER_DIRNAME=%%i"
SET PAR_PACKER_SRC=%PERL_INSTALL_DIR%\cpan\build\%PAR_PACKER_DIRNAME%

COPY /Y %ICO_FILE% %PAR_PACKER_SRC%\myldr\winres\pp.ico
COPY /Y %RC_FILE% %PAR_PACKER_SRC%\myldr\winres\pp.rc
IF EXIST %PAR_PACKER_SRC%\myldr\ppresource.coff DEL %PAR_PACKER_SRC%\myldr\ppresource.coff
CD /D %PAR_PACKER_SRC%\myldr\ && perl Makefile.PL
CD /D %PAR_PACKER_SRC%\myldr\ && gmake boot.exe
CD /D %PAR_PACKER_SRC%\myldr\ && gmake Static.pm
ATTRIB -R %PERL_INSTALL_DIR%\perl\site\lib\PAR\StrippedPARL\Static.pm
COPY /Y %PAR_PACKER_SRC%\myldr\Static.pm %PERL_INSTALL_DIR%\perl\site\lib\PAR\StrippedPARL\Static.pm

CHDIR /d %~dp0
SET PAR_VERBATIM=1

CMD /C %PERL_INSTALL_DIR%\perl\site\bin\pp --lib=centreon-plugins\ ^
-o resources\scripts\x64\centreon\centreon_plugins.exe centreon-plugins\centreon_plugins.pl ^
--unicode ^
-X IO::Socket::INET6 ^
--link=%PERL_INSTALL_DIR%\c\bin\libxml2-2__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\libiconv-2__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\liblzma-5__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\zlib1__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\libcrypto-1_1-x64__.dll ^
--link=%PERL_INSTALL_DIR%\c\bin\libssl-1_1-x64__.dll ^
-M Authen::NTLM ^
-M Date::Manip ^
-M Email::Send::SMTP::Gmail ^
-M HTTP::ProxyPAC ^
-M IO::Socket::SSL ^
-M JE ^
-M JSON::XS ^
-M Net::FTPSSL ^
-M Net::SSLeay ^
-M Tie::RefHash::Weak ^
-M Win32::Job ^
-M XML::LibXML::SAX ^
-M apps::activedirectory::local::plugin ^
-M apps::activedirectory::local::mode::dcdiag ^
-M apps::activedirectory::local::mode::dfsrbacklog ^
-M apps::activedirectory::local::mode::netdom ^
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
-M apps::backup::veeam::local::mode::tapejobs ^
-M apps::centreon::local::plugin ^
-M apps::centreon::local::mode::downtimetrap ^
-M apps::centreon::local::mode::centreonpluginsversion ^
-M apps::citrix::local::plugin ^
-M apps::citrix::local::mode::license ^
-M apps::citrix::local::mode::session ^
-M apps::citrix::local::mode::zone ^
-M apps::citrix::local::mode::folder ^
-M apps::cluster::mscs::local::plugin ^
-M apps::cluster::mscs::local::mode::listnodes ^
-M apps::cluster::mscs::local::mode::listresources ^
-M apps::cluster::mscs::local::mode::networkstatus ^
-M apps::cluster::mscs::local::mode::nodestatus ^
-M apps::cluster::mscs::local::mode::resourcestatus ^
-M apps::cluster::mscs::local::mode::resourcegroupstatus ^
-M apps::hyperv::2012::local::plugin ^
-M apps::hyperv::2012::local::mode::listnodevms ^
-M apps::hyperv::2012::local::mode::scvmmintegrationservice ^
-M apps::hyperv::2012::local::mode::scvmmsnapshot ^
-M apps::hyperv::2012::local::mode::scvmmvmstatus ^
-M apps::hyperv::2012::local::mode::nodeintegrationservice ^
-M apps::hyperv::2012::local::mode::nodereplication ^
-M apps::hyperv::2012::local::mode::nodesnapshot ^
-M apps::hyperv::2012::local::mode::nodevmstatus ^
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
-M apps::protocols::ldap::plugin ^
-M apps::protocols::ldap::mode::login ^
-M apps::protocols::ldap::mode::search ^
-M apps::protocols::ftp::plugin ^
-M apps::protocols::ftp::mode::commands ^
-M apps::protocols::ftp::mode::date ^
-M apps::protocols::ftp::mode::filescount ^
-M apps::protocols::ftp::mode::login ^
-M apps::protocols::http::plugin ^
-M apps::protocols::http::mode::expectedcontent ^
-M apps::protocols::http::mode::response ^
-M apps::protocols::tcp::plugin ^
-M apps::protocols::tcp::mode::responsetime ^
-M apps::protocols::x509::plugin ^
-M apps::protocols::x509::mode::certificate ^
-M apps::protocols::x509::mode::validity ^
-M apps::sccm::local::plugin ^
-M apps::sccm::local::mode::databasereplicationstatus ^
-M apps::sccm::local::mode::sitestatus ^
-M apps::wsus::local::plugin ^
-M apps::wsus::local::mode::computersstatus ^
-M apps::wsus::local::mode::updatesstatus ^
-M apps::wsus::local::mode::synchronisationstatus ^
-M apps::wsus::local::mode::serverstatistics ^
-M centreon::common::protocols::ldap::lib::ldap ^
-M centreon::common::powershell::exchange::2010::powershell ^
-M centreon::common::powershell::functions ^
-M centreon::common::powershell::hyperv::2012::listnodevms ^
-M centreon::common::powershell::hyperv::2012::nodeintegrationservice ^
-M centreon::common::powershell::hyperv::2012::nodereplication ^
-M centreon::common::powershell::hyperv::2012::nodesnapshot ^
-M centreon::common::powershell::hyperv::2012::nodevmstatus ^
-M centreon::common::powershell::hyperv::2012::scvmmintegrationservice ^
-M centreon::common::powershell::hyperv::2012::scvmmsnapshot ^
-M centreon::common::powershell::hyperv::2012::scvmmvmstatus ^
-M centreon::common::powershell::sccm::databasereplicationstatus ^
-M centreon::common::powershell::sccm::sitestatus ^
-M centreon::common::powershell::veeam::jobstatus ^
-M centreon::common::powershell::veeam::listjobs ^
-M centreon::common::powershell::veeam::tapejobs ^
-M centreon::common::powershell::windows::liststorages ^
-M centreon::common::powershell::wsus::computersstatus ^
-M centreon::common::powershell::wsus::updatesstatus ^
-M centreon::common::powershell::wsus::synchronisationstatus ^
-M centreon::common::powershell::wsus::serverstatistics ^
-M centreon::plugins::alternative::Getopt ^
-M centreon::plugins::backend::http::lwp ^
-M centreon::plugins::backend::http::curl ^
-M centreon::plugins::backend::http::curlconstants ^
-M centreon::plugins::script ^
-M hardware::devices::safenet::hsm::protecttoolkit::plugin ^
-M hardware::devices::safenet::hsm::protecttoolkit::mode::hardware ^
-M hardware::devices::safenet::hsm::protecttoolkit::mode::components::temperature ^
-M hardware::devices::safenet::hsm::protecttoolkit::mode::components::hwstatus ^
-M hardware::devices::safenet::hsm::protecttoolkit::mode::components::memory ^
-M os::windows::local::plugin ^
-M os::windows::local::mode::cmdreturn ^
-M os::windows::local::mode::ntp ^
-M os::windows::local::mode::pendingreboot ^
-M os::windows::local::mode::sessions ^
-M os::windows::local::mode::liststorages ^
-M storage::dell::compellent::local::plugin ^
-M storage::dell::compellent::local::mode::hbausage ^
-M storage::dell::compellent::local::mode::volumeusage ^
-M storage::emc::symmetrix::vmax::local::plugin ^
-M storage::emc::symmetrix::vmax::local::mode::hardware ^
-M storage::emc::symmetrix::vmax::local::mode::components::cabling ^
-M storage::emc::symmetrix::vmax::local::mode::components::director ^
-M storage::emc::symmetrix::vmax::local::mode::components::fabric ^
-M storage::emc::symmetrix::vmax::local::mode::components::module ^
-M storage::emc::symmetrix::vmax::local::mode::components::power ^
-M storage::emc::symmetrix::vmax::local::mode::components::sparedisk ^
-M storage::emc::symmetrix::vmax::local::mode::components::temperature ^
-M storage::emc::symmetrix::vmax::local::mode::components::voltage ^
--verbose

DEL /F /Q %RC_FILE%
