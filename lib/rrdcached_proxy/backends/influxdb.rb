require 'influxdb'

require 'rrdcached_proxy/backends/base'

module RRDCachedProxy
  module Backends
    class InfluxDB < Base
      def initialize(config)
        super

        # @config = {
        #   username: 'root',
        #   password: 'root',
        #   hosts: %w(influx01-staging.nine.ch),
        # }
        ::InfluxDB::Logging.logger = @config[:logger]

        ensure_database
      end

      def write(points)
        points.each do |point|
          data = {
            value: point.value,
            time: point.timestamp,
          }
          connection.write_point point.name, data, true, 's'
        end
      end

      private

      def connection
        @connection ||= ::InfluxDB::Client.new database, access_config
      end

      def database
        @database ||= Socket.gethostname
      end

      def ensure_database
        return if connection.get_database_list.find { |db| db['name'] == database }
        logger.info "[InfluxDB] Creating database #{database}"
        connection.create_database database
      end

      def access_config
        {
          username: @config[:username],
          password: @config[:password],
          hosts: @config[:hosts],
        }
      end
    end
  end
end
