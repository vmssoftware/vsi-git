$! This command procedure runs the test
$! for 'git status -unormal' command.
$! Shows untracked files and directories.
$!
$ TEST_NAME = "GIT_STATUS_UNORMAL"
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
$ PIPE CREATE/DIRECTORY [.TEST_2] > NL: 2> NL:
$ SET DEFAULT [.TEST_2]
$!
$ CREATE test_file_3.txt    !testing untracked files
$ CREATE test_file_4.txt    !testing untracked files
$!
$ SET DEFAULT [-]
$ PIPE git add test_file_1.txt  > NL: 2> NL:
$ PIPE git add test_file_2.txt  > NL: 2> NL:
$!
$ PIPE git status -unormal | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ SET DEFAULT [-]
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$!
$ EXIT
