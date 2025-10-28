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
