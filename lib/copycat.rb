require "copycat/engine"
require "copycat/implementation"
require "copycat/simple"

module Copycat
  mattr_accessor :username
  mattr_accessor :password

  def self.setup
    yield self
  end
end

