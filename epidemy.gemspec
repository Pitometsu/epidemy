# epidemy.gemspec

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epidemy/version'

Gem::Specification.new do |spec|
  spec.name          = "epidemy"
  spec.version       = Epidemy::VERSION
  spec.authors       = ["Pitometsu"]
  spec.email         = ["pitometsu@gmail.com"]
  spec.description   = "Strategy game for 2-4 players"
  spec.summary       = "Casual game"
  spec.homepage      = "http://github.com/Pitometsu/epidemy"
  spec.license       = "GNU v3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "byebug"
end
