# pi-node

Ansible configuration and scripts for the Raspberry Pi backup node.

The Pi acts as a passive backup node for the home server. It connects to the Optiplex server, retrieves backup data, creates encrypted Restic snapshots, and powers down after successful completion.

## Architecture

The backup flow is:

```
Optiplex server
      |
      | rsync / SSH
      v
Raspberry Pi backup node
      |
      | Restic
      v
Encrypted backup repository
```

The Pi initiates the backup job. The Optiplex does not push data to the backup node.

## Ansible

The node is provisioned using Ansible.

The playbook configures:

* Required packages
* Backup SSD mount
* Backup directories
* Backup scripts
* Cron schedule
* SSH key validation
* Restic password validation

A rebuilt Pi can be brought back to the expected state by running the Ansible playbook.

## Backup

`backup-optiplex.sh`:

* Triggers database dumps on Optiplex
* Pulls database dumps from Optiplex
* Pulls Docker configuration
* Pulls application data
* Pulls Immich library
* Creates Restic snapshots
* Applies retention policy
* Runs periodic Restic pruning
* Shuts down Pi after successful completion

## Storage layout

The backup SSD is mounted at `/srv`.

```
/srv
├── incoming     # temporary staging area
└── restic       # Restic repository
```

## Restore

Restore process documented separately.

## SSH key setup

The backup node requires an SSH key to connect from the Pi to the Optiplex.

This key is intentionally not stored in Git.

After rebuilding the Pi, create the key:

```
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_backup
```

Install it on the Optiplex:

```
ssh-copy-id -i ~/.ssh/id_ed25519_backup.pub calum@optiplex.local
```

Verify:

```
ssh -i ~/.ssh/id_ed25519_backup calum@optiplex.local
```

## Secrets

The Restic repository password is not stored in Git.

After rebuilding the node, restore:

```
/home/calum/.restic-password
```

from external secret storage.

## Recovery

The node is designed to be rebuilt rather than manually repaired.

Recovery process:

1. Install Pi OS.
2. Configure SSH access.
3. Run the Ansible playbook.
4. Restore required secrets.
5. Verify backup operation.
