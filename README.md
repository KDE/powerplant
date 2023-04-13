#  <img src="https://invent.kde.org/mbruchert/powerplant/-/raw/master/logo.png" height=64 >  PowerPlant

A verry WIP app to keep track of your plant's needs

![](https://i.imgur.com/17qanPl.png)


## build instructions

### flatpak builder (with kde sdk)
```
flatpak-builder tmp --force-clean --ccache --install --user org.kde.powerplant.json
```
### cmake
```
mkdir build
cd build
cmake ..
make
```


