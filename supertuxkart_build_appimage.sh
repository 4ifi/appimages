# download SuperTuxKart with dependencies
sudo apt update
sudo apt install curl fuse tar xz-utils
date=$(date +"%x %R:%S")
mkdir "SuperTuxKart AppImage $date"
cd "SuperTuxKart AppImage $date"
mkdir build && cd build
curl --retry 9999 --retry-delay 3 --speed-time 10 --retry-max-time 0 -C - -A "Linux $(uname -m)" -L https://sourceforge.net/projects/supertuxkart/files/latest/download -o data.tar.xz
tar -xvf data.tar.xz
rm data.tar.xz
mv * AppDir
cd AppDir
if [[ $(uname -m) =~ "64" ]]
then
rm -rf `ls | grep -v "bin-64\|data\|lib-64"`
else
rm -rf `ls | grep -v "bin\|data\|lib"`
fi
cd ..

# Create desktop file
cat > app.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=SuperTuxKart
Comment=A kart racing game
Icon=icon
Exec=AppRun %F
Categories=Game;
EOF

# Get app icon
#cp AppDir/data/supertuxkart_128.png icon.png
touch icon.png

# create app entrypoint
echo -e \#\!$(dirname $SHELL)/sh >> AppDir/AppRun
echo -e 'export DIRNAME="$(dirname "$(readlink -f "$0")")"' >> AppDir/AppRun
echo -e 'export MACHINE_TYPE=`uname -m`' >> AppDir/AppRun
echo -e 'export SYSTEM_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"' >> AppDir/AppRun
echo -e 'export SUPERTUXKART_DATADIR="$DIRNAME"' >> AppDir/AppRun
echo -e 'export SUPERTUXKART_ASSETS_DIR="$DIRNAME/data/"' >> AppDir/AppRun
echo -e 'cd "$DIRNAME"' >> AppDir/AppRun
if [[ $(uname -m) =~ "64" ]]
then
echo -e 'export LD_LIBRARY_PATH="$DIRNAME/lib-64:$LD_LIBRARY_PATH"' >> AppDir/AppRun
echo -e '"$DIRNAME/bin-64/supertuxkart" "$@"' >> AppDir/AppRun
else
echo -e 'export LD_LIBRARY_PATH="$DIRNAME/lib:$LD_LIBRARY_PATH"' >> AppDir/AppRun
echo -e '"$DIRNAME/bin/supertuxkart" "$@"' >> AppDir/AppRun
fi
chmod +x AppDir/AppRun

# Build AppImage
curl --retry 9999 --retry-delay 3 --speed-time 10 --retry-max-time 0 -C - -L https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$(uname -m).AppImage -o linuxdeploy
chmod +x linuxdeploy
./linuxdeploy --appdir AppDir --output appimage -d app.desktop -i icon.png

# clean
mv *.AppImage ../
cd ..
rm -rf build
