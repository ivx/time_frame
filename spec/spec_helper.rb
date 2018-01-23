
# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'time_frame'

Time.zone ||= 'UTC'

require 'rspec'
RSpec.configure do |config|
  config.order = 'random'
end

require 'byebug'
