$! Copyright (C) 2025 VMS Software, Inc.
$!
$! This program is free software: you can redistribute it and/or modify it
$! under the terms of the GNU General Public License as published by the Free
$! Software Foundation version 2 of the License.
$!
$! This program is distributed in the hope that it will be useful, but WITHOUT
$! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
$! FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
$!
$! You should have received a copy of the GNU General Public License along with
$! this program. If not, see https://www.gnu.org/licenses/
$!
$ root = f$trnlmn("pcsi$destination") - "]" + "GIT.]"
$ define GIT$ROOT 'root' /trans=conc /exec /sys
$ open/write fd SYS$COMMON:[SYS$STARTUP]GIT$DEFINE_ROOT.COM
$ write fd "$ define/nolog/exec/trans=conc GIT$ROOT ''root'"
$ write fd "$ exit"
$ close fd
$ purge/nolog SYS$COMMON:[SYS$STARTUP]GIT$DEFINE_ROOT.COM
$ set sec /prot=(w:re) SYS$COMMON:[SYS$STARTUP]GIT$DEFINE_ROOT.COM
$! Enhance privilege of git.exe
$ set message /noFACILITY /noSEVERITY /noIDENTIFICATION /noTEXT
$ install remove git$root:[git_core]git.exe
$ install remove git$root:[git_core]git-remote-http.exe
$ install remove git$root:[git_core]async_proc_wrapper.exe
$ install remove git$root:[git_core]git-upload-pack.exe
$ install remove git$root:[git_core]git-receive-pack.exe
$ install remove git$root:[ext_libs]libcurl$shr64.exe
$!
$ install add /privileged=(share) git$root:[git_core]git.exe
$ install add /privileged=(share) git$root:[git_core]git-remote-http.exe
$ install add /privileged=(share) git$root:[git_core]async_proc_wrapper.exe
$ install add /privileged=(share) git$root:[git_core]git-upload-pack.exe
$ install add /privileged=(share) git$root:[git_core]git-receive-pack.exe
$ install add /shared git$root:[ext_libs]libcurl$shr64.exe
$ set sec/prot=(w:r) git$root:[ext_libs]libcurl$shr64.exe
$! Enable Git in Bash
$ cpu_arch = f$getsyi("ARCH_NAME")
$ if cpu_arch .EQS. "IA64"
$ then
$   if f$search("sys$startup:gnv$startup.com") .NES. ""
$   then
$       @sys$startup:gnv$startup.com
$       if f$search("gnu:[bin]git.exe") .EQS. ""
$       then
$           copy git$root:[git_core]git.exe gnu:[bin] /nolog
$           set sec/prot=(w:re) gnu:[bin]git.exe
$       endif
$   endif
$ endif
$!
$ if cpu_arch .EQS. "x86_64"
$ then
$   if f$search("sys$startup:gnv$setup.com") .NES. ""
$   then
$       @sys$startup:gnv$setup.com
$       if f$search("gnu:[bin]git.exe") .EQS. ""
$       then
$           copy git$root:[git_core]git.exe gnu:[bin] /nolog
$           set sec/prot=(w:re) gnu:[bin]git.exe
$       endif
$   endif
$ endif
$!
$ set message /FACILITY /SEVERITY /IDENTIFICATION /TEXT
$ exit 1
