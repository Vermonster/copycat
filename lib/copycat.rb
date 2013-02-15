require "copycat/engine"
require "copycat/implementation"
require "copycat/routes"
require "copycat/simple"

module Copycat
  mattr_accessor :username
  mattr_accessor :password
  mattr_accessor :route
  mattr_accessor :create_nils
  @@route = 'copycat_translations'
  @@create_nils = true

  def self.setup
    yield self
  end
end

