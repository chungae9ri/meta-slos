# meta-slos
bitbake recipes for slos build

How to build slos using bitbake
1. Download poky 
   git clone git://git.yoctoproject.org/poky.git
2. Copy meta-slos to under poky/
3. Cd poky
4. Run ". oe-init-build-env build-slos"
5. Open build-slos/conf/bblayers.conf
6. Replace "BBLAYERS" variable with
   BBLAYERS ?= " /home/good4u/dotori/poky/meta-slos"
7. Run "bitbake slos" in poky/build-slos directory

Currently, do_fetch(), do_unpack(), do_compile(), do_build(), do_clean() 
tasks are implemented.

do_fetch() and do_unpack() tasks are git-clone from "github.com/chungae9ri/slos" 
and unpack it. Not do_patch() yet.

"bitbake slos -c clean" command cleans the output directory.
