#!/bin/sh

echo ">> sudo ./enable-WiFiAP.sh <output-network-interface> <ssid> <password>"
echo ">> password needs 8 characters as least"
echo ">> use default config if no arguments supplied"
echo "\n"

OUTINTERFACE=$1
SSID=$2
PASSWORD=$3

if [ -z "$1" ]; then
    echo ">> No arguments supplied, set default, eth0, SRG-3352C, 1234567890"
    OUTINTERFACE=eth0
    SSID=SRG-3352C
    PASSWORD=1234567890
else
    if [ `echo $1 | grep -c eth` -ne 1 ]; then
       if [ `echo $1 | grep -c ppp` -ne 1 ]; then
          echo ">> no output network interface, set default eth0"
          OUTINTERFACE=eth0
       fi
    fi
fi

if [ -z "$SSID" ]; then
    echo ">> No SSID and password, set default SRG-3352C and 1234567890"
    SSID=SRG-3352C
    PASSWORD=1234567890
fi

if [ -z "$PASSWORD" ]; then
    echo ">> No password, set default 1234567890"
    PASSWORD=1234567890
fi

#echo "install necessary package"
#apt-get update
#apt-get install -y isc-dhcp-server
#apt-get install -y hostapd 

if [ ! -f "/etc/hostapd/hostapd.conf.bak" ]; then
echo ">> backup original config file"
mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak
fi

echo ">> creating hostapd config file : /etc/hostapd/hostapd.conf"
echo "
interface=wlan0

# SSID to be used in IEEE 802.11 management frames
ssid=$SSID
# Driver interface type (hostap/wired/none/nl80211/bsd)
driver=nl80211
# Country code (ISO/IEC 3166-1)
country_code=TW

# Operation mode (a = IEEE 802.11a (5 GHz), b = IEEE 802.11b (2.4 GHz)
hw_mode=g
# Channel number
channel=1
# Maximum number of stations allowed
max_num_sta=5

# Bit field: bit0 = WPA, bit1 = WPA2
wpa=3
# Bit field: 1=wpa, 2=wep, 3=both
auth_algs=1

# Set of accepted cipher suites; disabling insecure TKIP
wpa_pairwise=TKIP
rsn_pairwise=CCMP
# Set of accepted key management algorithms
wpa_key_mgmt=WPA-PSK
wpa_passphrase=$PASSWORD

# hostapd event logger configuration
logger_stdout=-1
logger_stdout_level=2" > /etc/hostapd/hostapd.conf


echo ">> creating dhcpd config file : /etc/dhcp/dhcpd.conf"
echo "
default-lease-time 1209600;
max-lease-time 1814400;
ddns-update-style none;
ignore client-updates;
authoritative;
option local-wpad code 252 = text;
 
subnet 10.0.0.0 netmask 255.255.255.0 {
   option routers 10.0.0.1;
   option subnet-mask 255.255.255.0;
   option broadcast-address 10.0.0.255;
   option domain-name-servers 10.0.0.1, 8.8.8.8, 8.8.4.4;
   option time-offset 0;
   range 10.0.0.3 10.0.0.13;
}" > /etc/dhcp/dhcpd.conf

echo ">> config wifi ip and up"
ifconfig wlan0 up 10.0.0.1 netmask 255.255.255.0

echo ">> config dhcpd"
dhcpd wlan0

echo ">> enable network forward"
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface $OUTINTERFACE -j MASQUERADE
iptables --append FORWARD --in-interface wlan0 -j ACCEPT
sysctl -w net.ipv4.ip_forward=1

echo ">> start hostapd"
service hostapd restart


echo "\n\njob complete"
echo "output INTERFACE = $OUTINTERFACE"
echo "SSID = $SSID"
echo "PASSWORD = $PASSWORD"
echo "\n\n"

