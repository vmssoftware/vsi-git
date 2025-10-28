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
$! This command procedure runs the test
$! for "git bisect reset with an argument" option.
$!
$ TEST_NAME = "GIT_BISECT_RESET_ARG"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ CURRENT_CWD = f$directory()
$ PIPE git init > NL: 2> NL:
$ PIPE CREATE temp-file.vmq > NL: 2> NL:
$ PIPE git add temp-file.vmq > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$!
$ PIPE git commit -m "Initial commit" > NL: 2> NL:
$ PIPE git rev-parse HEAD | (READ SYS$PIPE INIT_ID && DEFINE/JOB/NOLOG INIT_ID &INIT_ID)
$ INIT_ID = F$TRNLNM("INIT_ID","LNM$JOB")
$ DEASIGN/JOB INIT_ID
$!
$ OPEN/APPEND OUTPUT_FILE_1 'CURRENT_CWD'temp-file.vmq
$ WRITE OUTPUT_FILE_1 "BEGINNING PHASE 1"
$ CLOSE OUTPUT_FILE_1
$ PIPE git add temp-file.vmq > NL: 2> NL:
$ PIPE git commit -m "Bad version" > NL: 2> NL:
$ PIPE git rev-parse HEAD | (READ SYS$PIPE BAD_ID && DEFINE/JOB/NOLOG BAD_ID &BAD_ID)
$ BAD_ID = F$TRNLNM("BAD_ID","LNM$JOB")
$ DEASIGN/JOB BAD_ID
$!
$ OPEN/APPEND OUTPUT_FILE_3 'CURRENT_CWD'temp-file.vmq
$ WRITE OUTPUT_FILE_3 "BEGINNING PHASE 2"
$ CLOSE OUTPUT_FILE_3
$ PIPE git add temp-file.vmq > NL: 2> NL:
$ PIPE git commit -m "Last commit" > NL: 2> NL:
$!
$ PIPE git bisect start > NL: 2> NL:
$ PIPE git bisect bad > NL: 2> NL:
$ PIPE git bisect good 'INIT_ID' > NL: 2> NL:
$ PIPE git bisect reset HEAD
$ PIPE git rev-parse HEAD | (READ SYS$PIPE CURR_ID && DEFINE/JOB/NOLOG CURR_ID &CURR_ID)
$ CURR_ID = F$TRNLNM("CURR_ID","LNM$JOB")
$ DEASIGN/JOB CURR_ID
$ IF CURR_ID .EQS. BAD_ID
$ THEN
$   PIPE WRITE SYS$OUTPUT "pass" | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ ELSE
$   PIPE WRITE SYS$OUTPUT "fail" | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ ENDIF
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
