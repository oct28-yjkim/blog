---
title: "Ceph Create Filesystem"
date: 2020-12-14T14:31:53Z
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
- file-system
- ceph-filesystem
- mds
series:
- ceph 
categories:
- ceph
- file-system
- ceph-filesystem
- mds
image: images/feature1/markdown.png
---



## 개요 

* ceph version 은 15.2 입니다. 

## 작업순서 

* mds deploy 
  * 예시에는 cephadm 으로 mds 를 스케줄 배포 하였습니다. 
* ceph file system 에 사용될 pool 을 생성한다. 
  * inode, tree 정보가 들어갈 metadata pool
  * data 가 들어갈 data pool 생성 

* Client 를 이용하여 file system 사용 

## create replicated pool 

```sh 

ceph orch apply mds cephfs --placement="ceph0,ceph1,ceph2"

FS_NAME=cephfs_repl_data
FS_META=cephfs_repl_meta
PG_CNT=8
ceph osd pool create ${FS_NAME} ${PG_CNT}
ceph osd pool create ${FS_META} ${PG_CNT}
ceph fs new cephfs ${FS_META} ${FS_NAME}

[root@ceph-test mnt]# ceph fs status
cephfs - 0 clients
======
RANK  STATE           MDS             ACTIVITY     DNS    INOS  
 0    active  cephfs.ceph1.witvio  Reqs:    0 /s    10     13   
      POOL          TYPE     USED  AVAIL  
cephfs_repl_meta  metadata  1536k   410G  
cephfs_repl_data    data       0    410G  
    STANDBY MDS      
cephfs.ceph2.iplnaa  
cephfs.ceph0.fpvsgg  
MDS version: ceph version 15.2.3 (d289bbdec69ed7c1f516e0a093594580a76b78d0) octopus (stable)

[root@ceph-test mnt]# ceph auth get client.admin | grep key 
exported keyring for client.admin
	key = AQDk/NleJfSOExAAKHtFWBmEDdNCLc/WGLFUaQ==

mount.ceph ceph1,ceph0,ceph2:/ /mnt/cephfs-repl -o name=admin,secret=AQDk/NleJfSOExAAKHtFWBmEDdNCLc/WGLFUaQ==

```


## erasure code pool 


```sh 

# deploy mds 
ceph orch apply mds cephfs --placement="ceph0,ceph1,ceph2"

FS_NAME=cephfs_era_data
FS_META=cephfs_era_meta
PG_CNT=8
ceph osd pool create ${FS_NAME} erasure
ceph osd pool create ${FS_META} ${PG_CNT}
ceph osd pool create cephfs_data ${PG_CNT}
# ceph fs 의 erasure code pool 을 사용하기 위하여는 해당 옵션을 enable 하여야 한다. 
ceph osd pool set ${FS_NAME} allow_ec_overwrites true
ceph osd pool application enable ${FS_NAME} cephfs

ceph fs new cephfs ${FS_META} ${FS_NAME} --force 

# ceph status 의 mds 의 active 가 앞으로 오게한다. 
mount.ceph ceph1,ceph0,ceph2:/ /mnt/cephfs-era -o name=admin,secret=AQDk/NleJfSOExAAKHtFWBmEDdNCLc/WGLFUaQ==
```
