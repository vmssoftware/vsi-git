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
$! for 'git init --separate-git-dir=<git-dir>' command
$
$ TEST_NAME = "GIT_INIT_SEPARATE"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ CC 'CWD'test.c
$ CC 'CWD'helper.c
$ LINK test, helper
$ RUN test
$ PIPE CREATE/dir [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE CREATE/dir [.TEST1] > NL: 2> NL:
$ PIPE CREATE/dir [.TEST2] > NL: 2> NL:
$ SET DEFAULT [.TEST2]
$ CWD1 = f$directory()
$ SET DEFAULT [-]
$ SET DEFAULT [.TEST1]
$ PIPE git init --separate-git-dir='CWD1' > NL: 2> NL:
$ PIPE type git. | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEF [--]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$
$ EXIT
