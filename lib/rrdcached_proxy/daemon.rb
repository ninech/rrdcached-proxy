require 'eventmachine'
require 'logger'

require 'rrdcached_proxy/rrdtool_connection'
require 'rrdcached_proxy/backends'

module RRDCachedProxy
  class Daemon
    def self.run
      EventMachine.run do
        logger = Logger.new(STDOUT)
        backend_config = { logger: logger }
        EventMachine::start_unix_domain_server '/tmp/test.sock',
                                               RRDToolConnection,
                                               logger,
                                               Backends::InfluxDB.new(backend_config)
      end
    end
  end
end
