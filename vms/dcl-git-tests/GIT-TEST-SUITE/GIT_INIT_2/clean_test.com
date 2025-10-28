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
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$!
$ LOG_FILES = F$SEARCH("*.LOG;*")
$ IF LOG_FILES .NES. ""
$ THEN
$   DELETE *.LOG;*
$ ENDIF
$!
$ OUT_FILES = F$SEARCH("*.OUT;*")
$ IF OUT_FILES .NES. ""
$ THEN
$   DELETE *.OUT;*
$ ENDIF
$!
$ GIT_FOLDER = F$SEARCH("TEST.DIR;1")
$ IF GIT_FOLDER .NES. ""
$ THEN
$   @'OUT_DIR'REMOVE_DIR test
$ ENDIF
$!
$ OBJ_FILES = F$SEARCH("*.OBJ;*")
$ IF OBJ_FILES .NES. ""
$ THEN
$   DELETE *.OBJ;*
$ ENDIF
$!
$ EXE_FILES = F$SEARCH("*.EXE;*")
$ IF EXE_FILES .NES. ""
$ THEN
$   DELETE *.EXE;*
$ ENDIF
$!
$ git_init_FILES = F$SEARCH("git_init.exp;*")
$ IF git_init_FILES .NES. ""
$ THEN
$   DELETE git_init.exp;*
$ ENDIF
