---
date: 2020-06-19T10:58:08-04:00
description: "cloud-init basic usage"
tags: ["cloudinit", "provisioning"]
categories: "cloudinit"
title: "cloud-init 을 이용한 간단한 KVM 배포 시나리오 "
---

# todo list

- [ ] check exists cloud image 
- [ ] if image is dont exitst try download cloud image ans extract image 
- [X] check exists vm file, if exists purge files 
- [X] generate new user-data, meta-data 
- [X] generate ci-image file
- [X] create vm  

### 설명 

* 아래 스크립트 대로 실행하면 
  * 인증 : ssh passwd 인증 root, yjkim1
  * 인증 : ssh-authorized-key 인증, yjkim1 -> sudo 하셔서 다음 작업하시면 됨 
* metadata 
  * static ip 정의 방법 까지는 테스트 해서 돌아가는것  확인 되었음 
  * cloud-init 20.02 버전의 latest 상태이며 
  * network 정의 방식이 nodatasource 의 레거시 정의방식은 잘되는것 확인 
  * version2 는 netplan 방식이다보니 안되는듯 함 
  * version1 도 해보니 안됨, 추가 디버깅 필요 
  * hostname 세팅도 잘되고 있음 


```sh 


> ls -al template
-rwxrwxrwx 1 root root 858783744  6월 20 00:56 CentOS-7-x86_64-GenericCloud-2003.qcow2
-rwxrwxrwx 1 root root       206  6월 20 12:41 meta-data
-rwxrwxrwx 1 root root      1117  6월 20 12:00 user-data

> cat template/user-data
#cloud-config
users:
  - name: yjkim1
    passwd: $6$5Z0nx4BSLgORhjka$tTGRJQi9cdh8a3tNVfrWCl1gHT9/t0jGQtZ3D4Ksm5ytDu2FXIubiIqalFm8dkO8Z/N4ilZP4EH3FG5IUfxNu/
    groups: wheel
    lock_passwd: false
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-rsa AAAAB3Nz

    # yjkim1:admin1234 
    # ssh-auth token 은 local 의 ssh key 이다. ssh-keygen -> ~/.ssh/idrsa.pub

ssh_pwauth: false
disable_root: false
chpasswd:
  list: |
     root:admin1234
  expire: False

# Remove cloud-init
runcmd:
#  - yum -y remove cloud-init
#  - updatedb

# Configure where output will go
output:
  all: ">> /var/log/cloud-init.log"
# EOF 

> cat template/meta-data
instance-id: kf0
local-hostname: kf0

network:
  version: 1
  config:
  - id: eth0
    mtu: 1500
    name: eth0
    subnets:
    - address: 192.168.122.14/24
      gateway: 192.168.122.1
      type: static
# EOF

> cat create-vm.sh
#!/bin/bash 

WORKSPACE=${PWD}
TEMPLATE=$WORKSPACE/template

CPU=6
MEM=10240
HOSTNAME=kf0
DISK=$HOSTNAME.qcow2

USER_DATA=user-data
META_DATA=meta-data
CI_ISO=$HOSTNAME-cidata.iso

IMAGE=$TEMPLATE/CentOS-7-x86_64-GenericCloud-2003.qcow2

rm -rf $WORKSPACE/$HOSTNAME 
mkdir -p $WORKSPACE/$HOSTNAME
cp $IMAGE $WORKSPACE/$HOSTNAME/$HOSTNAME.qcow2

cp $TEMPLATE/user-data $WORKSPACE/$HOSTNAME/$USER_DATA
cp $TEMPLATE/meta-data $WORKSPACE/$HOSTNAME/$META_DATA

genisoimage -output $WORKSPACE/$HOSTNAME/$CI_ISO -volid cidata -joliet -r $WORKSPACE/$HOSTNAME/$USER_DATA $WORKSPACE/$HOSTNAME/$META_DATA &>> $WORKSPACE/$HOSTNAME/$HOSTNAME-gen-image.log

virt-install \
  --memory $MEM \
  --vcpus $CPU \
  --name ${HOSTNAME} \
  --disk $WORKSPACE/$HOSTNAME/$HOSTNAME.qcow2,device=disk \
  --disk $WORKSPACE/$HOSTNAME/$CI_ISO,device=cdrom \
  --os-type Linux \
  --os-variant centos7.0 \
  --virt-type kvm \
  --graphics none \
  --network default \
  --import
# EOF 

> cat template/backup/meta-data-static-ip-success-case
instance-id: kf0
local-hostname: kf0

network-interfaces: |
  iface eth0 inet static
  address 192.168.122.2
  network 192.168.122.0
  netmask 255.255.255.0
  broadcast 192.168.122.255
  gateway 192.168.122.254
# EOF 

> sh -x create-vm.sh

```

# 결과물 

* https://github.com/seaofnight/cloud-init-tutorial

# 참고자료 

* [how to use centos cloud image with cloud-init](https://stafwag.github.io/blog/blog/2019/03/03/howto-use-centos-cloud-images-with-cloud-init/)
* [fabianlee - kvm cloud-init local centos](https://fabianlee.org/2020/03/14/kvm-testing-cloud-init-locally-using-kvm-for-a-centos-cloud-image/)
* [ref gist](https://gist.github.com/itzg/2577205f2036f787a2bd876ae458e18e)
* [redhat cloud init](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/installation_and_configuration_guide/setting_up_cloud_init)
* [on prem cloud-init example](https://docs.nebbiolo.io/latest/sw-adminguide/onprem-cloud-init/)
* [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html)
