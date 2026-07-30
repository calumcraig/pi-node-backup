# pi-node restore guide

## Purpose

This document describes how to restore the Pi backup node and recover backups created from the Optiplex server.

The backup design is:

- The Pi pulls backup data from the Optiplex.
- Database dumps are created on the Optiplex.
- The Pi stores the incoming backup data.
- Restic creates and maintains snapshots on the Pi.
- The Pi shuts down after a successful backup.

## Requirements

A replacement Pi requires:

- Rawspberry Pi OS Lite installed
- Network access
- A user account for the backup operations
- Git installed
- Restic installed
- rsync installed
- SSH installed
- SSH keys for:
  - Optiplex server access
  - Githib access

Clone this repository:

```bash
mkdir -p ~/git
cd ~/git
git clone <repository-url>
cd pi-node-backup
#Restore Restic repository
The Restic repository is stored at:



/srv/backup/restic
The Restic password file is stored at:



/home/calum/.restic-password
The password file is not stored in Git and must be restored separately.

Set the environment variable:



export RESTIC_PASSWORD_FILE=/home/calum/.restic-password
Verify the repository:



restic -r /srv/backup/restic snapshots
#Restore backup contents
The backup staging directory is:



/srv/backup/incoming
The backup contains:

 Database dumps: 

nextcloud.sql 

immich.sql 

 Docker configuration: 

/srv/docker 

 Application data: 

/srv/data 

 Immich library: 

/srv/storage/immich 

To restore files from Restic:



restic -r /srv/backup/restic restore latest --target /restore/location
Adjust the target location as required.

#SSH configuration
The Pi uses an SSH key to connect to the Optiplex:



/home/calum/.ssh/id_ed25519_backup
This key is not stored in Git and must be restored separately.

Verify SSH access:



ssh -i /home/calum/.ssh/id_ed25519_backup calum@optiplex.local
#Backup script
The backup script is:



backup-optiplex.sh
Install it:



cp backup-optiplex.sh ~/backup-optiplex.sh
chmod +x ~/backup-optiplex.sh
Test manually:



~/backup-optiplex.sh
#Scheduled backup
The backup runs from the Pi user crontab.

Current schedule:



0 3 * * * /home/calum/backup-optiplex.sh >> /home/calum/backup.log 2>&1
Check the cron configuration:



crontab -l
#Secrets not stored in Git
The following must be restored separately:

Restic password file:



~/.restic-password
SSH private key:



~/.ssh/id_ed25519_backup
 Any other credentials used by services or Docker environments. 

#Verification checklist
After restoring:

restic snapshots works

SSH connection to Optiplex works without a password

Backup script runs manually

Restic creates a new snapshot

Cron entry exists

Shutdown behaviour has been tested
