module RRDCachedProxy
  class Request
    attr_reader :raw

    def initialize(raw)
      @raw = raw
    end

    def command
      data[:command].upcase
    end

    def arguments
      return @arguments if @arguments
      return [] unless data[:arguments]
      @arguments = data[:arguments].split(' ')
    end

    def update?
      command == 'UPDATE'
    end

    private

    def data
      @data ||= raw.match /^(?<command>[A-Za-z]+)(?: (?<arguments>.+))?/
    end
  end
end
