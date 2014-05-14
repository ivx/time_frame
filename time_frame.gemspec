# coding: utf-8
require 'english'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'time_frame/version'

Gem::Specification.new do |spec|
  spec.name          = 'time_frame'
  spec.version       = TimeFrame::VERSION
  spec.authors       = ['Patrick Derichs', 'Bernhard Stoecker', 'Jan Zernisch']
  spec.email         = [
    'patrick.derichs@invision.de',
    'bernhard.stoecker@invision.de',
    'jan.zernisch@invision.de'
  ]
  spec.description   = %q(TimeFrame)
  spec.summary       = %q(Ruby gem that offers support for time frames)
  spec.homepage      = 'https://github.com/injixo/time_frame'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 4.0'
end
