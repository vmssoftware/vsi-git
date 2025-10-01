$! This command procedure runs the test
$! for 'git' command.
$!
$ TEST_NAME = "GIT_1"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT", "LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE GIT | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT