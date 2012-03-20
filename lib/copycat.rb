require "copycat/engine"

module CopycatImplementation
  # this method overrides part of the i18n gem, lib/i18n/backend/simple.rb
  def lookup(locale, key, scope = [], options = {})
    return super unless ActiveRecord::Base.connected?
    cct = CopycatTranslation.where(locale: locale, key: key).first
    return cct.value if cct
    value = super(locale, key, scope, options)
    if value.is_a?(String) || value.nil?
      CopycatTranslation.create(locale: locale, key: key, value: value)
    end
    value
  end
end

class I18n::Backend::Simple
  include CopycatImplementation
end
