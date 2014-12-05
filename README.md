# Amenthes

Amenthes is an environment for creating a live Linux system which allows secure EYES ONLY viewing of a batch of (leaked? :smirk:) files via a hardened desktop. See the [design](#design) section to understand exactly what the Amenthes live system provides.

The project is based on the wonderful [archiso](https://wiki.archlinux.org/index.php/Archiso) scripts.

## Build

Naturally, requires Arch. First, make sure you have `archiso` or `archiso-git` installed.

```bash
$ sudo su  # become root now, otherwise you get ugly permissions problems
$ chown -R root:root liveusb
$ cd liveusb
$ ./build.sh -v
```

You should now see `out/amenthes-YYYY.MM.DD-x86_64.iso`, which can be directly copied to a USB drive:

```bash
$ dd bs=4M if=out/amenthes-YYYY.MM.DD-x86_64.iso of=/dev/sdX && sync
```

## Design

First and foremost, Amenthes is a **proof of concept** project, and should never be used *as is*, assuming it will save your ass when shit hits the fan. Amenthes is a demonstration of technology which might be adopted to real-life use by experienced system administrators or developers. Having said that...

Consider the scenario in which a confidential source is interested in physically delivering (sneakernet, deaddrop, etc.) a batch of files to a friendly party - a journalist, for example. Furthermore, the source requests that files remain off the record, for the time being.

Amenthes enables a Linux user with basic command line knowledge to create a complete bootable ISO which contains an encrypted of set of documents and files, and can then be distributed to the target user.

The target user then receives a ready-to-boot live USB which contains all the dropped files. Knowing the encryption passphrase, which can be delivered via a separate secure channel, the user now has full access to the files. The Amenthes live desktop contains all the neccesary programs to view common files of all types: documents, spreadsheets, audio and video files, etc.

Additionally, the live desktop is hardened to prevent extraction of the files. The Amenthes environment blocks all network connections, does not recognize any hard disks or external storage devices.

### Threat Model

Amenthes assumes the target recipient is a friendly entity which obliges with the leaker's requests to keep all files EYES ONLY and off the record. If the target is not trustworthy, and has knowledge of the passphrase used to encrypt the content of the drive, **it is possible** for an experienced system administrator to extract the contents of the drive to a separate location.

If the physical device falls into the hands of an adversary, as long as the encryption passphrase is not revealed, the files can be considered as secure as the method used to encrypt them is against said adversary.
