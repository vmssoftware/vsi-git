$!This command procedure appends 
$!record to the end of the file
$!	
$ OPEN/APPEND FILE 'P1'
$ WRITE FILE "New added record."
$ CLOSE FILE
$!
$ EXIT
