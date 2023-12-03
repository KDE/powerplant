#  <img src="https://invent.kde.org/mbruchert/powerplant/-/raw/master/logo.png" height=64 >  PowerPlant

A very WIP app to keep track of your plant's needs

![](https://i.imgur.com/17qanPl.png)


## Build Instructions

### Flatpak Builder (with KDE Sdk)
```
flatpak-builder tmp --force-clean --ccache --install --user org.kde.powerplant.json
```
### CMake
```
mkdir build
cd build
cmake ..
make
```


