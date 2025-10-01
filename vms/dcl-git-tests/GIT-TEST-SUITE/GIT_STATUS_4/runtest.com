$! This command procedure runs the test
$! for 'git status' command, after deleting 
$! already added file.
$!
$ TEST_NAME = "GIT_STATUS_4"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$ CREATE test-file-1.cpp
$ PIPE GIT add test-file-1.cpp  > NL: 2> NL:
$ PIPE delete test-file-1.cpp;* > NL: 2> NL:
$ PIPE GIT status | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT


