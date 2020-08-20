#!/usr/bin/env bash
#
#----------[ Manage Dotfiles Script] ------------------+
#                                                      |
#  script : apt-pkgs.in.sh                             |
#  author : Wilson Faustino                            |
#  e-mail : <open source (a) wmfaustino dev>           |
#  site   : http://wmfaustino.dev                      |
#  version: 1.0.2 - removed apt install function       |
#  version: 1.0.1 - check for superuser privilleges    |
#  version: 1.0.0                                      |
#  date   : 16/08/2020                                 |
#  usage  : ./apt-pkgs.in.sh                           |
#                                                      |
#------------------------------------------------------+
#

# === GLOBAL VARIABLES

declare -Arg listOrigin=(
  [local]='./lib/apt-pkgs.list'
  [remote]='https://github.com/wmfaustino/setup-debian/raw/master/lib/apt-pkgs.list'
)

declare -g pkgsToInstall=''

# === ENTRY POINT

main(){

  _suCheck
  _getPkgsList

  apt install $pkgsToInstall -y
 
  exit 0
}

# === FUNCTIONS

function _suCheck(){
	
	local -r suErrMsg="\nYou need superpowers.\n\nTry it again as root user or use sudo.\n"

	(( "$EUID" !=0 )) && echo -e "$suErrMsg" && exit 1

	return 0
}

# ---

function _getPkgsList(){

  local listContent=''
  local -r errMsg='Unable to get package list'

  if [[ -f "${listOrigin[local]}" ]]; then
    listContent="$(< ${listOrigin[local]})"
  else
    listContent=$( curl -Lfs "${listOrigin[remote]}" 2> /dev/null ) || \
      { printf "\n%s\n\n" "${errMsg}" && exit 1; }
  fi
  
  pkgsToInstall=$(printf "%s" "${listContent}" | grep -vE '^#|^$' | sed 's/\s.*$//g')
  
  return 0
} 

# === BEGIN INSTALL
main
