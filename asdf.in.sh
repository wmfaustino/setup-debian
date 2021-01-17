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

# === KEYS ===
# --- asdf and latest version
declare -Ag _install=(
  [asdf]=0
  [plugin_latest]=0
)

# --- setup shell
declare -Ag _setup_shell=(
  [bashrc]=0
  [zshrc]=0
)

# --- add plugins
declare -Ag _add_plugin=(
  [golang]=0
  [lua]=0
  [neovim]=0
  [nodejs]=0
  [ruby]=0
  [rust]=0
  [python]=0
)
# =========================================================

# --- asdf default dir
: "${ASDF_DATA_DIR:=$HOME/.asdf}"

# --- bash
declare -rg bashrc="${HOME}/.bashrc"

declare -arg source_into_bashrc=(
  .\ \"'${ASDF_DATA_DIR}'/asdf.sh\"
  .\ \"'${ASDF_DATA_DIR}'/completions/asdf.bash\"
)

# --- zsh
declare -rg zshrc="${ZDOTDIR:=$HOME/.config/zsh}/.zshrc"

declare -arg source_into_zshrc=(
    .\ \"'${ASDF_DATA_DIR}'/asdf.sh\"
    '# append completions to fpath'
    "fpath=(${ASDF_DATA_DIR}/completions \$fpath)"
    '# initialise completions with ZSH''s compinit'
    'autoload -Uz compinit'
    'compinit'
)
# =========================================================

# === ASDF PLUGINS ===
# https://asdf-vm.com/#/plugins-all

# --- golang
# After using go get to install a package you need to run asdf reshim golang to get any new shims.
declare -Arg golang=(
  [dependencies]="coreutils curl"
  [repo]="https://github.com/kennyp/asdf-golang.git"
  [version]="latest"
)
# =========================================================

# --- lua
declare -Arg lua=(
  [dependencies]="linux-headers-$(uname -r) build-essential"
  [repo]="https://github.com/Stratus3D/asdf-lua.git"
  [version]="latest"
)
# =========================================================

# --- neovim
# https://github.com/richin13/asdf-neovim
declare -Arg neovim=(
  [version]="nightly"
)
# =========================================================

# --- nodejs
declare -Arg nodejs=(
  [dependencies]="dirmngr gpg curl"
  [repo]="https://github.com/asdf-vm/asdf-nodejs.git"
  [keys]='${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
  [version]="latest"
  )
# =========================================================

# --- ruby
declare -Arg ruby=(
  [repo]="https://github.com/asdf-vm/asdf-ruby.git"
  [version]="latest"
)
# =========================================================

# --- rust
# After you have installed rust, do NOT follow the directions it outputs to update your PATH -- asdf's shim will handle that for you!
declare -Arg rust=(
  [repo]="https://github.com/code-lever/asdf-rust.git"
  [version]="latest"
)
# =========================================================

# --- python
# https://github.com/danhper/asdf-python
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
# If you use pip to install a module like ipython that has binaries. You will need to run asdf reshim python for the binary to be in your path.
declare -Arg python=(
  [dependencies]="make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev"
  [version]="latest"
)
# =========================================================

# === FUNCTIONS ===
function _in_asdf(){

  [[ -d "$ASDF_DATA_DIR" ]] && mv "$ASDF_DATA_DIR" ~/.tool-versions /tmp

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
    echo "${file}" >> "$config_file"
  done

  return "$?"
}

function _add_asdf_plugin(){

  # $1 is the plugin associative array (dependencies, repo, key(gpg)
  # plugin will reference that associative array
  local -n plugin="$1"

  # Install plugin dependencies
  sudo apt install -qq -y ${plugin[dependencies]} > /dev/null 2>&1

  # first remove the plugin if it is already added
  # it removes first to avoid any gpg keys issue
  asdf plugin remove "$1"
  asdf plugin add "$1" "${plugin[repo]}"

  # Add gpg keys (if plugin requires)
  [[ ! -z "${plugin[keys]}" ]] && bash -c "${plugin[keys]}"


  return "$0"
}

function _in_asdf_plugin(){

  # $1 is the plugin associative array (dependencies, repo, key(gpg)
  # plugin will reference that associative array
  local -n plugin="$1"

  # After adding a plugin to asdf, you can install any version available
  # The version that will be installed is especified at each plugin associative array
  (( "${_add_plugin[plugin_latest]}" == 1 )) && asdf install "$1" "${plugin[version]}"

}

# =========================================================

# === ENTRY POINT ===
_main(){

  # --- Install asdf
  (( "${_install[asdf]}" == 1 )) && _in_asdf

  # --- Setup shells
  for shell in "${!_setup_shell[@]}"; do

    if (( "${_setup_shell[$shell]}" == 1 )); then

      # reference shell to setup_shell associative array
      local -n config_file="$shell"
      local -n lines_to_source="_setup_$shell"

    _setup_config_file "$config_file" "${lines_to_source[@]}"
  fi

  done

  # --- Install Plugins
  for plugin in "${!_add_plugin[@]}"; do

    (( "${_add_plugin[$plugin]}" == 0 )) && \
    _add_asdf_plugin "$plugin"

  done

  exit 0
}

# =========================================================

# === STARTS INSTALLATION ===
while [ -n "${1}" ]; do
        case "${1}" in
            "--asdf"      ) "${_install[asdf]}"=1         ;;
            "--bash"      ) "${_setup_shell[bashrc]}"=1   ;;
            "--zsh"       ) "${_setup_shell[zshrc]}"=1    ;;
            "--all-shells")
                        "${_setup_shell[bashrc]}"=1
                        "${_setup_shell[zshrc]}"=1        ;;
            "--golang"    ) "${_add_plugin[golang]}"=1    ;;
            "--lua"       ) "${_add_plugin[lua]}"=1       ;;
            "--neovim"    ) "${_add_plugin[neovim]}"=1    ;;
            "--nodejs"    ) "${_add_plugin[nodejs]}"=1    ;;
            "--ruby"      ) "${_add_plugin[ruby]}"=1      ;;
            "--rust"      ) "${_add_plugin[rust]}"=1      ;;
            "--python"    ) "${_add_plugin[python]}"=1    ;;
            "--latest"    ) "${_install[plugin_latest]}"=1;;
            "--add-all"   )
                           for plugin in "${!_add_plugin[@]}";
                             do
                               _add_plugin[$plugin]=1
                             done                         ;;
            "--help"      ) _usage; exit 0                ;;
            *             )
                        echo "Invalid option. ${1}"
                        exit 1                            ;;
        esac
      shift
done

_main
