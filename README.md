#  <img src="https://invent.kde.org/mbruchert/powerplant/-/raw/master/logo.png" height=64 >  PowerPlant

A verry WIP app to keep track of your plant's needs

![](https://i.imgur.com/d2rAxUF.png)

## pre built image urls:

`qrc:/assets/monstera.svg`

`qrc:/assets/aloe_vera.svg`

`qrc:/assets/green_lilly.svg`

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


