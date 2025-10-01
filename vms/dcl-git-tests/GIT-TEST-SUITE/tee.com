$! TEE.COM - command procedure to display/log data flowing through
$!  a pipeline
$! Usage: @TEE log-file
$!
$ IF F$SEARCH("''P1'").EQS.""
$ THEN 
$   OPEN/WRITE tee_file 'P1'
$ ELSE
$   OPEN/APPEND tee_file 'P1'
$ ENDIF
$!
$ LOOP:
$   READ/END_OF_FILE=EXIT SYS$PIPE LINE
$   WRITE/SYMBOL tee_file LINE ! Log output to the log file
$ GOTO LOOP
$ EXIT:
$   CLOSE tee_file
$ EXIT
