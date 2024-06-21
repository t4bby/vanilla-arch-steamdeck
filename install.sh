#!/bin/bash

echo "[*] Installing Dependencies"
cd /tmp
sudo pacman -Sy git base-devel dkms

# Some patches are in AUR
echo "[*] Installing yay"
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
echo y | LANG=C makepkg -si

echo "[*] Installing Jupiter Kernel Patches and Fan Control"
echo y | LANG=C yay --noprovides --answerdiff None --answerclean None --mflags "--noconfirm" jupiter-dkms jupiter-fan-control

echo "[*] Installing SteamOS packages"

# As much as posible, dont install generic packages from Steam Repository
echo "[!] Adding jupiter repository to pacman.conf"
if ! grep -q -F "[jupiter-main]" "/etc/pacman.conf"; then
    sudo cat << EOF >> /etc/pacman.conf

# SteamOS Jupiter Repository
[jupiter-main]
Server = https://steamdeck-packages.steamos.cloud/archlinux-mirror/$repo/os/$arch
SigLevel = Never

EOF
fi

# Update all packages
sudo pacman -Syu

echo "[-] Removing Dependecies Conflicts"
# If you have amd-ucode installed, SteamOS already included this on their linux-firmware package
sudo pacman -Rcns amd-ucode

echo "[+] Installing SteamOS packages"

# Install base SteamOS packages, cherrypick only the nessesary packages
sudo pacman -Sy adobe-source-code-pro-fonts noto-fonts noto-fonts-cjk steamdeck-dsp gamemode gamescope jupiter-hw-support jupiter-legacy-support powerbuttond steam-jupiter-stable steam-im-modules upower vpower volume_key jupiter-hw-support linux-firmware-neptune linux-firmware-neptune-whence noise-suppression-for-voice

echo "[!] Done installing packages!"

echo "[+] Copying SteamOS rootfs"
echo "[*] Changing permissions"
chmod +x ./rootfs/usr/bin/*

sudo cp ./rootfs/* /

echo "[!] Done copying rootfs"
echo "[+] You can now reboot to see the changes"
