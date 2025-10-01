$! This command procedure runs the test
$! for 'git status -no-column' command.
$!
$ TEST_NAME = "GIT_STATUS_NO_COLUMN"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$!
$ CREATE test_file_1.txt   
$ CREATE test_file_2.txt    
$ CREATE test_file_3.txt    
$ CREATE test_file_4.txt    
$!
$ PIPE GIT status --no-column | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
