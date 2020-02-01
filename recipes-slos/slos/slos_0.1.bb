DESCRIPTION = "BitBake recipe slos build"
PR = "r1"
PV = "1.0"
SRCREV = "v1.0"
SRC_URI = "git://github.com/chungae9ri/slos;protocol=https"
export MAKE = "make"
EXTRA_OEMAKE = ""
EXTRA_OECONF = ""

oe_runmake_call() {
	bbnote ${MAKE} ${EXTRA_OEMAKE} "$@"
	${MAKE} ${EXTRA_OEMAKE} "$@"
}

oe_runmake() {
	oe_runmake_call "$@" || die "oe_runmake failed"
}


do_build[dirs] = "${B}/git"
do_build[nostamp] = "1"
do_build() {
	cd ${B}/git

	if [ -e Makefile -o -e makefile -o -e GNUmakefile ]; then
		oe_runmake || die "make failed"
	else
		bbnote "nothing to compile"
	fi
}
addtask build after do_tc


addtask clean
do_clean[dirs] = "${B}/git"
do_clean[nostamp] = "1"
do_clean() {
	cd ${B}/git

	if [ -e Makefile -o -e makefile -o -e GNUmakefile ]; then
		oe_runmake clean || die "make failed"
	else
		bbnote "nothing to compile"
	fi
}
