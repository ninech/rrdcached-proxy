module RRDCachedProxy
  class UpdateData
    class InvalidTimestamp < StandardError; end

    Point = Struct.new(:name, :value, :timestamp, :metadata)

    attr_reader :rrd_path, :timestamped_values, :field_names, :metadata_regexp

    def initialize(request, field_names, metadata_regexp = //)
      @rrd_path = request.arguments.shift
      @timestamped_values = request.arguments
      @field_names = field_names
      @metadata_regexp = metadata_regexp
    end

    def points
      @points = []

      timestamped_values.each do |timestamped_value|
        timestamp, field_values = extract_timestamp_and_field_values timestamped_value

        field_values.each_with_index do |value, index|
          @points << Point.new(field_names[index], value.to_f, timestamp, metadata)
        end
      end

      @points
    end

    def metadata
      match = rrd_path.match metadata_regexp
      Hash[ match.names.zip(match.captures) ]
    end

    private

    def extract_timestamp_and_field_values(value)
      value_as_array = value.split(':')
      timestamp = sanitize_timestamp value_as_array.shift
      field_values = value_as_array.shift(field_names.length)

      [timestamp, field_values]
    end

    def sanitize_timestamp(timestamp)
      raise InvalidTimestamp, timestamp unless timestamp =~ /\A(N|\d+)\z/
      timestamp == 'N' ? Time.now.to_i : timestamp.to_i
    end
  end
end
