# Raspberry PI Backup Vault, installed with cloud-init

Cloud-init-powered unattended install for my "backup vault" on a Raspberry Pi.

This is not directly intendended for reuse, but more as an example on how to provision Raspberry Pi SD cards for unattended installs using [cloud-init](https://cloudinit.readthedocs.io/) -- which is a powerful yet underdocumented way of automating/customizing a Raspberry Pi installation on distributions supporting it (Ubuntu and Hypriot OS).

Btw: Raspbian, unfortunately, does not have any easy way to do general first-boot automation (only for very specific items like SSH activation or Wifi config).

This repo uses Ubuntu 20.04.1 as a base image, and a [forked version](https://github.com/easimon/flash) of [Hypriot's flash](https://github.com/hypriot/flash) to automate SD card creation.

## Use-case

I have an off-site backup of my data, backed up daily via rsync. For security reasons I want the data to be encrypted. I don't care about the OS disk being unencrypted, since it does not contain anything confidential, and encrypting it would require physical access to the vault to reboot.

For repeatable creation of the SD card, the setup process is automated using [cloud-init](https://cloudinit.readthedocs.io/). With this in place, preparing a replacement/upgrade SD card is easy.

## Requirements

- Raspberry Pi (2/3/4)
- An SD Card with 4 GB or more
- One or more USB disks/sticks attached for holding the backup data
- Some (preferably remote) location with Internet access to host the Pi
- Patience when transferring large amounts of data -- it's only a Pi in the end, Raspberry Pi 4 being much better than the preddecessors due to USB 3 and GBit Ethernet

## Features

- Configuration via cloud-init meta-data
- DynDNS client to make the remote Pi discoverable via DNS (mis-feature: configurable, but not un-configurable)
- Automated SSH key import from Launchpad or Github (using ssh_import_id)
- Data and swap on a encrypted LVM volume group (on the attached USB disk(s))
- Smartmontools to watch the disk health and some other performance related tools preinstalled

## USB disk preparation

The LVM volume group and logical volume group creation is not automated, since I had the disk with data on it before creating this. Instead, it needs to be manually created it using something like:

```bash
$ export LVMDISKS=/dev/sda /dev/sdb               # or whatever disks you want to use for LVM
$ pvcreate $LVMDISKS
$ vgcreate -n backup $LVMDISKS
$ lvcreate -L4G -n swap backup                    # creates 4GB swap logical volume
$ lvcreate -l100%FREE -n backup backup            # and the rest for data
$ cryptsetup luksFormat /dev/mapper/backup-backup # create a luks partition on the data LV. be sure to remember the password
$ cryptsetup open /dev/mapper/backup-backup backup-crypt
$ mkfs.ext4 /dev/mapper/backup-crypt
$ mount /dev/mapper/backup-crypt /mnt
$ mkdir -p /mnt/home
$ umount /mnt
```

You could as well use RAID instead/on top of LVM, just customize the crypttab and fstab in user-data.

## Installation

- [Download Ubuntu](https://ubuntu.com/download/raspberry-pi) image for your Raspberry PI. Both 32 and 64 bit should work. Uncompressing it beforehand is not necessary, but speeds up flashing considerably (especially when repeating the process multiple times).
- [Download the flash utility script](https://github.com/easimon/flash). The forked version adds support to modify more boot files, and removes the YAML verification, since the latter broke jinja templating in cloud-init user-data.
- Configure the paths to the ubuntu image and flash in [scripts/config.sh](scripts/config.sh).
- Copy [cloud-init/meta-data.yaml.template](cloud-init/meta-data.yaml.template) to `metadata.yaml` and configure according to your needs.
- Execute [scripts/flash-backup.sh](scripts/flash-backup.sh) to flash the image.

## Usage

The data disk is not automatically mounted on boot, since mounting it requires a password and I want the Pi come up unattended/headless, but not expose the password (otherwise I could run the disk unencrypted in the first place). Instead there's a script to mount it, which also asks for the password. This needs to be used once after each reboot, afterwards the disk stays mounted.

So, boot, log in via SSH, call `mount-backup` and enter the password.

Then take a look at [scripts/backup.sh](scripts/backup.sh) on how to push data to the vault. This is to be used at the *source computer* that wants to backup its data to the vault.

Notice, that it expects to have a single folder `home` on the backup disk, and the Raspberry has a symlink in `/mnt` pointing to that folder. The backup script is using the symlink as a sync target. The reason for this is to make the `rsync` fail fast when the disk is not mounted -- instead of quickly filling the SD card.
