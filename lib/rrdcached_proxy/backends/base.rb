module RRDCachedProxy
  module Backends
    class Base
      attr_reader :logger

      def initialize(config)
        @config = config
        @logger = config[:logger]
      end

      def write(points)
      end
    end
  end
end
