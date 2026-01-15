# Port Forwarding Setup for GitHub Actions

**How to allow GitHub Actions to SSH to your home server**

---

## The Problem

Your server is behind a router/NAT. GitHub Actions can't reach it because:
- Your router has a public IP (98.51.0.20)
- Your server has a private IP (192.168.x.x)
- Port 22 (SSH) isn't forwarded from router → server

---

## Solution Options

### Option 1: Port Forwarding (Simplest) ✅

**Best for:** Direct access, simple setup

**Steps:**
1. Configure router port forwarding
2. Use public IP in GitHub Secrets
3. Test connection

**Pros:**
- Simple
- Direct connection
- Fast

**Cons:**
- Exposes SSH to internet
- Requires router access
- Public IP may change

---

### Option 2: Cloudflare Tunnel (Recommended) ✅

**Best for:** Security, no port forwarding needed

**Steps:**
1. Install Cloudflare Tunnel on server
2. Configure tunnel for SSH
3. Use tunnel endpoint in GitHub Secrets

**Pros:**
- No port forwarding
- More secure
- Works behind any firewall
- Free SSL

**Cons:**
- Requires Cloudflare account
- Slightly more complex setup

---

### Option 3: Tailscale (Best for Privacy) ✅

**Best for:** Private networks, zero trust

**Steps:**
1. Install Tailscale on server
2. Get Tailscale IP
3. Use Tailscale IP in GitHub Secrets

**Pros:**
- Most secure
- No port forwarding
- Works anywhere
- Encrypted mesh network

**Cons:**
- Requires Tailscale account
- Both ends need Tailscale

---

## Option 1: Port Forwarding Setup

### Step 1: Check Server Firewall

```bash
# On your server
sudo ufw status

# If not active, enable and allow SSH
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status

# Should show:
# Status: active
# 22/tcp                    ALLOW       Anywhere
```

### Step 2: Find Your Server's Private IP

```bash
# On your server
hostname -I
# Output: 192.168.26.8 (or similar)
```

### Step 3: Configure Router Port Forwarding

**Access Router:**
1. Open browser: `http://192.168.1.1` or `http://192.168.0.1`
2. Login (check router label for default credentials)
3. Find "Port Forwarding" or "Virtual Server" section

**Common Router Brands:**
- **Netgear:** Advanced → Port Forwarding
- **Linksys:** Connectivity → Router Settings → Port Forwarding
- **TP-Link:** Advanced → NAT Forwarding → Virtual Servers
- **ASUS:** WAN → Virtual Server / Port Forwarding
- **Ubiquiti:** Settings → Routing & Firewall → Port Forwarding

**Add Rule:**
```
Service Name: SSH
External Port: 22
Internal Port: 22
Internal IP: 192.168.26.8 (your server's IP)
Protocol: TCP
Status: Enabled
```

**Save and Apply**

### Step 4: Find Your Public IP

```bash
# On your server or any device
curl ifconfig.me
# Output: 98.51.0.20 (your public IP)
```

### Step 5: Test Port Forwarding

**Option A: Online Tool**
1. Go to: https://canyouseeme.org
2. Enter port: `22`
3. Click "Check Port"
4. Should say: "Success: I can see your service"

**Option B: Command Line**
```bash
# From external network (or use online tool)
nc -zv 98.51.0.20 22
# Should say: Connection succeeded
```

### Step 6: Update GitHub Secrets

Go to: **Repository → Settings → Secrets → Actions**

Update:
```
SSH_HOST: 98.51.0.20  (your public IP, NOT domain)
SSH_PORT: 22
```

**⚠️ IMPORTANT:** Do NOT use `tylereno.me` if Cloudflare proxy is enabled. Cloudflare only proxies HTTP/HTTPS (ports 80/443), not SSH (port 22).

### Step 7: Test Connection

```bash
# On your local machine
./scripts/test-ssh-connection.sh

# Or manually
ssh -i ~/.ssh/github_actions_ark user@98.51.0.20
```

---

## Option 2: Cloudflare Tunnel Setup

### Step 1: Install Cloudflare Tunnel

```bash
# On your server
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
```

### Step 2: Authenticate

```bash
cloudflared tunnel login
# Opens browser - log in to Cloudflare
```

### Step 3: Create Tunnel

```bash
cloudflared tunnel create ark-ssh
# Note the tunnel ID
```

### Step 4: Configure Tunnel for SSH

```bash
# Create config
sudo mkdir -p /etc/cloudflared
sudo nano /etc/cloudflared/config.yml
```

Add:
```yaml
tunnel: YOUR_TUNNEL_ID
credentials-file: /root/.cloudflared/YOUR_TUNNEL_ID.json

ingress:
  - hostname: ssh.tylereno.me
    service: ssh://localhost:22
  - service: http_status:404
```

### Step 5: Route DNS

```bash
cloudflared tunnel route dns ark-ssh ssh.tylereno.me
```

### Step 6: Start Tunnel

```bash
# Test
cloudflared tunnel run ark-ssh

# Install as service
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

### Step 7: Update GitHub Secrets

```
SSH_HOST: ssh.tylereno.me
SSH_PORT: 22
```

**Note:** Cloudflare Tunnel handles the connection, no port forwarding needed!

---

## Option 3: Tailscale Setup

### Step 1: Install Tailscale

```bash
# On your server
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

### Step 2: Get Tailscale IP

```bash
# On your server
tailscale ip -4
# Output: 100.x.x.x (Tailscale IP)
```

### Step 3: Install Tailscale on GitHub Actions Runner

**Note:** This requires Tailscale auth key in GitHub Secrets.

Update workflow to install Tailscale before SSH:

```yaml
- name: Setup Tailscale
  run: |
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up --authkey=${{ secrets.TAILSCALE_AUTHKEY }}
```

### Step 4: Update GitHub Secrets

```
SSH_HOST: 100.x.x.x  (Tailscale IP)
SSH_PORT: 22
```

---

## Security Considerations

### Port Forwarding Security

**Risks:**
- SSH exposed to internet
- Brute force attacks possible
- Public IP visible

**Mitigations:**
1. **Use SSH keys only** (disable password auth)
   ```bash
   # On server: /etc/ssh/sshd_config
   PasswordAuthentication no
   PubkeyAuthentication yes
   ```

2. **Change SSH port** (security through obscurity)
   ```bash
   # On server: /etc/ssh/sshd_config
   Port 2222
   ```
   Then forward port 2222 instead of 22

3. **Use Fail2Ban**
   ```bash
   sudo apt install fail2ban
   ```

4. **Restrict SSH to GitHub IPs** (not recommended - IPs change)

### Cloudflare Tunnel Security

**Benefits:**
- No port forwarding needed
- Encrypted connection
- DDoS protection
- Access logs in Cloudflare

**Best Practice:**
- Use strong SSH keys
- Enable 2FA on Cloudflare account

### Tailscale Security

**Benefits:**
- Most secure option
- Encrypted mesh network
- Zero trust architecture
- No exposed ports

**Best Practice:**
- Use Tailscale ACLs to restrict access
- Enable 2FA on Tailscale account

---

## Troubleshooting

### "Connection timed out" After Port Forwarding

**Check:**
1. Router port forwarding rule is active
2. Server firewall allows port 22
3. Using public IP (not domain) in SSH_HOST
4. Router is not blocking outbound connections

**Test:**
```bash
# From external network
telnet 98.51.0.20 22
# Should connect (Ctrl+] to exit)
```

### "Connection refused"

**Check:**
1. SSH service running: `sudo systemctl status ssh`
2. Server firewall: `sudo ufw status`
3. SSH listening: `sudo netstat -tlnp | grep :22`

### "Permission denied"

**Check:**
1. SSH key in authorized_keys
2. Key permissions: `chmod 600 ~/.ssh/authorized_keys`
3. SSH config allows key auth

---

## Quick Reference

### Port Forwarding Checklist

- [ ] Server firewall allows port 22
- [ ] Router port forwarding configured
- [ ] Public IP identified
- [ ] Port forwarding tested (canyouseeme.org)
- [ ] GitHub Secrets updated with public IP
- [ ] SSH connection tested

### Cloudflare Tunnel Checklist

- [ ] Cloudflared installed
- [ ] Tunnel created
- [ ] Config file created
- [ ] DNS record added
- [ ] Tunnel service running
- [ ] GitHub Secrets updated with tunnel hostname

### Tailscale Checklist

- [ ] Tailscale installed on server
- [ ] Tailscale IP obtained
- [ ] Tailscale auth key in GitHub Secrets
- [ ] Workflow updated to install Tailscale
- [ ] GitHub Secrets updated with Tailscale IP

---

## Recommendation

**For Most Users:** Start with **Port Forwarding** (Option 1)
- Simplest setup
- Works immediately
- Good for testing

**For Production:** Use **Cloudflare Tunnel** (Option 2)
- More secure
- No router configuration
- Better for long-term

**For Maximum Security:** Use **Tailscale** (Option 3)
- Most secure
- Zero trust
- Best for sensitive deployments

---

**Next:** After setting up port forwarding, test with `./scripts/test-ssh-connection.sh`
