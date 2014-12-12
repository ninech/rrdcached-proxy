#!/usr/bin/env ruby

require 'socket'
require 'logger'

rrdcached_socket = UNIXSocket.new('/var/run/rrdcached.sock')
server = UNIXServer.new('/tmp/test.sock')

logger = Logger.new(STDOUT)

loop do
  logger.debug "waiting for client"
  client = server.accept
  logger.debug "  new client"

  begin
    loop do
      logger.debug "    waiting for request"
      request = client.gets

      logger.debug "      new request"
      rrdcached_socket.puts request

      if request =~ /^UPDATE /
        logger.debug "      UPDATE called, add backend call here!"
      end

      logger.debug '      waiting for response'

      response = rrdcached_socket.gets

      # Service first line will be something like:
      # 10 Command overview
      # -1 Usage: UPDATE <filename> <values> [<values> ...]
      data = response.match(/(-?\d+)(.+)/)
      expected_lines = data[0].to_i
      text = data[1]

      client.puts response

      logger.debug "      expected_lines: #{expected_lines}"
      if expected_lines >= 0
        expected_lines.times do
          response = rrdcached_socket.gets
          client.puts response
        end
      else
        logger.debug text
      end
      logger.debug '      got response'
    end
  rescue Errno::EPIPE
    logger.debug '  client disconnect'
  end
end
