$:.push File.expand_path("../lib", __FILE__)

require "workarea/taxjar/version"

Gem::Specification.new do |s|
  s.name        = "workarea-taxjar"
  s.version     = Workarea::Taxjar::VERSION
  s.authors     = ["Matt Smith"]
  s.email       = ["msmith@workarea.com"]
  s.summary     = "Taxjar Tax Plugin for the Workarea Ecommerce Platform"
  s.description = "Taxjar is a service for sales tax calculation and compliance"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.required_ruby_version = ">= 2.2.2"

  s.add_dependency "workarea", "~> 3.x", ">= 3.1.0"
  s.add_dependency "workarea-circuit_breaker"
  s.add_dependency "taxjar-ruby"
  s.add_development_dependency 'pry'
end
