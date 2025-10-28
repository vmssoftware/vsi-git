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
$! Set up Git environment
$!
$ SAY :== "WRITE SYS$OUTPUT"
$!
$ DEFINE_ROOT := SYS$COMMON:[SYS$STARTUP]GIT$DEFINE_ROOT.COM
$ IF f$search("''DEFINE_ROOT';*") .NES. ""
$ THEN
$   @'DEFINE_ROOT'
$ ELSE
$   SAY "GIT$ROOT logical is not defined!"
$ ENDIF
$!
$ GIT :== $GIT$ROOT:[GIT_CORE]GIT.EXE
