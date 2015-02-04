require 'spec_helper'
require 'em-spec/rspec'

require 'logger'
require 'rrdcached_proxy/rrdtool_connection'
require 'rrdcached_proxy/backends/base'

RSpec.describe RRDCachedProxy::RRDToolConnection do
  class TestConnection < RRDCachedProxy::RRDToolConnection
    attr_accessor :sent_data

    def send_data(data)
      self.sent_data += data
    end

    def sent_data
      @sent_data ||= ''
    end
  end

  let(:log_output) { StringIO.new }
  let(:logger) { Logger.new(log_output) }
  let(:rrdcached_socket) { StringIO.new }
  let(:em_signature) { 1337 }
  let(:backend) { double(RRDCachedProxy::Backends::Base) }
  let(:socket) { '/var/run/rrdcached.sock' }
  let(:blacklist) { nil }
  let(:metadata_regexp) { // }

  let(:instance) do
    TestConnection.new(em_signature, logger: logger,
                                     backend: backend,
                                     rrdcached_socket: socket,
                                     blacklist: blacklist,
                                     metadata_regexp: metadata_regexp)
  end

  before do
    allow(UNIXSocket).to receive(:new).with(instance_of(String)).and_return(rrdcached_socket)
    allow(backend).to receive(:write)
  end

  describe '#receive_line' do
    context 'HELP' do
      let(:data) { 'HELP' }

      before do
        allow(rrdcached_socket).to receive(:puts).with(data)

        allow(rrdcached_socket).to receive(:gets).
          and_return("10 Command overview\n",
                     "UPDATE <filename> <values> [<values> ...]\n",
                     "FLUSH <filename>\n",
                     "FLUSHALL\n",
                     "PENDING <filename>\n",
                     "FORGET <filename>\n",
                     "QUEUE\n",
                     "STATS\n",
                     "HELP [<command>]\n",
                     "BATCH\n",
                     "QUIT\n")
      end

      it 'pushes the received data to the client' do
        instance.receive_line(data)

        expect(instance.sent_data).to eq(
          <<-OUTPUT.gsub(/^\s+/, '')
          10 Command overview
          UPDATE <filename> <values> [<values> ...]
          FLUSH <filename>
          FLUSHALL
          PENDING <filename>
          FORGET <filename>
          QUEUE
          STATS
          HELP [<command>]
          BATCH
          QUIT
          OUTPUT
        )
      end
    end

    context 'UPDATE' do
      let(:data) { 'UPDATE lala.rrd 1420717489:1' }

      before do
        allow(rrdcached_socket).to receive(:gets).and_return("0 errors, enqueued 1 value(s).\n")
        allow(RRDCachedProxy::RRDFileInfo).to receive(:field_names).and_return(%w(name1))
      end

      it 'calls the backend to push the data as well' do
        expect(backend).to receive(:write).with(instance_of(Array))
        instance.receive_line(data)
      end

      it 'fetches the field names' do
        expect(RRDCachedProxy::RRDFileInfo).to receive(:field_names).with('lala.rrd').and_return(%w(name1))
        instance.receive_line(data)
      end

      context 'blacklisted rrd' do
        let(:blacklist) { Regexp.new('lala.+') }

        it 'does not call the backend' do
          expect(backend).to_not receive(:write)
          instance.receive_line data
        end
      end
    end
  end
end
