## Application Selection for Performance Testing

&nbsp;

### > Application Selection Matrix

| Workload Type               | Application Selected            | Justification                                                                            |
|-----------------------------|---------------------------------|------------------------------------------------------------------------------------------|
| *CPU-Intensive*             | `stress-ng`                     | Generates heavy computational load for controlled CPU stress testing                     |
| *RAM-Intensive*             | `stress-ng` with `--vm` workers | Allows allocation of a defined RAM workload for memory saturation tests                  |
| *I/O-Intensive*             | `dd` & large-file copy          | Tests disk read/write throughput and block performance                                   |
| *Network-Intensive*         | `iperf3`                        | Measures upload/download throughput and network latency                                  |
| *Server/Hosted Application* | `nginx` web server              | Lightweight server for concurrency, request handling, and network responsiveness testing |

---
&nbsp;
### > Installation Documentation (SSH Commands)


All applications will be installed remotely via SSH connection through Windows' *CMD*:

```bash
ssh fedora@192.168.0.100
ssh ubuntu@192.168.0.101
```

> Ubuntu installation

```bash
# System update
sudo apt update && sudo apt upgrade -y
# Stress testing suite
sudo apt install stress-ng -y
# Network benchmark tool
sudo apt install iperf3 -y
```

> Fedora installation

```bash
# System update
sudo dnf update -y
# Stress testing suite
sudo dnf install stress-ng -y
# Network benchmark tool
sudo dnf install iperf3 -y
```
&nbsp;

*Update both VMs, this can be done between VMs as well*
![Update](assets/week3/update.png)
*Install stress-ng*
![Update](assets/week3/stress.png)
*Install iperf3*
![Update](assets/week3/iperf3.png)


---
&nbsp;
### > Expected Resource Profiles

| Application                                 | Expected CPU Usage | Expected RAM Usage | Expected Disk I/O | Notes                                            |
|---------------------------------------------| ------------------ | ------------------ | ----------------- | ------------------------------------------------ |
| `stress-ng --cpu 3`                         | Very High          | Low/Medium         | None              | Maxes CPU cores proportionally                   |
| `stress-ng --vm 2 --vm-bytes 1G`            | Low CPU            | High RAM usage     | None              | Good for swap and memory pressure testing        |
| `dd if=/dev/zero of=testfile bs=3G count=2` | Low/Medium         | Low                | Very High         | Tests write throughput and block size efficiency |
| `iperf3 -s` / `iperf3 -c 192.168.0.100:101` | Medium             | Low                | Medium/High       | Measures network speed, round-trip time          |

---
&nbsp;
### > Monitoring Strategy
| Test            | Tools Used                  | Metrics Collected                                   | Output Method                        |
| --------------- |-----------------------------| --------------------------------------------------- | ------------------------------------ |
| CPU Stress Test | `htop`, `nmon`, `top`       | CPU %, load average, temperature, frequency scaling | Screenshots + recorded values        |
| RAM Saturation  | `free -h`, `vmstat`, `htop` | Memory consumption, swap usage, OOM events          | Before/after comparison              |
| Disk I/O        | `iotop`, `dd`               | Read/write speed (MB/s), I/O wait time              | Transfer rate logs + graphs optional |
| Network Test    | `iperf3`                    | Bandwidth (Mbps), latency, packet loss              | Client/server result logs            |

---
&nbsp;
## > Stress Fedora (server) CPU, RAM, I/O, Network

> `htop`, `nmon` and `top` with no cpu stress in Fedora (server)

![Monitor no load with htop](assets/week3/f_def_htop.png)
![Monitor no load with nmon](assets/week3/f_def_nmon.png)
![Monitor no load with top](assets/week3/f_def_top.png)


> `free` and `vmstat` with no cpu stress in Fedora (server)

![Monitor no load with free](assets/week3/f_def_free.png)
![Monitor no load with vmstat](assets/week3/f_def_vmstat.png)

> `iotop` with no I/O stress in Fedora (server)

![Monitor no load with iotop](assets/week3/f_def_iotop.png)

&nbsp;

> Run `stress-ng --cpu 3` in Fedora (server) and monitor using `htop`, `nmon` and `top` on Ubuntu (client)

![Run stress-ng --cpu](assets/week3/f_stress_cpu.png)
![Monitor stress-ng cpu with htop](assets/week3/f_stress_cpu_htop.png)
![Monitor stress-ng cpu with nmon](assets/week3/f_stress_cpu_nmon.png)
![Monitor stress-ng cpu with top](assets/week3/f_stress_cpu_top.png)

> Run `stress-ng --vm 2 --vm-bytes 1G` in Fedora (server) and monitor using `free -h`, `vmstat` and `htop` on Ubuntu (client)

![Run stress-ng ram](assets/week3/f_stress_ram.png)
![Monitor stress-ng ram with free](assets/week3/f_stress_ram_free.png)
![Monitor stress-ng ram with vmstat](assets/week3/f_stress_ram_vmstat.png)
![Monitor stress-ng ram with htop](assets/week3/f_stress_ram_htop.png)

> Run `dd if=/dev/zero of=testfile bs=3G count=2` in Fedora (server) and monitor using `iotop` on Ubuntu (client)

![Monitor stress-ng ram with vmstat](assets/week3/f_stress_io_dd.png)
![Monitor stress-ng ram with htop](assets/week3/f_stress_io_iotop.png)

> Run `iperf3 -c 192.168.0.101` in Fedora (server)

![Monitor stress-ng ram with vmstat](assets/week3/f_stress_net.png)

---
&nbsp;
## > Stress Ubuntu (client) CPU, RAM, I/O, Network

> `htop`, `nmon` and `top` with no cpu stress in Ubuntu (client)

![Monitor no load with htop](assets/week3/u_def_htop.png)
![Monitor no load with nmon](assets/week3/u_def_nmon.png)
![Monitor no load with top](assets/week3/u_def_top.png)

> `free` and `vmstat` with no cpu stress in Ubuntu (client)

![Monitor no load with free](assets/week3/u_def_free.png)
![Monitor no load with vmstat](assets/week3/u_def_vmstat.png)

> `iotop` with no I/O stress in Ubuntu (client)

![Monitor no load with iotop](assets/week3/u_def_iotop.png)

&nbsp;

> Run `stress-ng --cpu 3` in Ubuntu (client) and monitor using `htop`, `nmon` and `top` on Fedora (server)

![Run stress-ng --cpu](assets/week3/u_stress_cpu.png)
![Monitor stress-ng --cpu with htop](assets/week3/u_stress_cpu_htop.png)
![Monitor stress-ng --cpu with nmon](assets/week3/u_stress_cpu_nmon.png)
![Monitor stress-ng --cpu with top](assets/week3/u_stress_cpu_top.png)

> Run `stress-ng --vm 2 --vm-bytes 1G` in Ubuntu (client) and monitor using `free -h`, `vmstat` and `htop` on Fedora (server)

![Run stress-ng ram](assets/week3/u_stress_ram.png)
![Monitor stress-ng ram with free](assets/week3/u_stress_ram_free.png)
![Monitor stress-ng ram with vmstat](assets/week3/u_stress_ram_vmstat.png)
![Monitor stress-ng ram with htop](assets/week3/u_stress_ram_htop.png)

> Run `dd if=/dev/zero of=testfile bs=3G count=2` in Ubuntu (client) and monitor using `iotop` on Fedora (server)

![Monitor stress-ng ram with vmstat](assets/week3/u_stress_io_dd.png)
![Monitor stress-ng ram with htop](assets/week3/u_stress_io_iotop.png)

> Run `iperf3 -s` in Ubuntu (client)

![Monitor stress-ng ram with vmstat](assets/week3/u_stress_net.png)

