require 'spec_helper'

require 'rrdcached_proxy/backends/influxdb'
require 'rrdcached_proxy/update_data'

RSpec.describe RRDCachedProxy::Backends::InfluxDB do

  let(:influx_connection_double) { instance_double(::InfluxDB::Client) }
  let(:instance) { RRDCachedProxy::Backends::InfluxDB.new(config) }
  let(:database_name) { Socket.gethostname }
  let(:logger) { Logger.new(StringIO.new) }
  let(:config) { { logger: logger } }

  before do
    allow(::InfluxDB::Client).to receive(:new).and_return(influx_connection_double)
    allow(influx_connection_double).to receive(:get_database_list).and_return([])
    allow(influx_connection_double).to receive(:create_database)
    allow(influx_connection_double).to receive(:write_point)
  end

  it_behaves_like 'a backend'

  describe '#ensure_database' do
    context 'database exists' do
      before do
        allow(influx_connection_double).
          to receive(:get_database_list).and_return([{ 'name' => database_name }])
      end

      it 'does not create the database' do
        expect(influx_connection_double).to_not receive(:create_database)
        instance
      end
    end

    context 'database does not exist' do
      before do
        allow(influx_connection_double).to receive(:get_database_list).and_return([])
      end

      it 'does not create the database' do
        expect(influx_connection_double).to receive(:create_database).with(database_name)
        instance
      end
    end
  end

  describe '#connection' do
    let(:access_config) { { username: 'testi', password: 'supersecure', hosts: %w(example.org) } }
    let(:config) { { logger: logger }.merge(access_config) }

    it 'conntects to the specified database' do
      expect(::InfluxDB::Client).to receive(:new).with(database_name, access_config)
      instance
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
        to receive(:write_point).with('test77', { value: 3, time: 2 }, true, 's')
      instance.write [RRDCachedProxy::UpdateData::Point.new('test77', 3, 2)]
    end
  end
end
