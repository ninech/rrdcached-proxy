require 'spec_helper'

require 'rrdcached_proxy/daemon'

RSpec.describe RRDCachedProxy::Daemon do
  describe '.run' do
    before do
      allow(EventMachine).to receive(:run).and_yield
      allow(EventMachine).to receive(:start_unix_domain_server)
      allow(RRDCachedProxy::Backends::InfluxDB).to receive(:new).and_return('influxdb-backend')
    end

    it 'starts a new eventmachine server on a socket' do
      expect(EventMachine).to receive(:run).and_yield
      expect(EventMachine).to receive(:start_unix_domain_server)
      RRDCachedProxy::Daemon.run
    end

    it 'provides the socket, the service, the logger and the backend' do
      expect(EventMachine).to receive(:start_unix_domain_server).with(
        instance_of(String),
        RRDCachedProxy::RRDToolConnection,
        instance_of(Logger),
        'influxdb-backend')

      RRDCachedProxy::Daemon.run
    end
  end
end
