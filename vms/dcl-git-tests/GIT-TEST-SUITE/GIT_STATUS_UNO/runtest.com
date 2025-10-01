$! This command procedure runs the test
$! for 'git status -uno' command.
$! Show no untracked files.
$!
$ TEST_NAME = "GIT_STATUS_UNO"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$!
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ PIPE git init > NL: 2> NL:
$!
$ CREATE test_file_1.txt    !testing added files
$ CREATE test_file_2.txt    !testing added files
$ CREATE test_file_3.txt    !testing untracked files
$ CREATE test_file_4.txt    !testing untracked files
$!
$ PIPE GIT add test_file_1.txt  > NL: 2> NL:
$ PIPE GIT add test_file_2.txt  > NL: 2> NL:
$!
$ CWD1 = f$directory()
$ PIPE GIT status -uno | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
