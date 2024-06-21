#!/bin/bash

echo "Vanilla Arch Linux Script for Steam Deck"

if [[ $EUID -ne 0 ]]; then
    echo "$0 is not running as root. Try using sudo."
    exit -1
fi

echo "[*] Installing SteamOS packages"

# But as much as posible, dont install generic packages from Steam Repository
echo "[!] Adding jupiter repository to pacman.conf"
if ! grep -q -F "[jupiter-main]" "/etc/pacman.conf"; then
    cat << EOF >> /etc/pacman.conf

# SteamOS Jupiter Repository
[jupiter-main]
Server = https://steamdeck-packages.steamos.cloud/archlinux-mirror/\$repo/os/\$arch
SigLevel = Never

EOF
fi

# Update all packages
pacman -Syu

echo "[-] Removing Dependecies Conflicts"

# If you have amd-ucode installed, SteamOS already included this on their linux-firmware package
pacman -Rcns amd-ucode linux-firmware

echo "[+] Installing SteamOS packages"

# Install base SteamOS packages, cherrypick only the nessesary packages
pacman -Sy adobe-source-code-pro-fonts jupiter-main/noto-fonts \
            jupiter-main/noto-fonts-cjk jupiter-main/steamdeck-dsp \
            gamemode jupiter-main/gamescope jupiter-hw-support \
            jupiter-legacy-support jupiter-main/powerbuttond \
            steam-jupiter-stable steam-im-modules jupiter-main/upower \
            jupiter-main/vpower jupiter-main/volume_key jupiter-hw-support \
            linux-firmware-neptune linux-firmware-neptune-whence \
            noise-suppression-for-voice

echo "[!] Done installing packages!"

echo "[+] Copying SteamOS rootfs"
echo "[*] Changing permissions"

# Make binary in rootfs executable
chmod +x ./rootfs/usr/bin/*

# Copy configurations
cp -R ./rootfs/* /

echo "[!] Done copying rootfs"
echo "[+] You can now reboot to see the changes"
