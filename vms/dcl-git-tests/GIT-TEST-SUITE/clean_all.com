$! This command procedure cleans
$! the testing environment 
$ ECHO :== WRITE SYS$OUTPUT
$ esc[0,7] = %x1B
$ PIPE DELETE fails.log;* > NL: 2> NL:
$ PIPE DELETE testing.log;* > NL: 2> NL:
$
$ LOOP:
$   FILE = F$SEARCH("[]*.dir;*", 1)
$   IF FILE .EQS. "" 
$   THEN 
$       ECHO "CLEANING IS FINISHED"
$       EXIT
$   ELSE
$       SPEC = F$PARSE(FILE,,,"NAME")
$   	SET DEF [.'SPEC']
$   	ECHO "CLEANING: ''SPEC'"
$   	CLEAN_TEST = F$SEARCH("clean_test.com")
$   	IF CLEAN_TEST .EQS. ""
$   	THEN
$		    ECHO "''esc'[31m - CLEANING FAILD. MISSING MAKEFILE IN ''SPEC' ''esc'[m"
$           GOTO NEXT
$   	ELSE
$	 	    LOG_FILE = F$SEARCH("ERROR.LOG")
$	 	    IF CLEAN_TEST .EQS. ""
$	 	    THEN
$			    GOTO NEXT
$		    ELSE
$               @clean_test
$		    ENDIF
$       ENDIF
$   ENDIF
$ NEXT:
$   SET DEF [-]
$   GOTO LOOP
