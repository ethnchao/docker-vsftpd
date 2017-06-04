#!/bin/bash
# -*- coding: utf-8 -*-
set -e


setup() {
    if [[ "x${PASV_ADDRESS}" == "x" ]]; then
        pasv_address=127.0.0.1
    else
        pasv_address=$PASV_ADDRESS
    fi
    if [[ "x${PASV_MAX_PORT}" == "x" ]]; then
        pasv_max_port=21110
    else
        pasv_max_port=$PASV_MAX_PORT
    fi
    if [[ "x${PASV_MIN_PORT}" == "x" ]]; then
        pasv_min_port=21100
    else
        pasv_min_port=$PASV_MIN_PORT
    fi
    if [[ "x${FTP_USER}" == "x" ]]; then
        ftp_user=admin
    else
        ftp_user=$FTP_USER
    fi
    if [[ "x${FTP_PASS}" == "x" ]]; then
        ftp_pass=$(cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c 16)
    else
        ftp_pass=$FTP_PASS
    fi
    /adduser.sh --user "$ftp_user" --passwd "$ftp_pass"
    cd /etc/vsftpd/ || exit 1
    cp -f vsftpd.conf.example vsftpd.conf
    chmod 644 vsftpd.conf
    sed -i "s/PASV_ADDRESS/${pasv_address}/" vsftpd.conf
    sed -i "s/PASV_MAX_PORT/${pasv_max_port}/" vsftpd.conf
    sed -i "s/PASV_MIN_PORT/${pasv_min_port}/" vsftpd.conf
    touch '/etc/vsftpd/setup.done'
}


shutdown() {
    echo Shutting Down
    if [ -e /proc/$RUNVS ]; then
        kill -9 $RUNVS
        wait $RUNVS
    fi
    sleep 1
    exit
}


startup() {
    /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf &
    RUNVS=$!
    echo "Started vsftpd, PID is $RUNVS"
    trap shutdown SIGTERM SIGHUP SIGINT
    wait $RUNVS

    shutdown
}


printinfo() {
    log_file=$(grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2)
    pasv_addr=$(grep pasv_address /etc/vsftpd/vsftpd.conf|cut -d= -f2)
    pasv_max_port=$(grep pasv_max_port /etc/vsftpd/vsftpd.conf|cut -d= -f2)
    pasv_min_port=$(grep pasv_min_port /etc/vsftpd/vsftpd.conf|cut -d= -f2)
    user_info=$(cat /etc/vsftpd/virtual_users.txt)
    cat << EOB

    VSFTPD SERVER SETTINGS
    ---------------
    · Passive Address: $pasv_addr
    · Passive Port Range: $pasv_min_port:$pasv_max_port
    · Log File: $log_file
    · UserInfo(Odd lines are user names, even lines are passwords):

$user_info

EOB
}


main() {
    if [[ ! -f /etc/vsftpd/setup.done ]]; then
        setup
    fi
    printinfo
    startup
}


if [ $1 == "main" ]; then
    main
else
    "$@"
fi
