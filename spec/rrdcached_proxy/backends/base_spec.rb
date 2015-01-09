require 'spec_helper'

require 'rrdcached_proxy/backends/base'
require 'rrdcached_proxy/update_data'

RSpec.describe RRDCachedProxy::Backends::Base do
  let(:config) { {} }
  it_behaves_like 'a backend'
end
