$! Set up Git environment
$!
$ SAY :== "WRITE SYS$OUTPUT"
$!
$ DEFINE_ROOT := SYS$COMMON:[SYS$STARTUP]GIT$DEFINE_ROOT.COM
$ IF f$search("''DEFINE_ROOT';*") .NES. ""
$ THEN
$   @'DEFINE_ROOT'
$ ELSE
$   SAY "GIT$ROOT logical is not defined!"
$ ENDIF
$!
$ GIT :== $GIT$ROOT:[GIT_CORE]GIT.EXE