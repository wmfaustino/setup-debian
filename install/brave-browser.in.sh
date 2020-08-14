#!/usr/bin/env bash
# ------------------------------------------------------------
# bash_version: GNU bash, version 5.0.3(1)-release (x86_64-pc-linux-gnu)
# ------------------------------------------------------------

#TITLE          : inst_brave-browser
#DESCRIPTION    : Set up Brave repository at apt source list; Install Brave
#SOURCE         : 
#AUTHOR         : Wilson Faustino <open source (a) wfaustino dev>
#DATE           : 2020-jul-18
#VERSION        : 1.0.0    
#USAGE		      : ./inst_brave-browser

#NOTES          : It was tested on Debian Buster

#DISCLAIMER     : This script only helps to install Brave Browser.
#                 It is not responsable to Brave Browser itself, nor to it's repository
#                 Use it Brave Browser or this script at your own risk

# ------------------------------------------------------------
# Installation Script Released under MIT License
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

declare -rg package='brave-browser'

declare -Arg instScript=(
  [name]="${0##*/}"
  [version]="1.0.0"
  [date]='2020-jul-18'
)

declare -Arg author=(
  [name]='Wilson Faustino'
  [website]='wmfaustino.dev'
  [email]='open.source@wmfaustino.dev'
)

# ==========================================================
# === GLOBAL VARIABLES
# ==========================================================

declare -ar dependencies=(
  curl
  apt-transport-https
)

declare -Arg brave=(
  [key]='https://brave-browser-apt-release.s3.brave.com/brave-core.asc'
  [src]='deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main'
  [sourceList]='/etc/apt/sources.list.d/brave-browser-release.list'
  [trustedGpg]='/etc/apt/trusted.gpg.d/brave-browser-release.gpg'
)

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
  _superUserCheck

  (( "$confirmInstall" == 1 )) && _confirmInstallation
  
  # === Dependencies install
  _installDependencies "${dependencies[@]}"
  
  # === Repository setup
  _getKey "${brave[key]}" "${brave[trustedGpg]}"
  _setSourceList "${brave[src]}" ${brave[sourceList]}
  
  # === brave-browser install
  _aptInstall "${package}"

  exit 0

}

# ==========================================================
# === FUNCTIONS
# ==========================================================

# Shows all options provided by this program ---------------
_printHelp(){
  cat <<EOF
    
    How to use: "${instScript[name]}" [OPTIONS]
     
     OPTIONS:
      -i, --install   Default. Install "${package}" asking for confirmation
      -y              Install "${package}" without confirmation
      -v, --version   Prints version
      -h, --help      Prints this message
      -a, --about     Prints about message
    
    Exemples:
      $ ./${instScript[name]} --install
      $ ./${instScript[name]} -y
    
    * ${author[name]} - <${author[email]}> - ${instScript[name]} V. ${instScript[version]}
EOF

  return 0
}

# Indicates Brave Browser's site
_printAbout(){

  local website='https://brave.com/'

  printf "%s\n" "Website\: ${website}"
  return 0
}

# Prints version's number, date and author ------------------
_printVersion(){

  cat <<EOF
    ${instScript[name]} - version: ${instScript[version]}
    updated: ${instScript[date]} by ${author[name]}
EOF

  return 0
}

# Checks if user has super user powers ---------------------
_superUserCheck(){

  [[ "$EUID" -ne 0 ]] && \
    { printf "%s\n%s\n" "Not a superuser, no cookies for you!!!" \
      "Get your superuser's power and try it again"; exit 1; } 
    
  return 0
}

# Asks user if he agrees with the instalation --------------
_confirmInstallation(){

  local -Ar msgs=(
    [initial]="This program will install ${package}."
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

# ----------------------------------------------------------

_installDependencies(){

  apt install "${1}" -y

  return 0
}

_getKey(){
  
  curl "${1}" | apt-key --keyring "${2}" add -

  return 0
}

_setSourceList(){

  printf "%s" "${1}" | tee "${2}" > /dev/null

  return 0

}

_aptInstall(){

  apt update && \
  apt upgrade && \
  apt install "${1}" -y

  return 0
}

# ==========================================================
# === STARTS INSTALLATION
# ==========================================================

(( ! "$#" )) && main

case "$1" in
  "-i"|"--install") main
  "-y"            ) confirmInstall=0; main                ;;
  "-h"|"--help"   ) _printHelp      ; exit 0              ;;
  "-a"|"--about"  ) _printAbout     ; exit 0              ;;
  "-v"|"--version") _printVersion   ; exit 0              ;;
  *               ) _printMsg "Invalid option." && exit 1 ;;
esac
