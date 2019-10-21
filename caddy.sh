#!/bin/sh

go version

go get github.com/mholt/caddy/caddy
cd $GOPATH/src/github.com/mholt/caddy
TAG=git describe --abbrev=0
git checkout -b "adding_plugins" $TAG

go install github.com/mholt/caddy/caddy

caddy

sudo cp $GOPATH/bin/caddy /usr/local/bin/
sudo chown root:root /usr/local/bin/caddy
sudo chmod 755 /usr/local/bin/caddy
sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy
sudo mkdir /etc/caddy
sudo chown -R root:www-data /etc/caddy
sudo mkdir /etc/ssl/caddy
sudo chown -R root:www-data /etc/ssl/caddy
sudo chmod 0770 /etc/ssl/caddy
sudo mkdir /var/www
sudo chown www-data:www-data /var/www
sudo touch /etc/caddy/Caddyfile
sudo cp $GOPATH/src/github.com/mholt/caddy/dist/init/linux-systemd/caddy.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/caddy.service
sudo systemctl daemon-reload
sudo systemctl status caddy
