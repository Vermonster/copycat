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

  s.add_dependency 'rails', '>= 3.0.0', '< 4.0'

  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'rspec-rails', '~> 2.14'
  s.add_development_dependency 'factory_girl_rails', '~> 4.4'
  s.add_development_dependency 'capybara', '~> 2.2'
  s.add_development_dependency 'pry', '~> 0.9'
  s.add_development_dependency 'appraisal', '~> 0.5'
end
