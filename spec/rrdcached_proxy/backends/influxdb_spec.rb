require 'spec_helper'

require 'rrdcached_proxy/backends/influxdb'
require 'rrdcached_proxy/update_data'

RSpec.describe RRDCachedProxy::Backends::InfluxDB do

  let(:influx_connection_double) { instance_double(::InfluxDB::Client) }
  let(:instance) { RRDCachedProxy::Backends::InfluxDB.new(config) }
  let(:database_name) { 'db1' }
  let(:logger) { Logger.new(StringIO.new) }
  let(:config) { { database: database_name, logger: logger } }

  before do
    allow(::InfluxDB::Client).to receive(:new).and_return(influx_connection_double)
    allow(influx_connection_double).to receive(:get_database_list).and_return([])
    allow(influx_connection_double).to receive(:create_database)
    allow(influx_connection_double).to receive(:write_point)
  end

  it_behaves_like 'a backend'

  describe '#connection' do
    let(:access_config) { { username: 'testi', password: 'supersecure', hosts: %w(example.org) } }
    let(:config) { { database: database_name, logger: logger }.merge(access_config) }

    it 'connects to the specified database' do
      expect(::InfluxDB::Client).to receive(:new).with(database_name, access_config)
      instance.connection
    end
  end

  describe 'influx logging' do
    it 'sets the logger of influx' do
      expect(::InfluxDB::Logging).to receive(:logger=).with(logger)
      instance
    end
  end

  describe '#write' do
    it 'writes the points to InfluxDB' do
      expect(influx_connection_double).
        to receive(:write_point).with('test77', { value: 3, time: 2, metadata1: 'foobar' }, true, 's')
      instance.write [RRDCachedProxy::UpdateData::Point.new('test77', 3, 2, metadata1: 'foobar')]
    end
  end
end
