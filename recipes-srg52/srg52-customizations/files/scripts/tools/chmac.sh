#!/bin/bash

O_ETH0=$(ifconfig -a eth0 | awk '/ether/ { print $2 }')
O_ETH1=$(ifconfig -a eth1 | awk '/ether/ { print $2 }')
N_ETH0=$(srg52cfg -0)
N_ETH1=$(srg52cfg -1)

echo -e "ACTION==\"add\", SUBSYSTEM==\"net\", ATTR{address}==\"${O_ETH0}\", RUN+=\"/sbin/ip link set dev eth0 address ${N_ETH0}\"" > /etc/udev/rules.d/75-net-setup-link.rules

echo -e "ACTION==\"add\", SUBSYSTEM==\"net\", ATTR{address}==\"${O_ETH1}\", RUN+=\"/sbin/ip link set dev eth1 address ${N_ETH1}\"" >> /etc/udev/rules.d/75-net-setup-link.rules

#
echo -e "eth0:${O_ETH0} change to ${N_ETH0}"
echo -e "eth1:${O_ETH1} change to ${N_ETH1}"
ip link set dev eth0 address ${N_ETH0}
ip link set dev eth1 address ${N_ETH1}
