# ethnchao/vsftpd

![docker_logo](https://raw.githubusercontent.com/fauria/docker-vsftpd/master/docker_139x115.png)

[![](https://images.microbadger.com/badges/image/ethnchao/vsftpd.svg)](https://microbadger.com/images/ethnchao/vsftpd "Get your own image badge on microbadger.com")  [![](https://images.microbadger.com/badges/version/ethnchao/vsftpd.svg)](https://microbadger.com/images/ethnchao/vsftpd "Get your own version badge on microbadger.com")

This Docker container implements a vsftpd server, with the following features:

 * CentOS 7 base image.
 * vsftpd 3.0.2
 * Virtual users (You can add other users)
 * Passive mode

### Installation from [Docker registry hub](https://registry.hub.docker.com/u/ethnchao/vsftpd/).

You can download the image with the following command:

~~~~bash
docker pull ethnchao/vsftpd
~~~~

Environment variables
----

Use This image uses environment variables to allow the configuration of some parameteres at run time:

* Variable name: `FTP_USER`
* Default value: admin
* Accepted values: Any string. Avoid whitespaces and special chars.
* Description: Username for the default FTP account. If you don't specify it through the `FTP_USER` environment variable at run time, `admin` will be used by default.

----

* Variable name: `FTP_PASS`
* Default value: Random string.
* Accepted values: Any string.
* Description: If you don't specify a password for the default FTP account through `FTP_PASS`, a 16 characters random string will be automatically generated. You can obtain this value through the [container logs](https://docs.docker.com/reference/commandline/logs/).

----

* Variable name: `PASV_ADDRESS`
* Default value: 127.0.0.1.
* Accepted values: Any IPv4 address.
* Description: If you don't specify an IP address to be used in passive mode, 127.0.0.1 will be used, but it may cause problems, please set it to Docker host address.

----

* Variable name: `PASV_MIN_PORT`
* Default value: 21100.
* Accepted values: Any valid port number.
* Description: This will be used as the lower bound of the passive mode port range. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `PASV_MAX_PORT`
* Default value: 21110.
* Accepted values: Any valid port number.
* Description: This will be used as the upper bound of the passive mode port range. It will take longer to start a container with a high number of published ports.

----

Exposed ports and volumes
----

The image exposes ports `20` and `21`. Also, exports two volumes: `/home/vsftpd`, which contains users home directories, and `/var/log/vsftpd`, used to store logs.

Use cases
----

1) Create a temporary container for testing purposes:

~~~~bash
$ docker run -it --rm ethnchao/vsftpd
~~~~

2) Create a container in active mode using the default user account, with a binded data directory:

~~~~bash
$ docker run -it \
  -d -p 7021:21 -v /my/data/directory:/home/vsftpd \
  --name vsftpd ethnchao/vsftpd

# see logs for credentials:
$ docker logs vsftpd
~~~~

3) Create a **production container** with a custom user account, binding a data directory and enabling both active and passive mode:

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

4) Manually add a new FTP user to an existing container:
~~~~bash
# Enter docker container bash
$ docker exec -it vsftpd bash
# Add user: myuser2 with password: mypass2
$ /adduser.sh --user myuser2 --passwd mypass2
$ exit
~~~~
