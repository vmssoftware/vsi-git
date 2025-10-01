$! This command procedure runs the test
$! for 'git init -q' command.
$! Chechks if the command doesn't show warnings and hints.
$!
$ TEST_NAME = "GIT_INIT_Q_1"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init -q | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
