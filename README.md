# AppImage build scripts

## Available games:

- [x] SRB2
- [x] SRB2Kart
- [x] SuperTuxKart

## How to build AppImages:

```bash
$ chmod +x script.sh
$ ./script.sh
```

## How to download AppImages:
[Go to releases](https://github.com/4ifi/appimages/releases)

## How to run AppImage:

```bash
$ sudo apt install fuse -y
$ chmod +x AppImage
$ ./AppImage
```

## How to make AppImage fully portable:

```bash
$ ./AppImage --appimage-portable-home
$ ./AppImage --appimage-portable-config
```
