
# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new :spec

task default: %i[spec rubocop]
