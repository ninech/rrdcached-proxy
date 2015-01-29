# RRDcached Proxy

[![Code
Climate](https://codeclimate.com/github/ninech/rrdcached-proxy/badges/gpa.svg)](https://codeclimate.com/github/ninech/rrdcached-proxy)
[![Test
Coverage](https://codeclimate.com/github/ninech/rrdcached-proxy/badges/coverage.svg)](https://codeclimate.com/github/ninech/rrdcached-proxy)
[![Build
Status](https://travis-ci.org/ninech/rrdcached-proxy.svg?branch=master)](https://travis-ci.org/ninech/rrdcached-proxy)

Proof of concept for a RRDcached proxy.

## Setup

```
vagrant up
```

## Usage

Create sample RRD

```
rrdtool create /tmp/test.rrd        \
         --start 920804400          \
         DS:speed:COUNTER:600:U:U   \
         RRA:AVERAGE:0.5:1:24       \
         RRA:AVERAGE:0.5:6:10
```

Start a server

```
vagrant ssh

cd /vagrant
bundle install
sudo ruby bin/rrdcached-proxy
```

Start client

```
vagrant ssh
sudo socat - UNIX-CONNECT:/var/run/rrdcached-proxy.sock
# try HELP as command
UPDATE /tmp/test.rrd 1422541269:600
```

