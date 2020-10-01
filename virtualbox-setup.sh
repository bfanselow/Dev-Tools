#!/bin/bash
##############################################################################################
# Create a new VirtualBox VM using local ISO image
#
# This will create, register and configure the VM.
# Install the guest OS happens on the first startup: sudo vboxmanage startvm ${VM_NAME}
#
#
# USEFUL COMMANDS once VM is up
#  * start VM(headless): sudo vboxmanage startvm $VM --type headless
#  * stop VM: sudo vboxmanage controlvm $VM savestate
#  * ssh into VM: ssh -p 2222 ${VMUSER}@localhost"
#
##############################################################################################
# Change these variables as needed
VM_NAME="UbuntuServer-dev1"
ISO_PATH=~/Desktop/ubuntu-18.04.5-live-server-amd64.iso
VM_HD_PATH="${VM_NAME}.vdi" # The path to VM hard disk (to be created).
SHARED_PATH=~/VMShare/${VM_NAME} # Share home directory with the VM

DISK_SIZE_MB=50000
MEMORY_MB=8000

# setup
mkdir -p $SHARED_PATH

##
## start building
##

## Create and register the VM
vboxmanage createvm --name $VM_NAME --ostype Ubuntu_64 --register


## Create virtual disk 
vboxmanage createhd --filename $VM_NAME.vdi --size $DISK_SIZE_MB 
#vboxmanage createhd --filename $VM_NAME.vdi --size $DISK_SIZE_MB --variant Fixed 

## Add controllers
vboxmanage storagectl $VM_NAME --name "SATA Controller" --add sata --controller IntelAHCI
vboxmanage storageattach $VM_NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $VM_HD_PATH
vboxmanage storagectl $VM_NAME --name "IDE Controller" --add ide
vboxmanage storageattach $VM_NAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $ISO_PATH

## ??
vboxmanage modifyvm $VM_NAME --ioapic on
vboxmanage modifyvm $VM_NAME --memory $MEMORY_MB --vram 128
vboxmanage modifyvm $VM_NAME --nic1 nat

## Port forward 2222-->VM:22
vboxmanage modifyvm $VM_NAME --natpf1 "guestssh,tcp,,2222,,22"

## Port forward 127.0.0.1:8080-->VM:80
# VBoxManage modifyvm $VM_NAME --natpf1 "guesthttp,tcp,,8080,,80"

## ??
vboxmanage modifyvm $VM_NAME --natdnshostresolver1 on

## Shared folders (with host OS)
vboxmanage sharedfolder add $VM_NAME --name shared --hostpath $SHARED_PATH --automount

##
Final messages
echo ""
echo "To install OS: $ sudo vboxmanage startvm ${VM_NAME}"
