$! This command procedure runs the test
$! for 'git status' command, when there is not a git repository.
$!set def 
$ TEST_NAME = "GIT_STATUS_1"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE git status | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
