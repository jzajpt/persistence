# encoding: utf-8

require 'persistence'

spec_root = File.dirname(__FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(spec_root, "/support/**/*.rb")].each {|f| require f}

Persistence.init_persistence(host: 'localhost',
                             database: 'persistence_test',
                             collection: 'persistence_test')

RSpec.configure do |config|
  config.before(:each) do
  end

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
end

