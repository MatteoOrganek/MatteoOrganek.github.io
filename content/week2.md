## Security Planning and Testing Methodology

On week 2 I designated and executed a performance testing and security monitoring strategy for the two Linux-based virtual machines. The goal is to evaluate CPU, memory, and I/O efficiency under load and maintaining secure access through hardened configurations and remote monitoring.

> Test Environment (see [week 1's diagram](/week1.md)):
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

> The SSH on both VM uses the default SSH with port 22 (for now) and will be connected remotely using static IP addresses ending on 100-101:
```bash
ssh fedora@192.168.0.100
ssh ubuntu@192.168.0.101
```
&nbsp;

---
### > System Hardening checklist
System hardening is a process that changes the default settings in an operating system. It will ensure that unnecessary privileges are revoked and all possible vulnerabilities are addressed and removed. Below you can find some of the possible steps that can be taken to secure a System:
&nbsp;

> SSH Hardening 

The following commands will disable root login, enforce key-based authentication, and change default port.
```bash
sudo vi /etc/ssh/sshd_config
> Port: 9876
> PermitRootLogin: no
sudo systemctl disable sshd
sudo systemctl enable sshd
```
*Disabling password login and root access mitigates credential brute-forcing and privilege escalation. In 2016, Linux Mint’s servers were breached after attackers gained unauthorized access through weak SSH configuration, allowing a malicious ISO to be distributed [[6]](/references.md).*

&nbsp;

> Firewall configuration

The following will configure ufw (Ubuntu) / firewalld (Fedora), allow only SSH + required services and will drop everything else.
```bash
# fedora
sudo firewall-cmd --permanent --add-port=9876/tcp
# Just in case, remove default port
sudo firewall-cmd --permanent --remove-port=22/tcp 
sudo firewall-cmd --reload
```
*Configuring Firewalls to allow only certain connections can stop an incoming attack or stop the spread of viruses. WannaCry spread globally in May 2017, infecting hundreds of thousands of computers in 150+ countries. The primary exploit was EternalBlue (CVE-2017-0145) against Microsoft Windows systems with unpatched SMB vulnerabilities. It managed to duplicate itself through the network due to a lack of firewall defenses [[7]](/references.md).*

&nbsp;

> Automatic updates 

Configure automatic updates with unattended-upgrades / dnf automatic update service
```bash
# Ubuntu
sudo apt install unattended-upgrades
# Fedora
sudo dpkg-reconfigure unattended-upgrades
```
*A lack of automatic updates can turn a patchable flaw into a major risk for systems, as it can introduce known vulnerabilities. In 2017, Equifax suffered a massive data breach that exposed sensitive data for ~143 million people. The root cause was a known critical vulnerability (CVE-2017-5638) in the widely used web framework Apache Struts that was patched a few months prior [[8]](/references.md).
The Wannacry ransomware could have been contained with proper update support as well [[7]](/references.md).*
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

*Below you can find a trust boundary diagram showing both VMs' system hardening result*

![Trust Boundary Diagram](../assets/week2/trust.png)

---
&nbsp;

### > Threat Model & Mitigation Strategies

Below you may find three different threats and their respective mitigation strategies:

| **Threat**                                  | **Description**                                                               | **Assets at Risk**                                         | **Impact if Exploited**                                                              | **Mitigation Strategies**                                                                                              |
| ------------------------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| **Unauthorized Access via SSH Brute Force** | Attackers attempt repeated login attempts to gain access through SSH.         | System accounts, stored data, server integrity.            | Attacker gains control, data breach, service disruption.                             | Implement key-based authentication, disable password login, change default SSH port, use Fail2Ban, disable root login. |
| **Privilege Escalation**                    | A user or malicious actor exploits misconfigurations to gain elevated access. | Root privileges, configuration files, full system control. | Total system compromise, deletion or modification of files, persistence of attacker. | Enforce least-privilege access, audit sudoers regularly, apply security patches, enable logging and alerts.            |
| **Denial of Service (DoS)**                 | Excessive traffic or resource-heavy requests overload system resources.       | CPU, RAM, network bandwidth.                               | Service outage, performance degradation, loss of availability.                       | Enable rate-limiting, configure firewall rules, resource monitoring, load testing, set ulimit constraints.             |
