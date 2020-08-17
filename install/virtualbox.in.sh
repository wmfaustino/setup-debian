#!/usr/bin/env sh

echo deb '[arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib' | sudo tee --append '/etc/apt/sources.list.d/virtualbox.list'

sudo wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
sudo wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

sudo apt-get update
sudo apt-get install virtualbox-6.1

sudo apt-get install virtualbox-6.1

