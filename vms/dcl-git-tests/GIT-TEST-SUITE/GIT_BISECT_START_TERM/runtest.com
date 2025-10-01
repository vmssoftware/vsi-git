$! This command procedure runs the test
$! for 'git bisect start --term-(new|bad)=<term-new> --term-(old|good)=<term-old>' command
$!
$ TEST_NAME = "GIT_BISECT_START_TERM"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$ PIPE create a.txt > NL: 2> NL:
$ PIPE git add a.txt > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$ PIPE git commit -m "Example commit" > NL: 2> NL:
$ PIPE git bisect start --term-new=bug --term-old=feature > NL: 2> NL:
$ PIPE git bisect terms | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
