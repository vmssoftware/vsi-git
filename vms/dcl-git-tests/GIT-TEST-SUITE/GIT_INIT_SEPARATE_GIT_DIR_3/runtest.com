$! This command procedure runs the test
$! for 'git init --separate-git-dir=<git-dir>' command
$!
$ TEST_NAME = "GIT_INIT_SEPARATE"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ CC 'CWD'test.c
$ LINK test
$ RUN test
$ PIPE CREATE/dir [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE CREATE/dir [.TEST1] > NL: 2> NL:
$ PIPE CREATE/dir [.TEST2] > NL: 2> NL:
$ SET DEFAULT [.TEST2]
$ CWD1 = f$directory()
$ SET DEFAULT [-]
$ SET DEFAULT [.TEST1]
$ PIPE git init --separate-git-dir='CWD1' > NL: 2> NL:
$ SET DEF [-.TEST2]
$ PIPE dir [...] | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEF [--]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
