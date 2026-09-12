<!--
SPDX-FileCopyrightText: none
SPDX-License-Identifier: CC0-1.0
-->

# <img src="org.kde.powerplant.svg" height=48>  PowerPlant

An app to keep track of your plant's needs
![Screenshots of Powerplant](https://cdn.kde.org/screenshots/powerplant/powerplant.png)

### Nightly Versions
#### Flatpak

```bash
flatpak install https://cdn.kde.org/flatpak/powerplant-nightly/org.kde.powerplant.flatpakref
```
#### Android
Available on F-Droid with the [KDE F-Droid Nightly Build Repository](https://community.kde.org/Android/F-Droid#KDE_F-Droid_Nightly_Build_Repository).

## Build Instructions

### Flatpak Builder (with KDE Sdk)
```
flatpak-builder tmp --force-clean --ccache --install --user .flatpak-manifest.json
```
### CMake
```
mkdir build
cd build
cmake ..
make
```


