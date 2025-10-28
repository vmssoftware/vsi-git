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
$! for 'git stash' command, in
$!
$ TEST_NAME = "GIT_STASH_4"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ PIPE SET DEFAULT [.TEST] > NL: 2> NL:
$!
$ CREATE TEMP.VMQ
$ SET FILE/PROTECTION=(S:RWE,O:RWE,G:RWE,W:RWE) TEMP.VMQ
$ OPEN/WRITE logname TEMP.VMQ
$ WRITE logname "Before Commit"
$ CLOSE logname
$!
$ PIPE git init > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$ git add TEMP.VMQ
$ PIPE git commit -m "some_message" > NL: 2> NL:
$!
$ OPEN/APPEND logname TEMP.VMQ
$ WRITE logname "After Commit"
$ CLOSE logname
$!
$ PIPE PURGE > NL: 2> NL:
$ PIPE git stash | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$!
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT_STASH.COM
$!
$ EXIT
