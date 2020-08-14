#!/usr/bin/env bash
# ------------------------------------------------------------
# bash_version: GNU bash, version 5.0.3(1)-release (x86_64-pc-linux-gnu)
# ------------------------------------------------------------

#TITLE          : inst_vscodium
#DESCRIPTION    : Set up VSCodium repository at apt source list; Install VSCodium
#SOURCE         : 
#AUTHOR         : Wilson Faustino <sh (a) wfaustino dev>
#DATE           :
#VERSION        : 1.0.0    
#USAGE		      : ./inst_vscodium

#NOTES          : It was tested on Debian Buster

#DISCLAIMER     : This script only helps to install VSCodium.
#                 It is not responsable to VSCodium itself, nor to a it's repository
#                 Use it VSCodium or this script at your own risk

# ------------------------------------------------------------
# Released under MIT License
# ------------------------------------------------------------
 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ------------------------------------------------------------

# ==========================================================
# === ABOUT VARIABLES
# ==========================================================

declare -Arg itSelf=(
  [name]="${0##*/}"
  [version]="1.0.0"
  [date]='2020-jul-16'
)

declare -Arg author=(
  [name]='Wilson Faustino'
  [website]='wmfaustino.dev'
  [email]='sh@wmfaustino.dev'
)

# ==========================================================
# === GLOBAL VARIABLES
# ==========================================================

declare -Arg vscodium=(
  [key]='https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg'
  [src]='deb https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/debs/ vscodium main'
  [sourceList]='/etc/apt/sources.list.d/vscodium.list'
)

declare -rg _os=$(grep '^NAME' /etc/os-release | cut -d '"' -f2 | cut -d ' ' -f1)

# ==========================================================
# === INITIAL SETUP
# ==========================================================

shopt -s extglob

confirmInstall=1 # ask for confirmation is the default

_printMsg() { printf "\n%s\n\n" "$1" ; }

# ==========================================================
# === ENTRY POINT
# ==========================================================

main(){
  
  # === verifications
  _suCheck
  #_osCheck # TODO
  (( "$confirmInstall" == 1 )) && _confirmInstallation
  
  # === Repository setup
  _getKey "${vscodium[key]}"
  _setSourceList "${vscodium[src]}" "${vscodium[sourceList]}"

  # === VSCodium install
  _aptInstall
  
  exit 0
}

# ==========================================================
# === FUNCTIONS
# ==========================================================

# TODO -----------------------------------------------------
_osCheck(){
  :
}

# Checks if user has super user powers ---------------------
_suCheck(){

  [[ "$EUID" -ne 0 ]] && \
    { printf "%s\n%s\n" "Not a superuser, no cookies for you!!!" \
      "Get your superuser's power and try it again"; exit 1; } 
    
  return 0
}

# Asks user if he agrees with the instalation --------------
_confirmInstallation(){

  local -Ar msgs=(
    [initial]='This program will install VSCodium.'
    [answerOptions]='Type [yes | no] to confirm instalation or [help] for more information: '
    [no]='Ok... Maybe another time...'  
  )
  
  _printMsg "${msgs[initial]}"

  local count=0
  while :; do
    
    read -p "${msgs[answerOptions]}" confirmation
    
    case "$confirmation" in
      @(y|Y)@(es)  ) return 0                             ;;
      @(n|N)?(o)   ) _printMsg "${msgs[no]}"; exit 0      ;; 
      @(h|H)?(elp) ) _printHelp; exit 0                   ;;
      *            ) (( $(( ++count )) == 3 )) && \
                      { _printHelp; exit 1; } || continue ;;
    esac

  done
  return 0
}

# Adds the key to authenticate VSCodium package ------------
_getKey(){
  wget -qO - "${1}" | apt-key add -
  
  return 0
}

# Adds the VSCodium repository to apt source list ----------
_setSourceList(){
  printf "%s" "${1}" | tee --append "${2}" > /dev/null

  return 0
}

# Updates the apt repositories and install VSCodium's last version
_aptInstall(){

  apt update && apt upgrade && apt install codium -y
  return 0

}

# Shows all options provided by this program ---------------
_printHelp(){
  cat <<EOF
    
    How to use: "${itSelf[name]}" [OPTIONS]
     
     OPTIONS:
      -i, --install   Default. Install VSCodium asking for confirmation
      -y              Install VSCodium without confirmation
      -v, --version   Prints version
      -h, --help      Prints this message
      -a, --about     Prints about message
    
    Exemples:

      $ ./${itSelf[name]} --install
      $ ./${itSelf[name]} -y
    
    * ${author[name]} - <${author[email]}> - ${itSelf[name]} V. ${itSelf[version]}

EOF

  return 0
}

# Displays a breaffy description of VSCodium and where to get more information about it
_printAbout(){
  cat <<EOF

  VSCodium is a community-driven, freely-licensed binary distribution of Microsoft’s editor VSCode
  These binaries are licensed under the MIT license. Telemetry is disabled.

  Website: https://vscodium.com/
  Github : https://github.com/VSCodium/vscodium

  ----------------------------------------------------------------------------

  ${itSelf[name]} is a script that helps to get VSCodium installed on your Debian based system.
  It does so by adding a VSCodium repository to the apt source list.

EOF

  return 0
}

# Prints version's number, date and author ------------------
_printVersion(){

  cat <<EOF
    ${itSelf[name]} - version: ${itSelf[version]}
    updated: ${itSelf[date]} by ${author[name]}
EOF

  return 0
}

# ==========================================================
# === STARTS INSTALLATION
# ==========================================================

(( ! "$#" )) && main

while [[ -n "$1" ]]; do
        case "$1" in
            "-i"|"--install") main                    ;;
            "-y"            ) confirmInstall=0; main  ;;
            "-h"|"--help"   ) _printHelp      ; exit 0;;
            "-a"|"--about"  ) _printAbout     ; exit 0;;
            "-v"|"--version") _printVersion   ; exit 0;;
            *               ) _printMsg "Invalid option." && \
                                                exit 1;;
        esac
        shift
done
