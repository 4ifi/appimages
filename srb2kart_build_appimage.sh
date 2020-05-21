# download SRB2 with dependencies
sudo apt update
sudo apt install git gcc cmake curl p7zip-full build-essential nasm fuse libupnp-dev libgl1-mesa-dev libcurl4-openssl-dev zlib1g-dev libgme-dev libopenmpt-dev libsdl2-dev libpng-dev libsdl2-mixer-dev -y
date=$(date +"%x %R:%S")
mkdir "SRB2Kart AppImage $date"
cd "SRB2Kart AppImage $date"
git clone https://github.com/STJr/Kart-Public
cd Kart-Public
tag=$(git describe --tags $(git rev-list --tags --max-count=1))
version=$(curl -s https://api.github.com/repos/STJr/Kart-Public/releases/latest | grep "tarball_url" | sed 's/^.*Kart_Public_//' | sed 's/[^0-9]*//g')
mkdir tmp
mkdir assets/installer
cd tmp
apt download libjack-jackd2-0
dpkg-deb -x libjack-jackd2-0*.deb jack
curl --retry 9999 --retry-delay 3 --speed-time 10 --retry-max-time 0 -C - -L https://github.com/STJr/Kart-Public/releases/download/$(echo $tag)/srb2kart-v$(echo $version)-Installer.exe -o installer.exe
curl --retry 9999 --retry-delay 3 --speed-time 10 --retry-max-time 0 -C - -L https://github.com/STJr/Kart-Public/releases/download/$(echo $tag)/srb2kart-v$(echo $version)-Patch.zip -o patch.zip
7z x installer.exe
7z x -y patch.zip
mv mdls *.dat *.kart *.srb ../assets/installer/
cd ..

# build the application
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/bin -DSDL2_INCLUDE_DIR=../libs/SDL2/include
make -j$((`nproc`+1)) install DESTDIR=AppDir

# Create desktop file
cat > app.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=SRB2Kart
Comment=Open Source 3D Game
Icon=icon
Exec=AppRun %F
Categories=Game;
EOF

# Get app icon
cp ../src/sdl/SRB2Pandora/icon.png .
# create app entrypoint
echo -e \#\!$(dirname $SHELL)/sh >> AppDir/AppRun
echo -e 'HERE="$(dirname "$(readlink -f "${0}")")"' >> AppDir/AppRun
cd AppDir/usr/bin
file=$(ls srb2kart-*)
cd ../../..
echo -e 'SRB2WADDIR=$HERE/usr/bin LD_LIBRARY_PATH=$HERE/usr/lib:$LD_LIBRARY_PATH exec $HERE/usr/bin/'$file' -opengl "$@"' >> AppDir/AppRun
chmod +x AppDir/AppRun

# Build AppImage
mkdir AppDir/usr/lib
cp ../tmp/jack/usr/lib/*/libjack.so.0.* AppDir/usr/lib/libjack.so.0
curl --retry 9999 --retry-delay 3 --speed-time 10 --retry-max-time 0 -C - -L https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$(uname -m).AppImage -o linuxdeploy
chmod +x linuxdeploy
./linuxdeploy --appdir AppDir --output appimage -d app.desktop -i icon.png

# clean
mv *.AppImage ../../
cd ../..
rm -rf Kart-Public
