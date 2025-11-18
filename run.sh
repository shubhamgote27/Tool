#!/bin/bash

# ==========================================
# SG CLOUD DEVOPS MANAGER
# Combines the Installer and Uninstaller into one script.
# Contributor/Author: Shubham Gote
# LinkedIn: https://www.linkedin.com/in/shubham-gote-28a1a1215/
# ==========================================

# Colors for better visibility
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to pause and wait for user
pause() {
  echo -e "${BLUE}Process finished. Press [Enter] to return to menu...${NC}"
  read
}

log() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# ==========================================
# I. INSTALLATION FUNCTIONS (1-12)
# ==========================================

# 1. System Update
install_update() {
  echo -e "${GREEN}--- 1. Updating System Repositories ---${NC}"
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-get install -y curl wget apt-transport-https gnupg lsb-release ca-certificates software-properties-common
  echo -e "${GREEN}System Update Complete.${NC}"
  pause
}

# 2. Docker (Official Method)
install_docker() {
  echo -e "${GREEN}--- 2. Installing Docker (Official Repo) ---${NC}"
  sudo apt-get remove -y docker docker-engine docker.io containerd runc
  sudo apt-get update
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl start docker
  sudo systemctl enable docker
  echo -e "${GREEN}Docker Installed.${NC}"
  sudo docker --version
  pause
}

# 3. Jenkins
install_jenkins() {
  echo -e "${GREEN}--- 3. Installing Jenkins ---${NC}"
  sudo apt-get install -y openjdk-17-jre
  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y jenkins
  sudo systemctl enable jenkins
  sudo systemctl start jenkins
  echo -e "${GREEN}Jenkins Installed. Port 8080.${NC}"
    echo -e "${BLUE}------------------------------------------------------------${NC}"
    echo -e "${GREEN}JENKINS INITIAL ADMIN PASSWORD (Wait 10s for service start): ${NC}"
    sleep 10 
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    echo -e "${BLUE}------------------------------------------------------------${NC}"
  pause
}

# 4. Python 3
install_python() {
  echo -e "${GREEN}--- 4. Installing Python 3 ---${NC}"
  sudo apt-get install -y python3 python3-pip python3-venv
  python3 --version
  echo -e "${GREEN}Python 3 Installed.${NC}"
  pause
}

# 5. SonarQube (Via Docker)
install_sonarqube() {
  echo -e "${GREEN}--- 5. Deploying SonarQube (Container) ---${NC}"
  if ! command -v docker &> /dev/null; then echo -e "${RED}Docker is not installed. Please install Docker (Option 2) first.${NC}"; pause; return; fi
  sudo sysctl -w vm.max_map_count=262144
  echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
  sudo docker run -d --name sonarqube -p 9000:9000 --restart=always sonarqube:community
  echo -e "${GREEN}SonarQube container started on Port 9000.${NC}"
  pause
}

# 6. Kubernetes (Kubeadm, Kubelet, Kubectl)
install_kubernetes() {
  echo -e "${GREEN}--- 6. Installing Kubernetes Tools (v1.30) ---${NC}"
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
  sudo modprobe overlay
  sudo modprobe br_netfilter
  cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward        = 1
EOF
  sudo sysctl --system
  sudo apt-get install -y apt-transport-https ca-certificates curl gpg
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
  echo -e "${GREEN}Kubernetes Tools Installed.${NC}"
  pause
}

# 7. Nexus3 (Via Docker)
install_nexus() {
  echo -e "${GREEN}--- 7. Deploying Nexus3 (Container) ---${NC}"
  if ! command -v docker &> /dev/null; then echo -e "${RED}Docker is not installed. Please install Docker (Option 2) first.${NC}"; pause; return; fi
  sudo docker volume create --name nexus-data
  sudo docker run -d -p 8081:8081 --name nexus --restart=always -v nexus-data:/nexus-data sonatype/nexus3
  echo -e "${GREEN}Nexus3 container started on Port 8081.${NC}"
  pause
}

# 8. Terraform (Infrastructure as Code)
install_terraform() {
  echo -e "${GREEN}--- 8. Installing HashiCorp Terraform ---${NC}"
  apt-get install -y software-properties-common
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  apt-get update
  apt-get install -y terraform
  echo -e "${GREEN}Terraform installed. Version: $(terraform version | head -n 1)${NC}"
  pause
}

# 9. Ansible (Configuration Management)
install_ansible() {
  echo -e "${GREEN}--- 9. Installing Ansible (via PPA) ---${NC}"
  sudo apt-add-repository ppa:ansible/ansible -y
  apt-get update
  apt-get install -y ansible
  echo -e "${GREEN}Ansible installed. Version: $(ansible --version | head -n 1)${NC}"
  pause
}

# 10. Helm (Kubernetes Package Manager)
install_helm() {
  echo -e "${GREEN}--- 10. Installing Helm ---${NC}"
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  echo -e "${GREEN}Helm installed. Version: $(helm version --template '{{.Version}}')${NC}"
  pause
}

# 11. Prometheus (Monitoring - Via Docker)
install_prometheus() {
    echo -e "${GREEN}--- 11. Deploying Prometheus (Container) ---${NC}"
    if ! command -v docker &> /dev/null; then echo -e "${RED}Docker is not installed. Please install Docker (Option 2) first.${NC}"; pause; return; fi
    mkdir -p /opt/prometheus/config
    cat <<EOF > /opt/prometheus/config/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['host.docker.internal:9100']
EOF
    sudo docker run -d \
        --name prometheus \
        -p 9090:9090 \
        --restart=always \
        -v /opt/prometheus/config/prometheus.yml:/etc/prometheus/prometheus.yml \
        prom/prometheus
    echo -e "${GREEN}Prometheus container started on Port 9090.${NC}"
    pause
}

# 12. Grafana (Visualization - Via Docker)
install_grafana() {
    echo -e "${GREEN}--- 12. Deploying Grafana (Container) ---${NC}"
    if ! command -v docker &> /dev/null; then echo -e "${RED}Docker is not installed. Please install Docker (Option 2) first.${NC}"; pause; return; fi
    sudo docker volume create --name grafana-data
    sudo docker run -d \
        --name grafana \
        -p 3000:3000 \
        --restart=always \
        -v grafana-data:/var/lib/grafana \
        grafana/grafana
    echo -e "${GREEN}Grafana container started on Port 3000.${NC}"
    echo "Access via http://localhost:3000 (Default login: admin/admin)"
    pause
}


# ==========================================
# II. UNINSTALLATION FUNCTIONS (1-12)
# ==========================================

# 1. System Cleanup (Basic)
uninstall_update() {
    log "Removing unnecessary packages and cleaning up APT cache..."
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    echo -e "${GREEN}System cleanup complete.${NC}"
    pause
}

# 2. Docker
uninstall_docker() {
    log "Stopping and removing all Docker components and dependencies..."
    sudo systemctl stop docker
    sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null || log "No containers found to remove."
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo rm -rf /var/lib/docker
    sudo rm -f /etc/apt/sources.list.d/docker.list
    echo -e "${GREEN}Docker uninstalled.${NC}"
    pause
}

# 3. Jenkins
uninstall_jenkins() {
    log "Stopping and removing Jenkins and Java 17..."
    sudo systemctl stop jenkins
    sudo apt-get purge -y jenkins openjdk-17-jre
    sudo rm -f /etc/apt/sources.list.d/jenkins.list
    sudo rm -rf /var/lib/jenkins
    echo -e "${GREEN}Jenkins uninstalled.${NC}"
    pause
}

# 4. Python 3 (Basic check)
uninstall_python() {
    log "Removing Python 3 packages..."
    sudo apt-get remove -y python3 python3-pip python3-venv
    echo -e "${GREEN}Python 3 packages removed.${NC}"
    pause
}

# 5. SonarQube (Via Docker)
uninstall_sonarqube() {
    log "Stopping and removing SonarQube container and configuration..."
    sudo docker stop sonarqube 2>/dev/null || log "SonarQube container not running."
    sudo docker rm sonarqube 2>/dev/null || log "SonarQube container not found."
    sudo sed -i '/vm.max_map_count/d' /etc/sysctl.conf
    sudo sysctl -p
    echo -e "${GREEN}SonarQube container removed.${NC}"
    pause
}

# 6. Kubernetes (Kubeadm, Kubelet, Kubectl)
uninstall_kubernetes() {
    log "Removing Kubernetes tools..."
    sudo kubeadm reset -f 2>/dev/null || log "Kubeadm cluster not initialized or reset failed (safe to ignore)."
    sudo apt-get purge -y kubelet kubeadm kubectl
    sudo rm -f /etc/apt/sources.list.d/kubernetes.list
    sudo sed -i '/net.bridge.bridge-nf-call-iptables/d' /etc/sysctl.d/k8s.conf
    sudo sysctl --system
    echo -e "${GREEN}Kubernetes tools uninstalled.${NC}"
    pause
}

# 7. Nexus3 (Via Docker)
uninstall_nexus() {
    log "Stopping and removing Nexus3 container and volume..."
    sudo docker stop nexus 2>/dev/null || log "Nexus container not running."
    sudo docker rm nexus 2>/dev/null || log "Nexus container not found."
    log "WARNING: Nexus data volume (nexus-data) will be removed!"
    sudo docker volume rm nexus-data 2>/dev/null || log "Nexus data volume not found."
    echo -e "${GREEN}Nexus3 container and data removed.${NC}"
    pause
}

# 8. Terraform (Infrastructure as Code)
uninstall_terraform() {
    log "Removing Terraform..."
    sudo apt-get purge -y terraform
    sudo rm -f /etc/apt/sources.list.d/hashicorp.list
    echo -e "${GREEN}Terraform uninstalled.${NC}"
    pause
}

# 9. Ansible (Configuration Management)
uninstall_ansible() {
    log "Removing Ansible..."
    sudo apt-get purge -y ansible
    sudo apt-add-repository --remove ppa:ansible/ansible -y
    echo -e "${GREEN}Ansible uninstalled.${NC}"
    pause
}

# 10. Helm (Kubernetes Package Manager)
uninstall_helm() {
    log "Removing Helm..."
    sudo rm -f /usr/local/bin/helm
    echo -e "${GREEN}Helm uninstalled.${NC}"
    pause
}

# 11. Prometheus (Via Docker)
uninstall_prometheus() {
    log "Stopping and removing Prometheus container and config..."
    sudo docker stop prometheus 2>/dev/null || log "Prometheus container not running."
    sudo docker rm prometheus 2>/dev/null || log "Prometheus container not found."
    sudo rm -rf /opt/prometheus/config
    echo -e "${GREEN}Prometheus container and config removed.${NC}"
    pause
}

# 12. Grafana (Via Docker)
uninstall_grafana() {
    log "Stopping and removing Grafana container and volume..."
    sudo docker stop grafana 2>/dev/null || log "Grafana container not running."
    sudo docker rm grafana 2>/dev/null || log "Grafana container not found."
    log "WARNING: Grafana data volume (grafana-data) will be removed!"
    sudo docker volume rm grafana-data 2>/dev/null || log "Grafana data volume not found."
    echo -e "${GREEN}Grafana container and data removed.${NC}"
    pause
}

# ==========================================
# III. MENU HANDLERS
# ==========================================

# Menu 1: Installer
installer_menu() {
    while true; do
        clear
        echo -e "${GREEN}--------------------------------------------${NC}"
        echo -e "${GREEN} Script Contributed by: Shubham Gote ${NC}"
        echo -e "${GREEN}--------------------------------------------${NC}"
        echo "============================================"
        echo "   INSTALLER: SG CLOUD TOOLS (1/2)"
        echo "============================================"
        echo "1. System Update & Dependencies"
        echo "2. Docker (Official Engine)"
        echo "3. Jenkins (LTS) - Port 8080"
        echo "4. Python 3"
        echo "5. SonarQube (Docker) - Port 9000"
        echo "6. Kubernetes Tools (Kubeadm, Kubelet)"
        echo "7. Nexus3 (Docker) - Port 8081"
        echo "8. Terraform (IaC)"
        echo "9. Ansible (Config Management)"
        echo "10. Helm (K8s Package Manager)"
        echo "11. Prometheus (Monitoring) - Port 9090"
        echo "12. Grafana (Visualization) - Port 3000"
        echo "13. RETURN to Main Menu" 
        echo "============================================"
        read -p "Enter your choice [1-13]: " choice

        case $choice in
            1) install_update ;;
            2) install_docker ;;
            3) install_jenkins ;;
            4) install_python ;;
            5) install_sonarqube ;;
            6) install_kubernetes ;;
            7) install_nexus ;;
            8) install_terraform ;;
            9) install_ansible ;;
            10) install_helm ;;
            11) install_prometheus ;;
            12) install_grafana ;;
            13) break ;; # Exit this loop, return to main_menu
            *) echo -e "${RED}Invalid option. Please try again.${NC}"; sleep 2 ;;
        esac
    done
}

# Menu 2: Uninstaller
uninstaller_menu() {
    while true; do
        clear
        echo -e "${RED}--------------------------------------------${NC}"
        echo -e "${RED} DANGER ZONE: UNINSTALLER SCRIPT (2/2) ${NC}"
        echo -e "${RED}--------------------------------------------${NC}"
        echo "============================================"
        echo "   UNINSTALLER: SG CLOUD TOOLS"
        echo "============================================"
        echo "1. System Cleanup (Autoremove/Autoclean)"
        echo "2. Uninstall Docker"
        echo "3. Uninstall Jenkins"
        echo "4. Uninstall Python 3 Packages"
        echo "5. Uninstall SonarQube (Container/Config)"
        echo "6. Uninstall Kubernetes Tools"
        echo "7. Uninstall Nexus3 (Container/Data) - WARNING!"
        echo "8. Uninstall Terraform"
        echo "9. Uninstall Ansible"
        echo "10. Uninstall Helm"
        echo "11. Uninstall Prometheus (Container/Config)"
        echo "12. Uninstall Grafana (Container/Data) - WARNING!"
        echo "13. RETURN to Main Menu" 
        echo "============================================"
        read -p "Enter your choice [1-13]: " choice

        case $choice in
            1) uninstall_update ;;
            2) uninstall_docker ;;
            3) uninstall_jenkins ;;
            4) uninstall_python ;;
            5) uninstall_sonarqube ;;
            6) uninstall_kubernetes ;;
            7) uninstall_nexus ;;
            8) uninstall_terraform ;;
            9) uninstall_ansible ;;
            10) uninstall_helm ;;
            11) uninstall_prometheus ;;
            12) uninstall_grafana ;;
            13) break ;; # Exit this loop, return to main_menu
            *) echo -e "${RED}Invalid option. Please try again.${NC}"; sleep 2 ;;
        esac
    done
}


# ==========================================
# IV. PRIMARY ENTRY POINT
# ==========================================

while true; do
    clear
    echo "============================================"
    echo "   SG CLOUD DEVOPS MANAGER"
    echo "============================================"
    echo "Please select the desired action:"
    echo "1. Run INSTALLER (Setup/Install Tools)"
    echo "2. Run UNINSTALLER (Remove/Cleanup Tools)"
    echo "3. Exit Script"
    echo "============================================"
    read -p "Enter your choice [1-3]: " primary_choice

    case $primary_choice in
        1) installer_menu ;;
        2) uninstaller_menu ;;
        3) echo "Exiting SG DevOps Manager. Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid selection. Please enter 1, 2, or 3.${NC}"; sleep 2 ;;
    esac
done
