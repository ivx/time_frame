require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Rubocop::RakeTask.new

RSpec::Core::RakeTask.new :spec

task default: [:spec, :rubocop]

module Bundler
  class GemHelper
    def install
      desc "Build #{name}-#{version}.gem into the pkg directory."
      task 'build' do
        build_gem
      end

      desc "Build and install #{name}-#{version}.gem into system gems."
      task 'install' do
        install_gem
      end

      desc "Create tag #{version_tag} and build and push \
            #{name}-#{version}.gem to gems.injixo.com"
      task 'release' do
        release_gem
      end
      GemHelper.instance = self
    end

    def release_gem
      guard_clean
      built_gem_path = build_gem
      tag_version { git_push } # unless already_tagged?
      sh("gem inabox '#{built_gem_path}' -g https://rubygems.org")
      Bundler.ui.confirm "Pushed #{name} #{version} to rubygems.org"
    end
  end
end

Bundler::GemHelper.install_tasks
