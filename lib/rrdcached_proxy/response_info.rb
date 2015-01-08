module RRDCachedProxy
  class ResponseInfo
    class InvalidLine < StandardError
      def initialize(line)
        @line = line
      end

      def to_s
        "Invalid line: #{@line}"
      end
    end

    LINE_REGEXP = %r{(?<expected_lines>-?\d+)(?<text>.+)}

    def initialize(line)
      @line = line
    end

    def expected_lines
      data[:expected_lines].to_i
    end

    def text
      data[:text].strip
    end

    def data
      return @data if @data
      raise InvalidLine, @line unless @line =~ LINE_REGEXP
      @data = @line.match(/(?<expected_lines>-?\d+)(?<text>.+)/)
    end

    def to_s
      @line
    end

    def to_h
      { expected_lines: expected_lines, text: text }
    end
  end
end
