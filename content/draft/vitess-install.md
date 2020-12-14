---
title: "vitess"
intro: "vitess youtube 의 확장 가능한 DB"
date: 2020-06-01T10:58:08-04:00
featured_image: "/images/vitess18.jpg"
description: "vitess 설치 방법 "
tags: 
    - vitess
    - install
categories:
    - vitess
---

# vitess 소개 

오늘 포스팅 할 내용은 사내에서 사용하지 않기로 한 Vitess 라는 솔루션에 대한 기록 및 조사한 내용을 공유하는 자리를 가지도록 하곘다. 
비교제품군이 있으며 비교제품중에 선택이 되었으므로 사용 안할것 같은 내용은 기록을 하여 남기도록 하겠다. 
Vitess 는 Youtube 에 mysql 을 ScaleOut 하기 위하여 개발이 되었으며 
제품 소개 자료에서도 Scaleout에 대한 기능에 대하여 강점을 많이 설명을 하는 제품이다. 
![vitess archeture](https://vitess.io/docs/overview/img/VitessOverview.png)
하지만 Mysql 은 아래쪽에 있을뿐 다른 무언가가 많이 붙어 있는것을 볼수 있다. 
붙어 있는 컴포넌트에 대한 대략적인 설명을 하고 가겠다. 

### Component

* vTgate 

Vitess 의 외부에서 접속 할 수 있는 접점이라고 보면 된다. 
Vtgate 는 Topology 를 통하여 Sharding Key 정보를 확인 한후에 해당하는 Vtablet에 있는 데이터를 가져오도록 되어있다. 
Kubernetes 의 외부에 노출은 Service 로 될것이고 
일반 Baremetal 에 도커나 쌩으로 설치 되었을 시에는 당연이 Port 가 열려있을것이다. 
Get Start Locally 나 Start with Kubenetes 를 보아도 패키징이 아주 잘되있으며 
예제로 삼기에도 충분할정도로 자세하고 내공이 보여지도록 구성이 되어있다 

역시 갓갓 구글 


* Topology 

Topology 는 어떤 것으로 구성할지 선택할 수 있는 옵션들이 있다. 
일반적으로 예제에서는 ETCD를 이용하여 작성되어있는데 Zookeeper, Consel 등으로 구성할 수 있으며 vTablet 에서 저장하는 Sharding Key 가 어떻게 되느냐 클러스터의 형상이 어떻게 되느냐 등등에 대한 Metadata 가 저장이 되고 관리 되는곳이다. 
설치시에는 Global 로 1개, Cell 별로 Replica 개수를 지정하여 설치 할 수 있다. 

* vTablet

vTablet 는 Mysql 을 Proxy Server 역활을 해주는 프로세스이며 
1개의 Mysql Server 당 1개의 vTable 가 붙어서 해당 저장소를 관리 해준다. 
vTablet 는 Kubernetes 로 설치 될경우에는 
vtablet, mysql, ganeral-log, error-log,slow-log등 로그 컨테이너와 함께 생성이 되며 
만약 Monitoring 솔루션인 PMM 과 같이 배포하였을 경우에는 PMM 도 vTable 포드에 포함되어 배포가 된다. 


* vtctl

vtctl 은 topology 를 통하여 Cli 로 vschema, sharding, 혹은 ddl 등을 날릴수 있는 
cli client tool 이다 
설치는 vitess 를 build 하면 vtctlclient 가 빌드가 되며 빌드 된 bin 을 사용하여 topology 를 지정한다거나. vtctld kubernetes service 를 지정하여 명령을 날릴수 있다. 

vitess 의 vtctl 은 vtgate 로 명령을 날릴수 있고 vTablet 로도 직접 command 를 날려서 제어할 수 있다. 요청하는 방식은 cli 의 sub command 를 help 하여서 확인 하여야 된다. 

vtctl 은 위에 아키텍쳐 그림에서 보듯이 Dashboard 도 제공을 해 주고 있다. 
Material 기반의 UI 이며 조금은 개선이 되었으나 아직은 가식성이 좀 떨어지는 면이 있다. 



# install 

### install 절차 

* 사전 조건 
    * kubernetes 설치가 되어있어야 된다. 1.15 이상 
    * helm chart 를 이용하여 배포 할 예정이다. 
    * helm chart 는 1.16 버전에 맞추어서 old api remove 가 되어서 deploy, daemon api 를 맞게 정정 해주어야 된다. 
* 설치 절차 
    * topology 인 etcd 설치 
    * storage class 생성 
    * vitess depoly 의 절차로 설치가 된다. 

### install script 

* create kubernetes namespaces 

```sh 

$ kubectl create ns vitess 

```

* install etcd operator 

```sh 

# project 를 clone 해온다. 
$ git clone https://github.com/coreos/etcd-operator.git

# rbac 를 생성해준다. 
$ ./etcd-operator/example/rbac/create_role.sh --namespace=vitess   

# etcd operater 을 생성 해준다. 
$ kubectl create -f etcd-operator/example/deployment.yaml

# 생성 확인 
$ kubectl get crd | grep etcdcl 
NAME                                    KIND
etcdclusters.etcd.database.coreos.com   CustomResourceDefinition.v1beta1.apiextensions.k8s.io

# etcd operater helm chart 로 생성 
helm install stable/etcd-operator --name etcd --namespace vitess  \
  --set customResources.createEtcdClusterCRD=true \
  --set deployments.backupOperator=false \
  --set deployments.restoreOperator=false \
  --set etcdCluster.size=1

```

* create storage class 

```sh 

NAME=vitess1
POOL_NAME=$NAME-pool 
SC_NAME=$NAME-sc
cat <<EOF | kubectl create -f - 
apiVersion: ceph.rook.io/v1
kind: CephBlockPool
metadata:
  name: $POOL_NAME
  namespace: rook-ceph
spec:
  failureDomain: host
  replicated:
    size: 1
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
   name: $SC_NAME
provisioner: rook-ceph.rbd.csi.ceph.com
parameters:
    clusterID: rook-ceph
    pool: $POOL_NAME
    imageFormat: "2"
    imageFeatures: layering
    csi.storage.k8s.io/provisioner-secret-name: rook-ceph-csi
    csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
    csi.storage.k8s.io/node-stage-secret-name: rook-ceph-csi
    csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
    csi.storage.k8s.io/fstype: ext4
reclaimPolicy: Delete
EOF

```

* install vitess cluster 

```sh 

$ git clone https://github.com/vitessio/vitess.git

$ cd ~/vitess/example/helm

# 예제에서 생성하는 초기 vitess cluster 을 생성해준다. 
$ helm install --name vitess --namespace vitess ../../helm/vitess  \
  -f 101_initial_cluster.yaml --debug

```


# vitess client 

vitess 는 3가지의 Client 옵션을 가지고 있다. 

* vtctlclient 
* mysql client 
* grpc 
* vtctl gui 

위에 있는 옵션중에 mysql client 가 적용이 되면 그 외의 나머지 명령도 거의 mysql client 를 지원하는 것들이라서 왠만큼 사용하는데에는 문제가 없을듯 하다. 

vtctlclient, vtctl gui 등은 vschema, vindex, vseq 등등을 정의 설정하는데 사용을 할 수 있다. 
나머지 vtworker 등은 기록하지 않도록 하겠다. 


* vtctlclinet example 

```sh 

HOST=$(kubectl get svc vtctld -o json | jq -r ".spec.clusterIP")
PORT=$(kubectl get svc vtctld -o json | jq -r ".spec.ports[1].port")

vtctlclient -server $HOST:$PORT GetCellInfoNames   
vtctlclient -server $HOST:$PORT GetCellInfo zone1

vtctlclient -server $HOST:$PORT ListAllTablets
vtctlclient -server $HOST:$PORT ListTablets zone1-0794219800
vtctlclient -server $HOST:$PORT GetTablet zone1-0794219800
vtctlclient -server $HOST:$PORT GetKeyspaces  
vtctlclient -server $HOST:$PORT GetKeyspace commerce
vtctlclient -server $HOST:$PORT GetVSchema t

```