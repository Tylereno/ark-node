# ARK Quick Reference

## Check System Status

```bash
# View all services
docker ps

# Check download progress
/opt/ark/scripts/check-downloads.sh

# View Wikipedia download log
tail -f /tmp/wikipedia-download.log

# Check storage space
df -h /mnt/dock
```

## Download Scripts

```bash
# Wikipedia (90GB, run overnight)
/opt/ark/scripts/download-wikipedia.sh --unattended

# Survival guides
/opt/ark/scripts/download-survival.sh --all

# Maps (World + USA)
/opt/ark/scripts/download-maps.sh --starter

# Books (Project Gutenberg)
/opt/ark/scripts/download-books.sh --essential

# Monitor all downloads
/opt/ark/scripts/check-downloads.sh
```

## Service URLs

- Homepage Dashboard: http://nomad-node:3000
- Portainer: http://nomad-node:9000
- Jellyfin: http://nomad-node:8096
- FileBrowser: http://nomad-node:8084
- Open WebUI (Ollama): http://nomad-node:8080
- Kiwix (Wikipedia): http://nomad-node:8081
- Audiobookshelf: http://nomad-node:13378
- Home Assistant: http://nomad-node:8123
- Vaultwarden: http://nomad-node:8000

## Restart Services

```bash
# Restart single service
docker restart <service-name>

# Restart all services
cd /opt/ark
docker-compose restart

# View service logs
docker logs <service-name> -f
```

## Content Locations

- Wikipedia: `/mnt/dock/data/media/kiwix/`
- Books: `/mnt/dock/data/resources/books/`
- Survival Guides: `/mnt/dock/data/resources/survival/`
- Maps: `/mnt/dock/data/media/maps/`
- Media: `/mnt/dock/data/media/`

## Troubleshooting

```bash
# Check if mount is active
mountpoint /mnt/dock

# View system resources
htop

# Check disk usage by directory
du -sh /mnt/dock/data/*

# Kill stuck download
pkill -f download-wikipedia
```

## Backup

```bash
# Backup ARK configuration
sudo tar -czf ark-backup-$(date +%Y%m%d).tar.gz /opt/ark

# List docker volumes
docker volume ls
```
