$! This command procedure runs the test
$! for "git bisect good/bad" option.
$!
$ TEST_NAME = "GIT_BISECT_GOOD_BAD"
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
$ PIPE git rev-parse HEAD | (READ SYS$PIPE BAD_ID && DEFINE/JOB/NOLOG BAD_ID &BAD_ID)
$ BAD_ID = F$TRNLNM("BAD_ID","LNM$JOB")
$ DEASIGN/JOB BAD_ID
$!
$ OPEN/APPEND OUTPUT_FILE_2 'CWD''TEST_NAME'.EXP
$ WRITE OUTPUT_FILE_2 "[''BAD_ID'] Bad version" 
$ CLOSE OUTPUT_FILE_2
$!
$ OPEN/APPEND OUTPUT_FILE_3 'CURRENT_CWD'temp-file.vmq
$ WRITE OUTPUT_FILE_3 "BEGINNING PHASE 2"
$ CLOSE OUTPUT_FILE_3
$ PIPE git add temp-file.vmq > NL: 2> NL:
$ PIPE git commit -m "Last commit" > NL: 2> NL:
$!
$ PIPE git bisect start > NL: 2> NL:
$ PIPE git bisect bad > NL: 2> NL:
$ PIPE git bisect good 'INIT_ID' | @'OUT_DIR'TEE  'CWD''TEST_NAME'.OUT
$ @'OUT_DIR'REPORT_DIFF_RESULT.COM
$ SET DEF [-]
$!
$ EXIT
