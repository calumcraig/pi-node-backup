# Pi Node Restore Guide

## Purpose

This document describes how to restore the Pi backup node and recover the backup system after a failure of the Pi operating system or boot media.

The backup design is:

* The Pi pulls backup data from the OptiPlex server.
* Database dumps are created on the OptiPlex server.
* The Pi stores incoming backup data.
* Restic creates and maintains encrypted snapshots on the Pi.
* The Pi shuts down after a successful backup.

The Pi operating system is considered disposable. The source of truth is:

* This Git repository containing the backup scripts and documentation.
* The Restic repository stored on the backup SSD.
* Separately stored secrets and SSH keys.

---

# Requirements

A replacement Pi requires:

* Raspberry Pi OS Lite (64-bit) installed
* Network access
* A user account for backup operations
* Git installed
* Restic installed
* rsync installed
* SSH installed

The Pi should be configured with:

* Hostname: `pi-node`
* SSH enabled
* SSH key authentication configured

Install required packages:

```bash
sudo apt update
sudo apt install git restic rsync
```

---

# Restore repository files

Clone this repository:

```bash
mkdir -p ~/git
cd ~/git

git clone <repository-url>

cd pi-node-backup
```

The repository contains:

* `backup-optiplex.sh` - backup script
* `restore.md` - this restore documentation

The repository does not contain secrets.

---

# Restore backup SSD mount

The Restic repository is stored on the backup SSD:

```
/srv/backup/restic
```

Before accessing Restic, ensure the SSD is mounted correctly.

Identify the disk:

```bash
lsblk -f
```

Create the mount point:

```bash
sudo mkdir -p /srv/backup
```

Restore or recreate `/etc/fstab` so the SSD mounts automatically.

Test mounts:

```bash
sudo mount -a
```

Verify:

```bash
ls /srv/backup
```

You should see:

```
incoming
restic
```

Do not initialise a new Restic repository. The existing repository contains the backup history.

---

# Restore Restic access

The Restic password file is stored separately:

```
/home/calum/.restic-password
```

The password file is not stored in Git and must be restored manually.

Set permissions:

```bash
chmod 600 ~/.restic-password
```

Set the environment variable:

```bash
export RESTIC_PASSWORD_FILE=/home/calum/.restic-password
```

Verify the repository:

```bash
restic -r /srv/backup/restic snapshots
```

This should display existing snapshots.

---

# Restore backup contents

The backup staging directory is:

```
/srv/backup/incoming
```

The Restic backups contain:

## Database dumps

```
nextcloud.sql
immich.sql
```

## Docker configuration

```
/srv/docker
```

## Application data

```
/srv/data
```

## Immich library

```
/srv/storage/immich
```

Restore files from Restic:

```bash
restic -r /srv/backup/restic restore latest --target /restore/location
```

Adjust the target location as required.

---

# Restore SSH configuration

The Pi uses an SSH key to connect to the OptiPlex:

```
/home/calum/.ssh/id_ed25519_backup
```

This key is not stored in Git and must be restored separately.

Set permissions:

```bash
chmod 600 ~/.ssh/id_ed25519_backup
```

Test access:

```bash
ssh -i ~/.ssh/id_ed25519_backup calum@optiplex.local
```

The connection should work without requesting a password.

---

# Restore backup script

Copy the backup script from the repository:

```bash
cd ~/git/pi-node-backup

cp backup-optiplex.sh ~/backup-optiplex.sh

chmod +x ~/backup-optiplex.sh
```

Test manually:

```bash
~/backup-optiplex.sh
```

Verify that:

* rsync completes successfully
* Restic creates a new snapshot
* the backup log is updated

---

# Scheduled backup

The backup runs from the Pi user's crontab.

Current schedule:

```
0 3 * * * /home/calum/backup-optiplex.sh >> /home/calum/backup.log 2>&1
```

Restore the cron entry:

```bash
crontab -e
```

Verify:

```bash
crontab -l
```

---

# Secrets not stored in Git

The following must be restored separately:

## Restic password

```
~/.restic-password
```

## SSH private key

```
~/.ssh/id_ed25519_backup
```

## Other credentials

Any additional credentials used by services or Docker environments must also be restored separately.

---

# Verification checklist

After restoring:

* [ ] Pi hostname is `pi-node`
* [ ] SSH access works
* [ ] Backup SSD mounts correctly
* [ ] `restic snapshots` shows existing backups
* [ ] SSH connection to OptiPlex works without a password
* [ ] Backup script runs manually
* [ ] Restic creates a new snapshot
* [ ] Cron entry exists
* [ ] Shutdown behaviour has been tested
* [ ] A complete backup cycle has been observed successfully

---

# Future rebuilds

The Pi operating system should be treated as replaceable.

A complete rebuild should only require:

1. Installing Raspberry Pi OS Lite.
2. Installing required packages.
3. Cloning this repository.
4. Restoring secrets and SSH keys.
5. Mounting the backup SSD.
6. Running the backup script.

The Restic repository contains the backup history and should not need to be recreated.
