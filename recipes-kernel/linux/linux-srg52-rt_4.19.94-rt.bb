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

SRCREV = "b7bd05fe792a495dd4ca309caa758016cd896da7"
KERNEL_REV = "b7bd05fe792a495dd4ca309caa758016cd896da7"
KERNEL_DEFCONFIG = "srg52_defconfig"

SRC_URI += "https://github.com/AaeonIot/am335x-kernel/archive/v1.1.3.tar.gz"
# SRC_URI += "file://v1.1.3.tar.gz"
SRC_URI += "file://srg52_defconfig"

SRC_URI[md5sum] = "facc342216cd2e4e4e74d9442c477cbd"
SRC_URI[sha256sum] = "cfc93c7b95d84e39a935a43f5215acf1685f77bb660904c8b68b02a1dfcc3968"


S = "${WORKDIR}/am335x-kernel-1.1.3"
