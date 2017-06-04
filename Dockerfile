FROM centos:7
MAINTAINER ethnchao <maicheng.linyi@gmail.com>

RUN curl http://mirrors.aliyun.com/repo/Centos-7.repo -o /etc/yum.repos.d/CentOS-Base.repo \
    && yum install -y vsftpd \
        db4-utils \
        db4 \
    && yum clean all

ENV PASV_MAX_PORT 21110
ENV PASV_MIN_PORT 21100

RUN mkdir -p /home/vsftpd \
    && chown -R ftp:ftp /home/vsftpd \
    && echo -en "#%PAM-1.0\n\
auth    required    pam_userdb.so   db=/etc/vsftpd/virtual_users\n\
account required    pam_userdb.so   db=/etc/vsftpd/virtual_users\n\
session required    pam_loginuid.so" > /etc/pam.d/vsftpd_virtual

VOLUME ["/home/vsftpd"]
VOLUME ["/var/log/vsftpd"]

ADD run.sh /run.sh
ADD files/adduser.sh /adduser.sh
ADD files/vsftpd.conf /etc/vsftpd/vsftpd.conf.example
RUN chmod +x /run.sh /adduser.sh

EXPOSE 20 21

ENTRYPOINT ["/run.sh"]

CMD [ "main" ]
