$! This command procedure runs the test
$! for "git status git status --find-renames" option
$!
$ TEST_NAME = "GIT_STATUS_FIND_RENAMES_2"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ CURRENT_CWD = f$directory()
$ PIPE git init > NL: 2> NL:
$ PIPE create file.txt > NL: 2> NL:
$ OPEN/APPEND OUTPUT_FILE 'CURRENT_CWD'file.txt
$ WRITE OUTPUT_FILE "AA"
$ WRITE OUTPUT_FILE "BB"
$ CLOSE OUTPUT_FILE
$ PIPE git add . > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$ PIPE git commit -m "Initial commit" > NL: 2> NL:
$ PIPE git mv file.txt new_file.txt
$ OPEN/APPEND NEW_OUTPUT_FILE 'CURRENT_CWD'new_file.txt
$ WRITE NEW_OUTPUT_FILE "CC"
$ WRITE NEW_OUTPUT_FILE "DD"
$ WRITE NEW_OUTPUT_FILE "EE"
$ CLOSE NEW_OUTPUT_FILE
$ PIPE git add . > NL: 2> NL:
$ PIPE git status --find-renames=10% | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
