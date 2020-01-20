DESCRIPTION = "Install gcc toolchain to build SLOS"
PR = "r1"
PV = "1.0"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI = "\
	file://gcc-arm-none-eabi-6-2017-q1-update-linux.tar.bz2"
SRCREV = "v1.0"
TOOLCHAIN_OUT = "${HOME}/bin/arm-2017q1"

do_tc[nostamp] = "1"
do_tc() {
	mkdir -p ${TOOLCHAIN_OUT}
	cp ${S}/gcc-arm-none-eabi-6-2017-q1-update/arm-none-eabi ${TOOLCHAIN_OUT}/ -r
	cp ${S}/gcc-arm-none-eabi-6-2017-q1-update/bin ${TOOLCHAIN_OUT}/ -r
	cp ${S}/gcc-arm-none-eabi-6-2017-q1-update/lib ${TOOLCHAIN_OUT}/ -r
	cp ${S}/gcc-arm-none-eabi-6-2017-q1-update/share ${TOOLCHAIN_OUT}/ -r
}

do_compile() {
	:
}

do_build() {
	:
}

do_clean() {
	:
}

addtask tc after do_unpack before do_compile
