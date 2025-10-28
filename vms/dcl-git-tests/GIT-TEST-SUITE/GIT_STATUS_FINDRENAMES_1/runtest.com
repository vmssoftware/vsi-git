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
$! for "git status git status --find-renames" option
$!
$ TEST_NAME = "GIT_STATUS_FIND_RENAMES_1"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ CURRENT_CWD = f$directory()
$ PIPE git init > NL: 2> NL:
$ PIPE create file1.txt > NL: 2> NL:
$ PIPE create file2.txt > NL: 2> NL:
$ PIPE git add . > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$ PIPE git commit -m "Initial commit" > NL: 2> NL:
$ PIPE git mv file1.txt new_file1.txt
$ OPEN/APPEND OUTPUT_FILE 'CURRENT_CWD'file2.txt
$ WRITE OUTPUT_FILE "BEGINNING PHASE 1"
$ CLOSE OUTPUT_FILE
$ PIPE git add . > NL: 2> NL:
$ PIPE git status --find-renames | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
