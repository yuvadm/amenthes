# Amenthes

Amenthes ~~is~~ will be a single purpose, live USB-based, Linux distribution which enables secure viewing of a batch of (leaked? :smirk:) files via a hardened desktop.

The project is based on the wonderful [archiso](https://wiki.archlinux.org/index.php/Archiso) scripts.

## Build

Naturally, requires Arch. First, make sure you have `archiso` or `archiso-git` installed.

```bash
$ cd liveusb
$ sudo su  # become root now, otherwise you get ugly permissions problems
$ cp -r /usr/share/archiso/configs/baseline/* .
$ ./build.sh -v
```

You should now see `out/archlinux-YYYY.MM.DD-x86_64.iso`.
