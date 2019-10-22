#!/bin/sh

cd ~
curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz

tar xvf go1.6.linux-amd64.tar.gz
chown -R root:root ./go
mv go /usr/local

export GOPATH=$HOME/work
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

export GOROOT=$HOME/go
export GOPATH=$HOME/work
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

source ~/.profile
