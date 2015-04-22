#!/bin/bash

set -o errexit -o nounset -o pipefail

usage() {
cat << EOF
USAGE:
init-boot2docker.sh -p [path] -u [uid] -g [gid]
-p    Path to the working directory you wish to mount.
-u    The uid you wish to mount the working directory as.
-g    The gid you wish to mount hte working directory as.
-h    This dialog.
EOF
}


#If no arguments are given, print usage and terminate script
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

MP=""
U=""
G=""

while getopts :p:u:g:h key; do
    case $key in
        p)
            if [ -d "$OPTARG" ]; then
                MP="$OPTARG"
            else
                echo "Invalid Directory Path"
                exit 2
            fi
            ;;
        u)
            if [ "$OPTARG" -eq "$OPTARG" ] 2>/dev/null; then
                U="$OPTARG"
            else
                echo "Invalid UID."
                exit 2
            fi
            ;;
        g)
            if [ "$OPTARG" -eq "$OPTARG" ] 2>/dev/null; then
                G="$OPTARG"
            else
                echo "Invalid GID."
                exit 2
            fi
            ;;
        h)
            usage
            exit 1
            ;;
    esac
done

if [ -z "$MP" ] || [ -z "$U" ] || [ -z "$G" ]; then
    echo "All 3 arguments are required."
    usage
    exit 1
fi


# If no boot2docker vm is found, inititialize a new instance
if [ $(vboxmanage list vms | grep -ci 'boot2docker-vm') -ne 1 ]; then
    echo "No boot2docker VM found, initializing a new instance."
    boot2docker init
fi


# Start the vm if it is powered off and set shellinit
if [ $(vboxmanage list runningvms | grep -ci "boot2docker-vm") -ne 1 ]; then
    echo "The boot2docker VM is not running, starting now."
    if [ $(boot2docker start | grep -ci "Started.") -eq 1 ]; then
        $(boot2docker shellinit)
    else
        echo "Error starting boot2docker VM"
        exit 1
    fi
else
    # ensures shellinit is called
    $(boot2docker shellinit)
fi


# Unmounts the default share if it is detected.
if [ $(boot2docker ssh mount | grep vboxsf | awk '{print $3;}') == "/Users" ]; then
    echo "/Users mount deteted, unmounting now."
    boot2docker ssh sudo umount /Users
fi

boot2docker ssh sudo mkdir -p "$MP"
WORKDIR=$(basename "$MP")

vboxmanage sharedfolder add "boot2docker-vm" --name "$WORKDIR" --hostpath "$MP" --transient
boot2docker ssh sudo mount -t vboxsf -o uid="$U",gid="$G" "$WORKDIR" "$MP"
echo "Mount $MP created."
