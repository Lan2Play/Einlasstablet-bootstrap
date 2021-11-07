#!/bin/bash

# BOOTSTRAP
# Upgrade packages
echo "update apt repos"
sudo apt-get update -y
sudo apt-get --assume-yes upgrade

if [ ! -d "/root/.ssh" ]; then
   sudo mkdir /root/.ssh
fi

if [[ "$(sudo stat -L -c '%a' /root/.ssh)" != "700" ]]; then
   sudo chmod 700 /root/.ssh
fi

if [ ! -f "/root/.ssh/id_rsa" ]; then
   sudo ssh-keygen -t ed25519 -f /root/.ssh/id_rsa -N ''
   sudo cat /root/.ssh/id_rsa.pub
    while read -r -p "please add the key to github and confirm (y/n)? " response && ([ "$response" != "y" ] && [ "$response" != "Y" ])
    do
        echo "you need to confirm!"
    done
fi

if [[ "$(sudo stat -L -c '%a' /root/.ssh/id_rsa)" != "600" ]]; then
   sudo chmod 600 /root/.ssh/id_rsa
fi

if [[ "$(sudo stat -L -c '%a' /root/.ssh/id_rsa.pub)" != "644" ]]; then
   sudo chmod 644 /root/.ssh/id_rsa.pub
fi


if ! grep github.com /root/.ssh/known_hosts > /dev/null
then
   sudo ssh-keyscan github.com >> /root/.ssh/known_hosts
fi


if [ ! -d "/home/lan2play/.ssh" ]; then
    mkdir /home/lan2play/.ssh
fi

if [[ "$(stat -L -c '%a' /home/lan2play/.ssh)" != "700" ]]; then
    chmod 700 /home/lan2play/.ssh
fi

if [ ! -f "/home/lan2play/.ssh/id_rsa" ]; then
    sudo cp /root/.ssh/id_rsa /home/lan2play/.ssh/id_rsa
    sudo cp /root/.ssh/id_rsa.pub /home/lan2play/.ssh/id_rsa.pub
    sudo chown lan2play:lan2play /home/lan2play/.ssh/id_rsa
    sudo chown lan2play:lan2play /home/lan2play/.ssh/id_rsa.pub
fi

if [[ "$(stat -L -c '%a' /home/lan2play/.ssh/id_rsa)" != "600" ]]; then
    chmod 600 /home/lan2play/.ssh/id_rsa
fi

if [[ "$(stat -L -c '%a' /home/lan2play/.ssh/id_rsa.pub)" != "644" ]]; then
    chmod 644 /home/lan2play/.ssh/id_rsa.pub
fi


if ! grep github.com /home/lan2play/.ssh/known_hosts > /dev/null
then
    ssh-keyscan github.com >> /home/lan2play/.ssh/known_hosts
fi

if [ $(dpkg -l git| grep "ii.*git" | wc | awk '{print $1}') == 0 ]; then
  echo "git not found, installung"
  sudo apt-get --assume-yes install git
fi


echo "check repo available"
# Clone dev-env repo if not already present
if [ ! -d "/home/lan2play/.ansibledeploy" ]; then
  echo "ansibledeploy repo not available, clone"
  git clone git@github.com:Lan2Play/Einlasstablet.git /home/lan2play/.ansibledeploy && cd /home/lan2play/.ansibledeploy
else
  echo "ansibledeploy available, pull"
  cd /home/lan2play/.ansibledeploy && git pull
fi

/home/lan2play/.ansibledeploy/run.sh