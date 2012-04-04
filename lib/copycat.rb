require "copycat/engine"
require "copycat/implementation"
require "copycat/routes"
require "copycat/simple"

module Copycat
  mattr_accessor :username
  mattr_accessor :password
  mattr_accessor :route
  @@route = 'copycat_translations'

  def self.setup
    yield self
  end
end

