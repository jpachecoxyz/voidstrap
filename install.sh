#!/bin/bash

mkfs.xfs /dev/nvme0n1p4

mount /dev/nvme0n1p4 /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

export XBPS_ARCH=x86_64-musl && xbps-install -Suy -R http://mirrors.servercentral.com/voidlinux/current -r /mnt \
     xbps \
     base-minimal \
     vim \
     bash \
     git \
     curl \
     ncurses \
     less \
     man-pages \
     e2fsprogs \
     procps-ng \
     pciutils \
     usbutils \
     iproute2 \
     util-linux \
     kbd \
     ethtool \
     kmod \
     traceroute \
     opendoas \
     os-prober \
     bc \
     bgs \
     dejavu-fonts-ttf \
     dhcpcd \
     eudev \
     ffmpeg \
     file \
     gcc \
     zsh \
     mpv \
     fzf \
     openssh \
     unzip \
     xfsprogs \
     xz \
     zathura-pdf-poppler \
     linux5.10 \
     dracut \
     linux-firmware \
     linux-firmware-network \
     iputils \
     dbus-elogind \
     polkit \
     elogind \
     mesa-dri \
     gvfs \
     waybar

     walyand \

for dir in sys dev proc; do $(mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir); done
cp /etc/resolv.conf /mnt/etc
cp /etc/xbps.d/* /mnt/etc/xbps.d/ || echo "file missing, dont worry..."
cp postinstall.sh /mnt/root/
cp custom.sh /mnt/root/

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
/dev/nvme0n1p1/boot/efi   vfat    defaults,noatime,nodiratime        0   2
/dev/nvme0n1p4/           ext4    defaults,noatime,nodiratime        0   1
tmpfs       /tmp        tmpfs   defaults,nosuid,nodev,nodiratime   0   0
#tmpfs       /home/javier/.local/src/void-packages/masterdir/builddir    tmpfs   defaults,noatime,nodiratime,size=2G    0   0" > /etc/fstab

echo "Fstab file generated..."

xbps-reconfigure -fa

chown root:root /
chmod 755 /	

echo "permit nopass root" > /etc/doas.conf
echo "permit nopass keepenv :wheel" >> /etc/doas.conf

rm /var/service && ln -sf /etc/runit/runsvdir/current /var/service
EOF
