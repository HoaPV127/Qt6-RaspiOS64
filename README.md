# Prerequisite for host machine

``` bash
sudo apt update
sudo apt install -y \
    build-essential \
    crossbuild-essential-arm64 \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    gdb-multiarch \
    rsync \
    cmake ninja-build


cd <project dir>
export PROJECT_DIR=$(pwd)

```

# Download and extract source
suppose I downloaded qt-everywhere-src-6.9.2.tar.xz from qt official site 
``` bash

tar -xf qt-everywhere-src-6.9.2.tar.xz -C ${PROJECT_DIR}
export QT6_SRC="${PROJECT_DIR}/qt-everywhere-src-6.9.2"

```

# Build for host first

``` bash
mkdir build_host
cd build_host

cmake ${QT6_SRC}$ \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DQT_BUILD_EXAMPLES=OFF \
  -DQT_BUILD_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/qt6-host \
  -DQT_FEATURE_opengl=OFF \
  -DOPENGL_opengl=no \
  -DINPUT_opengl=no \
  -Wno-dev

# or build only qtbase for host
cmake ${QT6_SRC}/qtbase/ \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
    -DQT_FEATURE_opengl=OFF \
    -DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/qt6-host \
    -DINPUT_opengl=no \
    -DOPENGL_opengl=no \
    -DFEATURE_developer_build=ON

cmake --build . -j$(nproc)
cmake --install .
cd ..
```

# RaspiOS64 dependencies
``` bash
# from raspi
sudo apt update
sudo apt install -y \
  libxcb1-dev \
  libxcb-xkb-dev \
  libxcb-xinput-dev \
  libx11-dev \
  libx11-xcb-dev \
  libxrender-dev \
  libxext-dev \
  libxi-dev \
  libxrandr-dev \
  libxfixes-dev \
  libwayland-dev \
  libwayland-client0 \
  libwayland-cursor0 \
  libxkbcommon-dev \
```

# Prepare raspiOS64 sysroot

``` bash
mkdir -p raspiOS_sysroot/usr/include
mkdir -p raspiOS_sysroot/usr/lib
mkdir -p raspiOS_sysroot/lib
mkdir -p raspiOS_sysroot/usr/share

rsync -avz --delete rpi:/usr/include/ ${PROJECT_DIR}/raspiOS_sysroot/usr/include/
rsync -avz --delete rpi:/usr/lib/ ${PROJECT_DIR}/raspiOS_sysroot/usr/lib/
rsync -avz --delete rpi:/lib/ ${PROJECT_DIR}/raspiOS_sysroot/lib/
rsync -avz --delete rpi:/usr/share/pkgconfig/ ${PROJECT_DIR}/raspiOS_sysroot/usr/share/


#then, run fix-sysroot.sh script to fix symbolic link issues
./fix-sysroot.sh raspiOS_sysroot

```


# Build for raspiOS64
``` bash
mkdir -p ~/build-qt6-rpi
cd ~/build-qt6-rpi

# this configuration support both x11 and wayland
cmake ${QT6_SRC} \
  -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE=${PROJECT_DIR}/rpi-aarch64-toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX=/usr/local/qt6pi \
  -DQT_HOST_PATH=${PROJECT_DIR}/qt6-host \
  -DQT_FEATURE_opengles2=ON \
  -DQT_FEATURE_wayland=ON \
  -DQT_FEATURE_xcb=ON \
  -DQT_FEATURE_xcb-xinput=ON \
  -DQT_FEATURE_xcb-xkb=ON \
  -DQT_FEATURE_eglfs=ON \
  -DQT_FEATURE_xkbcommon_x11=ON \
  -DQT_FEATURE_xcb-glx=ON \
  -DQT_BUILD_EXAMPLES=OFF \
  -DQT_BUILD_TESTS=OFF \
  -Wno-dev


cmake --build . -j$(nproc)
DESTDIR=${PROJECT_DIR}/qt6pi-install-on-host cmake --install .
cd ..
```

# Packing

``` bash
cd 
tar tar -cJf ${PROJECT_DIR}/qt6-raspiOS-arm64.tar.xz ${PROJECT_DIR}/qt6pi-install-on-host

```

# Install
now, copy ${PROJECT_DIR}/qt6-raspiOS-arm64.tar.xz to raspi and install 

``` bash
sudo tar -xf /path/to/qt6pi-arm64.tar.xz -C /

```