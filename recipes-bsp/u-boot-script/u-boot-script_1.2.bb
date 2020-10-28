# Boot script generator for U-Boot
#
# Copyright (c) LYD/AAEON, 2020
#
# Authors:
#   KunYi <kunyi.chen@gmail.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-raw

DESCRIPTION = "Boot script generator for U-Boot"

SRC_URI = " \
    file://update-u-boot-script \
    file://u-boot-script \
    file://zz-u-boot-script"

DEBIAN_DEPENDS = "u-boot-tools, linux-image-${KERNEL_NAME}"

do_install() {
	install -v -d ${D}/etc/default
	install -v -m 644 ${WORKDIR}/u-boot-script ${D}/etc/default/
	
	install -v -d ${D}/usr/sbin
	install -v -m 755 ${WORKDIR}/update-u-boot-script ${D}/usr/sbin/

	install -v -d ${D}/etc/kernel/postinst.d
	install -v -m 755 ${WORKDIR}/zz-u-boot-script ${D}/etc/kernel/postinst.d
}

addtask do_install after do_transform_template