$! This command procedure runs the test
$! for "git bisect log" option.
$!
$ TEST_NAME = "GIT_BISECT_GOOD_BAD_LOG"
$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$ CWD = f$directory()
$ PIPE CREATE/DIRECTORY [.TEST] > NL: 2> NL:
$ SET DEFAULT [.TEST]
$ CURRENT_CWD = f$directory()
$ PIPE git init > NL: 2> NL:
$ PIPE CREATE temp-file.vmq > NL: 2> NL:
$ PIPE git add temp-file.vmq > NL: 2> NL:
$ PIPE PURGE > NL: 2> NL:
$ PIPE git config user.email "you@example.com" > NL: 2> NL:
$ PIPE git config user.name "Your Name" > NL: 2> NL:
$!
$ PIPE git commit -m "Initial commit" > NL: 2> NL:
$ PIPE git rev-parse HEAD | (READ SYS$PIPE INIT_ID && DEFINE/JOB/NOLOG INIT_ID &INIT_ID)
$ INIT_ID = F$TRNLNM("INIT_ID","LNM$JOB")
$ DEASIGN/JOB INIT_ID
$!
$ OPEN/APPEND OUTPUT_FILE_1 'CURRENT_CWD'temp-file.vmq
$ WRITE OUTPUT_FILE_1 "BEGINNING PHASE 1"
$ CLOSE OUTPUT_FILE_1
$ PIPE git add temp-file.vmq > NL: 2> NL:
$ PIPE git commit -m "Bad version" > NL: 2> NL:
$!
$ OPEN/APPEND OUTPUT_FILE_3 'CURRENT_CWD'temp-file.vmq
$ WRITE OUTPUT_FILE_3 "BEGINNING PHASE 2"
$ CLOSE OUTPUT_FILE_3
$ PIPE git add temp-file.vmq > NL: 2> NL:
$ PIPE git commit -m "Last commit" > NL: 2> NL:
$ PIPE git rev-parse HEAD | (READ SYS$PIPE Last_ID && DEFINE/JOB/NOLOG Last_ID &Last_ID)
$ Last_ID = F$TRNLNM("Last_ID","LNM$JOB")
$ DEASIGN/JOB Last_ID
$!
$ PIPE git bisect start > NL: 2> NL:
$ PIPE git bisect bad > NL: 2> NL:
$ PIPE git bisect good 'INIT_ID' > NL: 2> NL:
$ OPEN/APPEND RESULT_FILE 'CWD''TEST_NAME'.EXP
$ WRITE  RESULT_FILE    "git bisect start"
$ WRITE  RESULT_FILE    "# status: waiting for both good and bad commits"
$ WRITE  RESULT_FILE    "# bad: [''Last_ID'] Last commit"
$ WRITE  RESULT_FILE    "git bisect bad ''Last_ID'"
$ WRITE  RESULT_FILE    "# status: waiting for good commit(s), bad commit known"
$ WRITE  RESULT_FILE    "# good: [''INIT_ID'] Initial commit"
$ WRITE  RESULT_FILE    "git bisect good ''INIT_ID'"
$ CLOSE  RESULT_FILE
$!
$ PIPE git bisect log | @'OUT_DIR'TEE 'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
