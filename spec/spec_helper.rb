
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'time_period'
require 'active_support/core_ext'
Time.zone ||= 'UTC'

require 'rspec'

require 'factory_girl'

RSpec.configure do |config|
  config.order = 'random'
  config.include FactoryGirl::Syntax::Methods
end
