---
title: "使用hugo+github搭建博客"
date: 2020-01-18T15:23:44+08:00
draft: false
toc: true
categories: ["博客搭建"]
---

# 使用 hugo+github搭建博客

hugo 是基于 golang 实现的一个静态的网页生成软件。比较简单快捷。

主要步骤是:

1. hugo 的安装。
2. 主题的下载配置等。
3. 部署到 github page。

## hugo 安装

可以在 hugo 的 [github](https://github.com/gohugoio/hugo/releases)页面下选择对应的平台进行下载，下载完成之后可以使用对应的平台的二进制，然后根据平台配置环境变量。

### Mac 平台下

mac 下面的安装可以通过 HomeBrew 完成。如果没有按照 HomeBrew 可以参考这篇[文章](https://brew.sh/)。

```
brew install hugo
```

### Debian and Ubuntu平台下

```
sudo apt-get install hugo
```

### Windows 平台下

Windows下Hugo提供了Chocolatey方式的安装，通过如下命令即可。

```
choco install hugo -confirm
```

PS: 只在 mac 平台下安装过。

### 验证安装

安装完成后，打开终端，输入如下命令验证是否安装成功。

```shell
hugo version
```

## 主题的下载和配置等

### 创建一个站点

首先选择一个目录作为站点目录。比如选择 `/path/to/site`。

```shell
hugo new site /path/to/site
```

### 创建文章

创建你的第一篇文章:

```shell
hugo new 目录/文章名.md
```

上面的命令会在对应的 content 下面生成你指定的目录（如果不存在的话会创建一个）下生成对应的文件。

生成的内容如下:

```toml
title: "文章名"
date: 2020-01-18T11:57:10+08:00
draft: true
```

- title: 文章名
- date: 时间
- draft: 是否草稿

### 安装皮肤

可以在 Hugo 官网中找到一款好看的皮肤进行安装。

下面是一个大佬使用的皮肤。

maupassant: https://github.com/rujews/maupassant-hugo

安装皮肤，首先将皮肤从 github 上克隆下来。

```shell
git clone https://github.com/rujews/maupassant-hugo themes/maupassant
```

然后在配置文件中进行更新:

```toml
theme = "maupassant"
```

这里注意一点: 需要将文章放到 content/post 中。



### 配置

```toml

```


