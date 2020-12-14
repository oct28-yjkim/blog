---
title: "firewalld"
intro: "firewalld commands in centos 7"
date: 2020-06-01T10:58:08-04:00
description: "firewalld commands "
tags: 
    - firewalld 
    - command
categories:
    - firewalld
---


# Firewalld 

# Firewalld install 

```sh 

$ sudo yum install -y firewalld 
$ sudo systemctl status firewalld 
$ sudo systemctl start firewalld 
$ sudo firewall-cmd --state
output : running 


```

# Firewalld 사용방법 

* Zone 조회 
```sh 
# Default 조회 
$ sudo firewall-cmd --get-default-zone

# Active Zone list 조회 
$ firewall-cmd --get-active-zones

# 특정 Zone 의 정보 조회 
$ sudo firewall-cmd --zone=home --list-all

```

* Default Zone 변경 

```sh 
$ sudo firewall-cmd --set-default-zone=home
```

* Zone 에 Service 허용 
    * 영구와 비영구의 차이는 --reload 시에 비영구 옵션은 사라진다. 
```sh 
# Http 서비스 허용 
$ sudo firewall-cmd --zone=public --add-service=http
$ sudo firewall-cmd --zone=public --list-services
output : dhcpv6-client http ssh

# Http 서비스 영구 허용 
$ sudo firewall-cmd --zone=public --permanent --add-service=http

# Port/protocol 로 허용 
$ sudo firewall-cmd --zone=public --add-port=5000/tcp
$ sudo firewall-cmd --zone=public --list-ports
output : 5000/tcp

# Port/protocol 로 영구 허용 
$ sudo firewall-cmd --zone=public --add-port=5000/tcp

```

* Firewalld Service Reload 

```sh 
sudo firewall-cmd --reload
```

* firewalld example 

```sh 
{
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --add-masquerade --permanent

systemctl restart firewalld
}

{
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp

systemctl restart firewalld
}

```
