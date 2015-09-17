require 'influxdb'

require 'rrdcached_proxy/backends/base'

module RRDCachedProxy
  module Backends
    class InfluxDB < Base
      attr_reader :database

      def initialize(config)
        super

        @database = config[:database]

        ::InfluxDB::Logging.logger = config[:logger]
      end

      def write(points)
        points.each do |point|
          data = point.metadata.merge value: point.value,
                                      time:  point.timestamp
          connection.write_point point.name, data, true, 's'
        end
      end

      def connection
        @connection ||= ::InfluxDB::Client.new database, access_config
      end

      def access_config
        {
          username: config[:username],
          password: config[:password],
          hosts: config[:hosts]
        }
      end
    end
  end
end
