# 🚀 SG Cloud DevOps Manager

A comprehensive, menu-driven Bash script designed to set up or tear down a complete modern DevOps environment on Ubuntu/Debian systems (including AWS, Azure, or WSL).

This single script simplifies the process of installing and configuring essential tools for CI/CD, container orchestration, and Infrastructure as Code (IaC).

---

## 🛠️ Key Features

* **Single Script, Dual Function:** Choose between **Installation** (Setup) and **Uninstallation** (Cleanup) from the main menu.
* **Modular Installation:** Installs core components individually (Docker, Jenkins, Kubernetes, etc.).
* **Cloud-Native Deployment:** Uses Docker containers for non-system tools (SonarQube, Nexus, Prometheus, Grafana) for quick setup and isolation.
* **Automated Cleanup:** The Uninstaller safely removes packages, stops services, and deletes configuration files/Docker volumes.

---

## 📦 Installed Tools (12 Total)

The script offers individual options for these tools, categorized by function:

| Category | Tool | Port / Description |
| :--- | :--- | :--- |
| **CI/CD & Source** | **Jenkins** | Port 8080 (Automation Server) |
| | **Python 3** | Core language environment and PIP |
| **Container & Orchestration** | **Docker** | Container Engine |
| | **Kubernetes Tools** | `kubeadm`, `kubelet`, `kubectl` binaries |
| | **Helm** | Kubernetes package manager |
| **IaC & Configuration** | **Terraform** | HashiCorp IaC tool |
| | **Ansible** | Configuration management tool |
| **DevOps Services** | **SonarQube** | Port 9000 (Code quality analysis) |
| | **Nexus3** | Port 8081 (Artifact repository) |
| **Monitoring & Observability** | **Prometheus** | Port 9090 (Time-series monitoring) |
| | **Grafana** | Port 3000 (Visualization dashboard) |
| **System** | **System Update** | `apt update` and essential dependencies |

---

## ⚙️ How to Use (Quick Start)

The easiest way to use this script is via a direct execution command on your new server or WSL instance.

### 1. Prerequisites

* A fresh **Ubuntu/Debian** based server or an initialized **WSL2** instance.
* The user must have **`sudo`** privileges.

### 2. Execution (The Single Command)

Run the following command directly in your terminal. This downloads the script from the official repository and pipes it directly into Bash for execution:

```bash
wget https://github.com/shubhamgote27/Tool/raw/refs/heads/main/run.sh
bash run.sh
