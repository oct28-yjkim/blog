---
title: "Centos Vnc Setting"
date: 2020-12-14T07:17:13Z
description:
draft: false 
hideToc: false
enableToc: true
enableTocContent: false
tocFolding: false
tocPosition: inner
tocLevels: ["h2", "h3", "h4"]
tags:
- vnc
- centos 
series:
-
categories:
- vnc
- centos 
image: images/feature1/markdown.png
---

### how to gnome desktop install 

```sh 
$ gnome desktop install 
$ sudo yum update  
$ yum group list  
$ yum groupinstall "GNOME Desktop" "Graphical Administration Tools" 
$ ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target 
$ sudo reboot 
```

### tiger vnc install 

```sh 
$ yum install -y tigervnc-server 
$ vncserver 
# modify option -> geometry : resolution 
```
