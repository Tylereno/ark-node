# Tailscale ACL Setup for GitHub Actions

**Fix: "SSH handshake failed: EOF"**

---

## The Problem

The GitHub Actions runner connects to Tailscale, but the ACL (Access Control List) doesn't allow it to SSH to your server.

---

## The Fix: Update Tailscale ACL

**Go to:** https://login.tailscale.com/admin/acls/file

**Add or update your ACL file:**

```json
{
  "tagOwners": {
    "tag:github-actions": ["autogroup:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["tag:github-actions"],
      "dst": ["nomad-node-1:22"]
    }
  ]
}
```

**Or, to allow SSH to all your devices:**

```json
{
  "tagOwners": {
    "tag:github-actions": ["autogroup:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["tag:github-actions"],
      "dst": ["autogroup:members:22"]
    }
  ]
}
```

**Save the ACL file** - changes apply immediately.

---

## Verify Your Server Name

Find your server's Tailscale name:

```bash
docker exec tailscale tailscale status | grep "100.98.86.81"
```

Use that name in the ACL `dst` field (e.g., `nomad-node-1:22`).

---

## Alternative: Use IP Address

If you prefer using the IP directly:

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["tag:github-actions"],
      "dst": ["100.98.86.81:22"]
    }
  ]
}
```

---

## Test After ACL Update

1. Save the ACL in Tailscale admin
2. Re-run the GitHub Actions workflow
3. The SSH connection should now work

---

## Troubleshooting

**Still failing?** Check:

1. **Device appears in Tailscale admin?**
   - Go to: https://login.tailscale.com/admin/machines
   - Look for a device with tag `tag:github-actions`
   - If missing, the OAuth client might be wrong

2. **ACL syntax correct?**
   - Use Tailscale's ACL validator: https://login.tailscale.com/admin/acls/file
   - Click "Validate" before saving

3. **Server name matches?**
   - Run: `docker exec tailscale tailscale status`
   - Use the exact name shown (case-sensitive)
