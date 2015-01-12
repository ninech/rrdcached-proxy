require 'eventmachine'
require 'logger'
require 'syslogger'

require 'rrdcached_proxy/rrdtool_connection'
require 'rrdcached_proxy/backends'

module RRDCachedProxy
  class Daemon
    def initialize(config)
      @config = config
      set_log_level
    end

    def run
      logger.debug "Daemon got config: #{@config}"

      connection_config = {
        logger: logger,
        backend: backend,
        rrdcached_socket: @config[:rrdcached_socket],
        blacklist: @config[:blacklist],
      }

      EventMachine.run do
        EventMachine.start_unix_domain_server @config[:listen_socket], RRDToolConnection, connection_config
        set_socket_permissions
      end
    end

    def logger
      return @logger if @logger
      @logger = if @config[:log][:destination] == 'syslog'
                  Syslogger.new 'rrdcached-proxy', Syslog::LOG_PID, Syslog::LOG_LOCAL0
                else
                  Logger.new $stdout
                end
      @logger
    end

    def set_log_level
      level = @config[:log][:level].upcase
      if Logger.const_defined? level
        logger.level = Logger.const_get level
      else
        logger.level = Logger::INFO
      end
    end

    def backend
      backend_config = { logger: logger }
      case @config[:backend]
      when 'influxdb'
        Backends::InfluxDB.new backend_config.merge(@config[:influxdb])
      else
        Backends::Base.new backend_config
      end
    end

    def set_socket_permissions
      stat = File::Stat.new @config[:rrdcached_socket]
      File.chown stat.uid, stat.gid, @config[:listen_socket]
      File.chmod stat.mode, @config[:listen_socket]
    end
  end
end
