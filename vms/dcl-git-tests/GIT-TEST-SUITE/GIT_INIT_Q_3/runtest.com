$! This command procedure runs the test
$! for 'git init -q' command.
$! Checks if the command creates the necessary files.
$!
$ TEST_NAME = "GIT_INIT_Q_3"
$ SKIP = "EXPECTED"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ CC test.c
$ LINK test
$ RUN test
$ PURGE
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ git init -q
$ SET DEF [.^.GIT]
$ PIPE dir [...] | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEF [--]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
