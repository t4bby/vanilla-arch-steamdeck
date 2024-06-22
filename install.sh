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
pacman -Syu --noconfirm

echo "[-] Removing Dependecies Conflicts"

# If you have amd-ucode installed, SteamOS already included this on their linux-firmware package
pacman -Rcns --noconfirm amd-ucode linux-firmware

echo "[+] Installing SteamOS packages"

# Install base SteamOS packages, cherrypick only the nessesary packages
echo "[+] Installing Font Requirements"
pacman -Sy --noconfirm adobe-source-code-pro-fonts noto-fonts noto-fonts-cjk

echo "[+] Installing Audio firmware"
pacman -Sy --noconfirm jupiter-main/steamdeck-dsp alsa-ucm-conf noise-suppression-for-voice caps

echo "[+] Installing Firmware"
pacman -Sy --noconfirm jupiter-main/jupiter-hw-support \
            jupiter-main/upower jupiter-main/vpower \
            jupiter-main/jupiter-hw-support \
            jupiter-main/linux-firmware-neptune \
            jupiter-main/amd-ucode \
            jupiter-main/linux-firmware-neptune-whence \
            jupiter-main/jupiter-fan-control

echo "[+] Installing UI dependencies"
pacman -Sy --noconfirm qt5-tools

echo "[+] Installing Game Utilities"
pacman -Sy --noconfirm jupiter-main/mangohud gamemode jupiter-main/gamescope jupiter-main/steam-im-modules jupiter-main/steam_notif_daemon jupiter-main/steam-jupiter-stable

echo "[+] Installing bluetooth" 
pacman -Sy --noconfirm bluez bluez-plugins bluez-utils 

echo "[!] Done installing packages!"

echo "[+] Copying SteamOS configuration"
echo "[*] Changing binary permissions"

# Make binary in rootfs executable
chmod +x ./rootfs/usr/bin/*
chmod +x ./rootfs/usr/libexec/*

# Copy configurations
cp -R ./rootfs/* /
cp ./rootfs/skel/Desktop/* $HOME/Desktop
echo "[!] Done copying configurations"

# Linking binaries
ln -s /usr/bin/steamos-logger /usr/bin/steamos-info
ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice
ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning

echo "[*] Adding audio workarounds"

# Audio Workaround
mkdir /usr/lib/firmware/cirrus/
cp /usr/lib/firmware/cs35l41-dsp1-spk-*.bin /usr/lib/firmware/cirrus/
rm /usr/share/alsa/ucm2/conf.d/acp5x/Valve-Jupiter-1.conf

echo "[*] Enabling Services"
# Enabling Services
systemctl enable bluetooth
systemctl enable steamos-autologin.service
systemctl enable wireplumber-workaround.service
systemctl enable wireplumber-sysconf.service
systemctl enable pipewire-workaround.service
systemctl enable pipewire-sysconf.service
systemctl --global enable steam-web-debug-portforward.service

echo "[*] Disabling Conflict Services"
systemctl disable vpower.service
systemctl disable jupiter-biosupdate.service
systemctl disable jupiter-controller-update.service
systemctl disable jupiter-fan-control.service

echo "[!] Installation Completed"
echo "[+] You can now reboot to see the changes"
