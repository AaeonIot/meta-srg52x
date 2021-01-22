#
# SRG-335x Debian Buster
#
# Copyright (c) LYD/AAEON, 2020
#
# Authors:
#   KunYi <kunyi.chen@gmail.com>
#
# SPDX-License-Identifier: MIT
#
# for real-time
# Linux RT Kernel 4.19.94
#
require recipes-kernel/linux/linux-custom.inc

DESCRIPTION = "Linux Kernel for SRG-3352x"
SECTION = "kernel"
MAINTAINER = "KunYi <kunyi.chen@gmail.com>"

KBUILD_DEPENDS += "lzop:native"

SRCBRANCH = "srg52_dev"

SRCREV = "81f500c22eba467b8edcf2443ebf0cccd6bcdb66"
KERNEL_REV = "81f500c22eba467b8edcf2443ebf0cccd6bcdb66"
KERNEL_DEFCONFIG = "srg52_defconfig"

SRC_URI += "https://github.com/dqdqdq31/am335x-kernel/archive/v1.1.tar.gz"
# SRC_URI += "file://v1.1.tar.gz"
SRC_URI += "file://srg52_defconfig"

SRC_URI[md5sum] = "83618cbc1567cbae3dedb8391fc908fe"
SRC_URI[sha256sum] = "75e2e322fe8b3abb617f4daf72fbf3b8a4b0f407c65c83f4cb28fe62a8ed25b5"

S = "${WORKDIR}/am335x-kernel-1.1"
