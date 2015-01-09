require 'optparse'
require 'socket'
require 'yaml'
require 'hashie'

require 'rrdcached_proxy/daemon'

module RRDCachedProxy
  class CLI
    DEFAULT_CONFIG_FILE_PATH = '/etc/rrdcached_proxy.yml'
    DEFAULT_LISTEN_SOCKET = '/var/run/rrdcached-proxy.sock'
    DEFAULT_RRDCACHED_SOCKET = '/var/run/rrdcached.sock'

    DEFAULT_LOG_DESTINATION = :syslog
    DEFAULT_LOG_LEVEL = :info

    DEFAULT_INFLUXDB_DATABASE = Socket.gethostname.split('.').first

    DEFAULT_OPTIONS = {
      config_file: DEFAULT_CONFIG_FILE_PATH,
      config: {
        listen_socket: DEFAULT_LISTEN_SOCKET,
        rrdcached_socket: DEFAULT_RRDCACHED_SOCKET,
        influxdb: {
          database: DEFAULT_INFLUXDB_DATABASE,
        },
        log: {
          destination: DEFAULT_LOG_DESTINATION,
          level: DEFAULT_LOG_LEVEL,
        },
      }
    }

    attr_reader :arguments, :config

    def initialize(arguments)
      @arguments = arguments
      @config = Hashie::Hash.new
      @config.merge DEFAULT_OPTIONS[:config]
    end

    def run
      options = DEFAULT_OPTIONS

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options]"

        opts.separator ''
        opts.separator 'Options:'

        opts.on('--listen-socket=PATH', "Socket to listen on (default: #{DEFAULT_LISTEN_SOCKET})") do |path|
          options[:config][:listen_socket] = path
        end

        opts.on('--rrdcached-socket=PATH', "Path to rrdcached socket (default: #{DEFAULT_RRDCACHED_SOCKET})") do |path|
          options[:config][:rrdcached_socket] = path
        end

        opts.on('--backend=BACKEND', 'Backend to use') do |backend|
          options[:config][:backend] = backend
        end

        opts.on('-c', '--config-file=PATH', "Path to config file (default: #{DEFAULT_CONFIG_FILE_PATH})") do |path|
          options[:config_file] = path
        end

        opts.on('--log-destination=DEST', "Where to put logs, one of syslog or stdout (default: #{DEFAULT_LOG_DESTINATION})") do |log_destination|
          options[:config][:log][:destination] = log_destination
        end

        opts.on('--log-level=LEVEL', "Loglevel, one of debug, info, warn, error and fatal (default: #{DEFAULT_LOG_LEVEL})") do |log_level|
          options[:config][:log][:level] = log_level
        end

        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit 0
        end

        opts.separator ''
        opts.separator 'InfluxDB Backend:'

        opts.on('--influxdb-database=DATABASE', "Database (default: #{DEFAULT_INFLUXDB_DATABASE})") do |database|
          options[:config][:influxdb][:database] = database
        end

        opts.on('--influxdb-username=USERNAME', 'Username to connect to backend') do |username|
          options[:config][:influxdb][:username] = username
        end

        opts.on('--influxdb-password=PASSWORD', 'Password to connect to backend') do |password|
          options[:config][:influxdb][:password] = password
        end

        opts.on('--influxdb-hosts=HOST,HOST', 'Backend hosts') do |hosts|
          options[:config][:influxdb][:hosts] = hosts.split(',')
        end
      end

      opt_parser.parse!(arguments)

      @config = load_yaml(options[:config_file]).merge(options[:config])

      Daemon.new(config).run
    end

    def self.run(arguments)
      new(arguments).run
    end

    private

    def load_yaml(path)
      if path && File.exists?(path)
        YAML.load_file path
      else
        {}
      end
    end
  end
end
