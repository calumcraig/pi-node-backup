# pi-node

Configuration and scripts for the Raspberry Pi backup node.

## Backup

`backup-optiplex.sh`:

- Pulls database dumps from Optiplex
- Pulls Docker configuration
- Pulls application data
- Pulls Immich library
- Creates Restic snapshots
- Applies retention policy
- Shuts down Pi after successful backup

## Restore

Restore process documented separately.

## SSH key setup

The backup node requires an SSH key to connect from the Pi to the Optiplex.

This key is intentionally not stored in Git.

After rebuilding the Pi, create the key:

ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_backup

Install it on the Optiplex:

ssh-copy-id -i ~/.ssh/id_ed25519_backup.pub calum@optiplex.local

Verify:

ssh -i ~/.ssh/id_ed25519_backup calum@optiplex.local
