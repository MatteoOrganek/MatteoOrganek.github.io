## Application Selection for Performance Testing

Select applications representing different workload types for performance evaluation.
Deliverables (Journal):
1. Select applications representing different workload types (e.g. CPU-intensive, RAM-
   intensive, I/O-intensive, Network-intensive, and Server applications such as game servers)
   for performance evaluation and create an Application Selection Matrix listing applications
   with justifications for choosing them.
2. Installation Documentation with exact commands for SSH-based installation
3. Expected Resource Profiles documenting anticipated resource usage
4. Monitoring Strategy explaining measurement approach for each application

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
# Nginx web server
sudo apt install nginx -y
# Network benchmark tool
sudo apt install iperf3 -y
```

> Fedora installation

```bash
# System update
sudo dnf update -y
# Stress testing suite
sudo dnf install stress-ng -y
# Nginx web server
sudo dnf install nginx -y
# Network benchmark tool
sudo dnf install iperf3 -y
```

> Start the server using `sudo systemctl start nginx`