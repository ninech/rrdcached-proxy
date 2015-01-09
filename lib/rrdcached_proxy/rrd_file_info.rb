require 'rrd'

module RRDCachedProxy
  class RRDFileInfo
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def field_names
      file = RRD::File.new path
      file.header.datasources.map(&:name)
    end

    def self.field_names(path)
      new(path).field_names
    end
  end
end
