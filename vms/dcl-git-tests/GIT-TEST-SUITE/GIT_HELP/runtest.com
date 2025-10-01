$! This command procedure runs the test
$! for 'git help' command.
$!
$ TEST_NAME = "GIT_HELP"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE GIT help | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
