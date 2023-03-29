#!/bin/sh

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

eecho() {
    echo -e "${GREEN}$1${NC}"
}

eerror() {
    echo -e "${RED}$1${NC}"
}

# Check if 3proxy is installed
if ! command -v 3proxy > /dev/null 2>&1; then
    eecho "3proxy is not installed"
    exit 1
fi

# Stop 3proxy service
systemctl stop 3proxy

# Remove 3proxy configuration
rm -rf /usr/local/3proxy

# Remove iptables rules
iptables-save | awk '/3proxy/ { print $1 }' | xargs -I{} iptables -D INPUT -p tcp -m tcp --dport {} -j ACCEPT

# Remove ifconfig addresses
ifconfig | awk '/inet6 .* 3proxy/ {print $2}' | xargs -I{} ifconfig ${ETHNAME} inet6 del {}

# Restore original network config
if [ -f /etc/sysconfig/network-scripts/ifcfg-${ETHNAME}.orig ]; then
    mv /etc/sysconfig/network-scripts/ifcfg-${ETHNAME}.orig /etc/sysconfig/network-scripts/ifcfg-${ETHNAME}
fi

# Restore original rc.local
if [ -f /etc/rc.local.orig ]; then
    mv /etc/rc.local.orig /etc/rc.local
fi

eecho "Restore done!"

# Install proxy script
bash <(curl -s -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/ngbien83/proxyv6/main/tt.sh")

eecho "Installation done!"
