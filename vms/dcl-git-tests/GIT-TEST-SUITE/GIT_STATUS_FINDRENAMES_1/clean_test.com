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
$ PURGE
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
$ OUT_FILES = F$SEARCH("*.TXT;*")
$ IF OUT_FILES .NES. ""
$ THEN
$   DELETE *.TXT;*
$ ENDIF
$!
$ TEST_FOLDER = F$SEARCH("TEST.DIR;1")
$ IF TEST_FOLDER .NES. ""
$ THEN
$   DELETE/TREE [.TEST...]*.*;*
$   SET FILE/PROT=O:D TEST.DIR
$   DELETE TEST.DIR;
$ ENDIF
