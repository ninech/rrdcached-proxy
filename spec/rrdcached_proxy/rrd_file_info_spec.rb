require 'spec_helper'

require 'rrdcached_proxy/rrd_file_info'

RSpec.describe RRDCachedProxy::RRDFileInfo do
  let(:rrd_file_double) { instance_double(RRD::File) }
  let(:rrd_header_double) { instance_double(RRD::Header) }
  let(:rrd_datasource_double) { instance_double(RRD::DataSource) }
  let(:field_name) { 'name1' }
  let(:path) { '/tmp/test.rrd' }

  before do
    allow(RRD::File).to receive(:new).and_return(rrd_file_double)
    allow(rrd_file_double).to receive(:header).and_return(rrd_header_double)
    allow(rrd_header_double).to receive(:datasources).and_return([rrd_datasource_double])
    allow(rrd_datasource_double).to receive(:name).and_return(field_name)
  end

  describe '.field_names' do
    specify { expect { RRDCachedProxy::RRDFileInfo.field_names(path) }.to_not raise_error }
  end

  describe '#field_names' do
    specify { expect(RRDCachedProxy::RRDFileInfo.new(path).field_names).to eq(%w(name1)) }
  end
end
