$! This command procedure runs the test
$! for 'git help -g' command.
$!
$ TEST_NAME = "GIT_HELP_G"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE git help -g | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT


