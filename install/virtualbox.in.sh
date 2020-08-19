#!/usr/bin/env sh

echo deb '[arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib' | tee --append '/etc/apt/sources.list.d/virtualbox.list'

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -

apt-get update -y
apt-get install virtualbox-6.1 -y

apt-get install virtualbox-6.1 -y

