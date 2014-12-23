#!/bin/bash

set -e -u

# global settings
iso_name=amenthes
iso_label="AMENTHES"
install_dir=arch
arch=$(uname -m)
work_dir=work
encrypt_dir=encrypt
out_dir=out

# args
testing=false

# other paths
pacman_conf=${work_dir}/pacman.conf
script_path=$(readlink -f ${0%/*})

_usage() {
    echo "usage ${0} [options]"
    echo
    echo " General options:"
    echo " -t Enable testing packages (use for development ONLY)"
    echo " -h This help message"
    exit ${1}
}

# Helper function to run make_*() only one time per architecture.
run_once() {
    if [[ ! -e ${work_dir}/build.${1}_${arch} ]]; then
        $1
        touch ${work_dir}/build.${1}_${arch}
    fi
}

# Setup custom pacman.conf with current cache directories.
make_pacman_conf() {
    local _cache_dirs
    _cache_dirs=($(pacman -v 2>&1 | grep '^Cache Dirs:' | sed 's/Cache Dirs:\s*//g'))
    sed -r "s|^#?\\s*CacheDir.+|CacheDir = $(echo -n ${_cache_dirs[@]})|g" ${script_path}/pacman.conf > ${pacman_conf}
}

# Base installation (airootfs)
make_basefs() {
    mkarchiso -v -w "${work_dir}" -C "${pacman_conf}" -D "${install_dir}" init
}

# Additional packages (airootfs)
make_packages() {
    local _packages
    if [ "$testing" = true ]; then
        _packages=$(grep -h -v ^# ${script_path}/packages{,-test}.x86_64)
    else
        _packages=$(grep -h -v ^# ${script_path}/packages.x86_64)
    fi
    mkarchiso -v -w "${work_dir}" -C "${pacman_conf}" -D "${install_dir}" -p "${_packages}" install
}

# Copy mkinitcpio archiso hooks and build initramfs (airootfs)
make_setup_mkinitcpio() {
    mkdir -p ${work_dir}/airootfs/etc/initcpio/hooks
    mkdir -p ${work_dir}/airootfs/etc/initcpio/install
    cp /usr/lib/initcpio/hooks/archiso ${work_dir}/airootfs/etc/initcpio/hooks
    cp /usr/lib/initcpio/install/archiso ${work_dir}/airootfs/etc/initcpio/install
    cp ${script_path}/mkinitcpio.conf ${work_dir}/airootfs/etc/mkinitcpio-archiso.conf
    mkarchiso -v -w "${work_dir}" -D "${install_dir}" -r 'mkinitcpio -c /etc/mkinitcpio-archiso.conf -k /boot/vmlinuz-linux -g /boot/archiso.img' run
}

# Prepare encrypted loop device
make_encrypted_device() {
    # Variables
    local _cryptsize=$(expr $(du -d0 ${encrypt_dir} | grep -oe "[0-9]*") + 10000)  # add 10MB for crypt metadata
    local _loopdev=$(losetup -f)

    # Setup
    dd if=/dev/zero of=${work_dir}/airootfs/encrypted bs=1K count=${_cryptsize}
    losetup ${_loopdev} ${work_dir}/airootfs/encrypted
    echo -n "passphrase" | cryptsetup luksFormat ${_loopdev} -
    echo -n "passphrase" | cryptsetup open ${_loopdev} cryptloop --key-file -
    mkfs.ext4 /dev/mapper/cryptloop

    # Mount and copy
    mkdir -p ${work_dir}/airootfs/mnt/decrypted
    mount /dev/mapper/cryptloop ${work_dir}/airootfs/mnt/decrypted
    rmdir ${work_dir}/airootfs/mnt/decrypted/lost+found
    cp -a ${work_dir}/${encrypt_dir}/* ${work_dir}/airootfs/mnt/decrypted

    # Cleanup
    umount ${work_dir}/airootfs/mnt/decrypted
    cryptsetup close cryptloop
    losetup -d ${_loopdev}
}

# Customize installation (airootfs)
make_customize_airootfs() {
    cp -af ${script_path}/airootfs ${work_dir}
    mkarchiso -v -w "${work_dir}" -C "${pacman_conf}" -D "${install_dir}" -r '/root/customize_airootfs.sh' run
    rm ${work_dir}/airootfs/root/customize_airootfs.sh
}

# Prepare ${install_dir}/boot/
make_boot() {
    mkdir -p ${work_dir}/iso/${install_dir}/boot/${arch}
    cp ${work_dir}/airootfs/boot/archiso.img ${work_dir}/iso/${install_dir}/boot/${arch}/archiso.img
    cp ${work_dir}/airootfs/boot/vmlinuz-linux ${work_dir}/iso/${install_dir}/boot/${arch}/vmlinuz
}

# Prepare /${install_dir}/boot/syslinux
make_syslinux() {
    mkdir -p ${work_dir}/iso/${install_dir}/boot/syslinux
    sed "s|%ARCHISO_LABEL%|${iso_label}|g;
         s|%INSTALL_DIR%|${install_dir}|g;
         s|%ARCH%|${arch}|g" ${script_path}/syslinux/syslinux.cfg > ${work_dir}/iso/${install_dir}/boot/syslinux/syslinux.cfg
    cp ${work_dir}/airootfs/usr/lib/syslinux/bios/ldlinux.c32 ${work_dir}/iso/${install_dir}/boot/syslinux/
    cp ${work_dir}/airootfs/usr/lib/syslinux/bios/menu.c32 ${work_dir}/iso/${install_dir}/boot/syslinux/
    cp ${work_dir}/airootfs/usr/lib/syslinux/bios/libutil.c32 ${work_dir}/iso/${install_dir}/boot/syslinux/
}

# Prepare /isolinux
make_isolinux() {
    mkdir -p ${work_dir}/iso/isolinux
    sed "s|%INSTALL_DIR%|${install_dir}|g" ${script_path}/isolinux/isolinux.cfg > ${work_dir}/iso/isolinux/isolinux.cfg
    cp ${work_dir}/airootfs/usr/lib/syslinux/bios/isolinux.bin ${work_dir}/iso/isolinux/
    cp ${work_dir}/airootfs/usr/lib/syslinux/bios/isohdpfx.bin ${work_dir}/iso/isolinux/
    cp ${work_dir}/airootfs/usr/lib/syslinux/bios/ldlinux.c32 ${work_dir}/iso/isolinux/
}

# Build airootfs filesystem image
make_prepare() {
    mkarchiso -v -w "${work_dir}" -D "${install_dir}" prepare
}

# Build ISO
make_iso() {
    mkarchiso -v -w "${work_dir}" -D "${install_dir}" -L "${iso_label}" -o "${out_dir}" iso "${iso_name}-${arch}.iso"
}

(pacman -Qq archiso > /dev/null) || (echo "This script requires archiso(-git) to be installed"; _usage 1)
if [[ ${EUID} -ne 0 ]]; then
    echo "This script must be run as root."
    _usage 1
fi
if [[ ${arch} != x86_64 ]]; then
    echo "This script needs to be run on x86_64"
    _usage 1
fi

while getopts 'th' arg; do
    case "${arg}" in
        t) testing=true ;;
        h) _usage 0 ;;
        *)
            echo "Invalid argument '${arg}'"
            _usage 1
            ;;
    esac
done

mkdir -p ${work_dir}

run_once make_pacman_conf
run_once make_basefs
run_once make_packages
run_once make_setup_mkinitcpio
run_once make_encrypted_device
run_once make_customize_airootfs
run_once make_boot
run_once make_syslinux
run_once make_isolinux
run_once make_prepare
run_once make_iso
