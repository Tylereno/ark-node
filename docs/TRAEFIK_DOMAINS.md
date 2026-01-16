# Traefik Domain Names Reference

All services are configured to be accessible via friendly domain names through Traefik reverse proxy.

## 🏠 Local Domain Names (ark.local)

Add these to your `/etc/hosts` file (or use Tailscale MagicDNS):

```
# ARK Node Services
192.168.26.8  hub.ark.local ark.local
192.168.26.8  traefik.ark.local
192.168.26.8  portainer.ark.local
192.168.26.8  homepage.ark.local
192.168.26.8  ollama.ark.local
192.168.26.8  openwebui.ark.local
192.168.26.8  jellyfin.ark.local
192.168.26.8  audiobookshelf.ark.local
192.168.26.8  filebrowser.ark.local
192.168.26.8  syncthing.ark.local
192.168.26.8  vaultwarden.ark.local
192.168.26.8  kiwix.ark.local
192.168.26.8  homeassistant.ark.local
192.168.26.8  gitea.ark.local
192.168.26.8  code.ark.local
```

## 🌐 Tailscale MagicDNS Domains

These work automatically if MagicDNS is enabled:

- `jellyfin.nomad-node.tail143b3f.ts.net`
- `home.nomad-node.tail143b3f.ts.net` (Home Assistant)

## 📋 Service Access URLs

| Service | Domain | Port (Direct) | Description |
|---------|--------|---------------|-------------|
| **Homepage** | `hub.ark.local` | 3000 | Main dashboard |
| **Traefik** | `traefik.ark.local` | 8080 | Reverse proxy dashboard |
| **Portainer** | `portainer.ark.local` | 9000 | Container management |
| **Ollama** | `ollama.ark.local` | 11434 | AI LLM API |
| **Open WebUI** | `openwebui.ark.local` | 3001 | AI chat interface |
| **Jellyfin** | `jellyfin.ark.local` | 8096 | Media server |
| **Audiobookshelf** | `audiobookshelf.ark.local` | 13378 | Audiobooks & podcasts |
| **FileBrowser** | `filebrowser.ark.local` | 8081 | Web file manager |
| **Syncthing** | `syncthing.ark.local` | 8384 | Device sync |
| **Vaultwarden** | `vaultwarden.ark.local` | 8082 | Password manager |
| **Kiwix** | `kiwix.ark.local` | 8083 | Offline Wikipedia |
| **Home Assistant** | `homeassistant.ark.local` | 8123 | IoT automation |
| **Gitea** | `gitea.ark.local` | 3002 | Git hosting |
| **Code-Server** | `code.ark.local` | 8443 | VS Code IDE |

## ⚠️ Current Status

**Traefik is configured but has Docker API version issues:**
- Traefik v3.0 requires Docker API 1.44+
- Current Docker socket reports API 1.24
- Services are still accessible via direct ports
- Domain routing will work once Docker API is updated

## 🔧 Quick Access

**Via Traefik (when working):**
- All services: `http://<domain-name>` (port 80)

**Direct Access (always works):**
- Each service: `http://<ip>:<port>`

## 🚀 Next Steps

1. **Enable Tailscale MagicDNS** - Automatic domain resolution
2. **Update Docker** - Fix Traefik service discovery
3. **Add SSL/TLS** - Secure connections with Let's Encrypt
