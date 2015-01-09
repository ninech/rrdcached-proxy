require 'eventmachine'

require 'rrdcached_proxy/response_info'
require 'rrdcached_proxy/response'
require 'rrdcached_proxy/update_data'
require 'rrdcached_proxy/request'
require 'rrdcached_proxy/rrd_file_info'

module RRDCachedProxy
  class RRDToolConnection < EventMachine::Connection
    include EventMachine::Protocols::LineProtocol

    attr_reader :logger, :rrdcached_socket, :backend

    def initialize(logger, backend, rrdcached_socket = '/var/run/rrdcached.sock')
      @logger = logger
      @backend = backend
      @rrdcached_socket = UNIXSocket.new(rrdcached_socket)
      super
    end

    def receive_line(data)
      logger.debug "new request: #{data}"
      logger.debug 'opening connection to rrdcached'

      request = Request.new(data)

      if request.update?
        logger.debug 'UPDATE called'

        logger.debug 'fetching rrd info'
        field_names = RRDFileInfo.field_names(request.arguments.first)

        logger.debug 'writing to backend'
        backend.write UpdateData.new(request, field_names).points
      end

      logger.debug 'pushing to rrdcached'
      rrdcached_socket.puts data

      logger.debug 'waiting for rrdcached response'
      response_info_line = rrdcached_socket.gets

      response_info = ResponseInfo.new response_info_line

      logger.debug 'sending response to client'
      send_data response_info_line

      logger.debug "rrdcached response info: #{response_info.to_h}"
      response = Response.new(response_info, rrdcached_socket).read
      send_data response if response
      logger.debug 'sending response finished'
    end

    def unbind
      logger.debug 'client disconnected, disconnecting from rrdcached'
      rrdcached_socket.puts 'QUIT'
      rrdcached_socket.close
    end
  end
end
