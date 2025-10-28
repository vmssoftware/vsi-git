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
$! for "git bisect start --no-checkout" option.
$!
$ TEST_NAME = "GIT_BISECT_START_NO_CHECKOUT"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ CURRENT_CWD = f$directory()
$ PIPE git init > NL: 2> NL:
$ PIPE CREATE file1.vmq > NL: 2> NL:
$ PIPE git add file1.vmq > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$!
$ PIPE git commit -m "file1.vmq" > NL: 2> NL:
$ PIPE git rev-parse HEAD | (READ SYS$PIPE GOOD_COMMIT_1 && DEFINE/JOB/NOLOG GOOD_COMMIT_1 &GOOD_COMMIT_1)
$ GOOD_COMMIT_1 = F$TRNLNM("GOOD_COMMIT_1","LNM$JOB")
$ DEASIGN/JOB GOOD_COMMIT_1
$!
$ PIPE CREATE file2.vmq > NL: 2> NL:
$ PIPE git add file2.vmq > NL: 2> NL:
$ PIPE git commit -m "file2.vmq" > NL: 2> NL:
$ PIPE git rev-parse HEAD | (READ SYS$PIPE GOOD_COMMIT_2 && DEFINE/JOB/NOLOG GOOD_COMMIT_2 &GOOD_COMMIT_2)
$ GOOD_COMMIT_2 = F$TRNLNM("GOOD_COMMIT_2","LNM$JOB")
$ DEASIGN/JOB GOOD_COMMIT_2
$!
$ PIPE CREATE file3.vmq > NL: 2> NL:
$ PIPE git add file3.vmq > NL: 2> NL:
$ PIPE git commit -m "file3.vmq" > NL: 2> NL:
$ PIPE git rev-parse HEAD | (READ SYS$PIPE BAD_COMMIT && DEFINE/JOB/NOLOG BAD_COMMIT &BAD_COMMIT)
$ BAD_COMMIT == F$TRNLNM("BAD_COMMIT","LNM$JOB")
$ DEASIGN/JOB BAD_COMMIT
$!
$ PIPE git bisect start --no-checkout > NL: 2> NL:
$ PIPE git bisect bad 'BAD_COMMIT' > NL: 2> NL:
$ PIPE git bisect good 'GOOD_COMMIT_1' > NL: 2> NL:
$!
$ PIPE git rev-parse HEAD | (READ SYS$PIPE CURRENT_HEAD && DEFINE/JOB/NOLOG CURRENT_HEAD &CURRENT_HEAD)
$ CURRENT_HEAD = F$TRNLNM("CURRENT_HEAD","LNM$JOB")
$ DEASIGN/JOB CURRENT_HEAD 
$!
$ PIPE CREATE 'CWD''TEST_NAME'.OUT > NL: 2> NL:
$ OPEN /WRITE OUT_FILE 'CWD''TEST_NAME'.OUT
$!
$ IF CURRENT_HEAD .EQS. GOOD_COMMIT_2 THEN GOTO UPDATE_FILE
$ WRITE OUT_FILE "pass"
$ GOTO FINISH
$ UPDATE_FILE:
$ 	WRITE OUT_FILE "fail"
$!
$ FINISH:
$ 	CLOSE OUT_FILE
$	PURGE
$   @'OUT_DIR'REPORT_DIFF_RESULT.COM
$   SET DEF [-]
$!
$ EXIT
