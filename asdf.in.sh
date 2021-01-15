#!/usr/bin/env bash
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
# [ "${#}" -eq 0 ] && _usage

#--- root access
# [ $(id --user) -ne 0 ] && printf "\n%s\n" "You don't have root access" && exit 100

###=== VARIABLES ===

#--- config

# sudo apt install curl git

#=== INITIAL TESTS===

#--- script is running with argument(s)

#--- do not run with sudo

###=== VARIABLES ===

# --- asdf default dir
ASDF_DATA_DIR="$HOME/.asdf"

# --- bash
declare -rg _bashrc="${HOME}/.bashrc"

declare -arg source_into_bashrc=(
  .\ \"'${ASDF_DATA_DIR}'/asdf.sh\"
  .\ \"'${ASDF_DATA_DIR}'/completions/asdf.bash\"
)

# exec para pegar a ZDOTDIR
# --- zsh
declare -rg _zshrc="${ZDOTDIR:=$HOME/.config/zsh}/.zshrc"

declare -arg source_into_zshrc=(
    .\ \"'${ASDF_DATA_DIR}'/asdf.sh\"
    '# append completions to fpath'
    "fpath=(${ASDF_DATA_DIR}/completions \$fpath)"
    '# initialise completions with ZSH''s compinit'
    'autoload -Uz compinit'
    'compinit'
  )
# =========================================================

# === PLUGINS ===
# https://asdf-vm.com/#/plugins-all

# --- golang
# https://github.com/kennyp/asdf-golang
# After using go get to install a package you need to run asdf reshim golang to get any new shims.
declare -Arg _golang=(
  [dependencies]="coreutils curl"
  [repo]="https://github.com/kennyp/asdf-golang.git"
)
# =========================================================

# --- lua
# https://github.com/Stratus3D/asdf-lua
declare -Arg lua=(
  [dependencies]="linux-headers-$(uname -r) build-essential"
  [repo]="https://github.com/Stratus3D/asdf-lua.git"
)
# =========================================================

# --- nodejs
# https://github.com/asdf-vm/asdf-nodejs
declare -Arg nodejs=(
  [dependencies]="dirmngr gpg curl"
  [repo]="https://github.com/asdf-vm/asdf-nodejs.git"
  [keys]='${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
  )
# =========================================================

# --- python
# https://github.com/danhper/asdf-python
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
# If you use pip to install a module like ipython that has binaries. You will need to run asdf reshim python for the binary to be in your path.
declare -arg python=(
  [dependencies]='make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev'
)
# =========================================================

# --- ruby
# https://github.com/asdf-vm/asdf-ruby
declare -Arg ruby=(
  [repo]="https://github.com/asdf-vm/asdf-ruby.git"
)
# =========================================================

# --- rust
# https://github.com/code-lever/asdf-rust
# After you have installed rust, do NOT follow the directions it outputs to update your PATH -- asdf's shim will handle that for you!
declare -Arg rust=(
  [repo]="https://github.com/code-lever/asdf-rust.git"
)
# =========================================================

# === FUNCTIONS ===

function _in_asdf(){

  # clone the whole repo
  git clone https://github.com/asdf-vm/asdf.git "${ASDF_DATA_DIR}"
  cd "$ASDF_DATA_DIR"
  # checkout the latest branch
  git checkout "$(git describe --abbrev=0 --tags)"

  return "$?"
}

function _setup_config_file(){

  local -r config_file="$1"
  shift

  for file in "$@"; do
    echo "${file}" #>> "$config_file"
  done

  return "$?"
}

function _in_asdf_plugin(){

  local -n _plugin="$1"

  sudo apt install ${_plugin[dependencies]} -y

  asdf plugin-add "$1" "${_plugin[repo]}"
echo $?
  [[ ! -z "${_plugin[keys]}" ]] && bash -c "${_plugin[keys]}"
  echo $?
}

# _setup_config_file "$_bashrc" "${source_into_bashrc[@]}"
# _setup_config_file "$_zshrc" "${source_into_zshrc[@]}"
# _in_asdf_plugin nodejs
_in_asdf_plugin python
exit
# echo $ASDF_DATA_DIR

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
