#!/bin/bash
# set -v

source arm-build-vars.sh

container_exists() {
    if [ -z "$(lxc list -c n --format csv | grep $CONTAINER_NAME)" ]; then
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

add_packages() {

    lxc exec $CONTAINER_NAME -- apt update
    while [ $? != 0 ]; do
        lxc exec $CONTAINER_NAME -- apt update
        sleep 3
    done

    lxc exec $CONTAINER_NAME -- apt install -y gcc-5-arm-linux-gnueabihf build-essential make cmake
    while [ $? != 0 ]; do
        lxc exec $CONTAINER_NAME -- apt update
        lxc exec $CONTAINER_NAME -- apt install -y gcc-5-arm-linux-gnueabihf build-essential make cmake --fix-missing
        sleep 10
    done

    lxc exec $CONTAINER_NAME -- apt upgrade -y
    while [ $? != 0 ]; do
        lxc exec $CONTAINER_NAME -- apt update
        sleep 1
        lxc exec $CONTAINER_NAME -- apt upgrade -y --fix-missing
        sleep 1
    done

    lxc exec $CONTAINER_NAME -- apt autoremove -y

}

launch_container() {
    # launch new container
    echo "Launching"
    lxc launch ubuntu:x $CONTAINER_NAME

    # Wait for network interface to update
    echo "Waiting for networ interfaces to come up..."
    lxc exec $CONTAINER_NAME -- bash -c 'while [ "$(systemctl is-system-running 2>/dev/null)" != "running" ] && [ "$(systemctl is-system-running 2>/dev/null)" != "degraded" ]; do :; done'

    # install needed packages
    echo "Updating and installing packages"
    add_packages

    echo "mapping source files into container"
    lxc config device add $CONTAINER_NAME source_files_disk disk source="$(pwd)" path=/root/cFS

    echo "Snapshotting for future use"
    lxc snapshot $CONTAINER_NAME $SNAPSHOT_NAME
}

cd "$(dirname $0)"

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

# compile
echo "Compiling in container"
lxc exec $CONTAINER_NAME -- ./cFS/cross-build.sh

echo "Pulling files"
if [ -d "$MISSIONCONFIG" ]; then
    rm -r "$MISSIONCONFIG"
fi
lxc file pull -r $CONTAINER_NAME/root/$MISSIONCONFIG .

# cleanup
echo "Stopping container"

lxc stop $CONTAINER_NAME
