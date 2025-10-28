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
$! for 'git init -q' command.
$! Checks if the command creates the necessary files.
$!
$ TEST_NAME = "GIT_INIT_Q_3"
$ SKIP = "EXPECTED"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ CC test.c
$ LINK test
$ RUN test
$ PURGE
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ git init -q
$ SET DEF [.^.GIT]
$ PIPE dir [...] | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEF [--]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
