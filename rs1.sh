#!/bin/sh

# Stop the 3proxy service (if it's running)
systemctl stop 3proxy

# Remove the 3proxy package and its configuration files
yum remove -y 3proxy
rm -rf /usr/local/3proxy/

# Delete the proxy script and any files or directories that were created by the script
rm -rf /path/to/the/proxy/script
rm -f proxy.txt

# Remove any IPv6 addresses added to the network interface
ip -6 addr flush dev eth0

# Remove any firewall rules added to allow incoming traffic on proxy ports
iptables -D INPUT -p tcp --dport 20001 -m state --state NEW -j ACCEPT
iptables -D INPUT -p tcp --dport 20002 -m state --state NEW -j ACCEPT
# Repeat the above command for each proxy port that was added

# Remove the changes made to limits.conf
sed -i '/^* soft nofile 1024000$/d' /etc/security/limits.conf
sed -i '/^* hard nofile 1024000$/d' /etc/security/limits.conf

# Remove the changes made to rc.local
sed -i '/^bash \/path\/to\/the\/proxy\/script\/boot_rc.sh$/d' /etc/rc.local

# Restart the network service
systemctl restart network
