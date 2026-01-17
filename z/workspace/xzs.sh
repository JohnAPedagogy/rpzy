#!/bin/bash
mkdir -p ~/yocto/build/xzt
cp -r /mnt/c/work/Favorites/artefacts/Repos/rpzy/z/workspace/xzt/conf ~/yocto/build/xzt/conf
. /mnt/c/work/Favorites/artefacts/Repos/rpzy/z/workspace/sources/poky/buildtools/environment-setup-x86_64-pokysdk-linux
. /mnt/c/work/Favorites/artefacts/Repos/rpzy/z/workspace/sources/poky/oe-init-build-env ~/yocto/build/xzt
