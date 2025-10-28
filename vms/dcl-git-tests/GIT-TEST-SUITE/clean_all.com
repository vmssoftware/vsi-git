$! Copyright (C) 2025 VMS Software, Inc.
$!
$! This program is free software: you can redistribute it and/or modify it
$! under the terms of the GNU General Public License as published by the Free
$! Software Foundation version 2 of the License.
$!
$! This program is distributed in the hope that it will be useful, but WITHOUT
$! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
$! FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
$!
$! You should have received a copy of the GNU General Public License along with
$! this program. If not, see https://www.gnu.org/licenses/
$!
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
