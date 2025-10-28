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
$!Cheking result
$ STATUS == "CRASH"
$ ON ERROR THEN GOTO FINISH
$
$ DEFINE/USER_MODE SYS$ERROR  'CWD'ERROR.LOG
$ DEFINR/USER_MODE SYS$OUTPUT 'CWD'ERROR.LOG
$
$ OPEN/READ FILE1 'CWD''TEST_NAME'.OUT 
$ OPEN/READ FILE2 'CWD''TEST_NAME'.EXP
$ OPEN/WRITE TEMP1 'CWD''TEST_NAME_TMP'.OUT
$ OPEN/WRITE TEMP2 'CWD''TEST_NAME_TMP'.EXP
$
$ LOOP:
$ READ/END_OF_FILE=EOF FILE1 RECORD1
$ READ/END_OF_FILE=EOF FILE2 RECORD2
$ $POS1 = F$LOCATE(": ", RECORD1)
$ $POS2 = F$LOCATE(": ", RECORD2)
$ $TEXT1 = F$EXTRACT(0, $POS1, RECORD1)
$ $TEXT2 = F$EXTRACT(0, $POS2, RECORD2)
$ $TEXT1 = $TEXT1 + ": some_message"
$ $TEXT2 = $TEXT2 + ": some_message"
$ WRITE TEMP1 $TEXT1
$ WRITE TEMP2 $TEXT2
$ GOTO LOOP
$
$ EOF:
$ CLOSE FILE1
$ CLOSE FILE2
$ CLOSE TEMP1
$ CLOSE TEMP2
$
$ DIFF 'CWD''TEST_NAME_TMP'.OUT 'CWD''TEST_NAME_TMP'.EXP
$ diff_status = $STATUS
$
$ IF F$TYPE(SKIP).EQS."" THEN SKIP = "NONE"
$ IS_SKIPPED == (SKIP.EQS."EXPECTED") .OR. (SKIP .EQS. "UNEXPECTED")
$ SKIP = "NONE"
$
$ IF diff_status .eq. 7110665 ! files are identical
$ THEN
$   STATUS == "PASS"
$   IF IS_SKIPPED THEN STATUS == "UNEXPECTED"
$ ELSE
$   IF diff_status .eq. 7110675 THEN STATUS == "DIFF" ! files are different
$   IF IS_SKIPPED THEN STATUS == "EXPECTED"
$ ENDIF
$ FINISH:
$ WRITE SYS$OUTPUT "  STATUS: ''STATUS'"
$ EXIT 1 
