#!/bin/bash
###############################################################################
# The modules_sign target checks for corresponding .o files for every .ko that
# is signed. This doesn't work for package builds which re-use the same build
# directory for every flavour, and the .config may change between flavours.
# So instead of using this script to just sign lib/modules/$KernelVer/extra,
# sign all .ko in the buildroot.
#
# This essentially duplicates the 'modules_sign' Kbuild target and runs the
# same commands for those modules.
###############################################################################

set -e

MODSECKEY="${1}"
MODPUBKEY="${2}"
MODDIR="${3}"

MODULES=$(find "${MODDIR}" -type f -name '*.ko')

NPROC="$(nproc)"

[[ -z "${NPROC}" ]] && NPROC="1"

# This loop runs 2000+ iterations. Try to be fast.
echo "${MODULES}" | xargs -r -n 16 -P ${NPROC} sh -c "
for module; do
    ./scripts/sign-file sha512 ${MODSECKEY} ${MODPUBKEY} \${module}
    rm -f \${module}.sig \${module}.dig
done
" DUMMYARG0 # xargs appends ARG1 ARG2..., which go into ${module} in for loop.

RANDOMMOD=$(echo "${MODULES}" | sort -R | head -n 1)

if [[ "~Module signature appended~" != "$(tail -c 28 ${RANDOMMOD})" ]]; then
    echo "*****************************"
    echo "*** Modules are unsigned! ***"
    echo "*****************************"
    exit 1
fi

exit 0
