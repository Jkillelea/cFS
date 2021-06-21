#!/bin/bash
# set -v

IMAGE_SOURCE="ubuntu:x"
CONTAINER_NAME="crossbuilder"
SNAPSHOT_NAME="buildtoolsinstalled"

# clean up files
rm -rf ./crossbuildfiles.zip

container_exists() {
    lxc info $CONTAINER_NAME
    if [ $? -eq 0 ]; then
        exists=1
    else
        exists=0
    fi
}

is_running() {
    info=$(lxc info $CONTAINER_NAME | grep Status)
    if [ "$info" = "Status: Stopped" ]; then
        running=0
    else
        running=1
    fi
}

remove_container() {
    # clean up old container
    lxc stop $CONTAINER_NAME
    lxc delete $CONTAINER_NAME
}

launch_container() {
    # launch new container
    echo "Launching"
    lxc launch ubuntu:x $CONTAINER_NAME

    # install needed packages
    echo "Updating and installing packages"
    lxc exec $CONTAINER_NAME -- apt update
    lxc exec $CONTAINER_NAME -- apt upgrade -y --fix-missing
    lxc exec $CONTAINER_NAME -- apt autoremove -y
    lxc exec $CONTAINER_NAME -- apt update
    lxc exec $CONTAINER_NAME -- apt install -y gcc-5-arm-linux-gnueabihf build-essential make cmake

    echo "Snapshotting for future use"
    lxc snapshot $CONTAINER_NAME $SNAPSHOT_NAME
}

container_exists
if [ $exists -eq 0 ]; then
    echo "Container doesn't exist, starting"
    launch_container
else
    echo "Container exists, restoring"
    is_running
    if [ $running -eq 1 ]; then
        echo "Stopping"
        lxc stop $CONTAINER_NAME
    fi
    echo "Restoring snapshot"
    lxc restore $CONTAINER_NAME $SNAPSHOT_NAME
    echo "Starting"
    lxc start $CONTAINER_NAME
fi

set -e

# push source files to container
make distclean

echo "Packaging files"
pushd ../
tar cf cFS.tar cFS
lxc file push cFS.tar $CONTAINER_NAME/root/
rm cFS.tar
popd

echo "Unpackaging files"
lxc exec $CONTAINER_NAME -- tar xf cFS.tar

# compile
echo "Compiling in container"
lxc exec $CONTAINER_NAME -- ./cFS/cross-build.sh

echo "Pulling files"
lxc file pull -r $CONTAINER_NAME/root/cFS/build .

# cleanup
echo "Stopping container"
lxc stop $CONTAINER_NAME
