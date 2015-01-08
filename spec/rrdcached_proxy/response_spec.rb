require 'spec_helper'

require 'rrdcached_proxy/response_info'
require 'rrdcached_proxy/response'

RSpec.describe RRDCachedProxy::Response do
  let(:info) { instance_double(RRDCachedProxy::ResponseInfo) }
  let(:socket) { StringIO.new }

  let(:instance) { RRDCachedProxy::Response.new info, socket }

  before do
    allow(info).to receive(:expected_lines).and_return(expected_lines)
  end

  describe '#read' do
    subject { instance.read }

    context '-1 lines to read' do
      let(:expected_lines) { -1 }

      it { is_expected.to be_nil }

      it 'does not read from the socket' do
        expect(socket).to_not receive(:gets)
        subject
      end
    end

    context '0 lines to read' do
      let(:expected_lines) { 0 }

      it { is_expected.to be_nil }

      it 'does not read from the socket' do
        expect(socket).to_not receive(:gets)
        subject
      end
    end

    context '1 line to read' do
      let(:expected_lines) { 1 }

      before do
        socket.puts 'line'
        socket.rewind
      end

      it { is_expected.to eq("line\n") }
    end

    context '10 lines to read' do
      let(:expected_lines) { 10 }

      before do
        10.times do
          socket.puts 'line'
        end
        socket.rewind
      end

      it { is_expected.to eq("line\n" * 10) }
    end
  end
end
