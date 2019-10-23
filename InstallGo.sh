#!/bin/sh

cd
wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz

rm -rf /usr/local/go

sudo tar -xvf go1.13.1.linux-amd64.tar.gz
sudo mv go /usr/local

export GOROOT=/usr/local/go
export GOPATH=$HOME/Projects/Caddy
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

go version

echo "export GOROOT=/usr/local/go" >> ~/.profile
echo "export GOPATH=$HOME/Projects/Caddy" >> ~/.profile
echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> ~/.profile
