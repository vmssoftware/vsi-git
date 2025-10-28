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
$ OUT_FILES = F$SEARCH("*GIT_INIT_SEPARATE.EXP;*")
$ IF OUT_FILES .NES. ""
$ THEN
$   DELETE GIT_INIT_SEPARATE.EXP;*
$ ENDIF
$!
$ TEST_FOLDER = F$SEARCH("TEST.DIR;*")
$ IF TEST_FOLDER .NES. ""
$ THEN
$   @'OUT_DIR'REMOVE_DIR TEST
$ ENDIF
$!
$ OUT_FILES = F$SEARCH("*.OBJ;*")
$ IF OUT_FILES .NES. ""
$ THEN
$   DELETE *.OBJ;*
$ ENDIF
$!
$ OUT_FILES = F$SEARCH("*.EXE;*")
$ IF OUT_FILES .NES. ""
$ THEN
$   DELETE *.EXE;*
$ ENDIF
