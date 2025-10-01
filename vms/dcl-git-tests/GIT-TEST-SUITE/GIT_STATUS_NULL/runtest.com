$! This command procedure runs the test
$! for 'git status --null' command
$!
$ TEST_NAME = "GIT_STATUS_NULL"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$!
$ CREATE test_file_1.txt
$ CREATE test_file_2.txt
$!
$ PIPE git add test_file_1.txt  > NL: 2> NL:
$ PIPE git add test_file_2.txt  > NL: 2> NL:
$ PIPE DELETE test_file_2.txt;*  > NL: 2> NL:
$!
$ PIPE git status --null | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
