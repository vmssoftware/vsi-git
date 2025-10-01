$! This command procedure runs the test
$! for 'git status -uall' command.
$! Shows individual files in untracked directories
$!
$ TEST_NAME = "GIT_STATUS_UALL"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$!
$ CREATE test_file_1.txt    !testing added files
$ CREATE test_file_2.txt    !testing added files
$!
$ PIPE CREATE/dir [.TEST_2] > NL: 2> NL:
$ SET DEFAULT [.TEST_2]
$!
$ CREATE test_file_3.txt    !testing untracked files
$ CREATE test_file_4.txt    !testing untracked files
$!
$ SET DEFAULT [-]
$ PIPE GIT add test_file_1.txt  > NL: 2> NL:
$ PIPE GIT add test_file_2.txt  > NL: 2> NL:
$!
$ PIPE GIT status -uall | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
