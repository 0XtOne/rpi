#!/bin/bash

USERS=(
"pimaster:pimaster"
)

PACKAGES=(
"git"
"aptitude"
"build-essential"
"automake"
"libtool"
"bison"
"flex"
"nano"
"python-pygments"
"htop"
"zip"
"mc"
"gpm"
"p7zip"
"elinks"
"keyboard-configuration"
"raspi-copies-and-fills"
"pi-bluetooth"
"raspi-config"
"rng-tools"
"usbutils"
"firmware-brcm80211"
"firmware-realtek"
"wpasupplicant"
"iw"
"crda"
"wireless-regdb"
"wireless-tools"
)

# Check if running as root
if [ "$EUID" -ne 0 ]
  then printf "Please run as root\n"
  exit
fi

# Update & upgrade
apt-get update
apt-get -y upgrade

# Install packages & clean
for PACKAGE in ${PACKAGES[@]}; do
   apt-get -y install "$PACKAGE"
done
apt-get clean

# System configurations
printf "Set root password:\n"
passwd
raspi-config
echo "bcm2708-rng" >> /etc/modules
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

# Add users
printf "Creating user accounts\n"
for USER in ${USERS[@]}; do
   USER_NAME="$( cut -d ':' -f 1 <<< "$USER" )"
   USER_PASSWORD="$( cut -d ':' -f 2- <<< "$USER" )"
   printf "User name: "$USER_NAME"\n"
   printf "User password: "$USER_PASSWORD"\n"
   useradd -m -d /home/"$USER_NAME" -p `openssl passwd -crypt "$USER_PASSWORD"` "$USER_NAME" -s /bin/bash
done

# User configurations
for USER in ${USERS[@]}; do
   USER_NAME="$( cut -d ':' -f 1 <<< "$USER" )"
   mkdir -p /home/"$USER_NAME"/.config
   cp -r ./settings/user/dot_config_htop /home/"$USER_NAME"/.config/htop
   cp -r ./settings/user/dot_config_mc /home/"$USER_NAME"/.config/mc
   cp -r ./settings/user/dot_config_nano /home/"$USER_NAME"/.config/nano
   cp ./settings/user/dot_bashrc /home/"$USER_NAME"/.bashrc
   cp ./settings/user/dot_nanorc /home/"$USER_NAME"/.nanorc
   chown -R "$USER_NAME" /home/"$USER_NAME"/
done
