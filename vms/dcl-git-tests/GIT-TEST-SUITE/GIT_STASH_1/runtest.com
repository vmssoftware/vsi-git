$! This command procedure runs the test
$! for 'git stash' command in emtpy directory
$!
$ TEST_NAME = "GIT_STASH_1"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ PIPE SET DEFAULT [.TEST] > NL: 2> NL:
$ PIPE git init > NL: 2> NL:
$!
$ PIPE git stash | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEFAULT [-]
$!
$ EXIT
