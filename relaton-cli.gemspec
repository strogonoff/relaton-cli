
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "relaton/cli/version"

Gem::Specification.new do |spec|
  spec.name          = "relaton-cli"
  spec.version       = Relaton::Cli::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = %q{Relaton Command-line Interface}
  spec.description   = %q{Relaton Command-line Interface}
  spec.homepage      = "https://github.com/riboseinc/relaton-cli"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.extra_rdoc_files = %w[README.adoc LICENSE]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug", "~> 10.0"
  spec.add_development_dependency "rspec-command", "~> 1.0.3"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "rspec-core", "~> 3.4"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "relaton", "~> 0.3"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "liquid"
  # spec.add_runtime_dependency 'byebug'
end
