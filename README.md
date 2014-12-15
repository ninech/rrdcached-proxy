# RRDcached Proxy

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

