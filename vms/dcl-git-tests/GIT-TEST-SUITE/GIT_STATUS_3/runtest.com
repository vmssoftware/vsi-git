$! This command procedure runs the test
$! for 'git status' command, after git init
$! after adding some files and directory
$!
$ TEST_NAME = "GIT_STATUS_3"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$ CREATE test-file-1.cpp
$ CREATE test-file-2.c
$ PIPE CREATE/dir [.TEST_2] > NL: 2> NL:
$ SET DEFAULT [.TEST_2]
$ CREATE test-file-3.c
$ SET DEFAULT [-]
$ PIPE GIT status | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
