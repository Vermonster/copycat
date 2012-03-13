$:.push File.expand_path("../lib", __FILE__)

require "copycat/version"

Gem::Specification.new do |s|
  s.name        = "copycat"
  s.version     = Copycat::VERSION
  s.authors     = ["Andrew Ross", "Steve Masterman"]
  s.email       = ["info@vermonster.com"]
  s.homepage    = "https://github.com/Vermonster/copycat"
  s.summary     = "Rails engine for editing live website copy."
  s.description = "Edit live website copy."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 3.0.0"
end
