---
title: "Manjaro Local Setting"
date: 2020-12-14T07:20:50Z
description:
draft: false 
hideToc: false
enableToc: true
enableTocContent: false
tocFolding: false
tocPosition: inner
tocLevels: ["h2", "h3", "h4"]
tags:
- manjaro
- local
- setting
series:
- manjaro local setting 
categories:
- manjaro
- local
- setting
image: images/feature1/markdown.png
---

### 한글 설정 

```sh 
touch ~/.xprofile
echo "export GTK_IM_MODULE=fcitx" >> ~/.xprofile
echo "export QT_IM_MODULE=fcitx" >> ~/.xprofile
echo "export XMODIFIERS=@im=fcitx" >> ~/.xprofile
```

### zsh config 

* oh-my-zsh install 
* plugin install 
  * syntex-highlighting 
  * auutosuggestions
* p10k install 

```sh 
chsh -s `which zsh`
echo $SHELL 
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
```

### kvm tools install 

```sh 
LC_ALL=C lscpu | grep Virtualization
Virtualization: VT-x
sudo pacman -S virt-manager qemu vde2 ebtables dnsmasq bridge-utils openbsd-netcat
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
sudo usermod -a -G libvirt $USER
```


### virtualbox install 

```sh 
sudo pacman -S virtualbox virtualbox-ext-vnc virtualbox-guest-dkms virtualbox-host-dkms virtualbox-guest-utils virtualbox-guest-iso virtualbox-sdk 

$ uname -r
4.19.66-1-MANJARO
sudo pacman -S linux419-virtualbox-host-modules

sudo /sbin/vboxconfig
sudo /sbin/rcvboxdrv setup
```

### Miscellaneous

```sh 
# shout freeze solving 

# install other packages 
pacman -Ss -no-confirm jq, tree

```
