require 'eventmachine'

require 'rrdcached_proxy/response_info'
require 'rrdcached_proxy/response'
require 'rrdcached_proxy/update_data'
require 'rrdcached_proxy/request'
require 'rrdcached_proxy/rrd_file_info'

module RRDCachedProxy
  class RRDToolConnection < EventMachine::Connection
    include EventMachine::Protocols::LineProtocol

    attr_reader :logger, :rrdcached_socket, :backend, :blacklist

    def initialize(config)
      @logger = config[:logger]
      @backend = config[:backend]
      @rrdcached_socket = UNIXSocket.new config[:rrdcached_socket]
      @blacklist = config[:blacklist]

      @logger.debug "Connection config: #{config}"

      super
    end

    def receive_line(data)
      logger.debug "New request: #{data}"
      logger.debug 'Opening connection to rrdcached'

      request = Request.new(data)

      if request.update?
        logger.debug 'UPDATE called'
        handle_update request
      end

      logger.debug 'Pushing to rrdcached'
      rrdcached_socket.puts data

      logger.debug 'Waiting for rrdcached response'
      response_info_line = rrdcached_socket.gets

      response_info = ResponseInfo.new response_info_line

      logger.debug 'Sending response to client'
      send_data response_info_line

      logger.debug "rrdcached response info: #{response_info.to_h}"
      response = Response.new(response_info, rrdcached_socket).read
      send_data response if response
      logger.debug 'Sending response finished'
    end

    def handle_update(request)
      return if request.arguments.first =~ @blacklist
      logger.debug 'Fetching rrd info'
      field_names = RRDFileInfo.field_names(request.arguments.first)

      logger.debug 'Writing to backend'
      backend.write UpdateData.new(request, field_names).points
    end

    def unbind
      logger.debug 'Client disconnected, disconnecting from rrdcached'
      rrdcached_socket.puts 'QUIT'
      rrdcached_socket.close
    end
  end
end
