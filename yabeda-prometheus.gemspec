# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yabeda/prometheus/version"

Gem::Specification.new do |spec|
  spec.name          = "yabeda-prometheus"
  spec.version       = Yabeda::Prometheus::VERSION
  spec.authors       = ["Andrey Novikov"]
  spec.email         = ["envek@envek.name"]

  spec.summary       = "Extensible Prometheus exporter for your application"
  spec.homepage      = "https://github.com/yabeda-rb/yabeda-prometheus"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yabeda-rb/yabeda-prometheus"
  spec.metadata["changelog_uri"] = "https://github.com/yabeda-rb/yabeda-prometheus/blob/master/CHANGELOG.md"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3"

  spec.add_dependency "prometheus-client", ">= 3.0", "< 5.0"
  spec.add_dependency "yabeda", "~> 0.10"
  spec.add_dependency "rack"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
