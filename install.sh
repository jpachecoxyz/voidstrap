#!/usr/bin/env bash

# Created By: Javier Pacheco - jpacheco@cock.li
# Created On: 28/01/25
# Project: Void linux bootstrap

mkfs.ext4 /dev/nvme0n1p4
mount /dev/nvme0n1p4 /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

export XBPS_ARCH=x86_64-musl && xbps-install -Suy -R https://repo-default.voidlinux.org/current/musl -r /mnt \
    xbps \
    base-minimal \
    NetworkManager \
    Waybar \
    bash \
    bat \
    bc \
    bgs \
    bluez \
    brightnessctl \
    curl \
    dejavu-fonts-ttf \
    dhcpcd \
    direnv \
    dracut \
    e2fsprogs \
    elogind \
    emacs-pgtk \
    enchant2-devel \
    ethtool \
    eudev \
    eza \
    fastfetch \
    ffmpeg \
    file \
    firefox \
    font-ibm-plex-otf \
    foot \
    fzf \
    gcc \
    git \
    grim \
    gvfs \
    htop \
    hugo \
    hunspell \
    hunspell-devel \
    iproute2 \
    iputils \
    jq \
    psmisc \
    kbd \
    kmod \
    lazygit \
    less \
    libnotify \
    libnotify-devel \
    linux-firmware \
    linux-firmware-network \
    linux5.10 \
    mako \
    man-pages \
    mesa-dri \
    mpv \
    ncurses \
    neovim \
    nodejs \
    noto-fonts-emoji \
    nsxiv \
    opendoas \
    openssh \
    os-prober \
    p7zip \
    pciutils \
    polkit \
    procps-ng \
    pulseaudio \
    python3-pipx \
    ripgrep \
    seatd \
    slurp \
    stow \
    swappy \
    swww \
    tectonic \
    telegram-desktop \
    tofi \
    tomb \
    traceroute \
    unzip \
    usbutils \
    util-linux \
    vim \
    wf-recorder \
    xfsprogs \
    xrdb \
    xz \
    yazi \
    yt-dlp \
    zathura-pdf-poppler \
    zsh

for dir in sys dev proc; do $(mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir); done
cp /etc/resolv.conf /mnt/etc
cp /etc/xbps.d/* /mnt/etc/xbps.d/ || echo "file missing, dont worry..."
cp postinstall.sh /mnt/root/

xchroot /mnt /bin/bash <<EOF
xbps-install -Sy grub-x86_64-efi
status=$?
if [ $status -eq 16 ]; then
    xbps-install -uy xbps && xbps-install -uy grub-x86_64-efi
fi

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="void"

echo void > /etc/hostname

printf "
# /etc/rc.conf - system configuration for void-linux

# Set the host name.
# HOSTNAME="void"

# Set RTC to UTC or localtime.
HARDWARECLOCK="UTC"
TIMEZONE=America/Matamoros

# Keymap to load, see loadkeys(8).
KEYMAP=us\n" > /etc/rc.conf

echo "generating fstab file..."
printf "
/dev/nvme0n1p1 /boot/efi   vfat    defaults,noatime,nodiratime        0   2
/dev/nvme0n1p4 /           ext4    defaults,noatime,nodiratime        0   1
tmpfs       /tmp        tmpfs   defaults,nosuid,nodev,nodiratime   0   0

echo "Fstab file generated..."

xbps-reconfigure -fa

chown root:root /
chmod 755 /	

echo "permit nopass root" > /etc/doas.conf
echo "permit nopass keepenv :wheel" >> /etc/doas.conf

rm /var/service && ln -sf /etc/runit/runsvdir/current /var/service
EOF
