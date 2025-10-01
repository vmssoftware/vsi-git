$! This command procedure runs the test
$! for 'git status --show-stash' command
$!
$ TEST_NAME = "GIT_STATUS_SHOW_STASH"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$!	
$ CREATE file.txt 
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$ PIPE GIT add file.txt  > NL: 2> NL:
$ PIPE GIT commit -m "Add test1.txt" > NL: 2> NL:
$!
$ CREATE test1.txt 
$ PIPE GIT add test1.txt > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE GIT stash > NL: 2> NL:
$!
$ CREATE test2.txt
$ PIPE GIT add test2.txt  > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE GIT stash  > NL: 2> NL:
$!
$ PIPE GIT status --show-stash | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
