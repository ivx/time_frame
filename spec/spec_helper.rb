require 'time_frame'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

Time.zone ||= 'UTC'

require 'rspec'
RSpec.configure do |config|
  config.order = 'random'
end
