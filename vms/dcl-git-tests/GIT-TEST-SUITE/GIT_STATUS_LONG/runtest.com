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
$! for 'git status --long' command
$!
$ TEST_NAME = "GIT_STATUS_LONG"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$!
$ CREATE test_file_1.txt    !testing modified files
$ CREATE test_file_2.txt    !testing added files
$ CREATE test_file_3.txt    !testing untracked files
$ CREATE test_file_4.txt    !testing deleted files
$!
$ PIPE GIT add test_file_1.txt  > NL: 2> NL:
$ PIPE GIT add test_file_2.txt  > NL: 2> NL:
$ PIPE GIT add test_file_4.txt  > NL: 2> NL:
$ PIPE DELETE test_file_4.txt;*  > NL: 2> NL:
$!
$ CWD1 = f$directory()
$ @'OUT_DIR'APPEND_TEXT.COM 'CWD1'test_file_1.txt
$ PIPE GIT status --long | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
