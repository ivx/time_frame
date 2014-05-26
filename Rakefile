# Encoding: utf-8
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'

Rubocop::RakeTask.new

RSpec::Core::RakeTask.new :spec

task default: [:spec, :rubocop]
