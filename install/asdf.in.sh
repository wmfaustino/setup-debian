#!/usr/bin/env bash
# ___________________________________________________________________
#                                                                    |
# TITLE        : asdf.in.sh                                          |
# DESCRIPTION  : Installs ASDF, add plugins, install plugins         |
# AUTHOR       : Wilson Faustino <open source (a) wfaustino dev>     |
# DATE         : 2021-jan-18                                         |
# VERSION      : 1.0.0                                               |
# DEPENDENCIES : apt sudo                                            |
# NOTES        : Tested on Debian Buster and Raspberry Pi OS Buster; |
#                but should work on any Debian based Distribution    |
# LICENSE      : MIT                                                 |
# ___________________________________________________________________|

#=== ABOUT ===

script_title="${0##*/}"
script_version="1.0.1"
script_date='2021-jan-19'

author='Wilson Faustino'
author_website='wmfaustino dev'
author_email='open source (a) wmfaustino dev'

# Shows all options provided by this program ---------------
_usage(){

  cat <<EOF

    USAGE: ${script_title} [OPTIONS]

    OPTIONS:

      --asdf        Install asdf version manager

    SETUP SHELL:
      --bash        Source asdf into bashrc
      --zsh         Source asdf into zshrc
      --all-shells  Source asdf into both (bashrc and zshrc)

    ADD PLUGIN:
      --golang
      --lua
      --neovim
      --nodejs
      --ruby
      --rust
      --python
      --add-all     Add all plugins listed above

      --latest      Install latest version available for added plugins

      --help        Prints this message

    EXAMPLES:

      $ ./${script_title} --asdf --all-shells --add-all --latest
      $ ./${script_title} --asdf --zsh --lua --nodejs
      $ ./${script_title} --asdf --rust --latest
      $ ./${script_title} --python

    Dependencies: apt sudo

    * ${author} - <${author_email}> - ${script_title} V. ${script_version}

EOF

  exit 0
}

#=== INITIAL TESTS===

# --- script is running with argument(s)
(( "${#}" == 0 )) && _usage

#--- do not run with sudo
[[ -n "$SUDO_USER" ]] && echo "Do not run with sudo" && exit 100

# =========================================================

# === KEYS ===
declare -Ag _install=(
  [asdf]=0
  [plugin_latest]=0
)

# shell and plugins keys are set at their respectives associative arrays
# =========================================================

# --- asdf default dir
: "${ASDF_DATA_DIR:=$HOME/.asdf}"

# === SHELLS
# --- setup shell
declare -arg shells=(
  bash
  zsh
)

# --- bash
declare -Ag bash=(
  [config_file]="${HOME}/.bashrc"
  [source_asdf]=0
  [content_to_source]="
    . "'${ASDF_DATA_DIR}'/asdf.sh"
    . "'${ASDF_DATA_DIR}'/completions/asdf.bash"
  "
)

# --- zsh
declare -Ag zsh=(
  [config_file]="${ZDOTDIR:=$HOME/.config/zsh}/.zshrc"
  [source_asdf]=0
  [content_to_source]="
    . "'${ASDF_DATA_DIR}'/asdf.sh"
    "'# append completions to fpath'"
    "'fpath=(${ASDF_DATA_DIR}/completions $fpath)'"
    "'# initialise completions with ZSH''s compinit'"
    "'autoload -Uz compinit'"
    "'compinit'"
  "
)

# =========================================================

# === ASDF PLUGINS ===
# https://asdf-vm.com/#/plugins-all

# --- add plugins
declare -arg plugins=(
  golang
  lua
  neovim
  nodejs
  ruby
  rust
  python
)

# --- golang
# After using go get to install a package you need to run asdf reshim golang to get any new shims.
declare -Ag golang=(
  [dependencies]="coreutils curl"
  [repo]="https://github.com/kennyp/asdf-golang.git"
  [add]=0
  [version]="latest"
)
# =========================================================

# --- lua
declare -Ag lua=(
  [dependencies]="linux-headers-$(uname -r) build-essential"
  [repo]="https://github.com/Stratus3D/asdf-lua.git"
  [add]=0
  [version]="latest"
)
# =========================================================

# --- neovim
# https://github.com/richin13/asdf-neovim
declare -Ag neovim=(
  [add]=0
  [version]="nightly"
)
if [[ "$(uname -m)" =~ 'arm' ]]; then
  neovim[dependencies]="cmake pkg-config automake libtool libtool-bin unzip gettext"
  neovim[version]="ref:nightly"
fi
# =========================================================

# --- nodejs
declare -Ag nodejs=(
  [dependencies]="dirmngr gpg curl"
  [repo]="https://github.com/asdf-vm/asdf-nodejs.git"
  [keys]='${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
  [add]=0
  [version]="latest"
  )
# =========================================================

# --- ruby
declare -Ag ruby=(
  [repo]="https://github.com/asdf-vm/asdf-ruby.git"
  [add]=0
  [version]="latest"
)
# =========================================================

# --- rust
# After you have installed rust, do NOT follow the directions it outputs to update your PATH -- asdf's shim will handle that for you!
declare -Ag rust=(
  [repo]="https://github.com/code-lever/asdf-rust.git"
  [add]=0
  [version]="latest"
)
# =========================================================

# --- python
# https://github.com/danhper/asdf-python
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
# If you use pip to install a module like ipython that has binaries. You will need to run asdf reshim python for the binary to be in your path.
declare -Ag python=(
  [dependencies]="make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev"
  [add]=0
  [version]="latest"
)
# =========================================================

# === FUNCTIONS ===
function _in_asdf(){

  # Remove any old asdf version already installed
  [[ -d "$ASDF_DATA_DIR" ]] && rm -rf "$ASDF_DATA_DIR"

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

  echo -e "ASDF_DATA_DIR=$ASDF_DATA_DIR" >> "$config_file"

  for content in "$@"; do
    IFS=" "
    echo -e $content #>> "$config_file"
  done

  return "$?"
}

function _add_asdf_plugin(){

  # $1 is the plugin associative array (dependencies, repo, key(gpg)
  # plugin will reference that associative array
  local -n plugin="$1"

  # Install plugin dependencies
  if [[ ! -z "${plugin[dependencies]}" ]]; then

    echo "Plugin $1 requires ${plugin[dependencies]}"
    sudo apt install -qq -y ${plugin[dependencies]} > /dev/null 2>&1
  fi

  # first remove the plugin if it is already added
  # it removes first to avoid any gpg keys issue
  echo "Adding $1 plugin to asdf"
  asdf plugin remove "$1"
  asdf plugin add "$1" "${plugin[repo]}"

  # Add gpg keys (if plugin requires)
  [[ ! -z "${plugin[keys]}" ]] && bash -c "${plugin[keys]}"

  return 0
}

# =========================================================

# === ENTRY POINT ===
_main(){

  # --- Install asdf
  (( "${_install[asdf]}" == 1 )) && _in_asdf

  # --- Setup shells
  for sh in ${shells[@]}; do

    # reference sh to each shell associative array
    local -n shell_to_setup="$sh"

    (( "${shell_to_setup[source_asdf]}" == 1 )) && \
    echo -e "\nSourcing asdf into $sh"               && \
    _setup_config_file "${shell_to_setup[config_file]}" "${shell_to_setup[content_to_source]}"
  done

  # --- Adding Plugins
  for plugin in "${plugins[@]}"; do

    local -n plugin_arr="$plugin"

      (( "${plugin_arr[add]}" == 1 )) && {

        _add_asdf_plugin "$plugin";

        (( "${_install[plugin_latest]}" == 1 ))           && \
          asdf install "$plugin" "${plugin_arr[version]}" && \
          asdf global "$plugin" $(asdf list $plugin | sed 's/^[ \t]*//;s/[ \t]*$//')
    }
  done

  exit 0
}

# =========================================================

# === STARTS INSTALLATION ===
while [ -n "${1}" ]; do
        case "${1}" in
            "--asdf"      ) _install[asdf]=1
                          ;;
            "--bash"      ) bash[source_asdf]=1
                          ;;
            "--zsh"       ) zsh[source_asdf]=1
                          ;;
            "--all-shells")
                            for sh in ${shells[@]}; do
                              declare -n shell_to_setup="$sh"
                              shell_to_setup[source_asdf]=1
                            done
                          ;;
            "--golang" | \
            "--lua"    | \
            "--neovim" | \
            "--nodejs" | \
            "--ruby"   | \
            "--rust"   | \
            "--python"    )
                            declare -n plugin_arr="${1#--*}";
                            plugin_arr[add]=1;
                          ;;
            "--add-all"   )
                            for plugin in "${plugins[@]}"; do
                              declare -n plugin_arr="$plugin"
                              plugin_arr[add]=1
                            done
                          ;;
            "--latest"    ) _install[plugin_latest]=1
                          ;;
            "--help"      ) _usage; exit 0
                          ;;
            *             )
                            echo "Invalid option. ${1}"
                            exit 1
                          ;;
        esac
      shift
done

_main
