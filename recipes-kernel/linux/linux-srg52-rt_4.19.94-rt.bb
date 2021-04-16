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

SRCREV = "bb8f27c96f4edd2a5744fdf1a08159190fe73d07"
KERNEL_REV = "bb8f27c96f4edd2a5744fdf1a08159190fe73d07"
KERNEL_DEFCONFIG = "srg52_defconfig"

SRC_URI += "https://github.com/AaeonIot/am335x-kernel/archive/v1.1.2.tar.gz"
# SRC_URI += "file://1.1.2.tar.gz"
SRC_URI += "file://srg52_defconfig"

SRC_URI[md5sum] = "d1c99d2ab11fa2e9f58e9849e507daa7"
SRC_URI[sha256sum] = "9f64ad31bb3e856b072b5c7923a44a1527f875b8013b11db4c81e7af0c9735e3"


S = "${WORKDIR}/am335x-kernel-1.1.2"
