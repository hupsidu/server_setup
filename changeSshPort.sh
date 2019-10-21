#!/bin/sh

sed -i 's/^Port .*/'"Port 47691/g" /etc/ssh/sshd_config
service ssh restart
