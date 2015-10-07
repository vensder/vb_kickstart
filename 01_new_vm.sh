#!/bin/bash

set -ex

VBOX=`which VirtualBox`
VBOXMANAGE=`which VBoxManage`
VBOXBASE="${HOME}/VirtualBox VMs"

# The name of your VM
VM="centos7"
if [ "$1" ]; then
    VM=$1
fi

#if VM exists
if ${VBOXMANAGE} list vms | grep ${VM};  then
    ${VBOXMANAGE} unregistervm $VM --delete;
fi

VBOXINFO="${VBOXMANAGE} showvminfo ${VM}"

#Create the VM
${VBOXMANAGE} createvm --name "${VM}" --ostype "Linux_64" --register
${VBOXMANAGE} createhd --filename "${VBOXBASE}/${VM}/${VM}.vdi" --size 8192
${VBOXMANAGE} storagectl "${VM}" --name "SATA Controller" --add sata --controller IntelAHCI
${VBOXMANAGE} storageattach "${VM}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VBOXBASE}/${VM}/${VM}.vdi"

${VBOXMANAGE} modifyvm "${VM}" --memory 1024
${VBOXMANAGE} modifyvm "${VM}" --boot4 net
${VBOXMANAGE} modifyvm "${VM}" --macaddress1 08002786CE3E

## Start it up
#${VBOX} --startvm "${VM}"


