$! This command procedure runs the test
$! for 'git status -z' command
$!
$ TEST_NAME = "GIT_STATUS_Z"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$ PIPE CREATE a.txt > NL: 2> NL:
$ PIPE CREATE b.txt > NL: 2> NL:
$ PIPE git status -z | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
