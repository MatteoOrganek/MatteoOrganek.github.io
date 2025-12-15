#!/bin/bash
# Week 4 baseline verification script
# Checks SSH key, firewall rules, and admin user

echo "------------------------------"
echo -e "\n- SSH Key Authentication ------"
# Check if the authorized_keys file exists for user 'fedora'
SSH_DIR="/home/fedora/.ssh"
AUTHORIZED_KEYS="${SSH_DIR}/authorized_keys"
if [ -f "$AUTHORIZED_KEYS" ]; then
    echo "authorized_keys exists for fedora"
    echo "Permissions:"
    ls -ld "$SSH_DIR" "$AUTHORIZED_KEYS"
    echo "Contents of authorized_keys:"
    cat "$AUTHORIZED_KEYS"
else
    echo "authorized_keys NOT found for fedora! Key login may fail."
fi

echo -e "\n-------------------------------"
echo -e "\n- Firewall Rules --------------"
# Check if port 9876 is allowed
PORT=9876
# List all firewall rules and check if only this port is allowed
echo "Active firewall zones:"
firewall-cmd --get-active-zones
echo "Ports in public zone:"
firewall-cmd --zone=public --list-ports
echo "Rich rules:"
firewall-cmd --zone=public --list-rich-rules
# Check if port 9876 is the only allowed port, if not, notify user
PORTS=$(firewall-cmd --zone=public --list-ports)
if [[ "$PORTS" == "$PORT/tcp" ]]; then
    echo "Firewall correctly allows only port $PORT"
else
    echo "Firewall allows additional ports! Check rules."
fi

echo -e "\n------------------------------"
echo -e "\n- Admin User Check ------------"


# If User exists
if id "admin" >/dev/null 2>&1; then
    echo "User admin exists"
    groups "admin"
    UID=$(id -u "admin")
    if [ "$UID" -ne 0 ]; then
        echo "Admin is non-root"
    else
        echo "Admin is UID 0! This is a root-level account."
    fi
else
    echo "User admin does NOT exist!"
fi

# Week 5 baseline verification script
# Generate a readable SELinux report

echo "------------------------------"
# -e for special characters
echo -e "\n- SELinux Status ----------------"
getenforce
sestatus -v

echo -e "\n------------------------------"
echo -e "\n- SELinux Booleans -----------"
semanage boolean -l

echo -e "\n------------------------------"
echo -e "\n- SELinux AVC Denials --------"
sudo ausearch -m avc

echo -e "\n------------------------------"
echo -e "\n- SELinux Directory Contexts -"
ls -Z /etc/selinux

echo -e "\n------------------------------"
echo -e "\n- SELinux Process Contexts ---"
ps -Z 

echo -e "\n------------------------------"
echo "Baseline check complete."