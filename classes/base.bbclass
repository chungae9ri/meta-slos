# Copyright (C) 2003  Chris Larson
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

die() {
    bbfatal "$*"
}

bbnote() {
    echo "NOTE:" "$*"
}

bbwarn() {
    echo "WARNING:" "$*"
}

bbfatal() {
    echo "FATAL:" "$*"
    exit 1
}

addtask showdata
do_showdata[nostamp] = "1"
python do_showdata() {
    import sys
    # emit variables and shell functions
    bb.data.emit_env(sys.__stdout__, d, True)
    # emit the metadata which isnt valid shell
    for e in bb.data.keys(d):
        if d.getVarFlag(e, 'python', False):
            bb.plain("\npython %s () {\n%s}" % (e, d.getVar(e)))
}

addtask listtasks
do_listtasks[nostamp] = "1"
python do_listtasks() {
    import sys
    for e in bb.data.keys(d):
        if d.getVarFlag(e, 'task', False):
            bb.plain("%s" % e)
}

def get_lic_checksum_file_list(d):
    filelist = []
    lic_files = d.getVar("LIC_FILES_CHKSUM") or ''
    tmpdir = d.getVar("TMPDIR")
    s = d.getVar("S")
    b = d.getVar("B")
    workdir = d.getVar("WORKDIR")

    urls = lic_files.split()
    for url in urls:
        # We only care about items that are absolute paths since
        # any others should be covered by SRC_URI.
        try:
            (method, host, path, user, pswd, parm) = bb.fetch.decodeurl(url)
            if method != "file" or not path:
                raise bb.fetch.MalformedUrl(url)

            if path[0] == '/':
                if path.startswith((tmpdir, s, b, workdir)):
                    continue
                filelist.append(path + ":" + str(os.path.exists(path)))
        except bb.fetch.MalformedUrl:
            bb.fatal(d.getVar('PN') + ": LIC_FILES_CHKSUM contains an invalid URL: " + url)
    return " ".join(filelist)

addtask fetch before do_unpack
do_fetch[dirs] = "${DL_DIR}"
do_fetch[file-checksums] = "${@bb.fetch.get_checksum_file_list(d)}"
do_fetch[file-checksums] += " ${@get_lic_checksum_file_list(d)}"
do_fetch[vardeps] += "SRCREV"
python base_do_fetch() {

    src_uri = (d.getVar('SRC_URI') or "").split()
    if len(src_uri) == 0:
        return

    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.download()
    except bb.fetch2.BBFetchException as e:
        bb.fatal(str(e))
}

addtask unpack after do_fetch before do_build
do_unpack[dirs] = "${WORKDIR}"
do_unpack[cleandirs] = "${@d.getVar('S') if os.path.normpath(d.getVar('S')) != os.path.normpath(d.getVar('WORKDIR')) else os.path.join('${S}', 'patches')}"

python base_do_unpack() {
    src_uri = (d.getVar('SRC_URI') or "").split()
    if len(src_uri) == 0:
        return

    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.unpack(d.getVar('P'))
    except bb.fetch2.BBFetchException as e:
        bb.fatal(str(e))
}

oe_runmake_call() {
	bbnote ${MAKE} ${EXTRA_OEMAKE} "$@"
	${MAKE} ${EXTRA_OEMAKE} "$@"
}

oe_runmake() {
	oe_runmake_call "$@" || die "oe_runmake failed"
}


addtask compile after do_unpack before do_build
do_compile[dirs] = "${B}/git"
do_compile[nostamp] = "1"
base_do_compile() {
	cd ${B}/git

	if [ -e Makefile -o -e makefile -o -e GNUmakefile ]; then
		oe_runmake || die "make failed"
	else
		bbnote "nothing to compile"
	fi
}


addtask clean
do_clean[dirs] = "${B}/git"
do_clean[nostamp] = "1"
base_do_clean() {
	cd ${B}/git

	if [ -e Makefile -o -e makefile -o -e GNUmakefile ]; then
		oe_runmake clean || die "make failed"
	else
		bbnote "nothing to compile"
	fi
}

addtask build
do_build[dirs] = "${TOPDIR}"
do_build[nostamp] = "1"
python base_do_build () {
    bb.note("The included, default BB base.bbclass does not define a useful default task.")
    bb.note("Try running the 'listtasks' task against a .bb to see what tasks are defined.")
}

EXPORT_FUNCTIONS do_fetch do_unpack do_compile do_build do_clean 
