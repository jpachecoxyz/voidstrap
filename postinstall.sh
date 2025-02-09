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
ln -s /etc/sv/wpa_supplicant /var/service/

# Wifi
cp /etc/wpa_supplicant/ /etc/wpa_supplicant/wpa_supplicant-wifi.conf
echo "Name of device: "
read device
passphrase=$(/usr/bin/pinentry-curses --ttyname $(tty) --lc-ctype "$LANG" <<EOF | grep D | sed 's/^..//'
SETTIMEOUT 30
SETPROMPT Please enter your SSID passphrase:
SETOK Yes
SETCANCEL No
GETPIN
BYE
EOF
)

clear 

doas wpa_passphrase $device $passphrase  | doas tee -a /etc/wpa_supplicant/wpa_supplicant-wifi.conf > /dev/null 2>&1 && notify-send "Network log" "Network Added correctly"
doas sed -i '/#psk=/d' /etc/wpa_supplicant/wpa_supplicant-wifi.conf

# This must be in rc.local
INTERFACE="$(iwconfig  2>/dev/null | awk '/ESSID/ {print $1}')"
# sudo wpa_supplicant -B -i $INTERFACE -c /etc/wpa_supplicant/wpa_supplicant-wifi.conf  -D wext &

echo "message"
