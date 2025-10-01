$! This command procedure runs the test
$! for "git status git status --find-renames" option
$!
$ TEST_NAME = "GIT_STATUS_FIND_RENAMES_1"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ CURRENT_CWD = f$directory()
$ PIPE git init > NL: 2> NL:
$ PIPE create file1.txt > NL: 2> NL:
$ PIPE create file2.txt > NL: 2> NL:
$ PIPE git add . > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$ PIPE git commit -m "Initial commit" > NL: 2> NL:
$ PIPE git mv file1.txt new_file1.txt
$ OPEN/APPEND OUTPUT_FILE 'CURRENT_CWD'file2.txt
$ WRITE OUTPUT_FILE "BEGINNING PHASE 1"
$ CLOSE OUTPUT_FILE
$ PIPE git add . > NL: 2> NL:
$ PIPE git status --find-renames | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
