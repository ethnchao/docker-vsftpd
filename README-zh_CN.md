# ethnchao/vsftpd

![docker_logo](https://raw.githubusercontent.com/fauria/docker-vsftpd/master/docker_139x115.png)

[![](https://images.microbadger.com/badges/image/ethnchao/vsftpd.svg)](https://microbadger.com/images/ethnchao/vsftpd "Get your own image badge on microbadger.com")  [![](https://images.microbadger.com/badges/version/ethnchao/vsftpd.svg)](https://microbadger.com/images/ethnchao/vsftpd "Get your own version badge on microbadger.com")

本Docker镜像用于创建vsftpd服务器，提供以下功能：

 * CentOS 7 base image.
 * vsftpd 3.0.2
 * Virtual users (你可以添加其他用户)
 * Passive mode

### 由 [Docker registry hub](https://registry.hub.docker.com/u/ethnchao/vsftpd/) 安装.

执行以下命令下载本镜像：

~~~~bash
docker pull ethnchao/vsftpd
~~~~

环境变量
----

在run镜像时，本镜像使用环境变量进行配置部分参数：

* 变量名称: `FTP_USER`
* 默认值: admin
* 可选值: 任意字符串。避免使用空格和特殊字符.
* 描述: FTP账户用户名。如果没有通过`FTP_USER`这一环境变量指定，默认将使用`admin`。

----

* 变量名称: `FTP_PASS`
* 默认值: 随机字符串
* 可选值: 任意字符串
* 描述: FTP账户密码。如果没有通过`FTP_PASS`这一环境变量指定，我们将自动生成一个随机的16位的字符串，你可以通过 [Container logs](https://docs.docker.com/reference/commandline/logs/) 查看.

----

* 变量名称: `PASV_ADDRESS`
* 默认值: 127.0.0.1
* 可选值: Docker Host IPv4 地址
* 描述: 如果没有指定Passive Mode中使用的IP地址，将会使用 127.0.0.1，但是这会在Passive Mode 中产生某些问题，请设置为Docker Host的地址。

----

* 变量名称: `PASV_MIN_PORT`
* 默认值: 21100
* 可选值: 任意可用的端口号
* 描述: 在Passive Mode中端口绑定范围的最小值，记住使用 `docker -p` Publish 你的端口。

----

* 变量名称: `PASV_MAX_PORT`
* 默认值: 21110
* 可选值: 任意可用的端口号
* 描述: 在Passive Mode中端口绑定范围的最大值，在启动容器时，设定比较大的数字时会耗费更长的时间。

----

Exposed ports and volumes
----

本镜像Expose的端口有：`20` 和 `21`。另外，Expose两个Volume：`/home/vsftpd`，包含了用户的home目录，和 `/var/log/vsftpd`，用于存储日志文件。

使用案例
----

1) 创建临时容器用于测试：

~~~~bash
$ docker run -it --rm ethnchao/vsftpd
~~~~

2) 创建使用Active Mode的容器，默认FTP用户设置，以绑定方式挂载数据文件目录:

~~~~bash
$ docker run -it \
  -d -p 7021:21 -v /my/data/directory:/home/vsftpd \
  --name vsftpd ethnchao/vsftpd

# 查看用户信息:
$ docker logs vsftpd
~~~~

3) 创建 **生产环境容器** ，自定义FTP用户，以绑定的方式挂载数据目录，同时启动Passive Mode和 Active Mode：

~~~~bash
$ docker run -d \
  -v /my/data/directory:/home/vsftpd \
  -p 7020:20 -p 7021:21 \
  -p 21100-21110:21100-21110 \
  -e FTP_USER=myuser \
  -e FTP_PASS=mypass \
  -e PASV_ADDRESS=127.0.0.1 \
  -e PASV_MIN_PORT=21100 \
  -e PASV_MAX_PORT=21110 \
  --name vsftpd \
  --restart=always \
  ethnchao/vsftpd
~~~~

4) 手动添加一个新的FTP用户到已经存在的容器：
~~~~bash
# Enter docker container bash
$ docker exec -it vsftpd bash
# Add user: myuser2 with password: mypass2
$ /adduser.sh --user myuser2 --passwd mypass2
$ exit
~~~~
