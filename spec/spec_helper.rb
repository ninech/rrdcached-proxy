require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

APP_ROOT = File.join(File.dirname(Pathname.new(__FILE__).realpath), '..')

Dir[File.join(APP_ROOT, 'spec/support/**/*.rb')].each { |f| require f }

require 'influxdb'
require 'opentsdb'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    allow(InfluxDB::Client).to receive(:new).and_raise('This should be mocked')
    allow(OpenTSDB::Client).to receive(:new).and_raise('This should be mocked')
  end
end
