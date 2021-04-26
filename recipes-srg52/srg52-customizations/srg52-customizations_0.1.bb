#
# SRG-335x Debian Buster customizations
#
# Copyright (c) LYD/AAEON, 2020
#
# Authors:
#  KunYi <kunyi.chen@gmail.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-raw

DESCRIPTION = "SRG-335x customizations"

SRC_URI = " \
	file://postinst			\
	file://fw_env.config		\
	file://issue			\
	file://issue.net		\
	file://motd			\
	file://initramfs.fsck.hook	\
	file://rootoverlay.sh		\
	file://scripts/			\
	file://scripts/tools		\
	file://automount/		\
	file://Modem0.nmconnection	\
	file://Modem1.nmconnection	\
	file://Modem2.nmconnection	\
	file://Modem3.nmconnection	\
	file://Eth0.nmconnection	\
	file://Eth1.nmconnection	\
	file://udev/rules.d		\
	file://conf.d/			\
	file://can			\
	file://services			\
	file://srg52-init.service	\
	file://generic-startup.sh	\
	file://scripts/test/		\
	"

DEPENDS += "sshd-regen-keys u-boot-script"

DEBIAN_DEPENDS = " \
	ifupdown, isc-dhcp-client, net-tools, iputils-ping, ssh, sshd-regen-keys, hostapd, initramfs-tools"

do_install() {
	install -v -d ${D}/opt/scripts/tools
	install -m 0755 -d ${D}/opt/scripts
	install -v -m 755 ${WORKDIR}/scripts/tools/srg3352c_emmc_flasher.sh	${D}/opt/scripts/tools
	install -v -m 755 ${WORKDIR}/scripts/tools/to3352.sh	${D}/opt/scripts/tools
	install -v -m 755 ${WORKDIR}/scripts/CleanExpansion	${D}/opt/scripts/CleanExpansion
	install -v -m 755 ${WORKDIR}/scripts/EnableExpansionA	${D}/opt/scripts/EnableExpansionA
	install -v -m 755 ${WORKDIR}/scripts/EnableExpansionB	${D}/opt/scripts/EnableExpansionB


	# for can bus init
	install -v -d ${D}/usr/sbin
	install -m 755 ${WORKDIR}/can/srg52-initcan ${D}/usr/sbin

	# for access environment variables of u-boot
	install -v -d ${D}/etc/
	install -v -m 644 ${WORKDIR}/fw_env.config ${D}/etc/

	# for local & remote login issue
	install -v -d ${D}/opt/srg52/etc/issue/
	install -v -m 644 ${WORKDIR}/issue	${D}/opt/srg52/etc/issue/
	install -v -m 644 ${WORKDIR}/issue.net	${D}/opt/srg52/etc/issue/
	install -v -m 644 ${WORKDIR}/motd	${D}/opt/srg52/etc/issue/

	# add scripts for initramfs
	SCRIPTS=${D}/etc/initramfs-tools/scripts/init-bottom
	install -v -d ${SCRIPTS}
	install -m 0755 -d ${SCRIPTS}
	install -m 0740 ${WORKDIR}/rootoverlay.sh ${SCRIPTS}

	# add hooks for initramfs
	HOOKS=${D}/etc/initramfs-tools/hooks
	install -v -d ${HOOKS}
	install -m 0755 -d ${HOOKS}
	install -m 0740 ${WORKDIR}/initramfs.fsck.hook	${HOOKS}/fsck.hook

	# install NetworkManager connection settings file
	install -v -d ${D}/etc/NetworkManager/system-connections/
	install -v -m 600 ${WORKDIR}/Modem0.nmconnection	${D}/etc/NetworkManager/system-connections/Modem0.nmconnection
	install -v -m 600 ${WORKDIR}/Modem1.nmconnection	${D}/etc/NetworkManager/system-connections/Modem1.nmconnection
	install -v -m 600 ${WORKDIR}/Modem2.nmconnection	${D}/etc/NetworkManager/system-connections/Modem2.nmconnection
	install -v -m 600 ${WORKDIR}/Modem3.nmconnection	${D}/etc/NetworkManager/system-connections/Modem3.nmconnection
	install -v -m 600 ${WORKDIR}/Eth0.nmconnection	${D}/etc/NetworkManager/system-connections/Eth0.nmconnection
	install -v -m 600 ${WORKDIR}/Eth1.nmconnection	${D}/etc/NetworkManager/system-connections/Eth1.nmconnection

	# automount
	# install -v -d ${D}/etc/udev/rules.d/
	# install -m 644 ${WORKDIR}/automount/automount.rules ${D}/etc/udev/rules.d
	# install -v -d ${D}/etc/udev/scripts/
	# install -m 0755 -d ${D}/etc/udev/scripts/
	# install -m 755 ${WORKDIR}/automount/srg52-automount.sh ${D}/etc/udev/scripts
	install -v -d ${D}/lib/udev/rules.d/
	install -m 644 ${WORKDIR}/automount/media-automount.rules ${D}/lib/udev/rules.d/99-media-automount.rules

	install -v -d ${D}/lib/systemd/system/
	install -m 644 ${WORKDIR}/automount/media-automount@.service ${D}/lib/systemd/system/
	install -v -d ${D}/usr/bin
	install -m 755 ${WORKDIR}/automount/umount_dmenu	${D}/usr/bin/umount_dmenu
	install -m 755 ${WORKDIR}/automount/media-automount	${D}/usr/bin/media-automount

	# rules of udev
	install -v -d ${D}/etc/udev/rules.d/
	install -m 644 ${WORKDIR}/udev/rules.d/10-of-symlink.rules ${D}/etc/udev/rules.d/
	install -m 644 ${WORKDIR}/udev/rules.d/70-expansion-b.rules ${D}/etc/udev/rules.d/
	install -m 644 ${WORKDIR}/udev/rules.d/80-gpio-noroot.rules ${D}/etc/udev/rules.d/
	install -m 644 ${WORKDIR}/udev/rules.d/80-i2c-noroot.rules ${D}/etc/udev/rules.d/
	install -m 644 ${WORKDIR}/udev/rules.d/88-leds-noroot.rules ${D}/etc/udev/rules.d/
	install -m 644 ${WORKDIR}/udev/rules.d/98-com.rules ${D}/etc/udev/rules.d/

	# uartmode
	install -v -d ${D}/etc/srg52/conf.d/
	install -v -d ${D}/lib/systemd/system/
	install -m 644 ${WORKDIR}/conf.d/uartmode.toml	${D}/etc/srg52/conf.d/
	install -m 755 ${WORKDIR}/services/inituartmode.sh	${D}/etc/srg52/
	install -m 644 ${WORKDIR}/services/uartmode.service	${D}/lib/systemd/system/

	install -m 644 ${WORKDIR}/srg52-init.service ${D}/lib/systemd/system
	install -m 755 ${WORKDIR}/generic-startup.sh ${D}/etc/srg52
	
	# ppp script generator for BG96
	install -v -m 755 ${WORKDIR}/scripts/tools/ppp-creator.sh	${D}/opt/scripts/tools
	
	# wifi-ap mode
	install -v -m 755 ${WORKDIR}/scripts/tools/enable-WifiAP.sh	${D}/opt/scripts/tools
	install -v -m 755 ${WORKDIR}/scripts/tools/disable-WifiAP.sh	${D}/opt/scripts/tools
	
	mkdir ${D}/opt/scripts/test
	# uartmode test
	install -v -m 755 ${WORKDIR}/scripts/test/test232.sh	        ${D}/opt/scripts/test/
	install -v -m 755 ${WORKDIR}/scripts/test/test485Half.sh	${D}/opt/scripts/test/
	install -v -m 755 ${WORKDIR}/scripts/test/test422485Full.sh	${D}/opt/scripts/test/
	
	# 8 port rs485 test
	install -v -m 755 ${WORKDIR}/scripts/test/modpoll	${D}/opt/scripts/test/
	install -v -m 755 ${WORKDIR}/scripts/test/diagslave	${D}/opt/scripts/test/

	# led default on
	install -m 755 ${WORKDIR}/services/initledgreen.sh	${D}/etc/srg52/
	install -m 644 ${WORKDIR}/services/initled.service	${D}/lib/systemd/system/
}

addtask do_install after do_transform_template
