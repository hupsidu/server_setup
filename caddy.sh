#!/bin/sh

go version

go get github.com/mholt/caddy/caddy
cd $GOPATH/src/github.com/mholt/caddy
TAG=git describe --abbrev=0
git checkout -b "adding_plugins" $TAG

go install github.com/mholt/caddy/caddy

caddy
