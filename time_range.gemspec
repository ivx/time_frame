# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'time_range/version'

Gem::Specification.new do |spec|
  spec.name          = 'time_range'
  spec.version       = VERSION
  spec.authors       = ['Patrick Derichs', 'Bernhard Stoecker', 'Jan Zernisch']
  spec.email         = ['FT-Plan@injixo.com']
  spec.description   = %q{TimeRange}
  spec.summary       = %q{offers a specified range object for Time, Date or DateTime objects }
  spec.homepage      = 'http://www.invision.de'
  spec.license       = ''

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'powerpack'
end
