Title: virsh-cheat-sheet
Date: 2019-09-14 10:20
Modified: 2019-09-14 10:20
Category: virsh
Tags: virsh,cheat-sheet
Slug: virsh-cheat-sheet
Authors: yjkim 
Summary: virsh,cheat-sheet


# list 
```sh
virsh list 
virsh list --all
```

# start
```sh
virsh start ${vm_id}
```

# machine view 
```sh
virsh dominfo ${vm_id}
```

## machine get domid 
```sh
virsh domid ${vm_nm}
```

## machine get domname 
```sh
virsh domname ${vm_id}
```

# machine down 
```sh
virsh shutdown ${vm_id} 
```

# machine reboot 
```sh
virsh reboot ${vm_id} 
```

# machine remove 
```sh
virsh destroy ${vm_id} 
```

# machine remove 
```sh
virsh undefine ${vm_id}
```

# machine autostart loop
```sh
for i in $$(virsh list --uuid) ; do virsh autostart $i; done
```

# machine create 
```sh
{
    NODE_NAME=provision
    VRAM=1024
    VCPU=2
    OSTYPE=linux
    OSVARIANT=virtio26
    DISK="path=/data/kvm_disk/container-linux/container-linux1.qcow2,format=qcow2,bus=virtio"
    NETWORK="network:ovs-network,mac=52:54:00:fe:b3:c0"
    OUTPUT=/var/lib/libvirt/container-linux/container-linux1/domain.xml

    virt-install 
        --connect qemu:///system \
        --import \
        --name ${NODE_NAME} \
        --ram ${VRAM} \ 
        --vcpus ${VCPU} \
        --os-type=${OSTYPE} \
        --os-variant=${OSVARIANT} \
        --disk ${DISK} \
        --network ${NETWORK}
        --vnc --noautoconsole \
        --print-xml > ${OUTPUT}

    sed -ie 's|type="kvm"|type="kvm" xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0"|' "${OUTPUT}"
    sed -i "/<\/devices>/a <qemu:commandline>\n  <qemu:arg value='-fw_cfg'/>\n  <qemu:arg value='name=opt/com.coreos/config,file=${ignition_file}'/>\n</qemu:commandline>" "${OUTPUT}"

    virsh define ${OUTPUT}
    virsh start ${NODE_NAME}
}
```

# view kvm network command  
```sh
virsh net-list 

virsh net-destroy ${netid | name}

virsh net-edit ${network-name}

virsh net-create ${network-spec-file}
```