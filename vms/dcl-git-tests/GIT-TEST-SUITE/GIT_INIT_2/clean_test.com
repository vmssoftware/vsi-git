$ OUT_DIR = f$trnlnm("GITTEST$ROOT","LNM$PROCESS_TABLE")
$!
$ LOG_FILES = F$SEARCH("*.LOG;*")
$ IF LOG_FILES .NES. ""
$ THEN
$   DELETE *.LOG;*
$ ENDIF
$!
$ OUT_FILES = F$SEARCH("*.OUT;*")
$ IF OUT_FILES .NES. ""
$ THEN
$   DELETE *.OUT;*
$ ENDIF
$!
$ GIT_FOLDER = F$SEARCH("TEST.DIR;1")
$ IF GIT_FOLDER .NES. ""
$ THEN
$   @'OUT_DIR'REMOVE_DIR test
$ ENDIF
$!
$ OBJ_FILES = F$SEARCH("*.OBJ;*")
$ IF OBJ_FILES .NES. ""
$ THEN
$   DELETE *.OBJ;*
$ ENDIF
$!
$ EXE_FILES = F$SEARCH("*.EXE;*")
$ IF EXE_FILES .NES. ""
$ THEN
$   DELETE *.EXE;*
$ ENDIF
$!
$ git_init_FILES = F$SEARCH("git_init.exp;*")
$ IF git_init_FILES .NES. ""
$ THEN
$   DELETE git_init.exp;*
$ ENDIF
