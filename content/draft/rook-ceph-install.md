---
date: 2020-06-07T10:58:08-04:00
description: "rook-ceph"
tags: ["rook-ceph","install"]
categories: "ceph"
title: "rook-ceph 설치 및 rbd 연동 "
---

# Install 

```sh 
git clone https://github.com/rook/rook.git
cd cluster/examples/kubernetes/ceph
kubectl create -f common.yaml
kubectl create -f operator.yaml

# 아래는 예시입니다. 
## ceph cluster 설정에 맞추어서 변경을 해주셔야 합니다.
cat <<EOF | kubectl create  -f - 
---
apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  name: rook-ceph
  namespace: rook-ceph
spec:
  cephVersion:
    image: ceph/ceph:v14.2.4-20190917
    allowUnsupported: true
  dataDirHostPath: /var/lib/rook
  skipUpgradeChecks: false
  mon:
    count: 1
    allowMultiplePerNode: true
  dashboard:
    enabled: true
  monitoring:
    enabled: false  # requires Prometheus to be pre-installed
    rulesNamespace: rook-ceph
  network:
    hostNetwork: false
  rbdMirroring:
    workers: 0
  mgr:
    modules:
    # the pg_autoscaler is only available on nautilus or newer. remove this if testing mimic.
    - name: pg_autoscaler
      enabled: true
  storage:
    useAllNodes: true
    useAllDevices: false
    deviceFilter:
    config:
      databaseSizeMB: "1024" # this value can be removed for environments with normal sized disks (100 GB or larger)
      journalSizeMB: "1024"  # this value can be removed for environments with normal sized disks (20 GB or larger)
      osdsPerDevice: "1" # this value can be overridden at the node or device level
    nodes:
    - name: "k8s-master"
      devices:
      - name: "/dev/sdb"
    - name: "k8s-node1"
      devices:
      - name: "/dev/sdb"
---
EOF
```

