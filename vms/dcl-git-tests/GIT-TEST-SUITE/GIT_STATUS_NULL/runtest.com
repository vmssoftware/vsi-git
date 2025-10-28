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
$! for 'git status --null' command
$!
$ TEST_NAME = "GIT_STATUS_NULL"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$!
$ CREATE test_file_1.txt
$ CREATE test_file_2.txt
$!
$ PIPE git add test_file_1.txt  > NL: 2> NL:
$ PIPE git add test_file_2.txt  > NL: 2> NL:
$ PIPE DELETE test_file_2.txt;*  > NL: 2> NL:
$!
$ PIPE git status --null | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
