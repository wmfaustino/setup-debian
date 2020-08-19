#!/usr/bin/env bash

declare -rg baseUrl='https://github.com/wmfaustino/setup-debian/raw/master/install'

declare -arg installScripts=(
  apt-pkgs.in.sh
 neovim.in.sh
 #scodium.in.sh
 brave-browser.in.sh
 virtualbox.in.sh
)

declare -rg tmpDir='/tmp/debian-setup'

main(){

  _getInstallScripts
  _makeExecutable
  _install
}

function _getInstallScripts(){

  for script in "${installScripts[@]}"; do
    curl -L "${baseUrl}/${script}" -o "${tmpDir}/${script}" --create-dirs
  done

}

function _makeExecutable()(

  for script in "${tmpDir}"/*; do
    chmod 500 $script
  done

)

function _install(){
  
  for i in "${tmpDir}"/*; do
    "${i}" -y
    #curl -L "${base}/${i}" | bash -s -- -y
  done
  
  exit 0
}

main
#curl -L https://github.com/wmfaustino/handy-icon-fonts/raw/master/install.sh | sh
