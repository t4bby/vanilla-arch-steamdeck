# Vanilla Arch Linux (KDE) on Steam Deck
Because I do not like immutable OS and outdated packages. SteamOS already provides `nix` and `distrobox` but that is not enough for me, and installing other gaming distro contains too much bloatware for me. This contains configurations from different distro and mostly from Valve SteamOS. This contains a script that installs SteamOS packages to make your vanilla Arch Linux on Steam Deck installation SteamOS-like but preserves the non-immutable installation and Arch Linux repository.

# Requirements
- Fresh (or not?) Arch Linux installation with KDE 
- Steam Deck LCD (sorry, no `galileo` patches)

# Installation
```
cd /tmp
git clone https://github.com/t4bby/vanilla-arch-steamdeck
cd vanilla-arch-steamdeck
chmod +x install.sh
./install.sh
```

# Post Installation
## 1. Add this arguments on to your bootloader:
```
amd_iommu=off amdgpu.gttsize=8128 spi_amd.speed_dev=1 audit=0 fbcon=vc:2-6
```

### systemd-boot example for `linux-zen`:
```
title   Arch Linux (linux-zen)
linux   /vmlinuz-linux-zen
initrd  /amd-ucode.img
initrd  /initramfs-linux-zen.img
options root=PARTUUID=db8f7583-f5dc-477d-ab50-33524b90c731 zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs quiet amd_iommu=off amdgpu.gttsize=8128 spi_amd.speed_dev=1 audit=0 fbcon=vc:2-6
```

## 2. Install `jupiter-dkms` using `yay` for fan control in your kernel:
```
sudo pacman -S dkms
yay -S jupiter-dkms
```

# References
- https://gitlab.com/evlaV/jupiter-PKGBUILD
- https://github.com/ublue-os/bazzite
- https://github.com/Nobara-Project/steamdeck-edition-packages
