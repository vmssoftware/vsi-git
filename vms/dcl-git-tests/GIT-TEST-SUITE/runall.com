$
$ TRAVERSE : SUBROUTINE
$   LOOP:
$   RUN_TEST = F$SEARCH("[]runtest.com;*")
$   TEST_DIR = F$PARSE(RUN_TEST,,,"DIRECTORY")
$   RUN_TEST_SPEC = F$PARSE(RUN_TEST,,,"NAME")
$   IF RUN_TEST .EQS. ""
$   THEN
$     FILE = F$SEARCH("[]*.dir;*", 1)
$     IF FILE .EQS. "" THEN EXIT
$     SPEC = F$PARSE(FILE,,,"NAME")
$     SET DEF [.'SPEC']
$     FILE_OUT = F$SEARCH("*.OUT;")
$     FILE_OUT_NAME = F$PARSE(FILE_OUT,,,"NAME")
$     IF FILE_OUT_NAME .NES. "" 
$     THEN 
$     	SET DEF [-]
$     	GOTO LOOP
$     ENDIF
$     CALL TRAVERSE
$     SET DEF [-]
$     GOTO LOOP
$   ELSE
$     IF F$SEARCH("[]*.EXP") .EQS. "" 
$     THEN
$       ignored == ignored + 1
$       stout = "IGNORE --- ''TEST_DIR'"
$       write LOGFILE stout
$       echo "''ESC'[38;5;6m''stout'''ESC'[m"
$       EXIT
$     ENDIF
$
$     SET NOON
$     IS_SKIPPED == 0
$     STATUS == "CRASH"
$     @'RUN_TEST_SPEC'
$     IF STATUS .EQS. "PASS"
$     THEN
$       passes == passes + 1
$       stout = "PASS  ---  ''TEST_DIR'"
$       write LOGFILE stout
$       echo "''ESC'[32m''ESC'[1A''stout'''ESC'[m"
$       set def 'SAVE_DIR'
$       @clean_command 'SPEC' 1
$       set def 'TEST_DIR'
$       copy *.EXP;* *.out;*
$     ELSE
$     IF STATUS .EQS. "DIFF"
$     THEN
$       fails == fails + 1
$       stout = "FAIL  ---  ''TEST_DIR' (''STATUS')"
$       write LOGFILE stout
$       write FAILS stout
$       ECHO "''ESC'[31m''ESC'[1A''stout'''ESC'[m"
$     ELSE
$       IF STATUS .EQS. "UNEXPECTED"
$       THEN
$         unexp_passes == unexp_passes + 1
$         stout = "PASS  ---  ''TEST_DIR' (''STATUS')"
$         write LOGFILE stout
$         ECHO "''ESC'[33m''ESC'[1A''stout'''ESC'[m"
$       ELSE
$         IF (STATUS .EQS. "EXPECTED") .OR. IS_SKIPPED
$         THEN
$           exp_fails == exp_fails + 1
$           stout = "FAIL  ---  ''TEST_DIR' (EXPECTED)"
$           write LOGFILE stout
$           ECHO "''ESC'[34m''ESC'[1A''stout'''ESC'[m"
$         ELSE
$           crashes == crashes + 1
$           stout = "FAIL  ---  ''TEST_DIR' (''STATUS')"
$           write LOGFILE stout
$           write FAILS stout
$           ECHO "''ESC'[31m''ESC'[1A''stout'''ESC'[m"
$         ENDIF
$       ENDIF
$     ENDIF
$     SET ON
$   ENDIF
$
$ ENDSUBROUTINE
$
$ esc[0,7] = %x1B
$
$ ECHO :== WRITE SYS$OUTPUT
$ SAVE_DIR = F$DIRECTORY()
$ ON ERROR THEN GOTO _error
$ begintime = f$time()
$ unexp_passes == 0
$ passes == 0
$ fails == 0
$ crashes == 0
$ exp_fails == 0
$ ignored == 0
$ SKIP = "NONE"
$ IS_SKIPPED == 0
$ STATUS == "CRASH"
$ DATE = F$CVTIME(,,"DATE")
$ OPEN/WRITE LOGFILE []testing.log
$ OPEN/WRITE FAILS []fails.log
$ ECHO ""
$ CALL TRAVERSE
$ all_fails == fails + crashes
$ all_passes == passes + unexp_passes
$ all_tests == all_fails + all_passes + exp_fails
$ write LOGFILE ""
$ write LOGFILE "TESTED:  ''all_tests' tests"
$ write LOGFILE "PASSES:  ''passes' test"
$ write LOGFILE "  - UNEXPECTED:  ''unexp_passes' test"
$ write LOGFILE "FAILES:  ''all_fails' test"
$ write LOGFILE "  - DIFF:  ''fails' test"
$ write LOGFILE "  - CRASH:  ''crashes' test"
$ write LOGFILE "EXPECTED FAILS:  ''exp_fails' test"
$ write LOGFILE "IGNORED:  ''ignored' test"
$ write LOGFILE "Done Testing. Elapsed time: ", f$delta_time(begintime, f$time())
$
$ ECHO ""
$ IF all_tests .ne. 0 THEN ECHO "TESTED:  ''all_tests' tests"
$ IF passes .ne. 0 THEN ECHO "''esc'[42mPASSES:  ''all_passes' tests''esc'[m"
$ IF unexp_passes .ne. 0 THEN ECHO "''esc'[43m  - UNEXPECTED:  ''unexp_passes' tests''esc'[m"
$
$ IF all_fails .ne. 0
$ THEN
$   ECHO "''esc'[41mFAILES:  ''all_fails' tests''esc'[m"
$   IF fails .ne. 0 THEN ECHO "''esc'[41m  - DIFF:  ''fails' tests''esc'[m"
$   IF crashes .ne. 0 THEN ECHO "''esc'[41m  - CRASH:  ''crashes' tests''esc'[m"
$ ENDIF
$
$ IF exp_fails .ne. 0 THEN ECHO "''esc'[44mEXPECTED FAILS:  ''exp_fails' tests''esc'[m"
$ ECHO ""
$ IF all_fails .eq. 0 THEN ECHO "''esc'[42m    ALL TESTS PASSED !!! ''esc'[m"
$
$ ECHO "See the list of failed tests in FAILS.LOG file."
$ ECHO "Done Testing. Elapsed time: ", f$delta_time(begintime, f$time())
$ GOTO _exit
$
$_error:
$ ECHO "Error in test-case ''TEST_DIR'. Exiting..."
$
$_exit:
$ SET DEF 'SAVE_DIR'
$ CLOSE LOGFILE
$ CLOSE FAILS
$ EXIT
