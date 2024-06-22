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

# References
- https://gitlab.com/evlaV/jupiter-PKGBUILD
- https://github.com/ublue-os/bazzite
- https://github.com/Nobara-Project/steamdeck-edition-packages
