require 'spec_helper'

require 'rrdcached_proxy/response_info'

RSpec.describe RRDCachedProxy::ResponseInfo do
  let(:instance) { RRDCachedProxy::ResponseInfo.new(line) }

  context 'line is invalid' do
    let(:line) { 'invalid!' }

    describe '#expected_lines' do
      specify { expect { instance.expected_lines }.to raise_error(RRDCachedProxy::ResponseInfo::InvalidLine) }
    end

    describe '#text' do
      specify { expect { instance.text }.to raise_error(RRDCachedProxy::ResponseInfo::InvalidLine) }
    end

    describe '#data' do
      specify { expect { instance.data }.to raise_error(RRDCachedProxy::ResponseInfo::InvalidLine) }
    end

    describe '#to_s' do
      specify { expect(instance.to_s).to eq(line) }
    end

    describe '#to_h' do
      specify { expect { instance.to_h }.to raise_error(RRDCachedProxy::ResponseInfo::InvalidLine) }
    end
  end

  context '10 Command overview' do
    let(:line) { '10 Command overview' }

    describe '#expected_lines' do
      specify { expect(instance.expected_lines).to eq(10) }
    end

    describe '#text' do
      specify { expect(instance.text).to eq('Command overview') }
    end

    describe '#data' do
      specify { expect(instance.data).to be_a(MatchData) }
    end

    describe '#to_s' do
      specify { expect(instance.to_s).to eq(line) }
    end

    describe '#to_h' do
      specify { expect(instance.to_h).to eq(expected_lines: 10, text: 'Command overview') }
    end
  end

  context '-1 Unknown command: blubb' do
    let(:line) { '-1 Unknown command: blubb' }

    describe '#expected_lines' do
      specify { expect(instance.expected_lines).to eq(-1) }
    end

    describe '#text' do
      specify { expect(instance.text).to eq('Unknown command: blubb') }
    end

    describe '#data' do
      specify { expect(instance.data).to be_a(MatchData) }
    end

    describe '#to_s' do
      specify { expect(instance.to_s).to eq(line) }
    end

    describe '#to_h' do
      specify { expect(instance.to_h).to eq(expected_lines: -1, text: 'Unknown command: blubb') }
    end
  end
end
