#!/bin/sh

echo ">> ./enable-WiFiAP.sh <ssid> <password> <interface>"
echo ">> password needs 8 characters as least"
echo ">> use default config if no arguments supplied"
echo ">> Default ssid and password: hostname-random number and 12345678"
echo "\n"

SSID=$1
PASSWORD=$2
IFACE=$3

if [ -z "$ssid" ]; then
    echo ">> No SSID and password, set default ssid and password"
    SSID=$(hostname)-$(head -200 /dev/urandom | cksum | cut -f1 -d " ")
    PASSWORD=12345678
    echo ">> SSID = $SSID"
    echo ">> PASSWORD = $PASSWORD"
fi

if [ -z "$PASSWORD" ]; then
    echo ">> No password, set default password"
    PASSWORD=12345678
    echo ">> PASSWORD = $PASSWORD"
fi

if [ -z "$IFACE" ]; then
  if [ "`ifconfig | grep -c wlan0`" = 1 ]; then
    IFACE=wlan0
  elif [ "`ifconfig | grep -c wlx000e8e991114`" = 1 ]; then
    IFACE=wlx000e8e991114
  else
    echo ">> No interface, exit"
    exit 0
  fi
fi

echo ">> IFACE = $IFACE"

# delete original WIFI_AP profile
if [ "`nmcli con show | grep -c WIFI_AP`" = 1 ]; then
    echo ">> stop and delete original profile"
    sudo nmcli connection down WIFI_AP
    sudo nmcli c del WIFI_AP
fi

# disable standalone dnsmasq service
sudo systemctl disable dnsmasq
sudo systemctl stop dnsmasq

# for NetworkManager to run dnsmasq as a local caching DNS server
if [ 	! -f /etc/NetworkManager/NetworkManager.conf.bak ]; then
    echo ">> backup /etc/NetworkManager/NetworkManager.conf"
    sudo cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.bak
fi
if [ "`cat /etc/NetworkManager/NetworkManager.conf | grep -c [main]`" = 1 ]; then
 if [ "`cat /etc/NetworkManager/NetworkManager.conf | grep -c dns=dnsmasq`" = 1 ]; then
    echo ">> run dnsmasq as a local caching DNS server"
    cp /etc/NetworkManager/NetworkManager.conf .
    sudo echo "" >> NetworkManager.conf
    sudo echo "[main]" >> NetworkManager.conf
    sudo echo "dns=dnsmasq" >> NetworkManager.conf
    sudo cp NetworkManager.conf /etc/NetworkManager/
    rm NetworkManager.conf
 fi
fi

# create WiFi AP
sudo nmcli c add type wifi ifname wlan0 con-name WIFI_AP autoconnect yes ssid $SSID
sudo nmcli connection modify WIFI_AP 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
sudo nmcli connection modify WIFI_AP wifi-sec.key-mgmt wpa-psk
sudo nmcli connection modify WIFI_AP wifi-sec.psk "$PASSWORD"
sudo nmcli connection up WIFI_AP

# $? return last command successful or not.
# 1 is failure and 0 is successful.
if [ $? = 1 ]; then
	echo "\n\n>> connection up fail"
else
	echo "\n\n>> connection up success"
fi

# configuring DHCP subnet
sudo nmcli connection modify WIFI_AP ipv4.addr 192.168.5.1/24

# restart NetworkManager
sudo systemctl restart NetworkManager

# show connection
nmcli con show

if [ "`nmcli con show | grep -c WIFI_AP`" = 1 ]; then
	echo "\n\n>> WiFi AP enable enabled"
	echo ">> SSID = $SSID"
	echo ">> PASSWORD = $PASSWORD"
	echo "\n\n"
else
	echo "\n\n>> WiFi AP enable fail"
fi



