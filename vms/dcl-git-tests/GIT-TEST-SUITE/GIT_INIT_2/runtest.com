$! This command procedure runs the test
$! for 'git init' command.
$!
$ SKIP = "EXPECTED"
$ TEST_NAME = "GIT_INIT"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ CC test.c
$ LINK test
$ RUN test
$ PURGE
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEF [.TEST]
$ PIPE git init > NL: 2> NL:
$ SET DEF [.GIT]
$ PIPE dir [...] | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ SET DEF [--]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
