node default {
  package { 'rrdcached': ensure => present }
  package { 'rrdtool': ensure => present }
  package { 'ruby-bundler': ensure => present }
  package { 'socat': ensure => present }
}
