# Amenthes

Amenthes is an environment for creating a live Linux system which allows secure EYES ONLY viewing of a batch of (leaked? :smirk:) files via a hardened desktop. See the [design](#design) section to understand exactly what the Amenthes live system provides.

The project is based on the wonderful [archiso](https://wiki.archlinux.org/index.php/Archiso) scripts.

## Prerequisites

### Development

An existing `x86_64` [Arch Linux](https://www.archlinux.org/) system with `archiso` or `archiso-git` installed. This is currently a hard requirement due to the nature of the `mkarchiso` script. Support for other Linuces and OSs is planned for future releases.

### Target

Generated ISO currently supports `x86_64` targets only, with `i686` (32-bit) support planned for future releases. The desktop environment will run on most Intel, AMD/ATI and Nvidia video adapters.

## Prepare

Collect all the payload files under the `liveusb/encrypt` directory:

```bash
$ cp /path/to/payload/files/* liveusb/encrypt/
```

If your payload requires any special packages, add them now:

```bash
$ echo 'additional-package' >> packages.x86_64
```

## Build

```bash
$ sudo su  # become root now, otherwise you get ugly permissions problems
$ chown -R root:root liveusb
$ cd liveusb
$ ./build.sh
```

You should now see `out/amenthes-x86_64.iso`, which can be directly copied to a USB drive:

```bash
$ dd bs=4M if=out/amenthes-x86_64.iso of=/dev/sdX && sync
```

### Testing

For test builds targeting a VirtualBox VM, use the `-t` flag to add some required packages:

```bash
$ ./build.sh -t
```

Never target a VM for the real-life scenario, a VM client cannot be secured against a malicious VM host. Using this flag lets the end-user run under a VM, so just don't.

## Design

First and foremost, Amenthes is a **proof of concept** project, and should never be used *as is*, assuming it will save your ass when shit hits the fan. Amenthes is a demonstration of technology which might be adopted to real-life use by experienced system administrators or developers. Having said that...

Consider the scenario in which a confidential source is interested in physically delivering (sneakernet, deaddrop, etc.) a batch of files to a friendly party - a journalist, for example. Furthermore, the source requests that files remain off the record, for the time being.

Amenthes enables a Linux user with basic command line knowledge to create a complete bootable ISO which contains an encrypted of set of documents and files, and can then be distributed to the target user.

The target user then receives a ready-to-boot live USB which contains all the dropped files. Knowing the encryption passphrase, which can be delivered via a separate secure channel, the user now has full access to the files. The Amenthes live desktop contains all the neccesary programs to view common files of all types: documents, spreadsheets, audio and video files, etc.

Most importantly, the live desktop is hardened to prevent extraction of the files from the system. The Amenthes environment blocks all network connections and does not recognize any hard disks or external storage devices. The only way to extract files from a running Amenthes system is via low-level hardware exploits, such as BIOS malware or proprietary chip firmware exploits. These attack vectors are a serious risk to any environment, and dealing with them is, naturally, out of the scope of this project.

### Threat Model

Amenthes assumes the target recipient is a friendly entity which obliges with the leaker's requests to keep all files EYES ONLY and off the record. If the target is not trustworthy, and has knowledge of the passphrase used to encrypt the content of the drive, **it is possible** for an experienced system administrator to extract the contents of the drive to a separate location.

If the physical device falls into the hands of an adversary, as long as the encryption passphrase is not revealed, the files can be considered as secure as the method used to encrypt them is against said adversary.

## Hack

 - **Code**: https://github.com/yuvadm/amenthes
 - **Bugs**: https://github.com/yuvadm/amenthes/issues
 - **IRC**: [#amenthes](https://webchat.freenode.net/?channels=amenthes) on freenode.net

## License

GPLv2
