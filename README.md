# centreon-nsclient-build

## Overview 

You can find here all sources and scripts to build your own version of the centreon-nsclient agent. That's very useful when you want to create your own centreon_plugins.exe or customize nsclient.ini content (e.g allowed hosts values, specific command handler, etc.).

Pull request are disabled as Centreon teams manage the upgrade to the newer version of centreon-plugins and NSClient++. If you want to provide some feedback, ask for a new plugin to be included in the build routine, just open an issue to discuss about it. 

## Prerequisites

To use this repo, you must have:

* a Windows Server 2K8 or above, with a x64 architecture
* a 64bits version of Strawberry perl (http://strawberryperl.com/). The build env is tested with the version below: 

```
C:\Strawberry>perl -v

This is perl 5, version 26, subversion 0 (v5.26.0) built for MSWin32-x64-multi-thread

Copyright 1987-2017, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.
```

* perl PAR::Packer module installed. Substitute 'C:\Strawberry' with your own perl installation dir:

```C:\Strawberry>cpan install PAR::Packer```

* Some additionnal perl libs installed

```
Authen::NTLM
Date::Manip
Email::Send::SMTP::Gmail
HTTP::ProxyPAC
IO::Socket::SSL
JE
JSON::XS
Net::FTPSSL
Net::NTP
Net::SSLeay
Tie::RefHash::Weak
Win32::Job
XML::LibXML::SAX
```

## How to use it

### Quick tour of the files that matter

There are a lot of files in this repository, but you just have to know a few to build your own centreon-nsclient flavour. 

#### build_centreon_<32/64>.bat

Those two files allow you to generate a centreon_plugins.exe to be executed on a 32 or 64 bits Windows OS. You can bring your own modifications to the following lines if needed: 

- ```SET VERSION_PLUGIN=20000101```           # set the version of centreon-plugins, we recommend to follow official centreon_plugins releases (https://github.com/centreon-plugins/releases)
- ```set PERL_INSTALL_DIR=C:\Strawberry```    # set the path to your Strawberry perl installation dir 

If you want to add more plugins, its associated modes and dependencies, you can modify the ```CMD /C %PERL_INSTALL_DIR%\perl\site\bin\pp --lib=centreon-plugins\ ^``` command_line parameters. Only modify by adding of removing lines starting by -M. An extract below shows how we add our WSUS plugin to centreon_plugins.exe binary: 

```
-M apps::wsus::local::plugin ^
-M apps::wsus::local::mode::computersstatus ^
-M apps::wsus::local::mode::updatesstatus ^
-M apps::wsus::local::mode::synchronisationstatus ^
-M apps::wsus::local::mode::serverstatistics ^
```

#### builddef-<x64/Win32>.nsi

NullSoft Install Script system file. It will allow you to define some properties of your installer.

The three lines you may want to modify are:

```!define PRODUCT_VERSION "0.5.2.41"```                # Set the NSClient++ version, in this repository we are using 0.5.2.41, do not modify unless you know what you're doing

```!define PACKAGE_VERSION "20000101"```                # Set the release version, once again it's easier to stick to the official centreon-plugins release

```!define MSI_NSCLIENT "NSCP-0.5.2.41-Win32.msi"```    # If you modified the PRODUCT version, you may want to also tune this line to reflect the associated MSI

#### resources/nsclient.ini

This is your NSClient++ main config file, just modify it. A full documentation on available directives is avalaible from NSClient++ official website (https://docs.nsclient.org/tutorial/#default-settings).


### Building NSCLient++ agent with centreon_plugins.exe

Here are the step to take to build a NSClient agent: 

#### Clone repositories

```git clone https://github.com/centreon/centreon-nsclient-build```

* (optionnal) Update its submodule (centreon-plugins) 

:warning: Be warned that you might use some code from centreon-plugins master (=> unstable or wip code). If this is not what you want, just go to the next step. 

```
cd centreon-nsclient-build
git submodule update --init
```

#### build the 32bits plugin version

```C:\Your\path\to\localrepo\centreon-nsclient> build_centreon_plugins_32.bat```

Successful build output is like: 

```
        1 file(s) copied.
        1 file(s) copied.
Generating a gmake-style Makefile
Writing Makefile for myldr
Makefile:1080: warning: overriding recipe for target '.c.o'
Makefile:358: warning: ignoring old recipe for target '.c.o'
gcc -c -s -O2 -DWIN32 -D__USE_MINGW_ANSI_STDIO -DPERL_TEXTMODE_SCRIPTS -DPERL_IMPLICIT_CONTEXT -DPERL_IMPLICIT_SYS -DUSE_PERLIO -fwrapv -fno-
E"  -DLDLIBPTHNAME=\"\" -DPARL_EXE=\"parl.exe\" -DPAR_PACKER_VERSION=\"1.039\" -s -O2 main.c
windres -i winres/pp.rc -o ppresource.coff --input-format=rc --output-format=coff --target=pe-i386
g++ main.o ppresource.coff -s   -s -L"C:\STRAWB~2\perl\lib\CORE" -L"C:\STRAWB~2\c\lib"  "C:\STRAWB~2\perl\lib\CORE\libperl526.a" "C:\STRAWB~2
w64-mingw32\lib\libkernel32.a" "C:\STRAWB~2\c\i686-w64-mingw32\lib\libuser32.a" "C:\STRAWB~2\c\i686-w64-mingw32\lib\libgdi32.a" "C:\STRAWB~2\
[...]
[...]
[...]
Packing "C:\Users\ADMINI~1\AppData\Local\Temp\2\par-41646d696e6973747261746f72\cache-d9b6915b270bf0e6ae3204863f4f7c4a02de9245/f3a0f67d.dll"...
Written as "auto/File/Glob/Glob.xs.dll"
Press any key to continue . . .


C:\Your\path\to\localrepo\centreon-nsclient>
```

If it succeed, you must be able to see a centreon_plugins.exe in resources\scripts\Win32 directory.

#### build the 64bits plugin version

```C:\Your\path\to\localrepo\centreon-nsclient> build_centreon_plugins_64.bat```

Successful build output is like: 

```
        1 file(s) copied.
        1 file(s) copied.
Generating a gmake-style Makefile
Writing Makefile for myldr
Makefile:1080: warning: overriding recipe for target '.c.o'
Makefile:358: warning: ignoring old recipe for target '.c.o'
gcc -c -s -O2 -DWIN32 -DWIN64 -DCONSERVATIVE -D__USE_MINGW_ANSI_STDIO -DPERL_TEXTMODE_SCRIPTS -DPERL_IMPLICIT_CONTEXT -DPERL_IMPLICIT_SYS -DU
:\STRAWB~1\perl\lib\CORE"  -DLDLIBPTHNAME=\"\" -DPARL_EXE=\"parl.exe\" -DPAR_PACKER_VERSION=\"1.039\" -s -O2 main.c
windres -i winres/pp.rc -o ppresource.coff --input-format=rc --output-format=coff --target=pe-x86-64
g++ main.o ppresource.coff -s   -s -L"C:\STRAWB~1\perl\lib\CORE" -L"C:\STRAWB~1\c\lib"  "C:\STRAWB~1\perl\lib\CORE\libperl526.a" "C:\STRAWB~1
_64-w64-mingw32\lib\libkernel32.a" "C:\STRAWB~1\c\x86_64-w64-mingw32\lib\libuser32.a" "C:\STRAWB~1\c\x86_64-w64-mingw32\lib\libgdi32.a" "C:\S
[...]
[...]
[...]
Packing "C:\Users\ADMINI~1\AppData\Local\Temp\2\par-41646d696e6973747261746f72\cache-d9b6915b270bf0e6ae3204863f4f7c4a02de9245/f3a0f67d.dll"...
Written as "auto/File/Glob/Glob.xs.dll"
Press any key to continue . . .

C:\Your\path\to\localrepo\centreon-nsclient>
```

If it succeed, you must be able to see a centreon_plugins.exe in resources\scripts\x64 directory.

#### Build Centreon-NSCLient++ agent

```C:\Users\Administrator\Desktop\centreon-Agent-NSclient>build_centreon_nsclient.bat```

The process produces an output similar to: 

```
resources\scripts\Win32\centreon\centreon_plugins.exe
resources\scripts\Win32\centreon\check_logfiles.exe
2 File(s) copied
        1 file(s) copied.
        1 file(s) copied.

7-Zip (a) [32] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21

Scanning the drive:
2 folders, 4 files, 31971949 bytes (31 MiB)

Creating archive: ..\resources\resources.zip

Items to compress: 6


Files read from disk: 4
Archive size: 20661229 bytes (20 MiB)
Everything is Ok
----------------------------------------------------------------------
NSIS String Functions Header File 1.09 - Copyright 2004 Diego Pedroso
----------------------------------------------------------------------
 (C:\Users\Administrator\Desktop\centreon-Agent-NSclient\bin\nsis\Include\StrFunc.nsh:52)
$ {StrStrAdv} - Copyright 2003-2004 Diego Pedroso (macro:STRFUNC_FUNC:11)
$ {UnStrStrAdv} - Copyright 2003-2004 Diego Pedroso (macro:STRFUNC_FUNC:5)
$ {StrStrAdv} "$9" "$1" "{" "<" ">" "0" "0" "0" (macro:FUNCTION_STRING_StrStrAdv_Call:3)
$ {StrStrAdv} "$9" "$UninstallNSClientID" "}" "<" "<" "0" "0" "0" (macro:FUNCTION_STRING_StrStrAdv_Call:3)
$ {UnStrStrAdv} "$9" "$1" "{" "<" ">" "0" "0" "0" (macro:FUNCTION_STRING_UnStrStrAdv_Call:3)
$ {UnStrStrAdv} "$9" "$UninstallNSClientID" "}" "<" "<" "0" "0" "0" (macro:FUNCTION_STRING_UnStrStrAdv_Call:3)
Press any key to continue . . .

C:\Your\path\to\localrepo\centreon-nsclient>
```

Output of this build routine is two binaries: Centreon-NSClient-0.5.2.41-20000101-Win32.exe Centreon-NSClient-0.5.2.41-20000101-x64.exe

## Installation 

You can install the agent with a double-click on: Centreon-NSClient-0.5.2.41-20000101-Win32.exe or Centreon-NSClient-0.5.2.41-20000101-x64.exe. 

Note that you can use the following flags parameters of the .exe execution: 

    - /S : Silently installation
    - /nouninstall : no uninstall of the current package if it was already installed

Now, it's deployment time :) Enjoy ! 

## Plugin actually available with the centreon-plugins.exe binary 

- apps::activedirectory::local::plugin
- apps::backup::netbackup::local::plugin
- apps::backup::veeam::local::plugin
- apps::centreon::local::plugin
- apps::citrix::local::plugin
- apps::cluster::mscs::local::plugin
- apps::exchange::2010::local::plugin (works also with Exchange > 2010)
- apps::hyperv::2012::local::plugin
- apps::iis::local::plugin
- apps::protocols::ftp::plugin
- apps::protocols::http::plugin
- apps::protocols::ldap::plugin
- apps::protocols::tcp::plugin
- apps::protocols::x509::plugin
- apps::sccm::local::plugin
- apps::wsus::local::plugin
- hardware::devices::safenet::hsm::protecttoolkit::plugin
- os::windows::local::plugin
- storage::dell::compellent::local::plugin
- storage::emc::symmetrix::vmax::local::plugin

