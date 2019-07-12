# Centreon-Agent-NSClient

## Introduction

This project aims to build the _centreon\_plugins.exe_ script and the Centreon's NSClient++ installation package.

## Basic usage

### Build _centreon\_plugins.exe_

Download latest release of _centreon\_plugins_ projet.

Edit _VERSION\_PLUGIN_ variable to set release version.

Launch both _build\_centreon\_plugins\_32.bat_ and _build\_centreon\_plugins\_64.bat_ scripts to build Win32 et x64 versions of _centreon\_plugins.exe_.

### Build Centreon NSClient++

Edit _builddef-Win32.nsi_ and _builddef-x64.nsi_ to set _centreon\_plugins_ projet release version and NSClient++ version.

Launch _build\_centreon\_nsclient.bat_ to build both Win32 et x64 versions of Centreon NSClient++.
