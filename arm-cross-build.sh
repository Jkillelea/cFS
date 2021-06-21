#!/bin/bash
set -v

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
    lxc exec $CONTAINER_NAME -- apt install -y gcc-5-arm-linux-gnueabihf build-essential make cmake zip unzip tree

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

# push source files to container
make distclean

pushd ../
zip -r cFS.zip cFS/
lxc file push cFS.zip $CONTAINER_NAME/root/
rm cFS.zip
popd

lxc exec $CONTAINER_NAME -- unzip cFS.zip

# compile
lxc exec $CONTAINER_NAME -- ./cFS/cross-build.sh
lxc exec $CONTAINER_NAME -- zip -r crossbuildfiles.zip ./cFS/build/
lxc file pull -r $CONTAINER_NAME/root/crossbuildfiles.zip .
# lxc file pull -r $CONTAINER_NAME/root/cFS/build cross-build-files

# cleanup
lxc stop $CONTAINER_NAME
