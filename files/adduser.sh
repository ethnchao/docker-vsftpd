#!/bin/bash
# -*- coding: utf-8 -*-
set -e


printUsage() {
    echo "Usage: adduser.sh --user username --passwd password ."
}


main() {
    local username password
    username=$1
    password=$2
    if [[ "x$username" != 'x' ]] && [[ "x$password" != 'x' ]]; then
        mkdir -p "/home/vsftpd/${username}"
        chown -R ftp:ftp "/home/vsftpd/${username}"
        cd /etc/vsftpd/ || exit 1
        touch virtual_users.txt
        echo -e "${username}\n${password}" >> virtual_users.txt
        /usr/bin/db_load -T -t hash -f virtual_users.txt virtual_users.db
    else
        printUsage && exit 1
    fi
}


if [ "${1:0:1}" = '-' ]; then
    while [ $# -gt 0 ]; do
        arg=$1 ; shift
        case $arg in
        "--user")
            username="$1" ; shift;;
        "--passwd")
            password="$1" ; shift;;
        esac
    done
    main $username $password
else
    printUsage && exit 1
fi
