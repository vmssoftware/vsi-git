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
$ HEAD_FILES = F$SEARCH("HEAD.;*")
$ IF HEAD_FILES .NES. ""
$ THEN
$   DELETE HEAD.;*
$ ENDIF
$!
$ config_FILES = F$SEARCH("config.;*")
$ IF config_FILES .NES. ""
$ THEN
$   DELETE config.;*
$ ENDIF
$!
$ refs_FOLDER = F$SEARCH("refs.dir;*")
$ IF refs_FOLDER .NES. ""
$ THEN
$   @'OUT_DIR'REMOVE_DIR refs
$ ENDIF
$!
$ objects_FOLDER = F$SEARCH("objects.dir;*")
$ IF objects_FOLDER .NES. ""
$ THEN
$   @'OUT_DIR'REMOVE_DIR objects
$ ENDIF
