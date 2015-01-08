module RRDCachedProxy
  class Request
    attr_reader :raw

    def initialize(raw)
      @raw = raw
    end

    def command
      data[:command]
    end

    def arguments
      return [] unless data[:arguments]
      data[:arguments].split(' ')
    end

    def update?
      command == 'UPDATE'
    end

    private

    def data
      @data ||= raw.match /^(?<command>[A-Z]+)(?: (?<arguments>.+))?/
    end
  end
end
