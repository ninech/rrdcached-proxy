require 'spec_helper'

require 'rrdcached_proxy/daemon'

RSpec.describe RRDCachedProxy::Daemon do
  let(:config) do
    {
      rrdcached_socket: '/tmp/rrdcached.sock',
      listen_socket: '/tmp/listen.sock',
      log: { destination: :stdout, level: :debug }
    }
  end
  let(:instance) { RRDCachedProxy::Daemon.new(config) }
  let(:file_stat_double) { instance_double(File::Stat) }

  before do
    allow(file_stat_double).to receive(:uid).and_return(1000)
    allow(file_stat_double).to receive(:gid).and_return(1000)
    allow(file_stat_double).to receive(:mode).and_return(0644)
    allow(File::Stat).to receive(:new).with('/tmp/rrdcached.sock').and_return(file_stat_double)
    allow(File).to receive(:chmod)
    allow(File).to receive(:chown)
  end

  describe '#run' do
    before do
      allow(EventMachine).to receive(:run).and_yield
      allow(EventMachine).to receive(:start_unix_domain_server)
      allow(RRDCachedProxy::Backends::InfluxDB).to receive(:new).and_return('influxdb-backend')
    end

    it 'starts a new eventmachine server on a socket' do
      expect(EventMachine).to receive(:run).and_yield
      expect(EventMachine).to receive(:start_unix_domain_server)
      instance.run
    end

    context 'no backend specified' do
      it 'provides the socket, the service, the logger and the backend' do
        expect(EventMachine).to receive(:start_unix_domain_server).with(
          instance_of(String),
          RRDCachedProxy::RRDToolConnection,
          instance_of(Logger),
          instance_of(RRDCachedProxy::Backends::Base))

        instance.run
      end
    end

    context 'influxdb backend specified' do
      before do
        config[:backend] = 'influxdb'
        config[:influxdb] = {}
      end

      it 'provides the socket, the service, the logger and the backend' do
        expect(EventMachine).to receive(:start_unix_domain_server).with(
          instance_of(String),
          RRDCachedProxy::RRDToolConnection,
          instance_of(Logger),
          'influxdb-backend')

        instance.run
      end
    end
  end

  describe '#logger' do
    context 'syslog' do
      before do
        config[:log][:destination] = 'syslog'
      end
      specify { expect(instance.logger).to be_instance_of(Syslogger) }
    end

    context 'stdout' do
      before do
        config[:log][:destination] = 'stdout'
      end
      specify { expect(instance.logger).to be_instance_of(Logger) }
    end

    context 'unknown' do
      before do
        config[:log][:destination] = 'swag'
      end
      specify { expect(instance.logger).to be_instance_of(Logger) }
    end
  end

  describe '#set_log_level' do
    context 'invalid log level' do
      before do
        config[:log][:level] = 'swag'
      end
      specify { expect(instance.logger.level).to eq(Logger::INFO) }
    end

    context 'valid log level' do
      before do
        config[:log][:level] = 'fatal'
      end
      specify { expect(instance.logger.level).to eq(Logger::FATAL) }
    end
  end

  describe '#set_socket_permissions' do
    let(:file_stat_double) { instance_double(File::Stat) }

    it 'reads the permssions from the rrdcached socket' do
      expect(File::Stat).to receive(:new).with('/tmp/rrdcached.sock').and_return(file_stat_double)
      instance.set_socket_permissions
    end

    it 'sets the same permissions as rrdcached socket has' do
      allow(file_stat_double).to receive(:uid).and_return(1337)
      allow(file_stat_double).to receive(:gid).and_return(1337)
      allow(file_stat_double).to receive(:mode).and_return(0140755)
      expect(File).to receive(:chown).with(1337, 1337, '/tmp/listen.sock')
      expect(File).to receive(:chmod).with(0140755, '/tmp/listen.sock')
      instance.set_socket_permissions
    end
  end
end
