# Yocto Build Tutorial - RPZ Image

## Overview
This guide documents the complete process for building the RPZ image using Yocto Project (Scarhgap 5.0 LTS).

## Prerequisites
- Linux development environment
- At least 50GB free disk space
- Sufficient RAM (8GB recommended)
- Internet connection for downloading sources

## Repository Setup

### 1. Create Workspace Structure
```
workspace/
├── sources/
│   ├── poky/
│   ├── meta-openembedded/
│   └── meta-raspberrypi/
└── rpz/
    └── conf/
        ├── bblayers.conf
        └── local.conf
```

### 2. Clone Repositories

Initialize the sources directory:

```bash
# Clone Poky (Yocto Project reference distribution)
cd sources
git clone git://git.yoctoproject.org/poky.git
cd poky
git checkout scarthgap
cd ..

# Clone meta-openembedded (additional metadata layers)
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout scarthgap
cd ..

# Clone meta-raspberrypi (Raspberry Pi BSP)
git clone https://github.com/agherzan/meta-raspberrypi.git
cd meta-raspberrypi
git checkout scarthgap
cd ..
```

### 3. Branch Configuration

All repositories are set to use the **scarthgap** branch:
- **scarthgap** = Yocto Project 5.0 LTS (Long Term Support)
- Current version: yocto-5.0.14

To verify branches:
```bash
cd sources/meta-openembedded && git branch --show-current
cd sources/meta-raspberrypi && git branch --show-current
cd sources/poky && git branch --show-current
```

Expected output: `scarthgap` for all three repositories

## Build Configuration

### 1. Build Directory Setup

The build directory is `rpz/` with configuration in `rpz/conf/`:

- **bblayers.conf**: Defines which metadata layers are included
- **local.conf**: Local build configuration settings

### 2. bblayers.conf Configuration

Located at `rpz/conf/bblayers.conf`:

```
BBLAYERS ?= " \
  /opt/yocto/workspace/sources/poky/meta \
  /opt/yocto/workspace/sources/poky/meta-poky \
  /opt/yocto/workspace/sources/poky/meta-yocto-bsp \
  "
```

### 3. local.conf Configuration

Located at `rpz/conf/local.conf`:

Key settings:
- `MACHINE ??= "qemux86"` - Target machine (default)
- `DL_DIR ?= "/opt/yocto/cache/downloads"` - Download cache location
- `SSTATE_DIR ?= "/opt/yocto/cache/sstate-cache"` - Shared state cache location
- `DISTRO ?= "poky"` - Distribution configuration
- `PACKAGE_CLASSES ?= "package_rpm"` - Package format
- `EXTRA_IMAGE_FEATURES ?= "debug-tweaks"` - Development features (empty root password, etc.)

## Building the Image

### 1. Initialize Build Environment

```bash
cd /opt/yocto/workspace
source sources/poky/oe-init-build-env rpz
```

This sets up the environment and uses `rpz` as the build directory.

### 2. Start the Build

Build the default core image:

```bash
bitbake core-image-minimal
```

Or build other available images:
- `core-image-minimal` - Minimal bootable image
- `core-image-full-cmdline` - Image with full command line tools
- `core-image-base` - Base image with additional packages
- `core-image-sato` - Image with Sato GUI

### 3. Build Process

The build process will:
1. Download source tarballs to `DL_DIR`
2. Extract and compile packages
3. Generate shared state cache in `SSTATE_DIR`
4. Create root filesystem images
5. Build bootloader and kernel
6. Generate final output images

Typical build time: 30 minutes to several hours (depending on hardware and network speed)

## Build Output

After successful build, output images are located in:

```
rpz/tmp/deploy/images/<MACHINE>/
```

Common output files:
- `core-image-minimal-<MACHINE>.ext4` - Root filesystem image
- `core-image-minimal-<MACHINE>.cpio.gz` - Initramfs image
- `core-image-minimal-<MACHINE>.tar.bz2` - Compressed root filesystem
- `bzImage` - Linux kernel
- `*.rpi-sdimg` - SD card image (for Raspberry Pi targets)

## Common Commands

### Cleaning Build

```bash
# Clean specific package
bitbake -c clean <package>

# Clean all for specific package
bitbake -c cleansstate <package>

# Clean entire build
bitbake -c cleanall <package>
```

### Development Tasks

```bash
# Extract source code for development
bitbake -c devshell <package>

# Configure package interactively
bitbake -c menuconfig virtual/kernel

# Rebuild specific package
bitbake -c compile -f <package>
```

### Build Statistics

View build statistics:
```bash
cat rpz/tmp/buildstats/*/build_stats
```

## Troubleshooting

### Disk Space Issues
If build fails due to low disk space:
1. Clean sstate-cache: `rm -rf /opt/yocto/cache/sstate-cache/*`
2. Clean downloads: `rm -rf /opt/yocto/cache/downloads/*`
3. Clean temporary build files: `rm -rf rpz/tmp/*`

### Network Issues
If downloads fail:
1. Check DL_DIR permissions
2. Verify network connectivity
3. Use mirror sources if primary source is slow

### Layer Issues
To add additional layers (e.g., meta-openembedded, meta-raspberrypi):

1. Add to bblayers.conf:
```
BBLAYERS ?= " \
  /opt/yocto/workspace/sources/poky/meta \
  /opt/yocto/workspace/sources/poky/meta-poky \
  /opt/yocto/workspace/sources/poky/meta-yocto-bsp \
  /opt/yocto/workspace/sources/meta-openembedded/meta-oe \
  /opt/yocto/workspace/sources/meta-openembedded/meta-python \
  /opt/yocto/workspace/sources/meta-openembedded/meta-networking \
  /opt/yocto/workspace/sources/meta-raspberrypi \
  "
```

2. Rebuild as needed

## Version Summary

- **Yocto Project Version**: 5.0 (Scarhgap)
- **Branch**: scarthgap
- **LTS**: Yes (Long Term Support)
- **Release Date**: April 2024
- **EOL Date**: April 2028
- **Current Tag**: yocto-5.0.14

## Notes

- Build paths use `/opt/yocto/workspace` - adjust if your workspace is different
- Cache directories are shared across builds to improve performance
- First build takes longest due to downloading all sources
- Subsequent builds are faster if configuration doesn't change
