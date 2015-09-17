require 'opentsdb'

require 'rrdcached_proxy/backends/base'

module RRDCachedProxy
  module Backends
    class OpenTSDB < Base
      METRIC_KEY_TEMPLATE = 'nine.network_ports.%{name}'

      def initialize(config)
        super

        ::OpenTSDB.logger = @config[:logger]
      end

      def write(points)
        points.each do |point|
          connection.put metric: METRIC_KEY_TEMPLATE % { name: point.name },
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
          hostname: @config[:hostname],
          port: @config[:port]
        }
      end
    end
  end
end
