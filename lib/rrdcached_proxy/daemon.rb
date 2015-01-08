require 'eventmachine'
require 'logger'

require 'rrdcached_proxy/rrdtool_connection'
require 'rrdcached_proxy/backends'

module RRDCachedProxy
  class Daemon
    def self.run
      EventMachine.run do
        EventMachine::start_unix_domain_server '/tmp/test.sock',
                                               RRDToolConnection,
                                               Logger.new(STDOUT),
                                               Backends::Base.new
      end
    end
  end
end
