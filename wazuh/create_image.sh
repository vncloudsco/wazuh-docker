#!/bin/bash
# Wazuh App Copyright (C) 2018 Wazuh Inc. (License GPLv2)

apt-get install debootstrap git -y

# Create base image
debootstrap xenial wazuh > /dev/null

# Copy config files
cp wazuh-docker/wazuh/config/* wazuh/tmp/
chmod +x wazuh/tmp/configure_image.sh

# Mount necessary folders to perform actions
mount --bind /dev     wazuh/dev
mount --bind /dev/pts wazuh/dev/pts
mount --bind /proc    wazuh/proc
mount --bind /sys     wazuh/sys

# chroot into base image
chroot wazuh

# import base image as docker image
#tar -C wazuh -c . | docker import - wazuh

#docker run wazuh cat /etc/lsb-release
