# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aclize/version'

Gem::Specification.new do |spec|
  spec.name          = "aclize"
  spec.version       = Aclize::VERSION
  spec.authors       = ["Groza Sergiu"]
  spec.email         = ["serioja90@gmail.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  end

  spec.summary       = %q{ACL for your Rails application}
  spec.description   = %q{This gem allows you to define an ACL (Access Control List) for your Ruby on Rails application. It is simple to use and allows you to define access permissions for controllers, actions an paths.}
  spec.homepage      = "https://github.com/serioja90/aclize"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", ">= 12.0", "< 14"
  spec.add_runtime_dependency "actionpack", ">= 5.0", "< 7"
  spec.add_runtime_dependency "i18n", "~> 1.0"
end
