#!/usr/bin/env bash

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

function _in_asdf(){

  # clone the whole repo
  git clone https://github.com/asdf-vm/asdf.git "${ASDF_DATA_DIR%/.asdf}"
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

_setup_config_file "$_bashrc" "${source_into_bashrc[@]}"
_setup_config_file "$_zshrc" "${source_into_zshrc[@]}"

echo $ASDF_DATA_DIR


# Plugins
# https://asdf-vm.com/#/plugins-all

_in_asdf_nodejs(){
  # https://github.com/asdf-vm/asdf-nodejs

  sudo apt install dirmngr gpg curl -y

  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git

  bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'

  return "$?"
}

_in_asdf_golang(){
  # https://github.com/kennyp/asdf-golang

  sudo apt install coreutils curl -y

  asdf plugin-add golang https://github.com/kennyp/asdf-golang.git

  # After using go get to install a package you need to run asdf reshim golang to get any new shims.

  return "$?"
}

_in_asdf_rust(){
  # https://github.com/code-lever/asdf-rust

  asdf plugin-add rust https://github.com/code-lever/asdf-rust.git

# After you have installed rust, do NOT follow the directions it outputs to update your PATH -- asdf's shim will handle that for you!

  return "$?"
}

_in_asdf_ruby(){
  # https://github.com/asdf-vm/asdf-ruby

  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git

  return "$?"
}

_in_asdf_python(){
  # https://github.com/danhper/asdf-python

  # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
  sudo apt-get update; sudo apt-get install --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev -y

  asdf plugin-add python

# If you use pip to install a module like ipython that has binaries. You will need to run asdf reshim python for the binary to be in your path.

  return "$?"
}

_in_asdf_lua(){
  # https://github.com/Stratus3D/asdf-lua

  sudo apt-get install linux-headers-$(uname -r) build-essential -y

  asdf plugin-add lua https://github.com/Stratus3D/asdf-lua.git

  return "$?"
}



