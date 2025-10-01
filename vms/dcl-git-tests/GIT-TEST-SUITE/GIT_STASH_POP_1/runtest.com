$! This command procedure runs the test
$! for 'git stash pop' command, in
$!
$ TEST_NAME = "GIT_STASH_POP_1"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ PIPE SET DEFAULT [.TEST] > NL: 2> NL:
$!
$ CREATE TEMP.VMQ
$ SET FILE/PROTECTION=(S:RWE,O:RWE,G:RWE,W:RWE) TEMP.VMQ
$ OPEN/WRITE logname TEMP.VMQ
$ WRITE logname "Before Commit"
$ CLOSE logname
$!
$ PIPE git init > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$ git add TEMP.VMQ
$ PIPE git commit -m "some_message" > NL: 2> NL:
$!
$ OPEN/APPEND logname TEMP.VMQ
$ WRITE logname "After Commit"
$ CLOSE logname
$!
$ PIPE PURGE > NL: 2> NL:
$ PIPE git stash > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE git stash pop > NL: 2> NL:
$ PIPE TYPE TEMP.VMQ | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$!
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
