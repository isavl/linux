#!/bin/bash
###############################################################################
# This is a dummy substitute for depmod. Since we run depmod during
# postinst, we do not need or want to package the files that it generates.
###############################################################################

set -e

if [ "${1}" = "-V" ]; then
    # Satisfy version test.
    echo "not really module-init-tools"
elif [ "${1}" = "-b" -a "${2%/depmod.??????}" != "${2}" ]; then
    # Satisfy test of short kernel versions.
    mkdir -p "${2}/lib/modules/${3}"
    touch "${2}/lib/modules/${3}/modules.dep"
else
    echo "skipping depmod"
fi
