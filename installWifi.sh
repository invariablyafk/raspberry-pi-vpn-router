#!/bin/bash

if (($EUID)); then
    echo "This script must be run as root"
    exit 1
fi


# Update system repos
sudo apt-get update -y
sudo apt-get upgrade -y

# Install hostapd and dnsmasq, bridge utils, and openvpn for later
sudo apt-get install hostapd dnsmasq openvpn bridge-utils -y

sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

# configure dhcp
sudo cat <<EOT >> /etc/dhcpcd.conf

interface wlan0
static ip_address=192.168.0.10/24
denyinterfaces eth0
denyinterfaces wlan0

EOT

# save original dnsmasq.conf
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

# invent new dnsmasq.conf
sudo cat <<EOT >> /etc/dnsmasq.conf

interface=wlan0
  dhcp-range=192.168.0.11,192.168.0.30,255.255.255.0,24h

EOT

# set hostapd settings for soft access point
sudo cat <<EOT >> /etc/hostapd/hostapd.conf

interface=wlan0
bridge=br0
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ssid=Dev10101010
wpa_passphrase=testertester


EOT

# tell hostapd to use our new config file.
sudo cat <<EOT >> /etc/default/hostapd

DAEMON_CONF="/etc/hostapd/hostapd.conf"

EOT



# forward the traffic over your Ethernet cable
sudo cat <<EOT >> /etc/sysctl.conf

net.ipv4.ip_forward=1

EOT

# ip tables config
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

# Add 
#   iptables-restore < /etc/iptables.ipv4.nat
# to /etc/rc.local before exit 0; to preserve after reboot
sed -i 's_exit 0_iptables-restore < /etc/iptables.ipv4.nat;\n exit 0_g' /etc/rc.local

# add a new bridge
sudo brctl addbr br0
# connect eth0  to bridge
sudo brctl addif br0 eth0

# add bridge interface
sudo cat <<EOT >> /etc/network/interfaces

auto br0
iface br0 inet manual
bridge_ports eth0 wlan0

EOT

#hostapd is masked by default in latest raspbian 
systemctl unmask hostapd

systemctl enable hostapd
systemctl enable dnsmasq

echo "Please reboot the computer now. "