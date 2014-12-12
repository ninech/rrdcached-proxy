node default {
  package { 'rrdcached': ensure => present }
  package { 'ruby-bundler': ensure => present }
  package { 'socat': ensure => present }
}
