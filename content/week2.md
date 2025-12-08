## Security Planning and Testing Methodology

On week 2 I designated and executed a performance testing and security monitoring strategy for the two Linux-based virtual machines. The goal is to evaluate CPU, memory, and I/O efficiency under load and maintaining secure access through hardened configurations and remote monitoring.

> Test Environment:
*Virtual Machine 1*: Ubuntu (apt package manager)  
*Virtual Machine 2*: Fedora (dnf package manager)  
*Host Machine*: Windows 11 using VirtualBox with bridged network

&nbsp;

---
### > Performance Testing Strategy
I will be capturing idle system resource usage using `htop`, `iotop`, `nmon`, `journalctl`, `systemd-analyze` and `iftop` to create a baseline comparison with my tests [[5]](/references.md). The Windows machine will be connected to both VMs through *SSH* capturing relevant information after each test. Then,
- I will update the system using `apt update` and `dnf update`, the host will observe any CPU, RAM and I/O spikes.
- I will send an item through *SCP* (Secure Copy Protocol based on *SSH*), capturing any network, latency and I/O spikes.
- I will copy and paste in another directory the transferred file (1GB) and detect any I/O or transfer speed.

> The SSH on both VM uses the default SSH with port 22 (for now) and will be connected remotely using static IP addresses (100-101):
```bash
ssh fedora@192.168.0.100
ssh ubuntu@192.168.0.101
```
&nbsp;

---
### > System Hardening
System hardening is a process that changes the default settings in an operating system. It will ensure that unnecessary privileges are revoked and all possible vulnerabilities are addressed and removed. Below you can find some of the possible steps that can be taken to secure a System:
&nbsp;

> SSH Hardening 

The following commands will disable root login, enforce key-based authentication, and change default port.
```bash
sudo nano /etc/ssh/sshd_config
> PermitRootLogin: no
> PasswordAuthentication: no
> Port: 2222
sudo systemctl restart ssh
```
*Disabling password login and root access mitigates credential brute-forcing and privilege escalation. In 2016, Linux Mint’s servers were breached after attackers gained unauthorized access through weak SSH configuration, allowing a malicious ISO to be distributed.*

&nbsp;

> Firewall configuration

The following will configure ufw (Ubuntu) / firewalld (Fedora), allow only SSH + required services and will drop everything else.
```bash
# Ubuntu
sudo ufw enable
sudo ufw allow 2222/tcp
sudo ufw default deny incoming
# Fedora
sudo firewalld enable
sudo firewalld allow 2222/tcp
sudo firewalld default deny incoming
```
&nbsp;

> Automatic updates (Ubuntu)

Configure automatic updates with unattended-upgrades / dnf automatic update service
```bash
# Ubuntu
sudo apt install unattended-upgrades
# Fedora
sudo dpkg-reconfigure unattended-upgrades
```
&nbsp;

> SELinux/AppArmor status

Enable Mandatory Access Control with AppArmor (Ubuntu) or SELinux (Fedora) 
```bash
# Ubuntu
sudo systemctl enable apparmor
sudo systemctl start apparmor
sudo aa-status  
# Fedora
setenforce 1
getenforce  
```
&nbsp;

---
### Threat Model & Mitigation Strategies

Below you may find three different threats and their respective mitigation strategies:



   Threat	Risk Description	Impact	Mitigation
   Unauthorized Access via SSH Brute Force	Attackers attempt to guess login credentials	Server compromise, data loss	Key-based auth, custom port, fail2ban, disable root login
   Privilege Escalation	User exploits misconfigurations to obtain root access	Full system control	Least-privilege accounts, audit sudoers, log monitoring
   Network-Based Attack (Port Scanning/MITM)	Open ports exposed to network scanning	Data interception & intrusion	Firewall hardening, encrypted communication, monitor network traffic
   Malware from Package Repositories	Installing unsigned/untrusted software	System instability or compromise	Use official repos, verify GPG signatures
   DoS Under High Load	Resource exhaustion from heavy tasks	Server slowdown/outage	Resource limits, monitoring alerts, system load testing
   Reflection

Implementing a secure environment while testing performance highlighted the balance between resource efficiency and protection. Security controls such as SSH key authentication and firewall filtering help reduce attack vectors with minimal performance cost. SELinux/AppArmor introduces overhead, but offers strong mandatory access control—ideal for production workloads. For lightweight systems, Ubuntu with AppArmor might offer simpler management, while Fedora with SELinux suits environments demanding stronger security enforcement.