#!/usr/bin/env bash

# Test if user has root access
[[ "$EUID" -ne 0 ]] && echo "Please run as root" && exit 1

# Variables
appDownloadLink='https://dl.pstmn.io/download/latest/linux64'
appTarball='/tmp/postman-linux-x64.tar.gz'
installDir='/opt'
desktopEntryFile='/usr/share/applications/postman.desktop'

# Remove previous instalation
shopt -s nocasematch

rm -rf /opt/postman*

shopt -u nocasematch

# Get Postman tarball
curl -4L "$appDownloadLink" -o "$appTarball"

# Install Postman 
tar -xvzf "$appTarball" -C "$installDir"

# Create desktop menu
tee > /dev/null <<EOF > "$desktopEntryFile"
[Desktop Entry]
Encoding=UTF-8
Name=Postman
GenericName=API Client
X-GNOME-FullName=Postman API Client
Comment=Postman desktop client; Make and view REST API requests and responses;
Keywords=rest;api;http;request;response;
Exec=/opt/Postman/Postman
Terminal=false
Type=Application
Icon=/opt/Postman/app/resources/app/assets/icon.png
Categories=Development;Utilities;Code;
EOF

# End of script
exit "$?"
