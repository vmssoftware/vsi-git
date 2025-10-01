$! This command procedure runs the test
$! for 'git status -b (--branch)' command
$!
$ TEST_NAME = "GIT_STATUS_BRANCH_1"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$!	
$ CREATE test1.txt 
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$ PIPE GIT add test1.txt  > NL: 2> NL:
$ PIPE GIT commit -m "Add test1.txt" > NL: 2> NL:
$!
$ PIPE GIT branch test-branch > NL: 2> NL:
$ PIPE GIT checkout test-branch > NL: 2> NL:
$ CREATE test.txt 
$ PIPE GIT add test.txt > NL: 2> NL:
$ PIPE GIT status -b | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
