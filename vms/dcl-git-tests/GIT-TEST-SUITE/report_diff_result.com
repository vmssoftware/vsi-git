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
$ DIFF 'CWD''TEST_NAME'.OUT 'CWD''TEST_NAME'.EXP
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
