$! This command procedure runs the test
$! for 'git init -q' command.
$! Chechks if the command shows errors.
$!
$ TEST_NAME = "GIT_INIT_Q_2"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE git init -q --bare --separate-git-dir=path_sample | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
