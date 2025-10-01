$! This command procedure runs the test
$! for 'git status --renames' command
$!
$ TEST_NAME = "GIT_STATUS_RENAMES"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$ PIPE create a.txt > NL: 2> NL:
$ PIPE git add a.txt > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$ PIPE git commit -m "Example commit" > NL: 2> NL:
$ PIPE git mv a.txt b.txt
$ PIPE GIT status --renames | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
