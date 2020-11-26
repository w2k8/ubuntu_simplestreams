#!/bin/bash

KEYRING_FILE=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg
IMAGE_SRC=https://images.maas.io/ephemeral-v3/stable
IMAGE_DIR=/var/www/html/maas/images/ephemeral-v3/stable

sstream-mirror --keyring=$KEYRING_FILE $IMAGE_SRC $IMAGE_DIR 'arch=amd64' 'release~(bionic|focal)' --max=1 --progress
sstream-mirror --keyring=$KEYRING_FILE $IMAGE_SRC $IMAGE_DIR 'os~(grub*|pxelinux)' --max=1 --progress

