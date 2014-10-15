# Encoding: utf-8
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'byebug'
require 'time_frame'

Time.zone ||= 'UTC'

require 'rspec'
RSpec.configure do |config|
  config.order = 'random'
end
