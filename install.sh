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
echo "[+] Installing Font Requirements"
pacman -Sy adobe-source-code-pro-fonts noto-fonts noto-fonts-cjk

echo "[+] Installing Audio firmware"
pacman -Sy jupiter-main/steamdeck-dsp alsa-ucm-conf noise-suppression-for-voice

echo "[+] Installing Firmware"
pacman -Sy  jupiter-main/jupiter-hw-support \
            jupiter-main/upower jupiter-main/vpower \
            jupiter-main/jupiter-hw-support \
            jupiter-main/linux-firmware-neptune \
            jupiter-main/amd-ucode \
            jupiter-main/linux-firmware-neptune-whence

echo "[+] Installing UI dependencies"
pacman -Sy qt5-tools

echo "[+] Installing Game Utilities"
pacman -Sy jupiter-main/mangohud gamemode jupiter-main/gamescope jupiter-main/steam-im-modules jupiter-main/steam_notif_daemon jupiter-main/steam-jupiter-stable

echo "[+] Installing bluetooth" 
pacman -Sy bluez bluez-plugins bluez-utils 

echo "[!] Done installing packages!"

echo "[+] Copying SteamOS configuration"
echo "[*] Changing binary permissions"

# Make binary in rootfs executable
chmod +x ./rootfs/usr/bin/*

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
systemctl enable steamos-autologin
systemctl enable wireplumber-workaround
systemctl enable wireplumber-sysconf
systemctl enable pipewire-workaround
systemctl enable pipewire-sysconf
systemctl --global enable steam-web-debug-portforward.service

echo "[*] Disabling Conflict Services"
systemctl disable vpower
systemctl disable jupiter-biosupdate 
systemctl disable jupiter-controller-update
systemctl disable jupiter-fan-control

echo "[!] Installation Completed"
echo "[+] You can now reboot to see the changes"
