#!/bin/bash

# Script to create a fake libpython3.10 package to satisfy dependencies

set -e

echo "Installing equivs package builder..."
sudo apt install -y equivs

echo "Creating fake libpython3.10 package directory..."
mkdir -p /tmp/libpython3.10-fake
cd /tmp/libpython3.10-fake

echo "Creating package control file..."
cat > libpython3.10-fake << 'EOF'
Section: misc
Priority: optional
Package: libpython3.10
Version: 3.10.0-1
Architecture: amd64
Depends: libpython3.12
Description: Fake libpython3.10 package to satisfy dependencies
 This is a fake package that depends on libpython3.12 to satisfy
 the libpython3.10 dependency for OSELAS toolchain.
EOF

echo "Building fake package..."
equivs-build libpython3.10-fake

echo "Installing fake package..."
sudo dpkg -i libpython3.10_3.10.0-1_amd64.deb

echo "Cleaning up..."
cd /tmp
rm -rf /tmp/libpython3.10-fake

echo "Fake libpython3.10 package installed successfully!"
echo "You can now try installing the OSELAS toolchain:"
echo "sudo apt install -y oselas.toolchain-2024.11.1-arm-v7a-linux-gnueabihf-gcc-14.2.1-clang-19.1.7-glibc-2.40-binutils-2.43.1-kernel-6.11.6-sanitized"