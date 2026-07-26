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
