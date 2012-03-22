module Copycat
  class Engine < ::Rails::Engine
    # Enabling assets precompiling under rails 3.1
    if Rails.version >= '3.1'
      initializer :assets do |config|
        Rails.application.config.assets.precompile += %w( copycat_engine.css )
      end
    end
  end
end
