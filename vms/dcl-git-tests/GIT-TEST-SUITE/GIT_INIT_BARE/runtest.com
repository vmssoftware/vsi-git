$! This command procedure runs the test
$! for 'git --bare init' command.
$! 
$ SKIP = "EXPECTED"
$ TEST_NAME = "GIT_INIT_BARE"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ CC test.c
$ LINK test
$ RUN test
$ PURGE
$ PIPE GIT --bare init | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT