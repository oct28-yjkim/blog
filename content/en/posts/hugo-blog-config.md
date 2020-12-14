---
title: "Hugo Blog Config"
date: 2020-12-14T07:50:09Z
description:
draft: false 
hideToc: false
enableToc: true
enableTocContent: false
tocFolding: false
tocPosition: inner
tocLevels: ["h2", "h3", "h4"]
tags:
- hugo
- blog
- config 
series:
-
categories:
- hugo
- blog
- config 
image: images/feature1/markdown.png
---

## hugo docker 실행 방법 

```sh 
# ext 된 버전으로 실행 시켜야함.
docker run --rm -it \
-v $(pwd):/src \
-p 1313:1313 \
klakegg/hugo:0.78.2-ext-alpine server 
```

## hugo create blog 

```sh 
docker run --rm -it \
-v $(pwd):/src \
klakegg/hugo:0.78.2 new site oct28-yjkim.github.io  
```

## download themes 
```sh 
# hugo themes 에서 적절한 themes 를 확인 및 url을 체크 해놓는다. 
cd oct28-yjkim.github.io 
git init
git submodule add https://github.com/zzossig/hugo-theme-zzo.git themes/zzo

# config.toml 혹은 config 폴더에 설정을 정의 한다. 
```

## build hugo server 

```sh 
hugo -t zzo --debug -v 
```

## deploy hugo to github page 

```sh 


```
