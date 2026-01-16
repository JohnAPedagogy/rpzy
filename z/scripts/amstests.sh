#!/bin/bash

# Check if IP suffix argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <ip_suffix>"
    echo "Example: $0 142  # Deploys to 172.16.100.142"
    exit 1
fi

IP_SUFFIX=$1
TARGET_IP="172.16.100.${IP_SUFFIX}"

echo "Building and deploying AMS tests to ${TARGET_IP}..."

# Navigate to build directory
mkdir -p ~/ptx/../build
cd ~/ptx/../build

# Source environment and build
echo "Building tests with cross-compilation environment..."
/opt/qt5/qt5.5.1/bin/qmake ../ert4/local_src/ipt4-daemon/amstests.pro
source ../ert4/scripts/ptxenv.sh && make

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed"
    exit 1
fi

echo "Build successful, deploying to ${TARGET_IP}..."

# Deploy binary to target device
scp amstests root@${TARGET_IP}:/sbin/

if [ $? -ne 0 ]; then
    echo "ERROR: Deployment failed"
    exit 1
fi

echo "Deployment successful, running tests on ${TARGET_IP}..."

# Run tests on target device
ssh root@${TARGET_IP} "chmod +x /sbin/amstests && /sbin/amstests"

if [ $? -ne 0 ]; then
    echo "ERROR: Test execution failed or tests failed"
    exit 1
fi

echo "AMS tests completed successfully!"