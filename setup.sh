#!/usr/bin/env bash

declare -rg baseUrl='https://github.com/wmfaustino/setup-debian/raw/master/install'

declare -arg installScripts=(
  apt-pkgs.in.sh
  dropbox-cli.in.sh
 neovim.in.sh
 #scodium.in.sh
 brave-browser.in.sh
 virtualbox.in.sh
)

declare -rg tmpDir='/tmp/debian-setup'

main(){

  _getInstallScripts
  _setPermissions
  _install
}

function _getInstallScripts(){

  for script in "${installScripts[@]}"; do
    curl -L "${baseUrl}/${script}" -o "${tmpDir}/${script}" --create-dirs
  done

}

function _setPermissions()(

  local -r _USER="${SUDO_USER:-$USER}"
  chown -R "${_USER}":"${_USER}" "${tmpDir}"
  chmod -R 770 "${tmpDir}"

  exit 0
)

function _install(){
  
  for i in "${tmpDir}"/*; do
    ( "${i}" -y )
    #curl -L "${base}/${i}" | bash -s -- -y
  done
  
  exit 0
}

main
#curl -L https://github.com/wmfaustino/handy-icon-fonts/raw/master/install.sh | sh
