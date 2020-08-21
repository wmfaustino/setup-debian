#!/usr/bin/env bash
#----------[ Manage Dotfiles Script] ------------------+
#                                                      |
#  script : dropbox-cli.in.sh                          |
#  author : Wilson Faustino                            |
#  e-mail : <open source (a) wmfaustino dev>           |
#  site   : http://wmfaustino dev                      |
#  version: 1.0.0                                      |
#  date   : 2020-jul-28                                |
#  usage  : ./apt-pkgs.in.sh                           |
#                                                      |
#------------------------------------------------------+
#


# === GLOBAL VARIABLES

# === ABOUT VARIABLES
declare -Arg itSelf=(
  [name]="${0##*/}"
  [version]="1.0.0"
  [date]='2020-jul-28'
)

declare -Arg author=(
  [name]='Wilson Faustino'
  [website]='wmfaustino.dev'
  [email]='open source (a) wmfaustino dev'
  )

# === Source packages
declare -arg dependencies=(
  curl
  libatomic1
	python3
  python3-gpg
  tar
)

declare -Arg dropboxSrcUrl=(
  [daemon]='https://www.dropbox.com/download?plat=lnx.x86_64'
	[cliScript]='https://www.dropbox.com/download?dl=packages/dropbox.py'
)

declare -arg optPkgs=(
	nautilus
	nautilus-dropbox
)

# === Config

declare -rg _DISTRO=$(source /etc/os-release; echo ${NAME%% *})

declare -rg _USER="${SUDO_USER:-$USER}"
# using sudo makes HOME /root
# _HOME makes sure dropbox will be installed at actual user's HOME
declare -rg _HOME="/home/${_USER}"
declare -rg _USR_LOCAL_BIN='/usr/local/bin'

# =========================================================
# === KEYS
# =========================================================

declare -Ag installKeys=(
	[dependencies]=0
	[optPkgs]=0
)

# =========================================================
# === ENTRY POINT
# =========================================================

_main(){
  
	_suCheck # Check if user is a super user
	
	(( "${installKeys[dependencies]}" == 1 )) && \
    _installFromApt "${dependencies[@]}"
  _checkInstallStatus "${?}" 'Dependencies'

	(( "${installKeys[optPkgs]}" == 1 )) && \
    _installFromApt "${optPkgs[@]}"
  _checkInstallStatus "${?}" 'Optional Packages'
  
  # headless dropbox install
  _installDropboxDaemon # && _installControlScript
  _checkInstallStatus "${?}" 'Dropbox CLI'

	exit 0 
}

# =========================================================
# === FUNCTIONS
# =========================================================

# Shows all options provided by this program ---------------
function _usage(){
  cat <<EOF
    
    USAGE: ${itSelf[name]} [OPTIONS]
     
    OPTIONS:
      -i, --dropbox-cli   Install only dropbox cli
      -D, --dependencies  Install only dependencies
      -O, --optional-pkgs Install helpfull packages to manage fonts
      -y, --install-all   Install dropbox cli, dependencies and optional packages
      
      -V, --version       Prints version
      -h, --help          Prints this message
    
    EXEMPLES:
      $ ./${itSelf[name]} --install-all
      $ ./${itSelf[name]} -DO
  
    Dependencies: "${dependencies[*]}"
    Optional Pakages: "${optPkgs[*]}"
    
    * ${author[name]} - <${author[email]}> - ${itSelf[name]} V. ${itSelf[version]}
EOF

  exit 0
}

# Prints version's number, date and author ------------------
function _printVersion(){

  cat <<EOF
    ${itSelf[name]} - version: ${itSelf[version]}
    updated: ${itSelf[date]} by ${author[name]}
EOF

  exit 0
}

function _printAbout(){
  cat <<EOF
  The official dropbox cli client contains two packages:
    1- dropbox daemon
    2- dropbox python control script
    Source: https://www.dropbox.com/install
    ${itSelf[name]} is a script that automatize those two official packages installation.
    
    Beyond that, ${itSelf[name]} also gives the option to install dependencies and optional packages (directly from apt official repositories).
     
EOF

  exit 0
}

# --------------------------------------
########################################
# --------------------------------------

function _suCheck(){
	
	local -r suErrMsg="\nYou need superpowers.\n\nTry it again as root user or use sudo.\n"

	(( "$EUID" !=0 )) && echo -e "$suErrMsg" && exit 1

	return 0
}

# --------------------------------------

function _checkInstallStatus(){
       
       # ${1} == ${?}
  if (( "${1}" != 0 )); then
    printf "\n\n%s\n\n\n" "Error installing ${2}" && return "${1}"
  else
    printf "\n\n%s\n\n\n" "${2} successfully installed" && return 0
  fi
}

# --------------------------------------
########################################
# --------------------------------------

function _installDropboxDaemon()(
	
  cd "${_HOME}"
  
  [[ -d '.dropbox-dist' ]] && rm -rf '.dropbox-dist'

	curl -L "${dropboxSrcUrl[daemon]}" | tar xzf -

	return "${?}"
)

# --------------------------------------
# dropbox.py (official dropbox cli script)
#function _installControlScript()(
#  
#  local dropboxPy="${dropboxSrcUrl[cliScript]##*/}"
#    
#  cd "${_USR_LOCAL_BIN}"
#    
#  curl -LO "${dropboxSrcUrl[cliScript]}"
#	chmod "$((771))" "${dropboxPy}"
#	
#  return "${?}"
#)
#
# --------------------------------------
function _installFromApt(){
  # install dependencies and optional packages
	( IFS=$'\n'; apt install "${@}" -y )

	return "${?}"
}

# =========================================================
# === START INSTALLATION
# =========================================================

(( "${#}" == 0 )) && _usage

ARGS=$(getopt \
  --options iDOyVha \
  --longoptions "dropbox-cli,dependencies,optional-pkgs,install-all,version,help,about" \
  --name "${itSelf[name]}" \
  -- "$@" \
  2> /dev/null
)

# Bad arguments
(( "${?}" != 0 )) && {
  echo "Invalid option: ${1}";
  exit 1;
}

eval set -- "$ARGS";

while true; do
  case "${1}" in
    -i|--dropbox-cli  )            shift ; continue;;
    -D|--dependencies )
			installKeys[dependencies]=1; shift ; continue;;
    -O|--optional-pkgs)
			installKeys[optPkgs]=1     ; shift ; continue;;
    -y|--install-all  )
      installKeys[dependencies]=1        ;
      installKeys[optPkgs]=1             ;
      _main                      ; break           ;;
    -V|--version  ) _printVersion        ;  exit 0 ;;
    -h|--help     ) _usage               ;  exit 0 ;; 
    --            ) shift                ;  break  ;;
    *             ) echo 'Invalid option';  exit 1 ;;
  esac
done

_main
