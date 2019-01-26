lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rung/version"

Gem::Specification.new do |spec|
  spec.name          = "rung"
  spec.version       = Rung::VERSION
  spec.authors       = ["Jan Jędrychowski"]
  spec.email         = ["jan@jedrychowski.org"]

  spec.summary       = %q{Business operations DSL}
  spec.description   = %q{Service object/business operation/Railway DSL, inspired by Trailblazer Operation}
  spec.homepage      = "https://github.com/gogiel/rung"
  spec.license       = "MIT"


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|bin)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "cucumber", "~> 3.1"
end
