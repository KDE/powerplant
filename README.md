<!--
SPDX-FileCopyrightText: none
SPDX-License-Identifier: CC0-1.0
-->

# <img src="https://invent.kde.org/utilities/powerplant/-/raw/master/logo.png" height=64 >  PowerPlant

An app to keep track of your plant's needs

![](https://cdn.kde.org/screenshots/powerplant/powerplant.png)

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


