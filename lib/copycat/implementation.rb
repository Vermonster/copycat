module Copycat
  module Implementation
    # this method overrides part of the i18n gem, lib/i18n/backend/simple.rb
    def lookup(locale, key, scope = [], options = {})
      return super unless ActiveRecord::Base.connected? && CopycatTranslation.table_exists?
      cct = CopycatTranslation.where(locale: locale.to_s, key: key.to_s).first
      return cct.value if cct
      value = super(locale, key, scope, options)
      if value.is_a?(String) || value.nil? && Copycat.create_nils
        CopycatTranslation.create(locale: locale.to_s, key: key.to_s, value: value)
      end
      value
    end
  end
end
