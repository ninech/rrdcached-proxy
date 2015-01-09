require 'spec_helper'

require 'rrdcached_proxy/cli'

RSpec.describe RRDCachedProxy::CLI do
  let(:daemon_double) { instance_double(RRDCachedProxy::Daemon) }
  let(:instance) { RRDCachedProxy::CLI.new(arguments) }

  let(:arguments) { [] }

  before do
    allow(daemon_double).to receive(:run)
    allow(RRDCachedProxy::Daemon).to receive(:new).and_return(daemon_double)
  end

  describe '.run' do
    specify { expect { RRDCachedProxy::CLI.run(arguments) }.to_not raise_error }
  end

  describe '#run' do
    context 'config via file' do
      before do
        allow(File).to receive(:exists?).with('/tmp/config.yml').and_return(config_file_exists)
        allow(YAML).to receive(:load_file).and_return('listen_socket' => '/tmp/other.sock')
      end

      let(:arguments) { %w(-c /tmp/config.yml) }

      context 'config file exists' do
        let(:config_file_exists) { true }

        it 'loads the config from the config file' do
          expect(YAML).to receive(:load_file).and_return('listen_socket' => '/tmp/other.sock')
          expect { instance.run }.to change { instance.config[:listen_socket] }
        end

        context 'and config on cli specified' do
          let(:arguments) { %w(-c /tmp/config.yml --listen-socket /tmp/cli.sock) }

          it 'overrides the config values with the cli values' do
            expect { instance.run }.to change { instance.config[:listen_socket] }.to('/tmp/cli.sock')
          end
        end
      end

      context 'config file does not exist' do
        let(:config_file_exists) { false }

        specify { expect { instance.run }.to_not raise_error }
      end
    end

    context 'config via cli' do
      let(:arguments) { %w(--listen-socket /tmp/other.sock) }

      it 'sets the config from the cli' do
        expect { instance.run }.to change { instance.config[:listen_socket] }
      end
    end
  end
end
