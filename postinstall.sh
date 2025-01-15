#!/bin/sh

ETHCARD="$(ip addr | grep ^2: | awk '{print $2}' | cut -d : -f 1)"

echo "Add new user..."
read user
useradd -m -s /bin/zsh -U -G wheel,disk,lp,audio,video,optical,storage,scanner,network,plugdev,xbuilder $user

echo "Change user password..."
passwd $user


# Ethernet conection:
cp -R /etc/sv/dhcpcd-eth0 /etc/sv/dhcpcd-$ETHCARD
sed -i 's/eth0/$ETHCARD/' /etc/sv/dhcpcd-$ETHCARD/run
ln -s /etc/sv/dhcpcd-$ETHCARD /var/service/
