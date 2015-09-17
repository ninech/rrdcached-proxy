module RRDCachedProxy
  module Backends
  end
end

require 'rrdcached_proxy/backends/base'
require 'rrdcached_proxy/backends/influxdb'
require 'rrdcached_proxy/backends/opentsdb'
