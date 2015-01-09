require 'spec_helper'

require 'rrdcached_proxy/request'

RSpec.describe RRDCachedProxy::Request do
  let(:instance) { RRDCachedProxy::Request.new input }

  context 'HELP command' do
    let(:input) { 'HELP' }

    describe '#command' do
      subject { instance.command }
      it { is_expected.to eq('HELP') }
    end

    describe '#arguments' do
      subject { instance.arguments }
      it { is_expected.to eq([]) }
    end

    describe '#update?' do
      subject { instance.update? }
      it { is_expected.to eq(false) }
    end
  end

  context 'UPDATE command' do
    let(:input) { 'UPDATE lala.rrd 1420717489:1' }

    describe '#command' do
      subject { instance.command }
      it { is_expected.to eq('UPDATE') }
    end

    describe '#arguments' do
      subject { instance.arguments }
      it { is_expected.to eq(%w(lala.rrd 1420717489:1)) }

      it 'caches the value' do
        expect { instance.arguments.shift }.to change { instance.arguments }
      end
    end

    describe '#update?' do
      subject { instance.update? }
      it { is_expected.to eq(true) }
    end
  end
end
