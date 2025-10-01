$! This command procedure runs the test
$! for 'git init' command.
$!
$ SKIP = "EXPECTED"
$ TEST_NAME = "GIT_INIT"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CC test.c > NL: 2> NL:
$ PIPE LINK test > NL: 2> NL:
$ PIPE RUN test > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
