$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "copycat/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "copycat"
  s.version     = Copycat::VERSION
  s.authors     = ["Vermonster"]
  s.email       = ["info@vermonster.com"]
  s.homepage    = "http://www.github.com"
  s.summary     = "Copycat"
  s.description = "Copycat"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.2"

  s.add_development_dependency "sqlite3"
end
