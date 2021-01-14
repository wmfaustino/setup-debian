#!/usr/bin/env bash

# sudo apt install curl git

#=== INITIAL TESTS===

#--- script is running with argument(s)

#--- do not run with sudo

###=== VARIABLES ===

# --- asdf default dir
: ${ASDF_DATA_DIR:='$HOME/.asdf'}

# --- bash
_bashrc="${HOME}/.bashrc"

declare -arg bashrc_files_to_source=(
  .\ \""${ASDF_DATA_DIR}/asdf.sh"\"
  .\ \""${ASDF_DATA_DIR}/completions/asdf.bash"\"
)

# exec para pegar a ZDOTDIR
# --- zsh
  _zshrc="${ZDOTDIR:=$HOME/.config/zsh}/.zshrc"

declare -arg  zshrc_files_to_source=(
    .\ \""${ASDF_DATA_DIR}/asdf.sh"\"
    '# append completions to fpath'
    "fpath=(${ASDF_DATA_DIR}/completions $fpath)"
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

 # _setup_config_file "$_bashrc" "${bashrc_files_to_source[@]}"
# _setup_config_file "$_zshrc" "${zshrc_files_to_source[@]}"

echo $ASDF_DATA_DIR

exit



# Plugins
# https://asdf-vm.com/#/plugins-all

_in_asdf_nodejs(){
  # https://github.com/asdf-vm/asdf-nodejs

  local -r dependencies="dirmngr gpg curl"
  local -r asdf_nodejs="https://github.com/asdf-vm/asdf-nodejs.git"

  sudo apt install "$dependencies"

  asdf plugin-add nodejs "$asdf_nodejs"

  bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'

}



go

https://github.com/kennyp/asdf-golang

apt install coreutils
apt install curl

asdf plugin-add golang https://github.com/kennyp/asdf-golang.git

# After using go get to install a package you need to run asdf reshim golang to get any new shims.

rust

https://github.com/code-lever/asdf-rust

asdf plugin-add rust https://github.com/code-lever/asdf-rust.git

# After you have installed rust, do NOT follow the directions it outputs to update your PATH -- asdf's shim will handle that for you!

ruby
https://github.com/asdf-vm/asdf-ruby

asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git

python

https://github.com/danhper/asdf-python

asdf plugin-add python

# If you use pip to install a module like ipython that has binaries. You will need to run asdf reshim python for the binary to be in your path.

https://github.com/pyenv/pyenv/wiki#suggested-build-environment

sudo apt-get update; sudo apt-get install --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
