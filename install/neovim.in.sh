#!/usr/bin/env sh
# ---------------------------------------------------------
#
# TITLE         : Setup Neovim
# DESCRIPTION   : Install Neovim, Vim Plug, Plugins and Dotfile

# AUTHOR        : Wilson Faustino <open source (a) wfaustino dev>

# DATE          : 2020-aug-04
# VERSION       : 1.0.1    

# DEPENDENCIES  : git curl

# NOTES         : It was tested on Debian Buster and Ubuntu Mate 20.04 LTS, but should work on any Debian based Linux Distribution

# ---------------------------------------------------------
# Setup Script Released under MIT License
# ---------------------------------------------------------
 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# =========================================================
# === GLOBAL VARIABLES
# =========================================================

# === ABOUT VARIABLES

itSelfName="${0##*/}"
itSelfVersion="1.1.0"
itSelfDate='2020-dec-27'

authorName='Wilson Faustino'
authorWebsite='wmfaustino dev'
authorEmail='open source@wmfaustino dev'

# === DEPENDENCIES
dependencies="\
  build-essential \
  git \
  curl \
  golang\
"
# === CONFIG
_USER="${SUDO_USER:-$USER}"

configDir="/home/${_USER}/.config"
localDataDir="/home/${_USER}/.local/share"

# === DOTFILE
dotfile='init.vim'

dotfileSrcLink='https://github.com/wmfaustino/dotfiles/raw/master/.config/nvim/init.vim'
dotfileDestDir="${configDir}/nvim/${dotfile}"

# === VIMPLUG
vimPlug='plug.vim'

vimPlugSrcLink='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
vimPlugInstallDir="${localDataDir}/nvim/site/autoload/${vimPlug}"

# =========================================================
# === KEYS
# =========================================================
instDeps=0
instNvim=0
instDotfile=0

instVimPlug=0
in_pluggins=0


# =========================================================
# === FUNCTIONS
# =========================================================

# Shows all options provided by this program ---------------
_usage(){
  
  cat <<EOF

    USAGE: ${itSelfName} [OPTIONS]
    
    OPTIONS:

      -b, --base          Installs Neovim and Vim Plug
      -n, --neovim        Installs Neovim
      -p, --vim-plug      Installs Vim Plug
      -P, --pluggins      Installs Dotfile and Pluggins
      -d, --dotfiles      Installs Dotfile
      -D, --dependencies  Installs Dependencies
      
      -y, --install-all   Installs Neovim, Vim Plug, Pluggins, Dependencies and Dotfiles
      
      -V, --version       Prints version
      -h, --help          Prints this message
    
    EXEMPLES:
      
      $ ./${itSelfName} --install-all
      $ ./${itSelfName} -n -d
    
    Dependencies: git curl
    Dotfile: "${dotfileSrcLink}"

    * ${authorName} - <${authorEmail}> - ${itSelfName} V. ${itSelfVersion}

EOF

  exit 0
}

# Prints version's number, date and author ------------------
_printVersion(){

  cat <<EOF
    ${itSelfName} - version: ${itSelfVersion}
    updated: ${itSelfDate} by ${authorName}
EOF

  exit 0
}

# --------------------------------------
########################################
# --------------------------------------

_installFromApt(){

  # installPkgs: put all packages in a single line
  installPkgs="$(printf "%s" "${*}" | tr '\n' ' ')"

  if [ $(id --user) -ne 0 ]; then
    
    printf "\nYou need root acces in order to install ${installPkgs} from apt\n\n"
  
    # Regular users can not install from apt
    # Change to root only to install from apt
    su root -c "apt install ${installPkgs} -y"
  else # user is either root or executed with sudo
    apt install ${installPkgs} -y
  fi

	return "${?}"
}

_runCommandAsRegularUser(){

  command="${1}"

  if [ $(id --user) -eq 0 ]; then
    # user is either root or executed with sudo,
    # then change to regular user
    su "${_USER}" -c "${command}"
  else
    # User is a regular user
    eval "${command}"
  fi

  return "${?}"
}

_installFromCurl(){

  _outputFile="$1"
  _srcLink="$2"

  getFiles="curl -4fLo ${_outputFile} ${_srcLink} --create-dirs"

    # If root or sudo Curl a file,
    # it comes with root owenership and permissions
  _runCommandAsRegularUser "${getFiles}"
  
  return "${?}"
}

_installPlugins(){
  
  getPlugins="nvim --headless -c :PlugInstall -c :qa"
  
  # Plugins should be installed at user's directory,
  # not root's
  _runCommandAsRegularUser "${getPlugins}"

  return "${?}"
}

# =========================================================
# === ENTRY POINT
# =========================================================
_main(){
  
  # Install Dependencies
  [ "${instDeps}" -eq 1 ] && _installFromApt "${dependencies}"
  
  # Install Neovim
  [ "${instNvim}" -eq 1 ] && _installFromApt 'neovim'
  
  # Install Vim Plug
  [ "${instVimPlug}" -eq 1 ] && \
    _installFromCurl "${vimPlugInstallDir}" "${vimPlugSrcLink}"
  
  # Install Dotfile
  [ "${instDotfile}" -eq 1 ] && \
    _installFromCurl "${dotfileDestDir}" "${dotfileSrcLink}"
  
  # Install Plugins listed on dotfile
  if { [ "${in_pluggins}" -eq 1 ] && [ "${instDotfile}" -eq 1 ]; }; then
    _installPlugins
  fi
  
  exit 0
}

# =========================================================
# === STARTS INSTALLATION
# =========================================================

[ "${#}" -eq 0 ] && _usage

while [ -n "${1}" ]; do
        case "${1}" in
            "-b"|"--base"         ) instNvim=1 && instVimPlug=1   ;;
            "-n"|"--neovim"       ) instNvim=1                    ;;
            "-p"|"--vim-plug"     ) instVimPlug=1                 ;;
            "-P"|"--pluggins"     ) in_pluggins=1 && instDotfile=1;;
            "-d"|"--dotfiles"     ) instDotfile=1                 ;;
            "-D"|"--dependencies" ) instDeps=1                    ;;
            "-y"|"--install-all"  )
              instNvim=1                        ; 
              instVimPlug=1                     ;
              in_pluggins=1                     ;
              instDotfile=1                     ;
              instDeps=1                        ;
              _main                                               ;;
            "-h"|"--help"   ) _usage            ; exit 0          ;;
            "-V"|"--version") _printVersion     ; exit 0          ;;
            *               )
              _usage "Invalid option. ${1}"     ;
              exit 1                                           ;;
        esac
        shift
done

_main
