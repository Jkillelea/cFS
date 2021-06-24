#!/bin/bash
# set -v

source arm-build-vars.sh

container_exists() {
    # lxc info $CONTAINER_NAME
    # if [ $? -eq 0 ]; then

    if [ -z "lxc list -c n --format csv | grep $CONTAINER_NAME" ]; then
        exists=0
    else
        exists=1
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

    # Wait for network interface to update
    lxc exec $CONTAINER_NAME -- apt update
    while [ "$?" -ne "0" ]; do
        lxc exec $CONTAINER_NAME -- apt update
    done

    lxc exec $CONTAINER_NAME -- apt upgrade -y
    lxc exec $CONTAINER_NAME -- apt autoremove -y
    lxc exec $CONTAINER_NAME -- apt update

    lxc exec $CONTAINER_NAME -- apt install --fix-missing -y gcc-5-arm-linux-gnueabihf build-essential make cmake
    while [ "$?" -ne "0" ]; do
        lxc exec $CONTAINER_NAME -- apt install --fix-missing -y gcc-5-arm-linux-gnueabihf build-essential make cmake
    done

    echo "mapping source files into container"
    lxc config device add $CONTAINER_NAME source_files_disk disk source="$(pwd)" path=/root/cFS

    echo "Snapshotting for future use"
    lxc snapshot $CONTAINER_NAME $SNAPSHOT_NAME
}

cd "$(dirname $0)"

# container_exists
# if [ $exists -eq 0 ]; then
#     echo "Container doesn't exist, starting"
#     launch_container
# else
#     echo "Container exists, restoring"
#     is_running
#     if [ $running -eq 1 ]; then
#         echo "Stopping"
#         lxc stop $CONTAINER_NAME
#     fi
#     echo "Restoring snapshot"
#     lxc restore $CONTAINER_NAME $SNAPSHOT_NAME
#     echo "Starting"
#     lxc start $CONTAINER_NAME
# fi

remove_container

set -e

launch_container

# push source files to container
make distclean

# compile
echo "Compiling in container"
lxc exec $CONTAINER_NAME -- ./cFS/cross-build.sh

echo "Pulling files"
rm -r "$MISSIONCONFIG"
lxc file pull -r $CONTAINER_NAME/root/$MISSIONCONFIG .

# cleanup
echo "Stopping container"

lxc stop $CONTAINER_NAME
