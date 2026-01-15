# ARK Installation Guide

**Complete installation instructions for various environments.**

---

## Table of Contents

1. [Ubuntu/Debian Installation](#ubuntudebian-installation)
2. [Windows (Hyper-V VM)](#windows-hyper-v-vm)
3. [macOS (VirtualBox)](#macos-virtualbox)
4. [Proxmox VE](#proxmox-ve)
5. [Bare Metal](#bare-metal)
6. [Storage Configuration](#storage-configuration)
7. [Network Configuration](#network-configuration)

---

## Ubuntu/Debian Installation

### Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y git curl wget net-tools

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose v2
sudo apt install -y docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

### Deploy ARK

```bash
# Clone repository
sudo git clone <your-repo-url> /opt/ark
cd /opt/ark

# Set ownership
sudo chown -R $USER:$USER /opt/ark

# Configure (optional - edit docker-compose.yml)
nano docker-compose.yml

# Deploy
docker compose up -d

# Check status
docker ps
```

---

## Windows (Hyper-V VM)

ARK is designed to run in a Linux VM on Windows hosts, with shared storage via CIFS/SMB.

### Step 1: Create Ubuntu VM

1. Open Hyper-V Manager
2. Create New Virtual Machine:
   - Name: `nomad-node` (or similar)
   - Generation 2
   - Memory: 12GB (8GB minimum)
   - Network: Default Switch (for internet access)
   - Disk: 100GB (VHD)
3. Install Ubuntu 24.04 LTS
4. Complete Ubuntu setup

### Step 2: Configure VM Network

```bash
# Set static IP (recommended)
sudo nano /etc/netplan/00-installer-config.yaml
```

Example config:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.26.8/24
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
      routes:
        - to: default
          via: 192.168.26.1
```

Apply:
```bash
sudo netplan apply
```

### Step 3: Configure CIFS Mount (Storage)

Create credentials file:
```bash
sudo nano /etc/cifs-credentials
```

Add:
```
username=YOUR_WINDOWS_USERNAME
password=YOUR_WINDOWS_PASSWORD
domain=WORKGROUP
```

Secure it:
```bash
sudo chmod 600 /etc/cifs-credentials
```

Add to `/etc/fstab`:
```bash
sudo nano /etc/fstab
```

Add line:
```
//192.168.26.1/DOCK /mnt/dock cifs credentials=/etc/cifs-credentials,uid=1000,gid=1000,file_mode=0775,dir_mode=0775 0 0
```

Mount:
```bash
sudo mkdir -p /mnt/dock
sudo mount -a
```

Verify:
```bash
mountpoint /mnt/dock && echo "✓ Mounted"
```

### Step 4: Deploy ARK

Follow Ubuntu installation steps above.

---

## macOS (VirtualBox)

### Prerequisites

1. Install VirtualBox: https://www.virtualbox.org/
2. Download Ubuntu 24.04 LTS ISO

### VM Setup

1. Create New VM:
   - Name: nomad-node
   - Type: Linux
   - Version: Ubuntu (64-bit)
   - RAM: 12GB
   - Disk: 100GB (dynamically allocated)

2. Configure Network:
   - Adapter 1: NAT (for internet)
   - Adapter 2: Host-Only Adapter (for host access)

3. Install Ubuntu, then install Guest Additions:
```bash
sudo apt install -y virtualbox-guest-utils virtualbox-guest-dkms
```

### Shared Folder Setup

1. In VirtualBox, add Shared Folder:
   - Path: `/Users/yourname/ARK_Data` (create on Mac)
   - Name: `dock`
   - Auto-mount: Yes
   - Make Permanent: Yes

2. In Ubuntu VM:
```bash
sudo usermod -aG vboxsf $USER
sudo mkdir -p /mnt/dock
sudo ln -s /media/sf_dock /mnt/dock
```

3. Deploy ARK (follow Ubuntu steps)

---

## Proxmox VE

### Create CT (Container) or VM

**Container (Recommended):**
```bash
# On Proxmox host
pct create 100 local:vztmpl/ubuntu-24.04-standard_24.04-1_amd64.tar.zst \
  --hostname nomad-node \
  --memory 12288 \
  --cores 4 \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.26.8/24,gw=192.168.26.1 \
  --storage local-lvm \
  --rootfs local-lvm:100 \
  --unprivileged 1 \
  --features nesting=1

# Start container
pct start 100

# Enter container
pct enter 100
```

**Inside Container:**
```bash
# Install dependencies
apt update && apt upgrade -y
apt install -y docker.io docker-compose git curl

# Deploy ARK
git clone <repo-url> /opt/ark
cd /opt/ark
docker compose up -d
```

---

## Bare Metal

For dedicated hardware (Intel NUC, mini PC, server):

### Hardware Requirements

**Minimum:**
- CPU: Dual-core x86_64
- RAM: 8GB
- Storage: 100GB SSD
- Network: Ethernet

**Recommended:**
- CPU: Quad-core x86_64 (i5/Ryzen 5+)
- RAM: 16GB+
- Storage: 256GB NVMe SSD + 1TB HDD for media
- Network: Gigabit Ethernet

### Installation

1. Install Ubuntu Server 24.04 LTS
2. Configure network (static IP recommended)
3. Install Docker + Docker Compose
4. Deploy ARK (standard steps)

---

## Storage Configuration

### Option 1: Local Storage Only

Edit `docker-compose.yml`, replace all `/mnt/dock` paths with local paths:

```yaml
volumes:
  - /opt/ark/data/media:/media
  - /opt/ark/data/models:/models
  # etc.
```

### Option 2: External Drive

```bash
# Format drive (if new)
sudo mkfs.ext4 /dev/sdb1

# Get UUID
sudo blkid /dev/sdb1

# Add to /etc/fstab
UUID=your-uuid-here /mnt/dock ext4 defaults 0 2

# Mount
sudo mkdir -p /mnt/dock
sudo mount -a
```

### Option 3: Network Storage (NFS)

```bash
# Install NFS client
sudo apt install -y nfs-common

# Add to /etc/fstab
192.168.1.100:/export/ark /mnt/dock nfs defaults 0 0

# Mount
sudo mount -a
```

---

## Network Configuration

### Firewall Setup

```bash
# UFW (Ubuntu)
sudo ufw allow 3000/tcp  # Homepage
sudo ufw allow 3001/tcp  # Open WebUI
sudo ufw allow 8096/tcp  # Jellyfin
# ... add others as needed

sudo ufw enable
```

### DNS (Optional)

Add to `/etc/hosts` on client machines:
```
192.168.26.8  ark.local
192.168.26.8  homepage.ark.local
192.168.26.8  jellyfin.ark.local
# etc.
```

### Reverse Proxy (Advanced)

For custom domain access, configure Traefik labels in `docker-compose.yml`.

---

## Post-Installation

1. **Verify deployment:** `docker ps` (all 16 containers running)
2. **Access Homepage:** http://192.168.26.8:3000
3. **Complete setup wizards** (see Quickstart guide)
4. **Download content:** Run content download scripts
5. **Configure backups:** Set up regular backups of `/opt/ark/configs`

---

## Next Steps

- **[Quickstart Guide](QUICKSTART.md)** - Get up and running fast
- **[Configuration Guide](../guides/CONFIGURATION.md)** - Customize your setup
- **[Troubleshooting](../reference/TROUBLESHOOTING.md)** - Fix common issues

---

**Need help?** Open an issue on GitHub or check the [FAQ](../reference/FAQ.md).
