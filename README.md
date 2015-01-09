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

Start a server

```
vagrant ssh

cd /vagrant
sudo rm /tmp/test.sock ; sudo ruby bin/test.rb
```

Start client

```
vagrant ssh
sudo socat - UNIX-CONNECT:/tmp/test.sock
# try HELP as command
```

