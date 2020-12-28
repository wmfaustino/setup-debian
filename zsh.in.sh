#!/usr/bin/env sh
# ___________________________________________________________________
#                                                                    |
# TITLE        : zsh.in.sh                                           |
# DESCRIPTION  : Installs Zshell, some plugins and a dotfile        |
# AUTHOR       : Wilson Faustino <open source (a) wfaustino dev>     |
# DATE         : 2020-dez-28                                         |
# VERSION      : 1.0.0                                               |
# DEPENDENCIES : git curl                                            |
# NOTES        : Tested on Debian Buster and Raspberry Pi OS Buster; |
#                but should work on any Debian based Distribution    |
# LICENSE      : MIT                                                 |
# ___________________________________________________________________|

#=== ABOUT ===

itSelfName="${0##*/}"
itSelfVersion="1.0.0"
itSelfDate='2020-dec-28'

authorName='Wilson Faustino'
authorWebsite='wmfaustino dev'
authorEmail='open source@wmfaustino dev'

# Shows all options provided by this program ---------------
_usage(){
  
  cat <<EOF

    USAGE: ${itSelfName} [OPTIONS]
    
    OPTIONS:

      -z, --zshell         Installs Zshell and sets ZDOTDIR
      -Z, --zshell-default Installs Zshell, sets ZDOTDIR and makes it the default shell
      -p, --plugins       Installs Zshell, plugins and sets ZDOTDIR
      -d, --dotfiles       Installs Zshell, dotfiles and sets ZDOTDIR
      
      -I, --install-all    Installs Zshell, dotfiles, plugins, sets ZDOTDIR and makes it the default shell
      -V, --version        Prints version
      -h, --help           Prints this message
    
    EXAMPLES:
      
      $ ./${itSelfName} --install-all
      $ ./${itSelfName} -p -d
    
    Dependencies: git curl
    Dotfile: "${dotfile_src_link}"

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

#=== VARIABLES ===

#--- dependencies
dependencies="git curl"

#--- config
global_zshenv="/etc/zsh/zshenv"
zdotdir='$HOME/.config/zsh'

_USER="${SUDO_USER:-$USER}"

#--- dotfile
ZDOTDIR="/home/${_USER}/.config/zsh"

dotfiles_src_links="\
  https://raw.githubusercontent.com/wmfaustino/dotfiles/master/.config/zsh/.zshrc    \
  https://raw.githubusercontent.com/wmfaustino/dotfiles/master/.config/zsh/.p10k.zsh \
"

#--- plugins
ZPLUGDIR="${ZDOTDIR}/plugged"

plugins_git_repo="\
  https://github.com/zsh-users/zsh-history-substring-search.git \
  https://github.com/dracula/zsh.git                            \
  https://github.com/romkatv/powerlevel10k.git                  \
  https://github.com/zsh-users/zsh-autosuggestions.git          \
  https://github.com/zdharma/fast-syntax-highlighting.git       \
"
# =========================================================

# === KEYS ===
in_deps=0
create_bkp=0
in_dotfiles=0
in_plugins=0
change_shell=0
# =========================================================

# === FUNCTIONS ===
_in_from_apt(){
  
  # installPkgs: put all packages in a single line
  in_pkgs="$(printf "%s" "${*}" | tr '\n' ' ')"
  echo "$in_pkgs"
  if [ $(id --user) -ne 0 ]; then
    
    printf "\nYou need root acces in order to install ${in_pkgs} from apt\n\n"
  
    # Regular users can not install from apt
    #su root -c "apt install ${in_pkgs} -y"
    sudo apt install ${in_pkgs} -y

  else # user is either root or executed with sudo
    apt install ${in_pkgs} -y
  fi

	return "${?}"
}

_set_zdotdir(){

  grep 'ZDOTDIR' "$global_zshenv" >/dev/null
  if [ "$?" -ne 0 ]; then
  
    if [ $(id --user) -ne 0 ]; then
      
      printf "\nYou need root acces in order to se global environment variables\n\n"
    
      #echo ZDOTDIR=\"${zdotdir}\" | su root -c "tee -a $global_zshenv"
      echo ZDOTDIR=\"${zdotdir}\" | sudo tee -a "$global_zshenv"

    else # user is either root or executed with sudo
     #echo "ZDOTDIR=${zdotdir}" >> "$global_zshenv"
      echo ZDOTDIR=\"${zdotdir}\" | tee -a "$global_zshenv"
    fi
  fi

  return "$?"

}

_create_backup(){
  bkp_src="\
    /home/$_USER/.*zsh* \
    /home/$_USER/.config/zsh  \
"
  bkp_dest="/home/$_USER/.config/bkp/zsh-$(date '+%Y-%m-%d %H:%M:%S')"
  mkdir -p "$bkp_dest"

  for src in $bkp_src; do 
   cp -RbLp "$src" "$bkp_dest" && rm -rf "$src"
  printf "Dotfile Backup: %s\n\n" "${bkp_dest}/${src##*/}"
  done

}

_in_dotfiles()(

	[ -d "$ZDOTDIR" ] || mkdir -p "$ZDOTDIR"
	
  cd "$ZDOTDIR"

  for dotfile in "$*"; do
    curl -4fLO $dotfile >/dev/null
  done

  return "${?}"
)

_in_plugins()(
  
	[ -d "$ZPLUGDIR" ] && mkdir -p "$ZPLUGDIR"
  
  cd "$ZPLUGDIR"

	for plugin in $*; do
    echo $plugin
    git git-force-clone $plugin
  done

  return "${?}"
)

# =========================================================
# === ENTRY POINT ===
_main(){
  
  _in_from_apt zsh && _set_zdotdir

  # Install Dependencies
  [ "$in_deps" -eq 1 ] && _in_from_apt ${dependencies}
  
  # create backup
  #[ "$create_bkp" -eq 1 ] && _create_backup
  
  # Install Dotfile
  #[ "$in_dotfiles" -eq 1 ] && _in_dotfiles ${dotfiles_src_links}
  
  # Install Plugins listed on dotfile
  [ "$in_plugins" -eq 1 ] && _in_plugins ${plugins_git_repo}
  
  # Change the user's default shell
  [ "$change_shell" -eq 1 ] && sudo usermod --shell $(which zsh) "$_USER"

  exit 0
}

# =========================================================
# === STARTS INSTALLATION ===

[ "${#}" -eq 0 ] && _usage

while [ -n "${1}" ]; do
        case "${1}" in
            "-z"|"--zshell"        ) _main              ;;
            "-Z"|"--zshell-default") change_shell=1     ;;
            "-p"|"--plugins"   )
                                in_deps=1
                                in_plugins=1            ;;
            "-d"|"--dotfiles"   )
                                in_deps=1
                                create_bkp=1
                                in_dotfiles=1
                                in_plugins=1            ;;
            "-I"|"--install-all")
                                in_deps=1
                                create_bkp=1
                                in_dotfiles=1
                                in_plugins=1
                                change_shell=1
                                _main                   ;;
            "-h"|"--help"       ) _usage       ; exit 0 ;;
            "-V"|"--version"    ) _printVersion; exit 0 ;;
            *                   )
                                "Invalid option. ${1}" ;
                                _usage
                                exit 1                  ;;
        esac
      shift
done

_main
