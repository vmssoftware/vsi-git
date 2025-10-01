$! This command procedure runs the test
$! for 'git status --porcelain[=<version>]' command.
$! By default the version is v1
$!
$ TEST_NAME = "GIT_STATUS_PORCELAIN_1"
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
$ PIPE GIT add test_file_1.txt  > NL: 2> NL:
$ PIPE GIT add test_file_2.txt  > NL: 2> NL:
$ PIPE GIT add test_file_4.txt  > NL: 2> NL:
$ PIPE DELETE test_file_4.txt;*  > NL: 2> NL:
$!
$ CWD1 = f$directory()
$ @'OUT_DIR'APPEND_TEXT.COM 'CWD1'test_file_1.txt
$ PIPE GIT status --porcelain | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
