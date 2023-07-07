#!/bin/bash

# Check for necessary packages
if ! command -v ufw &> /dev/null
then
    echo "ufw could not be found. Please install it."
    exit
fi

if ! command -v fail2ban-server &> /dev/null
then
    echo "fail2ban could not be found. Please install it."
    exit
fi

# Set up UFW rules
sudo ufw limit 22/tcp  
sudo ufw allow 80/tcp  
sudo ufw allow 443/tcp  
sudo ufw default deny incoming  
sudo ufw default allow outgoing
sudo ufw --force enable

# Harden /etc/sysctl.conf
echo "kernel.modules_disabled=1" | sudo tee -a /etc/sysctl.conf > /dev/null
echo "net.ipv4.conf.all.rp_filter=1" | sudo tee -a /etc/sysctl.conf > /dev/null

# Load new sysctl settings
sudo sysctl -p

# PREVENT IP SPOOFS
cat <<EOF | sudo tee /etc/host.conf > /dev/null
order bind,hosts
multi on
EOF

# Enable fail2ban
if [ ! -f jail.local ]
then
    echo "jail.local file not found. Please ensure it exists in the current directory."
    exit
fi

sudo cp jail.local /etc/fail2ban/
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Show listening ports
echo "listening ports:"
sudo netstat -tunlp
