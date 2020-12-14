---
title: "Ceph Create Rbd"
date: 2020-12-14T14:36:07Z
description:
draft: false
hideToc: false
enableToc: true
enableTocContent: false
tocFolding: false
tocPosition: inner
tocLevels: ["h2", "h3", "h4"]
tags:
- ceph 
- rbd 
- block-device
series:
- ceph 
categories:
- ceph
- rbd 
- block-device
image: images/feature2/content.png
---

## 개요 

* ceph pool 생성 
* client mount 
* benchmark 

* ceph 의 pool 종류는 replicated, erasure 2가지 형태가 있다. 


### ceph create replicated pool 

```sh

# pg calcualte exp : 100 = (3 * 100) / 3
## 대략 7.x 가 나와서 default 옵션인 8로 진행 
##             (OSDs * 100)
##Total PGs =  ------------
##              pool size
ceph osd pool create rbd_repl_bench 8 8 

# rbd create \
# ${IMAGE_NAME:=img_repl_bench} \
# --size ${10G, 1024:default unit is MB} \
# --pool ${POOL_NAME:=rbd_repl_bench}
rbd create img_repl_bench --size 102400 --pool rbd_repl_bench

# rbd 의 기능을 비활성 화 하여야만이 image 를 host 에 map 할 수 있다. 
rbd feature disable rbd_repl_bench/img_repl_bench object-map fast-diff deep-flatten

# host 에 map 한다. 
## mapping 시에 mod_probe 의 rbd 가 enable 되어있어야 하며 
## linux 의 kernal rbd 가 호스트에 bus 를 생성하여서 통신한다. 
rbd map rbd_repl_bench/img_repl_bench 

mkfs.xfs /dev/rbd2

mkdir -p /mnt/rbd-repl/

fstrim -v /mnt/rbd-repl

# benchmark script 직접 돌려보기 바란다. 
rbd bench --io-type write rbd_repl_bench/img_repl_bench  --io-size 4M --rbd-cache=false 
rbd bench rbd_repl_bench/img_repl_bench  --io-type write --io-size 4M --io-threads 16 --io-total 10G --io-pattern rand --rbd-cache=false 
date; time dd if=/dev/zero of=./testfile bs=1G count=5 oflag=dsync; sync; rm -rf testfile ; sync; date; fstrim -v /mnt/rbd-repl;

# 호스트의 disk 를 쓰고있는지 모니터링 하는 스크립트 
iostat -xkdzt /dev/sdb /dev/sdc /dev/sdd /dev/sde 1 | tee rbd-map-repl.txt

# rbd mapped image 에 write 한 후에 데이터를 삭제할 경우에 rados 를 이용하여 조회하면 pool 내에는 데이터가 그대로 있다. 
# scrub 옵션을 활성화 하여야 하며 manually 하게 pool 의 데이터를 삭제하려면 아래 커맨드를 실행 한다.
# disk 의 trim 기능이 잇어야 한다고 한다. 최신 ssd 의 경우 보장하지만 회사 서버는 그리 최신이 아니여서 수동으로 진행한다. 
# fstrim -v ${TRIM_POINT}
fstrim -v /mnt/rbd-repl

```

### ceph create erasure code pool 

```sh 

# erasure coded pool 의 경우 metadata pool 과 data pool 이 필요하다. 
# erasure code profile 의 경우 default 옵션으로 진행한다.
ceph osd pool create rbd_erasure_meta_bench 8 8 
ceph osd pool create rbd_erasure_bench erasure

# rbd image 로 사용하기 위한 옵션 enable 
ceph osd pool set rbd_erasure_bench allow_ec_overwrites true

# rbd image create 
rbd create --size 100G --data-pool rbd_erasure_bench rbd_erasure_meta_bench/img_erasure_bench

# rbd mapping 하기 위한 옵션 disable 처리 
rbd feature disable rbd_erasure_meta_bench/img_erasure_bench object-map fast-diff deep-flatten

# rbd image 를 호스트에 mapping 한다. 
rbd map rbd_erasure_meta_bench/img_erasure_bench

# file system 생성 : recommand option 인 xfs 로 생성 
mkfs.xfs /dev/rbd1

# mount point mkdir 
mkdir -p /mnt/rbd-era/

# mount 
mount /dev/rbd1 /mnt/rbd-era/

# benchamrk script 
rados bench -p rbd_repl_bench 10 write --no-cleanup
rados -p rbd_repl_bench cleanup
rados bench -p rbd_erasure_bench 10 write --no-cleanup
rados -p rbd_erasure_bench cleanup
dd if=/dev/zero of=./testfile bs=1G count=5 oflag=dsync  
date; time dd if=/dev/zero of=./testfile bs=1G count=5 oflag=dsync; sync; rm -rf testfile ; sync; date;

# sampling scripts 

iostat -xkdzt -p ALL 1
iostat -xkdzt  /dev/sdc 1
iostat -xkdzt /dev/sdb /dev/sdc /dev/sdd /dev/sde 1 | tee ceph-bench.txt
iostat -xkcdzt /dev/sdc /dev/sdd /dev/sde 1 | tee ceph-bench.txt

```
