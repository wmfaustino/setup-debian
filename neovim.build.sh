sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
rm -r build/  # clear the CMake cache
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/home/faustino/.local/builds/neovim"
sudo apt-get install libtool libtool-bin autoconf automake cmake libncurses5-dev g++
sudo make install
export PATH="/home/faustino/.local/builds/neovim/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
