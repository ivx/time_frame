# Encoding: utf-8
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

# active_record setup for active_record handler specs
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3', database: ':memory:'
)

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :vogon_poems, force: true do |t|
    t.datetime :written_at
  end
end
