#!/bin/bash

sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove && sudo apt autoclean \
sudo systemctl daemon-reload \

sudo apt install -y \
nfs-kernel-server nfs-common \
gh tree ncdu ceph ceph-deploy btrfs-progs \
hub \
nmap \
htop iftop iotop nload glances\
prometheus \
zx \
git \
fzf \
python3-fabric python3-pip\
ansible \
nginx \
borgbackup \

npm && \

npm install -g zx && \

sudo snap install powershell  --classic && \

sudo snap refresh

sudo apt update && sudo systemctl daemon-reload
