require 'spec_helper'

require 'rrdcached_proxy/update_data'
require 'rrdcached_proxy/request'

RSpec.describe RRDCachedProxy::UpdateData do
  let(:arguments) { %w(1420721875:1) }
  let(:field_names) { %w(ifOutOctets) }

  let(:request) { instance_double(RRDCachedProxy::Request) }
  let(:instance) { RRDCachedProxy::UpdateData.new(request, field_names) }
  let(:rrd_path) { '/var/pnp4nagios/perfdata/infralg/ntp_upstream.rrd' }

  before do
    allow(Time).to receive(:now).and_return(1337)

    allow(request).to receive(:command).and_return('UPDATE')
    allow(request).to receive(:arguments).and_return([rrd_path].concat(arguments))
  end

  describe '#points' do
    subject { instance.points }
    context 'single value' do
      let(:arguments) { %w(1420721875:1) }

      specify { expect(subject.length).to eq(1) }
      specify { expect(subject.first.name).to eq('ifOutOctets') }
      specify { expect(subject.first.value).to eq(1) }
      specify { expect(subject.first.timestamp).to eq(1420721875) }
    end

    context 'float value' do
      let(:arguments) { %w(1420721875:0.1) }

      specify { expect(subject.length).to eq(1) }
      specify { expect(subject.first.name).to eq('ifOutOctets') }
      specify { expect(subject.first.value).to eq(0.1) }
      specify { expect(subject.first.timestamp).to eq(1420721875) }
    end

    context 'N timestamp' do
      let(:arguments) { %w(N:1) }

      specify { expect(subject.length).to eq(1) }
      specify { expect(subject.first.name).to eq('ifOutOctets') }
      specify { expect(subject.first.value).to eq(1) }
      specify { expect(subject.first.timestamp).to eq(1337) }
    end

    context 'multiple values' do
      let(:arguments) { %w(1420721875:1:2) }
      let(:field_names) { %w(ifOutOctets ifInOctets) }

      specify { expect(subject.length).to eq(2) }

      specify { expect(subject.first.name).to eq('ifOutOctets') }
      specify { expect(subject.first.value).to eq(1) }
      specify { expect(subject.first.timestamp).to eq(1420721875) }

      specify { expect(subject.last.name).to eq('ifInOctets') }
      specify { expect(subject.last.value).to eq(2) }
      specify { expect(subject.last.timestamp).to eq(1420721875) }
    end

    context 'multiple timestamps' do
      let(:arguments) { %w(1420721875:1 1420723879:2) }

      specify { expect(subject.length).to eq(2) }

      specify { expect(subject.first.name).to eq('ifOutOctets') }
      specify { expect(subject.first.value).to eq(1) }
      specify { expect(subject.first.timestamp).to eq(1420721875) }

      specify { expect(subject.last.name).to eq('ifOutOctets') }
      specify { expect(subject.last.value).to eq(2) }
      specify { expect(subject.last.timestamp).to eq(1420723879) }
    end

    context 'N timestamp' do
      let(:arguments) { %w(N:1) }

      specify { expect(subject.length).to eq(1) }

      specify { expect(subject.first.name).to eq('ifOutOctets') }
      specify { expect(subject.first.value).to eq(1) }
      specify { expect(subject.first.timestamp).to eq(Time.now.to_i) }
    end

    context 'at-style timestamp' do
      let(:arguments) { %w(-1month:1) }

      specify { expect { subject }.to raise_error }
    end

    context 'unequal values and field names' do
      let(:arguments) { %w(1420721875:1:2) }

      specify { expect(subject.length).to eq(1) }

      specify { expect(subject.first.name).to eq('ifOutOctets') }
      specify { expect(subject.first.value).to eq(1) }
      specify { expect(subject.first.timestamp).to eq(1420721875) }
    end
  end

  describe '#metadata' do
    let(:instance) { RRDCachedProxy::UpdateData.new(request, field_names, regexp) }

    context 'when it finds matches' do
      let(:regexp) { /(?<hostname>[^\/]+)\/(?<metric>[^\/]+).rrd/ }

      it 'turns an rrd_path and a regexp into a hash' do
        expect(instance.metadata).to eq('hostname' => 'infralg', 'metric' => 'ntp_upstream')
      end
    end

    context 'when it does not find matches' do
      let(:regexp) { // }

      it 'returns an empty hash' do
        expect(instance.metadata).to eq({})
      end
    end
  end
end
