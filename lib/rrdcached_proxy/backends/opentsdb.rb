require 'opentsdb'

require 'rrdcached_proxy/backends/base'

module RRDCachedProxy
  module Backends
    class OpenTSDB < Base
      attr_reader :namespace

      def initialize(config)
        super

        @namespace = config[:namespace]

        ::OpenTSDB.logger = config[:logger]
      end

      def write(points)
        points.each do |point|
          connection.put metric: "#{namespace}.#{point.name}",
                         value: point.value,
                         timestamp: point.timestamp,
                         tags: point.metadata
        end
      end

      def connection
        @connection ||= ::OpenTSDB::Client.new access_config
      end

      def access_config
        {
          hostname: config[:hostname],
          port: config[:port]
        }
      end
    end
  end
end
