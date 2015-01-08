module RRDCachedProxy
  class Response
    def initialize(info, socket)
      @info = info
      @socket = socket
    end

    def read
      return nil unless @info.expected_lines >= 0
      response = nil

      @info.expected_lines.times do
        response ||= ''
        response += @socket.gets
      end
      response
    end
  end
end
