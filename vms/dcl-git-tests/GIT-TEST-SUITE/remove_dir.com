$ set noon
$ del/tree [.'p1'...]*.*;*
$ set file/prot=O:D 'p1'.dir
$ del 'p1'.dir;
$ set on
