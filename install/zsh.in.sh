#!/usr/bin/env sh
# ___________________________________________________________________
#                                                                    |
# TITLE        : zsh.in.sh                                           |
# DESCRIPTION  : Installs Zshell, some plugins and a dotfile         |
# AUTHOR       : Wilson Faustino <open source (a) wfaustino dev>     |
# DATE         : 2021-jan-07                                         |
# VERSION      : 2.0.0                                               |
# DEPENDENCIES : git curl                                            |
# NOTES        : Tested on Debian Buster and Raspberry Pi OS Buster; |
#                but should work on any Debian based Distribution    |
# LICENSE      : MIT                                                 |
# ___________________________________________________________________|

#=== ABOUT ===

itSelfName="${0##*/}"
itSelfVersion="2.0.0"
itSelfDate='2021-jan-07'

authorName='Wilson Faustino'
authorWebsite='wmfaustino dev'
authorEmail='open source (a) wmfaustino dev'

# Shows all options provided by this program ---------------
_usage(){
  
  cat <<EOF

    USAGE: ${itSelfName} [OPTIONS]
    
    OPTIONS:

      -z, --zdotdir      Installs Zshell and sets ZDOTDIR
      -p, --plugins      Installs Zshell, plugins and sets ZDOTDIR
      -d, --dotfiles     Installs Zshell, dotfiles and sets ZDOTDIR
      -Z, --zsh-default  Installs Zshell, sets ZDOTDIR and makes it the default shell
      
      -I, --install-all  Installs Zshell, dotfiles, plugins, sets ZDOTDIR and makes it the default shell
      -h, --help         Prints this message
    
    EXAMPLES:
      
      $ ./${itSelfName} --install-all
      $ ./${itSelfName} -p -d
    
    Dependencies: git curl
    Dotfile: "${dotfile_src_link}"

    * ${authorName} - <${authorEmail}> - ${itSelfName} V. ${itSelfVersion}

EOF

  exit 0
}

#=== INITIAL TESTS===

#--- script is running with argument(s)
[ "${#}" -eq 0 ] && _usage

#--- root access
[ $(id --user) -ne 0 ] && printf "\n%s\n" "You don't have root access" && exit 100

###=== VARIABLES ===

#--- config
global_zshenv="/etc/zsh/zshenv"
zdotdir='$HOME/.config/zsh'

_USER="${SUDO_USER:-$USER}"

#--- HOME
HOME="/home/${_USER}"
[ "$_USER" = 'root' ] && HOME='/root'

#--- ZDOTDIR
ZDOTDIR="${HOME}/.config/zsh"

#--- plugins
ZPLUGDIR="${ZDOTDIR}/plugged"

plugins_git_repo="\
  https://github.com/zsh-users/zsh-history-substring-search.git \
  https://github.com/dracula/zsh.git                            \
  https://github.com/romkatv/powerlevel10k.git                  \
  https://github.com/zsh-users/zsh-autosuggestions.git          \
  https://github.com/zdharma/fast-syntax-highlighting.git       \
"

#--- dotfiles
dotfiles_src_links="\
  https://raw.githubusercontent.com/wmfaustino/dotfiles/master/.config/zsh/.zshrc    \
  https://raw.githubusercontent.com/wmfaustino/dotfiles/master/.config/zsh/.p10k.zsh \
"

# =========================================================

# === KEYS ===
in_dotfiles=0
in_plugins=0
change_shell=0
# =========================================================

# === FUNCTIONS ===

_set_zdotdir(){

  grep '.config/zsh' "$global_zshenv" >/dev/null

  [ "$?" -ne 0 ] && echo 'ZDOTDIR='\"${zdotdir}\" | tee -a "$global_zshenv"

  return "$?"

}

_create_backup(){

  bkp_src="${@}"
  bkp_dest="$HOME/.config/bkp/zsh-$(date '+%Y-%m-%d %H:%M:%S')"

  mkdir -p "$bkp_dest"

  for src in $bkp_src; do

    [ -e "$src" ] && {
      cp -RbLp "$src" "$bkp_dest" && rm -rf "$src"
      printf "Backup: %s\n\n" "${bkp_dest}/${src##*/}"
    }
  done

  return "$?"
}

_apt_install(){

   which "$1" >/dev/null
  
  [ "$?" -eq 0 ] || {
    printf "\n%s\n" "Instaling $1"
    apt install "$1" -y >/dev/null
  }

  return $?
}

_in_dotfiles()(

  _apt_install curl

	[ -d "$ZDOTDIR" ] || mkdir -p "$ZDOTDIR"
	
  cd "$ZDOTDIR"

  printf "\n%s\n" "Setting up dotfiles"
  
  for dotfile in $*; do
    curl -4fLO --silent $dotfile >/dev/null
  done

  chown -f -R "${_USER}:${_USER}" "$ZDOTDIR"

  return "${?}"
)

_in_plugins()(

  _apt_install git

	[ -d "$ZPLUGDIR" ] || mkdir -p "$ZPLUGDIR"
  
  cd "$ZPLUGDIR"

  printf "\n%s\n" "Installing zsh plugin:"
	
  for plugin in $*; do

    printf "%s\n" "$plugin"
    git clone --quiet $plugin >/dev/nul
  
  done

  chown -f -R "${_USER}:${_USER}" "$ZPLUGDIR"

  return "${?}"
)

# =========================================================
# === ENTRY POINT ===
_main(){
  
  _apt_install zsh && _set_zdotdir
  
  # Install Dotfile
  if [ "$in_dotfiles" -eq 1 ]; then
    _create_backup "$HOME/.*zsh* $HOME/*zsh* ${ZDOTDIR}"
    _in_dotfiles ${dotfiles_src_links}
  fi

  # Install Plugins
  if [ "$in_plugins" -eq 1 ]; then
    _create_backup "$ZPLUGDIR"
    _in_plugins ${plugins_git_repo}
  fi

  # Change the user's default shell
  [ "$change_shell" -eq 1 ] && usermod --shell $(which zsh) "$_USER"

  exit 0
}

# =========================================================
# === STARTS INSTALLATION ===

while [ -n "${1}" ]; do
        case "${1}" in
            "-z"|"--zdotdir"     ) :              ;;
            "-p"|"--plugins"     ) in_plugins=1   ;;
            "-d"|"--dotfiles"    ) in_dotfiles=1  ;;
            "-Z"|"--zsh-default" ) change_shell=1 ;;
            "-I"|"--install-all" )
                                   in_dotfiles=1
                                   in_plugins=1
                                   change_shell=1
                                   _main          ;;
            "-h"|"--help"        ) _usage; exit 0 ;;
            *                    )
                                  echo "Invalid option. ${1}"
                                  exit 1          ;;
        esac
      shift
done

_main
