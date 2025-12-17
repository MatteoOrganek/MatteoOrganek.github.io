## Security Audit and System Evaluation
The goal for this phase was to conduct a comprehensive security audit and evaluate the overall system configuration. The focus was on identifying vulnerabilities, verifying access control, reviewing running services, and assessing remaining risks.

The mandatory tasks included:

&nbsp;

### > Security scanning using Lynis
The system was scanned with `Lynis`, a host-based security auditing tool. The command executed [[16]](/references.md) was:

```bash
sudo lynis audit system --quick
```

![lynis_scan_base.png](../assets/week7/lynis_scan_base.png)

The `Lynis` score before remediation was 66/100, showing moderate compliance with many potential security issues [[16]](/references.md).

![linys_score.png](../assets/week7/linys_score.png)

The baseline audit showed one Warning and 34 Suggestions:

![linys_scan_result.png](../assets/week7/linys_scan_result.png)

The main waring specified that fail2ban jail was disabled. To enable it, I created the file `/etc/fail2ban/jail.local` and added `enabled=true` to both *sshd* and *proftpd*. This action bumped the score to 68/100.

![fail2ban.png](../assets/week7/fail2ban.png)

I added a malware scanner as suggested, installing rkhunter.
![malware.png](../assets/week7/malware.png)

Blacklist unused protocols:
![blacklist_protocols.png](../assets/week7/blacklist_protocols.png)

Extra SSH Hardening
![ssh1.png](../assets/week7/ssh1.png)
![ssh2.png](../assets/week7/ssh2.png)
![ssh3.png](../assets/week7/ssh3.png)
![ssh4.png](../assets/week7/ssh4.png)

Finally, after following some of the suggestions, I received a score of 83/100.
![yay.png](../assets/week7/yay.png)

Disabling services improved security but slightly reduced system convenience (e.g., local printing and device discovery).

---
&nbsp;

### > Network security assessment using nmap

---
&nbsp;

### > Verification of access control policies

---
&nbsp;

### > Service audit and justification of all running services

---
&nbsp;

### > System configuration review and optimization