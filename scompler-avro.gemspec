# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scompler/avro/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.4.0'
  spec.name          = 'scompler-avro'
  spec.version       = Scompler::Avro::VERSION
  spec.authors       = ['Alex Pylko']
  spec.email         = ['alexpylko@gmail.com']
  spec.summary       = 'Write a short summary, because RubyGems requires one.'
  spec.description   = 'Write a longer description or delete this line.'
  spec.homepage      = 'https://github.com/Scompler/scompler-avro'
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'activesupport'
  spec.add_dependency 'avro_turf'
  spec.add_dependency 'aws-sdk-glue'
  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'dry-configurable'
  spec.add_dependency 'snappy'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
