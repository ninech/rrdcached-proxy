require 'spec_helper'

require 'rrdcached_proxy/backends/opentsdb'
require 'rrdcached_proxy/update_data'

RSpec.describe RRDCachedProxy::Backends::OpenTSDB do

  let(:opentsdb_connection_double) { instance_double(::OpenTSDB::Client) }
  let(:instance) { RRDCachedProxy::Backends::OpenTSDB.new(config) }
  let(:logger) { Logger.new(StringIO.new) }
  let(:config) { { logger: logger } }

  before do
    allow(::OpenTSDB::Client).to receive(:new).and_return(opentsdb_connection_double)
    allow(opentsdb_connection_double).to receive(:put)
  end

  it_behaves_like 'a backend'

  describe '#connection' do
    let(:access_config) { { hostname: 'example.org', port: 1234 } }
    let(:config) { { logger: logger }.merge(access_config) }

    it 'connects to the opentsdb server' do
      expect(::OpenTSDB::Client).to receive(:new).with(access_config)
      instance.connection
    end
  end

  describe 'logging' do
    it 'sets the logger of opentsdb' do
      expect(::OpenTSDB).to receive(:logger=).with(logger)
      instance
    end
  end

  describe '#write' do
    it 'writes the points to OpenTSDB' do
      expect(opentsdb_connection_double).
        to receive(:put).with(
          metric: 'nine.network_ports.test77', value: 3, timestamp: 2, tags: { metadata1: 'foobar' }
        )
      instance.write [RRDCachedProxy::UpdateData::Point.new('test77', 3, 2, metadata1: 'foobar')]
    end
  end
end
