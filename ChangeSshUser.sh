#!/bin/sh

adduser servermgmt
id servermgmt
ls -lad /home/servermgmt/

echo "### NEW PASSWORD FOR USER ###"
echo "###       servermgmt      ###"
passwd servermgmt

echo 'servermgmt ALL=(ALL) ALL' >> /etc/sudoers
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

/etc/init.d/sshd restart
